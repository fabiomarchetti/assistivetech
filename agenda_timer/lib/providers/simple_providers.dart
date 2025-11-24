import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/json_data_service.dart';
import '../services/arasaac_api.dart';
import '../services/tts_service.dart';
import '../services/file_upload_service.dart';
import '../models/attivita.dart';

// Provider per il servizio JSON
final jsonDataServiceProvider = Provider<JsonDataService>(
  (ref) => JsonDataService(),
);

// Provider per client ARASAAC
final arasaacClientProvider = Provider<ArasaacApiClient>(
  (ref) => ArasaacApiClient(),
);

// Provider per TTS
final ttsProvider = Provider<TtsService>((ref) => TtsService());

// Provider per upload file
final fileUploadServiceProvider = Provider<FileUploadService>(
  (ref) => FileUploadService(),
);

// Provider per utente selezionato
final selectedUserProvider = StateProvider<String?>((ref) => null);

// Provider per agenda selezionata
final selectedAgendaProvider = StateProvider<String?>((ref) => null);

// Provider per lista utenti
final usersProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.read(jsonDataServiceProvider);
  return await service.getUsers();
});

// Provider per agende dell'utente selezionato
final agendasProvider = FutureProvider<List<String>>((ref) async {
  final selectedUser = ref.watch(selectedUserProvider);
  if (selectedUser == null) return [];

  final service = ref.read(jsonDataServiceProvider);
  return await service.getAgendasForUser(selectedUser);
});

// Provider per attività dell'agenda selezionata
final activitiesProvider = FutureProvider<List<Attivita>>((ref) async {
  final selectedUser = ref.watch(selectedUserProvider);
  final selectedAgenda = ref.watch(selectedAgendaProvider);

  if (selectedUser == null || selectedAgenda == null) return [];

  final service = ref.read(jsonDataServiceProvider);
  return await service.getActivitiesForAgenda(selectedUser, selectedAgenda);
});

// Notifier per gestire operazioni sugli utenti
class UsersNotifier extends StateNotifier<AsyncValue<List<String>>> {
  UsersNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadUsers();
  }

  final Ref ref;

  Future<void> _loadUsers() async {
    try {
      final service = ref.read(jsonDataServiceProvider);
      final users = await service.getUsers();
      state = AsyncValue.data(users);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addUser(String userName) async {
    try {
      final service = ref.read(jsonDataServiceProvider);
      await service.addUser(userName);
      await _loadUsers(); // Ricarica la lista
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final usersNotifierProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<String>>>(
      (ref) => UsersNotifier(ref),
    );

// Notifier per gestire operazioni sulle agende
class AgendasNotifier extends StateNotifier<AsyncValue<List<String>>> {
  AgendasNotifier(this.ref) : super(const AsyncValue.loading()) {
    // Ascolta i cambiamenti dell'utente selezionato
    ref.listen(selectedUserProvider, (previous, next) {
      _loadAgendas();
    });
    _loadAgendas();
  }

  final Ref ref;

  Future<void> _loadAgendas() async {
    try {
      final selectedUser = ref.read(selectedUserProvider);
      if (selectedUser == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final service = ref.read(jsonDataServiceProvider);
      final agendas = await service.getAgendasForUser(selectedUser);
      state = AsyncValue.data(agendas);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addAgenda(String agendaName) async {
    try {
      final selectedUser = ref.read(selectedUserProvider);
      if (selectedUser == null) throw Exception('Nessun utente selezionato');

      final service = ref.read(jsonDataServiceProvider);
      await service.addAgenda(selectedUser, agendaName);
      await _loadAgendas(); // Ricarica la lista
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final agendasNotifierProvider =
    StateNotifierProvider<AgendasNotifier, AsyncValue<List<String>>>(
      (ref) => AgendasNotifier(ref),
    );

// Notifier per gestire operazioni sulle attività
class ActivitiesNotifier extends StateNotifier<AsyncValue<List<Attivita>>> {
  ActivitiesNotifier(this.ref) : super(const AsyncValue.loading()) {
    // Ascolta i cambiamenti dell'utente e agenda selezionati
    ref.listen(selectedUserProvider, (previous, next) {
      _loadActivities();
    });
    ref.listen(selectedAgendaProvider, (previous, next) {
      _loadActivities();
    });
    _loadActivities();
  }

  final Ref ref;

  Future<void> _loadActivities() async {
    try {
      final selectedUser = ref.read(selectedUserProvider);
      final selectedAgenda = ref.read(selectedAgendaProvider);

      if (selectedUser == null || selectedAgenda == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final service = ref.read(jsonDataServiceProvider);
      final activities = await service.getActivitiesForAgenda(
        selectedUser,
        selectedAgenda,
      );
      state = AsyncValue.data(activities);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addActivity({
    required String activityName,
    required String imageUrl,
    required TipoAttivita type,
    required String phrase,
    Uint8List? imageBytes,
  }) async {
    try {
      final selectedUser = ref.read(selectedUserProvider);
      final selectedAgenda = ref.read(selectedAgendaProvider);

      if (selectedUser == null) throw Exception('Nessun utente selezionato');
      if (selectedAgenda == null) throw Exception('Nessuna agenda selezionata');

      final service = ref.read(jsonDataServiceProvider);
      await service.addActivity(
        userName: selectedUser,
        agendaName: selectedAgenda,
        activityName: activityName,
        imageUrl: imageUrl,
        type: type,
        phrase: phrase,
        imageBytes: imageBytes,
      );

      await _loadActivities(); // Ricarica la lista
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final activitiesNotifierProvider =
    StateNotifierProvider<ActivitiesNotifier, AsyncValue<List<Attivita>>>(
      (ref) => ActivitiesNotifier(ref),
    );
