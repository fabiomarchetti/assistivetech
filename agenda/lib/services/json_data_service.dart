import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../models/attivita.dart';
import 'file_upload_service.dart';

/// Servizio per gestire dati tramite file JSON e cartella assets
class JsonDataService {
  static const String dataUrl = '/assets/data.json';
  static const String apiUrl = './api/save_data.php';
  static const String assetsImagePath = '/assets/images/';

  final FileUploadService _uploadService = FileUploadService();

  /// Carica i dati dal file JSON
  Future<Map<String, dynamic>> loadData() async {
    try {
      if (kIsWeb) {
        // Su web, carica tramite API
        final response = await http.get(Uri.parse('${_getBaseUrl()}$apiUrl'));
        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
      } else {
        // Su mobile, carica dal file locale (se esiste)
        final file = File('assets/data.json');
        if (await file.exists()) {
          final content = await file.readAsString();
          return jsonDecode(content) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('⚠️ Errore caricamento dati: $e');
    }

    // Ritorna struttura vuota se non riesce a caricare
    return {
      'users': <String>[],
      'agendas': <String, List<String>>{},
      'activities': <Map<String, dynamic>>[],
    };
  }

  /// Salva i dati nel file JSON
  Future<void> saveData(Map<String, dynamic> data) async {
    if (kIsWeb) {
      // Su web, salva tramite API
      try {
        final response = await http.post(
          Uri.parse('${_getBaseUrl()}$apiUrl'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['success']) {
            print('💾 Dati salvati sul server tramite API');
          } else {
            print('❌ Errore salvataggio: ${result['message']}');
          }
        } else {
          print('❌ Errore HTTP: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Errore chiamata API: $e');
      }
    } else {
      // Su mobile, salva localmente
      final file = File('assets/data.json');
      await file.writeAsString(jsonEncode(data));
      print('💾 Dati salvati localmente');
    }
  }

  /// Carica un file immagine sul server e restituisce il path
  Future<String> uploadImageFile({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Upload supportato solo su web');
    }

    try {
      print('📤 Upload immagine: $fileName');
      final result = await _uploadService.uploadImage(
        imageBytes: imageBytes,
        fileName: fileName,
      );

      if (result != null && result['success'] == true) {
        final path = result['path'] as String;
        print('✅ Immagine caricata: $path');
        return path;
      } else {
        throw Exception(
          'Errore durante upload: ${result?['message'] ?? 'Errore sconosciuto'}',
        );
      }
    } catch (e) {
      print('❌ Errore upload immagine: $e');
      rethrow;
    }
  }

  /// Restituisce l'URL dell'immagine (senza scaricarla)
  Future<String> getImageUrl(String imageUrl, String fileName) async {
    // Su web, usa direttamente l'URL ARASAAC
    if (kIsWeb) {
      print('🌐 Uso URL diretto: $imageUrl');
      return imageUrl;
    } else {
      // Su mobile, potremmo scaricare e salvare localmente
      // Per ora usiamo anche qui l'URL diretto per semplicità
      print('📱 Uso URL diretto per mobile: $imageUrl');
      return imageUrl;
    }
  }

  /// Ottiene la lista degli utenti
  Future<List<String>> getUsers() async {
    final data = await loadData();
    return List<String>.from(data['users'] ?? []);
  }

  /// Aggiunge un nuovo utente
  Future<void> addUser(String userName) async {
    final data = await loadData();
    final users = List<String>.from(data['users'] ?? []);

    if (!users.contains(userName)) {
      users.add(userName);
      data['users'] = users;
      data['agendas'][userName] = <String>[];
      await saveData(data);
    }
  }

  /// Ottiene le agende di un utente
  Future<List<String>> getAgendasForUser(String userName) async {
    final data = await loadData();
    final agendas = data['agendas'] as Map<String, dynamic>? ?? {};
    return List<String>.from(agendas[userName] ?? []);
  }

  /// Aggiunge una nuova agenda
  Future<void> addAgenda(String userName, String agendaName) async {
    final data = await loadData();
    final agendas = Map<String, dynamic>.from(data['agendas'] ?? {});

    final userAgendas = List<String>.from(agendas[userName] ?? []);
    if (!userAgendas.contains(agendaName)) {
      userAgendas.add(agendaName);
      agendas[userName] = userAgendas;
      data['agendas'] = agendas;
      await saveData(data);
    }
  }

  /// Ottiene le attività di un'agenda
  Future<List<Attivita>> getActivitiesForAgenda(
    String userName,
    String agendaName,
  ) async {
    final data = await loadData();
    final activities = List<Map<String, dynamic>>.from(
      data['activities'] ?? [],
    );

    final agendaActivities = activities
        .where((a) => a['user'] == userName && a['agenda'] == agendaName)
        .map(
          (a) => Attivita(
            id: a['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
            nomeUtente: a['user'] as String,
            nomePittogramma: a['name'] as String,
            nomeAgenda: a['agenda'] as String,
            posizione: a['position'] as int,
            tipo: (a['type'] as String) == 'foto'
                ? TipoAttivita.foto
                : TipoAttivita.pittogramma,
            filePath: a['image_path'] as String,
            fraseVocale: a['phrase'] as String? ?? '',
          ),
        )
        .toList();

    agendaActivities.sort((a, b) => a.posizione.compareTo(b.posizione));
    return agendaActivities;
  }

  /// Aggiunge una nuova attività
  Future<void> addActivity({
    required String userName,
    required String agendaName,
    required String activityName,
    required String imageUrl,
    required TipoAttivita type,
    required String phrase,
    Uint8List? imageBytes,
  }) async {
    String imagePath;

    // Se abbiamo i bytes dell'immagine (file caricato), fai upload
    if (imageBytes != null && type == TipoAttivita.foto) {
      final fileName = _makeSafeFileName(
        '${activityName}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      imagePath = await uploadImageFile(
        imageBytes: imageBytes,
        fileName: fileName,
      );
    } else {
      // Altrimenti usa l'URL diretto (pittogrammi ARASAAC)
      final fileName =
          '${activityName}_${DateTime.now().millisecondsSinceEpoch}.png';
      imagePath = await getImageUrl(imageUrl, fileName);
    }

    // Aggiunge l'attività ai dati
    final data = await loadData();
    final activities = List<Map<String, dynamic>>.from(
      data['activities'] ?? [],
    );

    // Calcola la prossima posizione
    final existingActivities = activities
        .where((a) => a['user'] == userName && a['agenda'] == agendaName)
        .toList();
    final nextPosition = existingActivities.isEmpty
        ? 1
        : (existingActivities
                  .map((a) => a['position'] as int)
                  .reduce((a, b) => a > b ? a : b)) +
              1;

    activities.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'user': userName,
      'agenda': agendaName,
      'name': activityName,
      'image_path': imagePath,
      'phrase': phrase,
      'position': nextPosition,
      'type': type == TipoAttivita.foto ? 'foto' : 'pittogramma',
    });

    data['activities'] = activities;
    await saveData(data);
  }

  /// Ottiene l'URL base del server
  String _getBaseUrl() {
    if (kIsWeb) {
      return ''; // URL relativo per web
    }
    return 'file://'; // Path locale per mobile
  }

  /// Rende sicuro un nome file
  String _makeSafeFileName(String fileName) {
    return fileName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '_')
        .replaceAll(RegExp(r'_{2,}'), '_');
  }
}
