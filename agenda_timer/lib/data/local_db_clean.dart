import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/attivita.dart';

/// Database locale completamente pulito per gestire utenti, agende e attività
class LocalDatabase {
  static const _dbName = 'agenda_clean.db';
  static const _dbVersion = 2; // Database completamente nuovo

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        print('🆕 Creazione database completamente nuovo...');

        // Tabella utenti
        await db.execute('''
          CREATE TABLE utenti (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL UNIQUE,
            created_at TEXT,
            updated_at TEXT,
            is_deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Tabella agende
        await db.execute('''
          CREATE TABLE agende (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            nome_utente TEXT NOT NULL,
            created_at TEXT,
            updated_at TEXT,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE
          )
        ''');

        // Indice UNIQUE parziale per record attivi
        await db.execute('''
          CREATE UNIQUE INDEX idx_agende_active_unique 
          ON agende (nome, nome_utente) 
          WHERE is_deleted = 0
        ''');

        // Tabella attività
        await db.execute('''
          CREATE TABLE attivita (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome_utente TEXT NOT NULL,
            nome_pittogramma TEXT NOT NULL,
            nome_agenda TEXT NOT NULL,
            posizione INTEGER NOT NULL,
            tipo TEXT NOT NULL,
            file_path TEXT NOT NULL,
            frase_vocale TEXT,
            created_at TEXT,
            updated_at TEXT,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (nome_utente) REFERENCES utenti (nome) ON DELETE CASCADE
          )
        ''');

        print('✅ Database completamente nuovo creato');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          print(
            '🔄 Migrazione v1 -> v2: Spostamento attività da "educatore" a "fabio"',
          );
          await db.update(
            'attivita',
            {'nome_utente': 'fabio'},
            where: 'nome_utente = ?',
            whereArgs: ['educatore'],
          );
          print('✅ Migrazione completata: attività spostate a "fabio"');
        }
      },
    );
    return _db!;
  }

  // --- GESTIONE UTENTI ---

  /// Restituisce tutti i nomi utenti non eliminati
  Future<List<String>> fetchUserNames() async {
    final db = await database;

    // Debug: controlla tutti gli utenti nel database
    final allUsers = await db.query('utenti');
    print('👥 Tutti gli utenti nel database:');
    for (final user in allUsers) {
      print('  - Nome: "${user['nome']}", Eliminato: ${user['is_deleted']}');
    }

    final rows = await db.query(
      'utenti',
      columns: ['nome'],
      where: 'is_deleted = 0',
      orderBy: 'nome COLLATE NOCASE ASC',
    );
    final userNames = rows.map((e) => e['nome'] as String).toList();
    print('👥 Utenti attivi: $userNames');
    return userNames;
  }

  /// Inserisce un nuovo utente
  Future<void> insertUser(String nome) async {
    final db = await database;
    print('➕ Tentativo di creare utente: "$nome"');

    try {
      await db.insert('utenti', {
        'nome': nome,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      print('✅ Utente "$nome" creato con successo');
    } catch (e) {
      print('❌ Errore creazione utente "$nome": $e');
      rethrow;
    }
  }

  /// Soft delete utente per nome (elimina anche tutte le agende e attività)
  Future<void> softDeleteUser(String nome) async {
    final db = await database;
    await db.update(
      'utenti',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'nome = ?',
      whereArgs: [nome],
    );
    await softDeleteAllInAgenda(nome, nome);
  }

  // --- GESTIONE AGENDE ---

  /// Restituisce tutti i nomi agende per un utente specifico (non eliminate)
  Future<List<String>> fetchAgendaNames(String nomeUtente) async {
    final db = await database;
    final rows = await db.query(
      'agende',
      columns: ['nome'],
      where: 'is_deleted = 0 AND nome_utente = ?',
      whereArgs: [nomeUtente],
      orderBy: 'nome COLLATE NOCASE ASC',
    );
    return rows.map((e) => e['nome'] as String).toList();
  }

  /// Inserisce una nuova agenda
  Future<void> insertAgenda(String nome, String nomeUtente) async {
    final db = await database;
    await db.insert('agende', {
      'nome': nome,
      'nome_utente': nomeUtente,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': 0,
    });
  }

  /// Soft delete agenda per nome e utente
  Future<void> softDeleteAgenda(String nome, String nomeUtente) async {
    final db = await database;
    await db.update(
      'agende',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'nome = ? AND nome_utente = ?',
      whereArgs: [nome, nomeUtente],
    );
    await softDeleteAllInAgenda(nome, nomeUtente);
  }

  // --- GESTIONE ATTIVITÀ ---

  /// Elenco attività per agenda e utente (non eliminate), ordinate per posizione crescente
  Future<List<Attivita>> fetchAttivitaByAgenda(
    String nomeAgenda,
    String nomeUtente,
  ) async {
    final db = await database;

    print('🔍 Query database per agenda: "$nomeAgenda", utente: "$nomeUtente"');

    // Debug: controlla se il database è completamente vuoto
    final allActivitiesInDb = await db.query('attivita');
    print(
      '📊 TOTALE attività nel database (incluse eliminate): ${allActivitiesInDb.length}',
    );
    if (allActivitiesInDb.isEmpty) {
      print('❌ DATABASE COMPLETAMENTE VUOTO - Nessuna attività trovata!');
    } else {
      print('📋 Tutte le attività nel database:');
      for (final activity in allActivitiesInDb) {
        print(
          '  - ID: ${activity['id']}, Utente: "${activity['nome_utente']}", Agenda: "${activity['nome_agenda']}", Pittogramma: "${activity['nome_pittogramma']}", Deleted: ${activity['is_deleted']}',
        );
      }
    }

    // Prima controlliamo tutte le attività per questo utente
    final allRows = await db.query(
      'attivita',
      where: 'nome_utente = ?',
      whereArgs: [nomeUtente],
    );
    print('📊 Tutte le attività per utente "$nomeUtente": ${allRows.length}');
    for (final row in allRows) {
      print(
        '  - Agenda: "${row['nome_agenda']}", Eliminata: ${row['is_deleted']}, Pittogramma: "${row['nome_pittogramma']}"',
      );
    }

    // Poi facciamo la query specifica
    final rows = await db.query(
      'attivita',
      where: 'is_deleted = 0 AND nome_agenda = ? AND nome_utente = ?',
      whereArgs: [nomeAgenda, nomeUtente],
      orderBy: 'posizione ASC',
    );

    print('🎯 Attività trovate per "$nomeAgenda": ${rows.length}');

    return rows
        .map(
          (e) => Attivita(
            id: e['id'] as int?,
            nomeUtente: e['nome_utente'] as String,
            nomePittogramma: e['nome_pittogramma'] as String,
            nomeAgenda: e['nome_agenda'] as String,
            posizione: e['posizione'] as int,
            tipo: (e['tipo'] as String) == 'foto'
                ? TipoAttivita.foto
                : TipoAttivita.pittogramma,
            filePath: e['file_path'] as String,
            fraseVocale: (e['frase_vocale'] as String?) ?? '',
            createdAt: (e['created_at'] as String?) != null
                ? DateTime.tryParse(e['created_at'] as String)
                : null,
            updatedAt: (e['updated_at'] as String?) != null
                ? DateTime.tryParse(e['updated_at'] as String)
                : null,
            isDeleted: (e['is_deleted'] as int) == 1,
          ),
        )
        .toList();
  }

  /// Inserisce una nuova attività
  Future<void> insertAttivita(Attivita attivita) async {
    final db = await database;
    print('💾 Inserimento attività nel database:');
    print('  - Utente: "${attivita.nomeUtente}"');
    print('  - Agenda: "${attivita.nomeAgenda}"');
    print('  - Pittogramma: "${attivita.nomePittogramma}"');
    print('  - Posizione: ${attivita.posizione}');
    print('  - Tipo: ${attivita.tipo}');
    print('  - File: "${attivita.filePath}"');
    print('  - Frase: "${attivita.fraseVocale}"');

    try {
      await db.insert('attivita', {
        'nome_utente': attivita.nomeUtente,
        'nome_pittogramma': attivita.nomePittogramma,
        'nome_agenda': attivita.nomeAgenda,
        'posizione': attivita.posizione,
        'tipo': attivita.tipo == TipoAttivita.foto ? 'foto' : 'pittogramma',
        'file_path': attivita.filePath,
        'frase_vocale': attivita.fraseVocale,
        'created_at': attivita.createdAt?.toIso8601String(),
        'updated_at': attivita.updatedAt?.toIso8601String(),
        'is_deleted': attivita.isDeleted ? 1 : 0,
      });
      print('✅ Attività inserita con successo nel database');
    } catch (e) {
      print('❌ Errore inserimento attività: $e');
      rethrow;
    }
  }

  /// Soft delete attività per ID
  Future<void> softDeleteAttivitaById(int id, String nomeAgenda) async {
    final db = await database;
    await db.update(
      'attivita',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ? AND nome_agenda = ?',
      whereArgs: [id, nomeAgenda],
    );
  }

  /// Sostituisce il contenuto di un'attività (file + nome) mantenendo la stessa posizione
  Future<void> replaceAttivitaContent({
    required int id,
    required String nomePittogramma,
    required String filePath,
    required String tipo,
  }) async {
    final db = await database;
    await db.update(
      'attivita',
      {
        'nome_pittogramma': nomePittogramma,
        'file_path': filePath,
        'tipo': tipo,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Aggiorna le posizioni con l'ordine fornito (lista di id in nuovo ordine)
  Future<void> updateAttivitaPositions(
    String nomeAgenda,
    List<int> orderedIds,
  ) async {
    final db = await database;
    int pos = 1;
    for (final id in orderedIds) {
      await db.update(
        'attivita',
        {'posizione': pos++, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ? AND nome_agenda = ?',
        whereArgs: [id, nomeAgenda],
      );
    }
  }

  /// Elimina tutte le attività (soft) di un'agenda per un utente specifico
  Future<void> softDeleteAllInAgenda(
    String nomeAgenda,
    String nomeUtente,
  ) async {
    final db = await database;
    await db.update(
      'attivita',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'nome_agenda = ? AND nome_utente = ? AND is_deleted = 0',
      whereArgs: [nomeAgenda, nomeUtente],
    );
  }

  /// Riordina le attività aggiornando le posizioni nel database
  Future<void> reorderAttivita(
    String nomeAgenda,
    String nomeUtente,
    int oldIndex,
    int newIndex,
  ) async {
    final db = await database;

    // Ottieni tutte le attività ordinate per posizione
    final attivita = await fetchAttivitaByAgenda(nomeAgenda, nomeUtente);

    if (oldIndex < 0 ||
        oldIndex >= attivita.length ||
        newIndex < 0 ||
        newIndex >= attivita.length) {
      throw Exception('Indici non validi per il riordino');
    }

    // Sposta l'elemento nella nuova posizione
    final movedItem = attivita.removeAt(oldIndex);
    attivita.insert(newIndex, movedItem);

    // Aggiorna tutte le posizioni nel database
    for (int i = 0; i < attivita.length; i++) {
      await db.update(
        'attivita',
        {'posizione': i + 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [attivita[i].id],
      );
    }

    print(
      '🔄 Riordinamento completato: ${attivita.length} attività aggiornate',
    );
  }
}
