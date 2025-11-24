# CLAUDE.md

Questo file fornisce indicazioni a Claude Code (claude.ai/code) quando lavora con il codice in questa repository.

## Panoramica del Progetto
Progressive Web App Flutter per la gestione di sequenze di attività con pittogrammi ARASAAC e supporto foto. Utilizza interfaccia in lingua italiana e si integra con le API ARASAAC per pittogrammi di accessibilità. L'app è progettata per uso educativo/terapeutico, particolarmente per utenti con necessità comunicative.

**Deployment**: PWA ospitata su server Aruba (assistivetech.it) nella sottocartella `/agenda`
- URL di produzione: https://www.assistivetech.it/agenda
- Server: hosting Aruba con supporto PHP e upload file
- Database: MySQL Aruba (disponibile ma non utilizzato - app usa storage locale/JSON)

## Comandi di Sviluppo
```bash
# Comandi Flutter standard
flutter pub get                    # Installa dipendenze
flutter run                       # Esegui app in modalità debug
flutter run -d <device_id>         # Esegui su dispositivo specifico
flutter devices                   # Lista dispositivi disponibili
flutter test                      # Esegui test
flutter analyze                   # Analisi codice/linting
dart format .                     # Formatta codice

# Comandi di build
flutter build apk                 # Android APK
flutter build ios                 # iOS (richiede macOS)
flutter build web                 # Versione web (per deployment)

# Generazione codice (per modelli Freezed)
dart run build_runner build       # Genera codice una volta
dart run build_runner watch       # Monitora e rigenera automaticamente
dart run build_runner build --delete-conflicting-outputs  # Rebuild completo
```

## Architettura
**Gestione Stato**: Riverpod con flutter_riverpod (pattern AutoDisposeAsyncNotifier)
**Layer Dati**: Cross-platform - SQLite (sqflite) per mobile, Hive per web storage + API PHP per persistenza
**Modelli**: Freezed per classi immutabili con serializzazione JSON
**Gestione File**: Platform-aware - FileStorageService per mobile, conversione base64 + upload PHP per web
**Integrazione API**: Client HTTP per ricerca pittogrammi ARASAAC con caching
**Text-to-Speech**: flutter_tts con velocità configurabile

### Componenti Chiave
- `lib/main.dart` - Entry point con Material app e UI principale
- `lib/models/` - Modelli Freezed (Attivita, Agenda, Utente) con file generati .freezed.dart e .g.dart
- `lib/providers/providers.dart` - Gestione stato Riverpod completa (640+ righe)
- `lib/data/` - Layer database con pattern adapter cross-platform (LocalDatabase, DatabaseAdapter)
- `lib/services/` - Client API esterni (ARASAAC), TTS, cache immagini, upload file
- `lib/widgets/` - Componenti UI modulari (AgendaDrawer, ActivityList, FloatingActionButtons, etc.)
- `lib/utils/validators.dart` - Utilità di validazione input
- `lib/l10n/app_localizations.dart` - Supporto internazionalizzazione

### Modelli Dati (Freezed)
- **Utente**: Supporto multi-utente con capacità soft delete
- **Agenda**: Collezioni di attività per utente con cascade delete
- **Attivita**: Modello core con supporto pittogramma/foto, posizionamento e frasi TTS
- Tutti i modelli usano Freezed con serializzazione JSON e immutabilità

### Pattern Gestione Stato
- **Tipi Provider**: Usa AutoDisposeAsyncNotifier per provider dati, Notifier per stato semplice
- **Cross-reference**: Provider che si ascoltano reciprocamente (es. attività si ricaricano quando cambia utente/agenda)
- **Gestione Errori**: Stati errore completi con messaggi user-friendly in italiano
- **Flusso Dati**: Selezione Utente → Selezione Agenda → Gestione Attività

### Provider Stato Principali
- `utentiProvider` - Operazioni CRUD utenti con validazione duplicati
- `utenteSelezionatoProvider` - Stato utente attualmente selezionato
- `agendeProvider` - Gestione agende per utente selezionato
- `agendaSelezionataProvider` - Agenda attualmente selezionata
- `attivitaPerAgendaProvider` - Gestione complessa attività con riordinamento, operazioni CRUD
- `arasaacSearchProvider` - Ricerca API ARASAAC con debounce (350ms di ritardo)
- `imageCacheProvider` - Servizio cache immagini ARASAAC
- `ttsProvider` & `ttsSpeedProvider` - Text-to-speech con velocità configurabile

### Gestione Specifica per Piattaforma

#### Web (Deployment Produzione)
- **Storage**: Combinazione Hive locale + API PHP per persistenza server
- **Immagini**: Conversione base64 automatica per pittogrammi, upload PHP per foto utente
- **API Endpoints**:
  - `web/api/upload_image.php` - Upload immagini (max 5MB, JPG/PNG/GIF/WebP)
  - `web/api/save_data.php` - Salvataggio/caricamento dati JSON
- **File Path**: Upload in `/assets/images/` con path relativi `/agenda/assets/images/`
- **Configurazione PWA**: Manifest completo con icone e modalità standalone

#### Mobile
- **Storage**: Accesso diretto file system, database SQLite
- **Immagini**: File picker nativo, gestione diretta file locali
- **Fallback**: Può usare anche le API web se configurato

### Schema Database
- Pattern adapter cross-platform (DatabaseAdapter) gestisce differenze SQLite/Hive
- Pattern soft delete con flag isDeleted
- Relazioni chiavi esterne con comportamento cascade delete
- Ordinamento basato su posizione per attività all'interno delle agende

### Configurazione PWA
**File**: `web/manifest.json`
- Nome: "Agenda Pittogrammi"
- Modalità: standalone
- Tema: #673AB7 (viola)
- Icone: 192px, 512px, maskable
- Orientamento: any
- Scope: relativo alla sottocartella

### Integrazione Server Aruba
**Hosting**: Server Aruba con supporto PHP
- FTP: ftp.assistivetech.it
- Path produzione: `/agenda/` (sottocartella del dominio)
- Database MySQL disponibile (non utilizzato)
- Upload file via PHP con validazioni sicurezza

### Struttura Test
- Test widget base in `test/widget_test.dart`
- Usa ProviderScope per test Riverpod
- Test inizializzazione app e elementi UI core

### Dipendenze Generazione Codice
- `freezed` e `json_annotation` per generazione modelli
- `build_runner` per workflow generazione codice
- File generati: `.freezed.dart` (classi immutabili), `.g.dart` (serializzazione JSON)

## Note Importanti
- L'app è già deployata e funzionante su https://www.assistivetech.it/agenda
- Non sono necessarie modifiche alla struttura di deployment
- I file PHP gestiscono upload e persistenza dati per la versione web
- L'architettura supporta sia uso offline (mobile) che online (web con sincronizzazione)