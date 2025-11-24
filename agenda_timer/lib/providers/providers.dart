import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/arasaac_api.dart';
import '../data/local_db_clean.dart';
import '../data/database_adapter.dart';
import '../models/attivita.dart';
import '../data/file_storage.dart';
import '../services/image_cache_service.dart';
import '../services/tts_service.dart';
import '../services/file_upload_service.dart';
import '../models/video_educatore.dart';
import '../services/video_api_service.dart';

// Provider per client ARASAAC
final arasaacClientProvider = Provider<ArasaacApiClient>((ref) {
  return ArasaacApiClient();
});

// Provider per ricerca ARASAAC con debounce
class ArasaacSearchNotifier
    extends AutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  Timer? _debounce;
  String _locale = 'it';

  @override
  Future<List<Map<String, dynamic>>> build() async {
    return [];
  }

  // Imposta locale (es. it, es, en)
  void setLocale(String locale) {
    _locale = locale;
  }

  // Avvia ricerca con debounce
  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(query);
    });
  }

  // Esegue la ricerca effettiva
  Future<void> _performSearch(String query) async {
    state = const AsyncLoading();
    try {
      final api = ref.read(arasaacClientProvider);
      final results = await api.searchPictograms(locale: _locale, query: query);
      state = AsyncData(results);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

final arasaacSearchProvider =
    AutoDisposeAsyncNotifierProvider<
      ArasaacSearchNotifier,
      List<Map<String, dynamic>>
    >(ArasaacSearchNotifier.new);

// Database provider
final localDbProvider = Provider<LocalDatabase>((ref) => LocalDatabase());

// Database adapter provider for cross-platform support
final databaseAdapterProvider = Provider<DatabaseAdapter>(
  (ref) => DatabaseAdapter.instance,
);

// Storage provider per salvataggio file
final fileStorageProvider = Provider<FileStorageService>(
  (ref) => FileStorageService(),
);

// Cache provider per immagini ARASAAC
final imageCacheProvider = Provider<ImageCacheService>(
  (ref) => ImageCacheService(),
);

// TTS provider per sintesi vocale
final ttsProvider = Provider<TtsService>((ref) => TtsService());

// Provider per la velocità TTS
class TtsSpeedNotifier extends Notifier<double> {
  @override
  double build() => 0.4; // Velocità predefinita

  void setSpeed(double speed) {
    state = speed.clamp(0.1, 1.0);
    // Aggiorna la velocità nel servizio TTS
    ref.read(ttsProvider).setSpeechRate(state);
  }
}

final ttsSpeedProvider = NotifierProvider<TtsSpeedNotifier, double>(
  TtsSpeedNotifier.new,
);

// Provider per il timer automatico di avanzamento pagine
class AutoTimerNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Timer disabilitato per default

  void toggle() {
    state = !state;
  }

  void enable() {
    state = true;
  }

  void disable() {
    state = false;
  }
}

final autoTimerProvider = NotifierProvider<AutoTimerNotifier, bool>(
  AutoTimerNotifier.new,
);

// Provider per l'intervallo del timer (in secondi)
class TimerIntervalNotifier extends Notifier<int> {
  @override
  int build() => 5; // 5 secondi per default

  void setInterval(int seconds) {
    state = seconds.clamp(3, 60); // Min 3 sec, Max 1 minuto
  }
}

final timerIntervalProvider = NotifierProvider<TimerIntervalNotifier, int>(
  TimerIntervalNotifier.new,
);

// --- GESTIONE UTENTI ---

// Provider per elenco utenti
class UtentiNotifier extends AutoDisposeAsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    try {
      final db = ref.read(databaseAdapterProvider);
      return await db.fetchUserNames();
    } catch (e) {
      return [];
    }
  }

  /// Crea un nuovo utente e ricarica la lista
  Future<void> createUser(String nome) async {
    try {
      final db = ref.read(databaseAdapterProvider);
      await db.insertUser(nome);
      state = AsyncData(await db.fetchUserNames());
    } catch (e) {
      // Gestisci specificamente l'errore di duplicato
      String errorMessage;
      if (e.toString().contains('UNIQUE constraint failed') ||
          e.toString().contains('2067')) {
        errorMessage = 'Esiste già un utente con il nome "$nome"';
      } else {
        errorMessage = 'Errore creazione utente "$nome": ${e.toString()}';
      }

      state = AsyncError(errorMessage, StackTrace.current);
      throw Exception(errorMessage);
    }
  }

  /// Elimina un utente e tutte le sue agende/attività
  Future<void> deleteUser(String nome) async {
    try {
      final db = ref.read(databaseAdapterProvider);
      await db.softDeleteUser(nome);
      state = AsyncData(await db.fetchUserNames());
    } catch (e) {
      state = AsyncError(
        'Errore eliminazione utente "$nome": ${e.toString()}',
        StackTrace.current,
      );
      rethrow;
    }
  }
}

final utentiProvider =
    AutoDisposeAsyncNotifierProvider<UtentiNotifier, List<String>>(
      UtentiNotifier.new,
    );

// Provider per utente attualmente selezionato
class UtenteSelezionato extends Notifier<String?> {
  @override
  String? build() => null; // nessun utente selezionato all'avvio

  void select(String? nome) => state = nome;
}

final utenteSelezionatoProvider = NotifierProvider<UtenteSelezionato, String?>(
  UtenteSelezionato.new,
);

// Provider per elenco agende (temporaneo - usa utente predefinito)
class AgendeNotifier extends AutoDisposeAsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    // Monitora i cambiamenti dell'utente selezionato
    ref.listen(utenteSelezionatoProvider, (previous, next) {
      // Se cambia l'utente, ricarica le agende
      if (previous != next) {
        print('🔄 Utente cambiato da "$previous" a "$next" - ricarico agende');
        ref.invalidateSelf();
      }
    });

    try {
      final db = ref.read(databaseAdapterProvider);
      // Usa l'utente selezionato dinamicamente
      final nomeUtente =
          ref.read(utenteSelezionatoProvider) ?? 'Utente Predefinito';

      print('👤 Utente selezionato: "$nomeUtente"');
      print('📚 Caricamento agende per utente: "$nomeUtente"');
      final agende = await db.fetchAgendaNames(nomeUtente);
      print('✅ Trovate ${agende.length} agende: $agende');
      return agende;
    } catch (e) {
      print('❌ Errore caricamento agende: $e');
      return [];
    }
  }

  /// Crea una nuova agenda e ricarica la lista
  Future<void> createAgenda(String nome) async {
    final nomeUtente =
        ref.read(utenteSelezionatoProvider) ?? 'Utente Predefinito';
    try {
      final db = ref.read(databaseAdapterProvider);
      await db.insertAgenda(nome, nomeUtente);
      state = AsyncData(await db.fetchAgendaNames(nomeUtente));
    } catch (e) {
      // Gestisci specificamente l'errore di duplicato
      String errorMessage;
      if (e.toString().contains('UNIQUE constraint failed') ||
          e.toString().contains('2067')) {
        errorMessage = 'Esiste già un\'agenda con il nome "$nome"';
      } else {
        errorMessage = 'Errore creazione agenda "$nome": ${e.toString()}';
      }

      state = AsyncError(errorMessage, StackTrace.current);
      throw Exception(errorMessage);
    }
  }

  /// Forza il ricaricamento delle agende
  Future<void> reload() async {
    print('🔄 Forzato refresh delle agende');
    ref.invalidateSelf();
  }

  /// Elimina un'agenda e tutte le sue attività (cascade delete)
  Future<void> deleteAgenda(String nome) async {
    final nomeUtente =
        ref.read(utenteSelezionatoProvider) ?? 'Utente Predefinito';
    try {
      final db = ref.read(databaseAdapterProvider);

      // Prima elimina tutte le attività dell'agenda
      await db.softDeleteAllInAgenda(nome, nomeUtente);

      // Poi elimina l'agenda
      await db.softDeleteAgenda(nome, nomeUtente);

      // Ricarica la lista delle agende
      state = AsyncData(await db.fetchAgendaNames(nomeUtente));
    } catch (e) {
      state = AsyncError(
        'Errore eliminazione agenda "$nome": ${e.toString()}',
        StackTrace.current,
      );
      rethrow;
    }
  }
}

final agendeProvider =
    AutoDisposeAsyncNotifierProvider<AgendeNotifier, List<String>>(
      AgendeNotifier.new,
    );

// Provider per agenda selezionata (nome)
class AgendaSelezionata extends Notifier<String?> {
  @override
  String? build() => null; // nessuna agenda selezionata all'avvio

  void select(String? nome) {
    print('🎯 Selezione agenda: "$nome"');
    state = nome;
  }
}

final agendaSelezionataProvider = NotifierProvider<AgendaSelezionata, String?>(
  AgendaSelezionata.new,
);

// Provider per attività dell'agenda selezionata
class AttivitaPerAgendaNotifier
    extends AutoDisposeAsyncNotifier<List<Attivita>> {
  @override
  Future<List<Attivita>> build() async {
    // Monitora i cambiamenti dell'agenda selezionata e dell'utente
    ref.listen(agendaSelezionataProvider, (previous, next) {
      // Se cambia l'agenda, ricarica i dati
      if (previous != next) {
        print('🔄 Agenda cambiata da "$previous" a "$next" - ricarico dati');
        // Forza il refresh immediato
        ref.invalidateSelf();
        // Ricarica anche i dati dell'agenda
        ref.read(agendeProvider.notifier).reload();
      }
    });

    ref.listen(utenteSelezionatoProvider, (previous, next) {
      // Se cambia l'utente, ricarica i dati
      if (previous != next) {
        print('🔄 Utente cambiato da "$previous" a "$next" - ricarico dati');
        ref.invalidateSelf();
      }
    });

    try {
      final db = ref.read(databaseAdapterProvider);
      final nomeAgenda = ref.read(agendaSelezionataProvider);
      // Usa l'utente selezionato dinamicamente
      final nomeUtente =
          ref.read(utenteSelezionatoProvider) ?? 'Utente Predefinito';

      print('👤 Utente selezionato per attività: "$nomeUtente"');
      print(
        '📋 Caricamento attività per agenda: "$nomeAgenda", utente: "$nomeUtente"',
      );

      if (nomeAgenda == null) {
        print('⚠️ Nessuna agenda selezionata');
        return [];
      }

      final attivita = await db.fetchAttivitaByAgenda(nomeAgenda, nomeUtente);
      print('✅ Caricate ${attivita.length} attività per agenda "$nomeAgenda"');
      return attivita;
    } catch (e) {
      print('❌ Errore caricamento attività: $e');
      return [];
    }
  }

  /// Forza il ricaricamento dei dati dell'agenda corrente
  Future<void> reload() async {
    print('🔄 Forzato refresh delle attività');
    ref.invalidateSelf();
  }

  /// Forza il refresh quando si torna a un'agenda
  Future<void> refreshOnReturn() async {
    print('🔄 Refresh al ritorno all\'agenda');
    // Invalida sia le attività che le agende
    ref.invalidateSelf();
    ref.read(agendeProvider.notifier).reload();
  }

  // Aggiunge una attività alla prossima posizione disponibile
  Future<void> addAttivita({
    required String nomeUtente,
    required String nomePittogramma,
    required String nomeAgenda,
    required TipoAttivita tipo,
    required String filePath,
    String fraseVocale = '',
    Uint8List? imageBytes,
  }) async {
    print(
      '➕ Aggiunta attività: "$nomePittogramma" per utente "$nomeUtente" in agenda "$nomeAgenda"',
    );
    try {
      final db = ref.read(databaseAdapterProvider);
      final current = await db.fetchAttivitaByAgenda(nomeAgenda, nomeUtente);
      final nextPos = current.isEmpty ? 1 : current.last.posizione + 1;
      final now = DateTime.now();

      print('📝 Posizione successiva: $nextPos');
      print('📁 File path originale: $filePath');
      print('💬 Frase vocale: "$fraseVocale"');

      // Gestisci il file path in base alla piattaforma e tipo
      String processedFilePath = filePath;

      if (kIsWeb && tipo == TipoAttivita.foto && imageBytes != null) {
        // Su web, per le foto caricate, fai upload sul server
        try {
          final fileName =
              '${nomePittogramma}_${DateTime.now().millisecondsSinceEpoch}.png';
          final uploadService = FileUploadService();
          final uploadResult = await uploadService.uploadImage(
            imageBytes: imageBytes,
            fileName: fileName,
          );
          processedFilePath = uploadResult?['path'] ?? filePath;
          print('📤 Foto caricata sul server: $processedFilePath');
        } catch (e) {
          print('⚠️ Errore upload foto: $e');
          // Fallback: converti in base64
          final base64 = base64Encode(imageBytes);
          processedFilePath = 'data:image/png;base64,$base64';
          print('📸 Foto convertita in base64 come fallback');
        }
      } else if (kIsWeb && tipo == TipoAttivita.foto) {
        // Su web, per le foto locali, converti in base64 se necessario
        if (!filePath.startsWith('data:') && !filePath.startsWith('http')) {
          // È un file locale che deve essere convertito in base64
          try {
            final file = File(filePath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final base64 = base64Encode(bytes);
              processedFilePath = 'data:image/png;base64,$base64';
              print(
                '📸 Foto convertita in base64: ${processedFilePath.substring(0, 50)}...',
              );
            }
          } catch (e) {
            print('⚠️ Errore conversione foto in base64: $e');
          }
        }
      } else if (kIsWeb &&
          tipo == TipoAttivita.pittogramma &&
          filePath.startsWith('http')) {
        // Su web, per i pittogrammi ARASAAC, scarica e converti in base64
        try {
          final cacheService = ref.read(imageCacheProvider);
          final bytes = await cacheService.fetchAndCache(filePath);
          if (bytes != null) {
            final base64 = base64Encode(bytes);
            processedFilePath = 'data:image/png;base64,$base64';
            print(
              '🎨 Pittogramma convertito in base64: ${processedFilePath.substring(0, 50)}...',
            );
          }
        } catch (e) {
          print('⚠️ Errore conversione pittogramma in base64: $e');
        }
      }

      print(
        '📁 File path processato: ${processedFilePath.substring(0, 50)}...',
      );

      final attivita = Attivita(
        nomeUtente: nomeUtente,
        nomePittogramma: nomePittogramma,
        nomeAgenda: nomeAgenda,
        posizione: nextPos,
        tipo: tipo,
        filePath: processedFilePath,
        fraseVocale: fraseVocale,
        createdAt: now,
        updatedAt: now,
      );

      await db.insertAttivita(attivita);
      print('✅ Attività salvata nel database');

      final updated = await db.fetchAttivitaByAgenda(nomeAgenda, nomeUtente);
      print('📊 Attività dopo salvataggio: ${updated.length}');
      state = AsyncData(updated);
    } catch (e) {
      print('❌ Errore salvataggio attività: $e');
      state = AsyncError(
        'Errore aggiunta attività "$nomePittogramma": ${e.toString()}',
        StackTrace.current,
      );
      rethrow;
    }
  }

  // Elimina (soft) per id
  Future<void> deleteById(int id) async {
    try {
      final db = ref.read(databaseAdapterProvider);
      final nomeAgenda = ref.read(agendaSelezionataProvider);
      if (nomeAgenda == null) {
        throw StateError('Nessuna agenda selezionata per eliminazione');
      }
      await db.softDeleteAttivitaById(id, nomeAgenda);
      final nomeUtente = 'Utente Predefinito';
      state = AsyncData(await db.fetchAttivitaByAgenda(nomeAgenda, nomeUtente));
    } catch (e) {
      state = AsyncError(
        'Errore eliminazione attività (ID: $id): ${e.toString()}',
        StackTrace.current,
      );
      rethrow;
    }
  }

  // Sostituisce contenuto (file + nome) mantenendo stessa posizione
  Future<void> replace({
    required int id,
    required String nomePittogramma,
    required String filePath,
    required TipoAttivita tipo,
  }) async {
    final db = ref.read(databaseAdapterProvider);
    final nomeAgenda = ref.read(agendaSelezionataProvider);
    if (nomeAgenda == null) return;

    // Gestisci il file path in base alla piattaforma
    String processedFilePath = filePath;

    if (kIsWeb && tipo == TipoAttivita.foto) {
      // Su web, per le foto locali, converti in base64 se necessario
      if (!filePath.startsWith('data:') && !filePath.startsWith('http')) {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final base64 = base64Encode(bytes);
            processedFilePath = 'data:image/png;base64,$base64';
            print('🔄 Foto sostituta convertita in base64');
          }
        } catch (e) {
          print('⚠️ Errore conversione foto sostituta: $e');
        }
      }
    } else if (kIsWeb &&
        tipo == TipoAttivita.pittogramma &&
        filePath.startsWith('http')) {
      // Su web, per i pittogrammi ARASAAC, scarica e converti in base64
      try {
        final cacheService = ref.read(imageCacheProvider);
        final bytes = await cacheService.fetchAndCache(filePath);
        if (bytes != null) {
          final base64 = base64Encode(bytes);
          processedFilePath = 'data:image/png;base64,$base64';
          print('🔄 Pittogramma sostituto convertito in base64');
        }
      } catch (e) {
        print('⚠️ Errore conversione pittogramma sostituto: $e');
      }
    }

    await db.replaceAttivitaContent(
      id: id,
      nomePittogramma: nomePittogramma,
      filePath: processedFilePath,
      tipo: tipo == TipoAttivita.foto ? 'foto' : 'pittogramma',
    );
    final nomeUtente =
        ref.read(utenteSelezionatoProvider) ?? 'Utente Predefinito';
    state = AsyncData(await db.fetchAttivitaByAgenda(nomeAgenda, nomeUtente));
  }

  // Reorder: aggiorna posizioni in base al nuovo ordine
  Future<void> reorder(int oldIndex, int newIndex) async {
    print('🔄 Provider reorder: da $oldIndex a $newIndex');
    try {
      final nomeAgenda = ref.read(agendaSelezionataProvider);
      if (nomeAgenda == null) {
        throw StateError('Nessuna agenda selezionata per riordino');
      }
      print('📋 Agenda selezionata: $nomeAgenda');
      final List<Attivita> current = List<Attivita>.from(
        state.value ?? <Attivita>[],
      );
      if (newIndex > oldIndex) newIndex -= 1;
      final item = current.removeAt(oldIndex);
      current.insert(newIndex, item);
      state = AsyncData(current);
      final List<int> ids = current.map((e) => e.id!).toList();
      print('🔄 Aggiornamento database con ${ids.length} ID: $ids');
      await ref
          .read(databaseAdapterProvider)
          .updateAttivitaPositions(nomeAgenda, ids);
      print('✅ Database aggiornato con successo');
    } catch (e) {
      // Ripristina stato precedente in caso di errore
      final nomeUtente =
          ref.read(utenteSelezionatoProvider) ?? 'Utente Predefinito';
      state = AsyncData(
        await ref
            .read(localDbProvider)
            .fetchAttivitaByAgenda(
              ref.read(agendaSelezionataProvider) ?? '',
              nomeUtente,
            ),
      );
      rethrow;
    }
  }

  // Export agenda in JSON minimale (solo mobile)
  Future<File> exportAgendaJson() async {
    if (kIsWeb) {
      throw UnsupportedError('Export JSON non supportato su web');
    }
    final nomeAgenda = ref.read(agendaSelezionataProvider);
    if (nomeAgenda == null) throw Exception('Nessuna agenda selezionata');
    final list = await build();
    final _ = {
      'nome_agenda': nomeAgenda,
      'attivita': list
          .map(
            (a) => {
              'nome_utente': a.nomeUtente,
              'nome_pittogramma': a.nomePittogramma,
              'posizione': a.posizione,
              'tipo': a.tipo == TipoAttivita.foto ? 'foto' : 'pittogramma',
              'file_path': a.filePath,
            },
          )
          .toList(),
    };
    throw UnsupportedError(
      'Export non supportato nella versione web - usare JsonDataService',
    );
    // final dir = await ref.read(fileStorageProvider).ensureAgendaDir(nomeAgenda);
    // final file = File(
    //   '${dir.path}/export_${DateTime.now().millisecondsSinceEpoch}.json',
    // );
    // await file.writeAsString(jsonEncode(map));
    // return file;
  }

  // Import agenda da JSON (sostituisce le attività correnti)
  Future<void> importAgendaJson(File jsonFile) async {
    final nomeAgenda = ref.read(agendaSelezionataProvider);
    if (nomeAgenda == null) return;
    final db = ref.read(databaseAdapterProvider);
    final raw = await jsonFile.readAsString();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final att = (map['attivita'] as List).cast<Map<String, dynamic>>();
    final nomeUtente =
        ref.read(utenteSelezionatoProvider) ?? 'Utente Predefinito';
    await db.softDeleteAllInAgenda(nomeAgenda, nomeUtente);
    int pos = 1;
    for (final a in att) {
      await db.insertAttivita(
        Attivita(
          nomeUtente: a['nome_utente'] as String? ?? 'educatore',
          nomePittogramma: a['nome_pittogramma'] as String? ?? 'attivita',
          nomeAgenda: nomeAgenda,
          posizione: pos++,
          tipo: (a['tipo'] as String) == 'foto'
              ? TipoAttivita.foto
              : TipoAttivita.pittogramma,
          filePath: a['file_path'] as String,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    state = AsyncData(await db.fetchAttivitaByAgenda(nomeAgenda, nomeUtente));
  }
}

final attivitaPerAgendaProvider =
    AutoDisposeAsyncNotifierProvider<AttivitaPerAgendaNotifier, List<Attivita>>(
      AttivitaPerAgendaNotifier.new,
    );

// Provider per gestione video educatore
class VideoEducatoreNotifier extends AutoDisposeAsyncNotifier<List<VideoEducatore>> {
  final VideoApiService _apiService = VideoApiService();

  @override
  Future<List<VideoEducatore>> build() async {
    try {
      // Carica i video dal database Aruba via API
      return await _apiService.getAllVideo();
    } catch (e) {
      print('Errore caricamento video: $e');
      // In caso di errore, restituisce lista vuota per evitare crash
      return [];
    }
  }

  Future<void> salvaVideo(VideoEducatore video) async {
    state = const AsyncLoading();
    try {
      // Salva nel database Aruba via API
      final videoSalvato = await _apiService.salvaVideo(video);

      // Aggiorna lo stato locale
      final currentVideos = state.value ?? [];
      state = AsyncData([videoSalvato, ...currentVideos]);

      print('Video salvato con successo: ${videoSalvato.nomeVideo}');
    } catch (e) {
      print('Errore salvataggio video: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> eliminaVideo(int idVideo) async {
    state = const AsyncLoading();
    try {
      // Elimina dal database Aruba via API
      await _apiService.eliminaVideo(idVideo);

      // Aggiorna lo stato locale
      final currentVideos = state.value ?? [];
      final updatedVideos = currentVideos.where((v) => v.idVideo != idVideo).toList();
      state = AsyncData(updatedVideos);

      print('Video eliminato con successo: ID $idVideo');
    } catch (e) {
      print('Errore eliminazione video: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<List<VideoEducatore>> getVideoPerUtente(String nomeUtente) async {
    try {
      return await _apiService.getVideoPerUtente(nomeUtente);
    } catch (e) {
      print('Errore getVideoPerUtente: $e');
      return [];
    }
  }

  Future<List<VideoEducatore>> getVideoPerAgenda(String nomeAgenda) async {
    try {
      return await _apiService.getVideoPerAgenda(nomeAgenda);
    } catch (e) {
      print('Errore getVideoPerAgenda: $e');
      return [];
    }
  }

  // Ricarica i video forzatamente
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final videos = await _apiService.getAllVideo();
      state = AsyncData(videos);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final videoEducatoreProvider =
    AutoDisposeAsyncNotifierProvider<VideoEducatoreNotifier, List<VideoEducatore>>(
      VideoEducatoreNotifier.new,
    );

// Provider per gestire comunicazioni tra main widget e AgendaPageView
class PageNavigationNotifier extends StateNotifier<PageNavigationCommand?> {
  PageNavigationNotifier() : super(null);

  void navigateLeft() {
    state = PageNavigationCommand.left;
    Future.delayed(const Duration(milliseconds: 100), () {
      state = null; // Reset dopo l'uso
    });
  }

  void navigateRight() {
    state = PageNavigationCommand.right;
    Future.delayed(const Duration(milliseconds: 100), () {
      state = null; // Reset dopo l'uso
    });
  }

  void repeatPhrase() {
    state = PageNavigationCommand.repeat;
    Future.delayed(const Duration(milliseconds: 100), () {
      state = null; // Reset dopo l'uso
    });
  }
}

enum PageNavigationCommand { left, right, repeat }

final pageNavigationProvider =
    StateNotifierProvider<PageNavigationNotifier, PageNavigationCommand?>(
      (ref) => PageNavigationNotifier(),
    );
