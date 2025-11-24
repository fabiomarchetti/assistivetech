import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/attivita.dart';
import 'local_db.dart';

/// Adapter per gestire database multi-piattaforma
/// Usa Hive per web e SQLite per mobile
class DatabaseAdapter {
  static DatabaseAdapter? _instance;
  static DatabaseAdapter get instance {
    _instance ??= DatabaseAdapter._();
    return _instance!;
  }

  DatabaseAdapter._();

  LocalDatabase? _sqliteDb;
  Box<Map>? _hiveUsersBox;
  Box<Map>? _hiveAgendasBox;
  Box<Map>? _hiveActivitiesBox;

  bool _initialized = false;

  /// Inizializza il database appropriato per la piattaforma
  Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      // Web: usa Hive
      await Hive.initFlutter();
      _hiveUsersBox = await Hive.openBox<Map>('users');
      _hiveAgendasBox = await Hive.openBox<Map>('agendas');
      _hiveActivitiesBox = await Hive.openBox<Map>('activities');
      print('🌐 Database Hive inizializzato per WEB');
    } else {
      // Mobile: usa SQLite
      _sqliteDb = LocalDatabase();
      print('📱 Database SQLite inizializzato per MOBILE');
    }

    _initialized = true;
  }

  // --- GESTIONE UTENTI ---

  Future<List<String>> fetchUserNames() async {
    await initialize();

    if (kIsWeb) {
      final users = _hiveUsersBox!.values
          .where((u) => u['is_deleted'] == false)
          .map((u) => u['nome'] as String)
          .toList();
      users.sort();
      return users;
    } else {
      return await _sqliteDb!.fetchUserNames();
    }
  }

  Future<void> insertUser(String nome) async {
    await initialize();

    if (kIsWeb) {
      // Verifica se esiste già
      final existing = _hiveUsersBox!.values.any(
        (u) => u['nome'] == nome && u['is_deleted'] == false,
      );
      if (existing) {
        throw Exception('Utente già esistente');
      }

      await _hiveUsersBox!.add({
        'nome': nome,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
      });
      print('✅ Utente "$nome" creato con Hive');
    } else {
      await _sqliteDb!.insertUser(nome);
    }
  }

  Future<void> softDeleteUser(String nome) async {
    await initialize();

    if (kIsWeb) {
      final box = _hiveUsersBox!;
      for (int i = 0; i < box.length; i++) {
        final user = box.getAt(i);
        if (user != null && user['nome'] == nome) {
          user['is_deleted'] = true;
          user['updated_at'] = DateTime.now().toIso8601String();
          await box.putAt(i, user);
          break;
        }
      }
    } else {
      await _sqliteDb!.softDeleteUser(nome);
    }
  }

  // --- GESTIONE AGENDE ---

  Future<List<String>> fetchAgendaNames(String nomeUtente) async {
    await initialize();

    if (kIsWeb) {
      final agendas = _hiveAgendasBox!.values
          .where(
            (a) => a['nome_utente'] == nomeUtente && a['is_deleted'] == false,
          )
          .map((a) => a['nome'] as String)
          .toList();
      agendas.sort();
      return agendas;
    } else {
      return await _sqliteDb!.fetchAgendaNames(nomeUtente);
    }
  }

  Future<void> insertAgenda(String nome, String nomeUtente) async {
    await initialize();

    if (kIsWeb) {
      // Verifica se esiste già
      final existing = _hiveAgendasBox!.values.any(
        (a) =>
            a['nome'] == nome &&
            a['nome_utente'] == nomeUtente &&
            a['is_deleted'] == false,
      );
      if (existing) {
        throw Exception('Agenda già esistente');
      }

      await _hiveAgendasBox!.add({
        'nome': nome,
        'nome_utente': nomeUtente,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
      });
    } else {
      await _sqliteDb!.insertAgenda(nome, nomeUtente);
    }
  }

  Future<void> softDeleteAgenda(String nome, String nomeUtente) async {
    await initialize();

    if (kIsWeb) {
      final box = _hiveAgendasBox!;
      for (int i = 0; i < box.length; i++) {
        final agenda = box.getAt(i);
        if (agenda != null &&
            agenda['nome'] == nome &&
            agenda['nome_utente'] == nomeUtente) {
          agenda['is_deleted'] = true;
          agenda['updated_at'] = DateTime.now().toIso8601String();
          await box.putAt(i, agenda);
          break;
        }
      }
    } else {
      await _sqliteDb!.softDeleteAgenda(nome, nomeUtente);
    }
  }

  // --- GESTIONE ATTIVITÀ ---

  Future<List<Attivita>> fetchAttivitaByAgenda(
    String nomeAgenda,
    String nomeUtente,
  ) async {
    await initialize();

    if (kIsWeb) {
      final activities = _hiveActivitiesBox!.values
          .where(
            (a) =>
                a['nome_agenda'] == nomeAgenda &&
                a['nome_utente'] == nomeUtente &&
                a['is_deleted'] == false,
          )
          .map(
            (a) => Attivita(
              id: a['id'] as int?,
              nomeUtente: a['nome_utente'] as String,
              nomePittogramma: a['nome_pittogramma'] as String,
              nomeAgenda: a['nome_agenda'] as String,
              posizione: a['posizione'] as int,
              tipo: (a['tipo'] as String) == 'foto'
                  ? TipoAttivita.foto
                  : TipoAttivita.pittogramma,
              filePath: a['file_path'] as String,
              fraseVocale: a['frase_vocale'] as String? ?? '',
              createdAt: a['created_at'] != null
                  ? DateTime.tryParse(a['created_at'] as String)
                  : null,
              updatedAt: a['updated_at'] != null
                  ? DateTime.tryParse(a['updated_at'] as String)
                  : null,
              isDeleted: a['is_deleted'] as bool? ?? false,
            ),
          )
          .toList();

      activities.sort((a, b) => a.posizione.compareTo(b.posizione));
      return activities;
    } else {
      return await _sqliteDb!.fetchAttivitaByAgenda(nomeAgenda, nomeUtente);
    }
  }

  Future<void> insertAttivita(Attivita attivita) async {
    await initialize();

    if (kIsWeb) {
      String filePath = attivita.filePath;

      // Se è un'immagine locale (bytes), convertila in base64
      if (attivita.filePath.startsWith('data:') ||
          attivita.filePath.contains('base64')) {
        filePath = attivita.filePath; // È già base64
      } else {
        // Per il web, usa direttamente il path (URL ARASAAC)
        filePath = attivita.filePath;
      }

      await _hiveActivitiesBox!.add({
        'id': DateTime.now().millisecondsSinceEpoch, // Genera ID unico
        'nome_utente': attivita.nomeUtente,
        'nome_pittogramma': attivita.nomePittogramma,
        'nome_agenda': attivita.nomeAgenda,
        'posizione': attivita.posizione,
        'tipo': attivita.tipo == TipoAttivita.foto ? 'foto' : 'pittogramma',
        'file_path': filePath,
        'frase_vocale': attivita.fraseVocale,
        'created_at': attivita.createdAt?.toIso8601String(),
        'updated_at': attivita.updatedAt?.toIso8601String(),
        'is_deleted': false,
      });
      print('🌐 Attività salvata su web: ${attivita.nomePittogramma}');
    } else {
      await _sqliteDb!.insertAttivita(attivita);
    }
  }

  Future<void> softDeleteAttivitaById(int id, String nomeAgenda) async {
    await initialize();

    if (kIsWeb) {
      final box = _hiveActivitiesBox!;
      for (int i = 0; i < box.length; i++) {
        final activity = box.getAt(i);
        if (activity != null && activity['id'] == id) {
          activity['is_deleted'] = true;
          activity['updated_at'] = DateTime.now().toIso8601String();
          await box.putAt(i, activity);
          break;
        }
      }
    } else {
      await _sqliteDb!.softDeleteAttivitaById(id, nomeAgenda);
    }
  }

  Future<void> softDeleteAllInAgenda(
    String nomeAgenda,
    String nomeUtente,
  ) async {
    await initialize();

    if (kIsWeb) {
      final box = _hiveActivitiesBox!;
      for (int i = 0; i < box.length; i++) {
        final activity = box.getAt(i);
        if (activity != null &&
            activity['nome_agenda'] == nomeAgenda &&
            activity['nome_utente'] == nomeUtente) {
          activity['is_deleted'] = true;
          activity['updated_at'] = DateTime.now().toIso8601String();
          await box.putAt(i, activity);
        }
      }
    } else {
      await _sqliteDb!.softDeleteAllInAgenda(nomeAgenda, nomeUtente);
    }
  }

  Future<void> replaceAttivitaContent({
    required int id,
    required String nomePittogramma,
    required String filePath,
    required String tipo,
  }) async {
    await initialize();

    if (kIsWeb) {
      final box = _hiveActivitiesBox!;
      for (int i = 0; i < box.length; i++) {
        final activity = box.getAt(i);
        if (activity != null && activity['id'] == id) {
          activity['nome_pittogramma'] = nomePittogramma;
          activity['file_path'] = filePath;
          activity['tipo'] = tipo;
          activity['updated_at'] = DateTime.now().toIso8601String();
          await box.putAt(i, activity);
          break;
        }
      }
    } else {
      await _sqliteDb!.replaceAttivitaContent(
        id: id,
        nomePittogramma: nomePittogramma,
        filePath: filePath,
        tipo: tipo,
      );
    }
  }

  Future<void> updateAttivitaPositions(
    String nomeAgenda,
    List<int> orderedIds,
  ) async {
    await initialize();

    if (kIsWeb) {
      final box = _hiveActivitiesBox!;
      for (int i = 0; i < orderedIds.length; i++) {
        final id = orderedIds[i];
        for (int j = 0; j < box.length; j++) {
          final activity = box.getAt(j);
          if (activity != null && activity['id'] == id) {
            activity['posizione'] = i + 1;
            activity['updated_at'] = DateTime.now().toIso8601String();
            await box.putAt(j, activity);
            break;
          }
        }
      }
    } else {
      await _sqliteDb!.updateAttivitaPositions(nomeAgenda, orderedIds);
    }
  }
}
