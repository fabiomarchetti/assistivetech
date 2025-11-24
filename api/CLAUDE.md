
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Questo file fornisce indicazioni a Claude Code (claude.ai/code) quando lavora con il codice in questa repository.

## ⚡ Comandi Essenziali di Sviluppo

### Sito Web Principale (PHP/HTML/JavaScript)
```bash
# Test locale del sito principale
# Aprire direttamente i file HTML nel browser o usare:
php -S localhost:8000                    # Server PHP locale
python -m http.server 8080              # Server Python locale

# Non ci sono comandi di build - tutto è statico/PHP
```

### App Flutter Agenda
```bash
cd agenda/

# Setup e sviluppo
flutter pub get                         # Installa dipendenze
flutter run -d web-server --web-port=8082  # Sviluppo web locale
flutter run -d chrome                   # Test su Chrome

# Code generation (necessario dopo modifiche ai modelli Freezed)
dart run build_runner build --delete-conflicting-outputs

# Test e qualità codice
flutter test                           # Esegui test
flutter analyze                       # Linting e analisi statica
dart format .                         # Formattazione automatica

# Build per produzione
flutter build web                     # Build per deployment su Aruba
```

### Deployment su Aruba
```bash
# 1. Build Flutter se necessario
cd agenda/ && flutter build web

# 2. Upload via FTP (configurazione in .vscode/ftp-sync.json)
# Host: ftp.assistivetech.it
# User: 7985805@aruba.it
# Pass: 67XV57wk4R

# 3. Eseguire script SQL su http://mysql.aruba.it se richiesto
```

## 🌟 Panoramica del Progetto

**AssistiveTech.it** è un sistema completo per gestione assistive technology che include:
- **Sito web principale** con sistema autenticazione multi-ruolo
- **App Agenda Flutter PWA** per gestione pittogrammi ARASAAC
- **Sistema Training Cognitivo** con auto-generazione app Flutter PWA per esercizi
- **Sistema di amministrazione** completo per gestione utenti, sedi e ruoli
- **Gestione sedi** multi-location con associazioni utenti

Il progetto è deployato su hosting Aruba (assistivetech.it) con database MySQL e supporto PHP.

## 🏛️ Architettura di Alto Livello

### Flusso di Autenticazione Multi-Ruolo
Il sistema implementa un flusso di autenticazione centralizzato che determina l'accesso basato sui ruoli:

1. **Login centralizzato** (`login.html` → `api/auth_login.php`)
2. **Verifica credenziali** contro tabella `registrazioni` MySQL
3. **Redirect automatico** basato su `ruolo_registrazione`:
   - `sviluppatore` → `/admin/` (invisibile, accesso totale)
   - `amministratore` → `/admin/` (gestione sistema)
   - `educatore` → `/dashboard.html` (gestione pazienti)
   - `paziente` → `/agenda/` (uso app Flutter)
4. **Sessione browser** salvata in localStorage

### Sistema Auto-Generazione Training Cognitivo
Architettura avanzata per creazione automatica di app Flutter PWA:

- **Admin crea categoria** → `api/api_categorie_esercizi.php` auto-genera cartella + template HTML
- **Admin crea esercizio** → `api/api_esercizi.php` auto-genera app Flutter completa con:
  - Struttura progetto (`pubspec.yaml`, `lib/main.dart`)
  - Configurazione PWA (`web/manifest.json`, service worker)
  - Build pronto per deployment
- **Database sync** automatico con link diretti alle app generate
- **Zero configurazione manuale** - sistema completamente automatizzato

### Architettura Cross-Platform Agenda Flutter
L'app Agenda implementa un pattern adapter per supportare web e mobile:

- **State Management**: Riverpod con AutoDisposeAsyncNotifier pattern
- **Storage Strategy**:
  - Mobile: SQLite nativo + file system
  - Web: Hive locale + API PHP per persistenza server
- **Image Handling**:
  - Mobile: File picker nativo
  - Web: Base64 conversion + upload via PHP
- **API Integration**: Client HTTP per ARASAAC con caching intelligente
- **Code Generation**: Freezed per modelli immutabili con serializzazione JSON automatica

## 🏗️ Architettura del Sistema

```
assistivetech.it/
├── 🏠 SITO PRINCIPALE (Root Directory)
│   ├── index.html              # Homepage landing page
│   ├── login.html              # Pagina autenticazione
│   ├── register.html           # Registrazione nuovi utenti
│   ├── dashboard.html          # Dashboard educatori
│   ├── .htaccess              # Configurazione Apache
│   ├── api/                   # API PHP sistema autenticazione
│   │   ├── auth_login.php     # Endpoint login
│   │   ├── auth_registrazioni.php  # CRUD utenti completo
│   │   ├── api_sedi.php       # API gestione sedi
│   │   ├── api_settori_classi.php  # API gestione settori e classi
│   │   ├── api_categorie_esercizi.php  # API gestione categorie esercizi con auto-gen cartelle (solo sviluppatore)
│   │   ├── api_esercizi.php     # API gestione esercizi con auto-gen app Flutter (solo sviluppatore)
│   │   ├── create_database.sql     # Schema database principale
│   │   ├── create_table_*.sql      # Script creazione tabelle
│   │   └── insert_existing_users.sql # Migrazione dati esistenti
│   └── admin/                 # Pannello amministrativo
│       └── index.html         # Gestione utenti admin
│
├── 🧠 TRAINING COGNITIVO (Sottodirectory /training_cognitivo/)
│   ├── index.html             # Pagina master navigazione categorie/esercizi
│   └── [categoria_nome]/      # Cartelle auto-generate per ogni categoria
│       ├── index.html         # Pagina categoria con lista esercizi
│       └── [esercizio_nome]/  # App Flutter PWA auto-generate per ogni esercizio
│           ├── pubspec.yaml   # Configurazione Flutter
│           ├── lib/main.dart  # Codice Dart principale
│           ├── web/           # Build web PWA
│           └── assets/        # Risorse app
│
└── 📱 APP AGENDA (Sottodirectory /agenda/)
    ├── lib/                   # Codice Dart Flutter
    ├── web/                   # Build web e API agenda
    ├── pubspec.yaml          # Dipendenze Flutter
    └── CLAUDE.md             # Documentazione specifica Flutter
```

## 👥 Sistema Multi-Ruolo

### 🔵 Sviluppatore (Riservato)
- **Accesso**: Pannello admin completo (`/admin/`) ma invisibile nelle liste
- **Privilegi**: Accesso TOTALE - può creare TUTTO (amministratori, educatori, pazienti, sedi, settori, classi, categorie esercizi, esercizi)
- **Protezioni**: Non appare nelle liste utenti, non può essere modificato/eliminato
- **Credenziali**: marchettisoft@gmail.com / Filohori11!
- **Unico autorizzato**: Può creare account amministratore

### 🔴 Amministratore
- **Accesso**: Pannello admin completo (`/admin/`)
- **Privilegi**: Gestione educatori, pazienti, sedi, settori, classi
- **Funzioni**: Creazione/modifica sedi, associazione utenti-sedi, panoramica sistema
- **Limitazioni**: NON può creare altri amministratori, NON può modificare/eliminare account sviluppatore

### 🟡 Educatore
- **Accesso**: Dashboard personalizzata (`/dashboard.html`)
- **Privilegi**: Gestione pazienti assegnati, creazione agende
- **Funzioni**: Statistiche personali, accesso agenda pittogrammi
- **Sede**: Assegnato a sede specifica, settore e classe

### 🟢 Paziente
- **Accesso**: Diretto all'app agenda (`/agenda/`)
- **Privilegi**: Utilizzo sequenze pittogrammi create dagli educatori
- **Modalità**: Semplificata, senza gestione utenti
- **Sede**: Assegnato a sede specifica, settore e classe

## 🗄️ Database MySQL

### Schema Tabelle (Formato Date Italiano)
```sql
registrazioni:
├── id_registrazione (INT AUTO_INCREMENT)
├── nome_registrazione (VARCHAR 100)
├── cognome_registrazione (VARCHAR 100)
├── username_registrazione (VARCHAR 255 UNIQUE)
├── password_registrazione (VARCHAR 255)
├── ruolo_registrazione (ENUM: amministratore/educatore/paziente/sviluppatore)
├── data_registrazione (VARCHAR 10) → "13/09/2024"
├── ultimo_accesso (VARCHAR 19) → "13/09/2024 15:30:45"
└── stato_account (ENUM: attivo/sospeso/eliminato)

sedi:
├── id_sede (INT AUTO_INCREMENT)
├── nome_sede (VARCHAR 200 UNIQUE)
├── indirizzo (VARCHAR 255)
├── citta (VARCHAR 100)
├── provincia (CHAR 2)
├── cap (VARCHAR 10)
├── telefono (VARCHAR 20)
├── email (VARCHAR 255)
├── data_creazione (VARCHAR 19) → "13/09/2024 15:30:45"
└── stato_sede (ENUM: attiva/sospesa/chiusa)

educatori:
├── id_educatore (INT AUTO_INCREMENT)
├── id_registrazione (INT FK UNIQUE)
├── nome (VARCHAR 100)
├── cognome (VARCHAR 100)
├── settore (VARCHAR 100)
├── classe (VARCHAR 50)
├── id_sede (INT FK)
├── telefono (VARCHAR 20)
├── email_contatto (VARCHAR 255)
├── note_professionali (TEXT)
├── stato_educatore (ENUM: attivo/sospeso/in_formazione)
└── data_creazione (VARCHAR 19) → "13/09/2024 15:30:45"

pazienti:
├── id_paziente (INT AUTO_INCREMENT)
├── id_registrazione (INT FK UNIQUE)
├── nome (VARCHAR 100)
├── cognome (VARCHAR 100)
├── settore (VARCHAR 100)
├── classe (VARCHAR 50)
├── id_sede (INT FK)
└── data_creazione (VARCHAR 19) → "13/09/2024 15:30:45"

educatori_pazienti:
├── id_associazione (INT AUTO_INCREMENT)
├── id_educatore (INT FK)
├── id_paziente (INT FK)
├── data_associazione (VARCHAR 10) → "13/09/2024"
├── is_attiva (BOOLEAN)
└── note (TEXT)

categorie_esercizi:
├── id_categoria (INT AUTO_INCREMENT)
├── nome_categoria (VARCHAR 100 NOT NULL)
├── descrizione_categoria (VARCHAR 255 NOT NULL)
├── note_categoria (VARCHAR 255)
└── link (VARCHAR 255) → "/training_cognitivo/[categoria_nome]/"

esercizi:
├── id_esercizio (INT AUTO_INCREMENT)
├── id_categoria (INT FK REFERENCES categorie_esercizi)
├── nome_esercizio (VARCHAR 150 NOT NULL)
├── descrizione_esercizio (TEXT NOT NULL)
├── data_creazione (VARCHAR 19)
├── stato_esercizio (ENUM: attivo/sospeso/archiviato)
└── link (VARCHAR 255) → "/training_cognitivo/[categoria]/[esercizio]/"

log_accessi:
├── id_log (INT AUTO_INCREMENT)
├── username (VARCHAR 255)
├── esito (ENUM: successo/fallimento)
├── indirizzo_ip (VARCHAR 45)
├── user_agent (TEXT)
└── timestamp_accesso (VARCHAR 19) → "13/09/2024 15:30:45"
```

### Configurazione Connessione
- **Host**: 31.11.39.242
- **Username**: Sql1073852
- **Password**: 5k58326940
- **Database**: Sql1073852_1

## 🔧 API Endpoints Principali

### Sistema Autenticazione
- `api/auth_login.php` - Login con redirect automatico per ruolo
- `api/auth_registrazioni.php` - CRUD completo utenti (solo admin/sviluppatore)

### Gestione Sistema
- `api/api_sedi.php` - CRUD sedi con associazioni utenti
- `api/api_settori_classi.php` - Gestione settori e classi
- `api/educatori_pazienti.php` - Associazioni educatori-pazienti

### Training Cognitivo (Auto-Generazione)
- `api/api_categorie_esercizi.php` - CRUD categorie + auto-gen cartelle
- `api/api_esercizi.php` - CRUD esercizi + auto-gen app Flutter PWA

### Agenda Flutter (Web Support)
- `agenda/web/api/save_data.php` - Persistenza dati JSON cross-platform
- `agenda/web/api/upload_image.php` - Upload immagini (max 5MB, JPG/PNG/GIF/WebP)

## 🌐 Deployment su Aruba

### Credenziali FTP
- **Host**: ftp.assistivetech.it
- **Username**: 7985805@aruba.it
- **Password**: 67XV57wk4R (o Filohori33!)
- **Porta**: 21

### Procedura Deployment
1. **Configurare filtro FTP** in pannello Aruba (Sicurezza → Limita accesso FTP)
2. **Upload file** via FTP mantenendo struttura directory
3. **Eseguire script SQL** su http://mysql.aruba.it (in ordine):
   - `create_table_sedi.sql` - Crea tabella sedi
   - `update_table_educatori.sql` - Aggiorna tabella educatori
   - `create_table_pazienti.sql` - Crea tabella pazienti
   - `add_id_sede_to_tables.sql` - Aggiunge foreign key sedi
   - `add_developer_role.sql` - Aggiunge ruolo sviluppatore e converte account
   - `insert_existing_users.sql` - Migra utenti esistenti
   - `add_link_fields.sql` - Aggiunge campi link a categorie ed esercizi
4. **Test funzionalità** su URL produzione

### URL Finali
- **Homepage**: https://assistivetech.it/
- **Login**: https://assistivetech.it/login.html
- **Admin**: https://assistivetech.it/admin/
- **Dashboard**: https://assistivetech.it/dashboard.html
- **Agenda**: https://assistivetech.it/agenda/
- **Training Cognitivo**: https://assistivetech.it/training_cognitivo/

## 🔧 Tecnologie Utilizzate

### Frontend
- **HTML5/CSS3/JavaScript** - Sito principale
- **Bootstrap 5** - Framework UI responsive
- **Bootstrap Icons** - Iconografia
- **Flutter/Dart** - App agenda PWA

### Backend
- **PHP 8.x** - API server-side
- **MySQL 8.x** - Database relazionale
- **Apache** - Server web

### Sicurezza
- **Validazione input** completa
- **Headers sicurezza** (X-Frame-Options, XSS-Protection)
- **Log accessi** e operazioni
- **Protezione file** sensibili via .htaccess
- **Protezione ruolo sviluppatore**: Account protetto, invisibile e non modificabile

## 📱 App Agenda Flutter (Sottosistema)

L'app agenda è documentata separatamente in `agenda/CLAUDE.md` e include:

### Architettura Tecnica
- **Gestione stato**: Riverpod con flutter_riverpod (pattern AutoDisposeAsyncNotifier)
- **Modelli dati**: Freezed per classi immutabili con serializzazione JSON
- **Storage cross-platform**: SQLite (sqflite) per mobile, Hive per web + API PHP per persistenza
- **Integrazione API**: Client HTTP per pittogrammi ARASAAC con caching
- **TTS**: Flutter Text-to-Speech con velocità configurabile
- **PWA**: Manifest completo, modalità standalone, icone e configurazione offline

### Provider Principali (Riverpod)
- `utentiProvider` - CRUD utenti con validazione duplicati
- `utenteSelezionatoProvider` - Utente attualmente selezionato
- `agendeProvider` - Gestione agende per utente selezionato
- `agendaSelezionataProvider` - Agenda correntemente attiva
- `attivitaPerAgendaProvider` - CRUD attività con riordinamento
- `arasaacSearchProvider` - Ricerca pittogrammi API ARASAAC
- `ttsProvider` - Text-to-speech e configurazione velocità

### Struttura Modelli (Freezed)
- **Utente**: Multi-utente con supporto soft delete
- **Agenda**: Collezioni attività per utente con cascade delete
- **Attivita**: Modello core con pittogramma/foto, posizione, TTS

### Deployment Web (Aruba)
- **URL produzione**: https://assistivetech.it/agenda/
- **Storage**: Hive locale + sync server via `web/api/save_data.php`
- **Upload immagini**: `web/api/upload_image.php` (max 5MB, JPG/PNG/GIF/WebP)
- **Path assets**: `/agenda/assets/images/` per immagini utente

## 🛠️ Manutenzione e Troubleshooting

### Problemi Comuni
1. **Errore FTP 530**: Configurare filtro accessi FTP in pannello Aruba
2. **CORS API**: Verificare headers Access-Control-Allow-Origin
3. **Date formato**: Sistema usa formato italiano dd/mm/yyyy
4. **Password**: Attualmente in chiaro per compatibilità

### File di Configurazione
- `.htaccess` - Configurazione Apache, sicurezza, compressione, routing
- `DEPLOYMENT_GUIDE.md` - Guida step-by-step deployment
- `README.md` - Documentazione completa progetto
- `pre_deployment_check.html` - Tool verifica pre-deployment
- `agenda/pubspec.yaml` - Dipendenze Flutter e configurazione app
- `agenda/web/manifest.json` - Configurazione PWA
- `agenda/analysis_options.yaml` - Regole linting Dart
- `.vscode/ftp-sync.json` - Configurazione sync FTP VS Code

### Log e Monitoraggio
- **Log accessi**: `/logs/access.log`
- **Log registrazioni**: `/logs/registrations.log`
- **Database log**: Tabella `log_accessi`

## 🔄 Flusso di Autenticazione

1. **Utente accede** a `/login.html`
2. **Credenziali inviate** a `api/auth_login.php`
3. **Verifica database** tabella `registrazioni`
4. **Redirect basato su ruolo**:
   - Amministratore → `/admin/`
   - Educatore → `/dashboard.html`
   - Paziente → `/agenda/`
5. **Sessione salvata** in localStorage browser

## 🧠 Sistema Training Cognitivo - AUTO-GENERAZIONE AVANZATA

### 🚀 Panoramica Sistema (Implementato 20/09/2025)

Il **Sistema Training Cognitivo** è una piattaforma avanzata che auto-genera **app Flutter PWA complete** per ogni esercizio cognitivo. Quando si crea una nuova categoria o esercizio dal pannello admin, il sistema:

1. **Auto-genera cartelle** con struttura completa
2. **Crea app Flutter** pronte all'uso con PWA
3. **Configura database** con link automatici
4. **Genera interfacce** responsive per navigazione

### 🏗️ Architettura Auto-Generazione

#### Creazione Categoria
```
Admin crea "Memoria Visiva" →
├── Genera cartella: /training_cognitivo/memoria_visiva/
├── Crea index.html con template Bootstrap
├── Aggiorna database: link = "/training_cognitivo/memoria_visiva/"
└── Log operazione: logs/categorie_esercizi.log
```

#### Creazione Esercizio
```
Admin crea "Sequenze Colori" in categoria "Memoria Visiva" →
├── Genera cartella: /training_cognitivo/memoria_visiva/sequenze_colori/
├── Crea struttura Flutter completa:
│   ├── pubspec.yaml (dipendenze Flutter)
│   ├── lib/main.dart (app principale)
│   ├── web/index.html (PWA entry point)
│   ├── web/manifest.json (configurazione PWA)
│   └── assets/images/ (risorse)
├── Aggiorna database: link = "/training_cognitivo/memoria_visiva/sequenze_colori/"
└── Log operazione: logs/esercizi.log
```

### 📱 Template Flutter Auto-Generati

#### Struttura App PWA Completa
Ogni esercizio viene auto-generato con:

- **pubspec.yaml**: Configurazione dipendenze Flutter
- **lib/main.dart**: App Material Design responsive
- **web/index.html**: Entry point PWA ottimizzato
- **web/manifest.json**: Configurazione installazione PWA
- **assets/**: Directory per immagini e risorse

#### Caratteristiche Template
- **PWA Ready**: Installabile come app nativa
- **Responsive**: Adatta a desktop, tablet, smartphone
- **Material Design**: UI coerente con sistema AssistiveTech
- **Offline Capable**: Service worker configurato
- **Cross-Platform**: Funziona su iOS, Android, Web

### 🗄️ Database con Link Automatici

#### Tabelle Aggiornate
```sql
categorie_esercizi:
├── id_categoria (INT AUTO_INCREMENT)
├── nome_categoria (VARCHAR 100 NOT NULL)
├── descrizione_categoria (VARCHAR 255 NOT NULL)
├── note_categoria (VARCHAR 255)
└── link (VARCHAR 255) → Auto-generato: "/training_cognitivo/[categoria_sanitizzata]/"

esercizi:
├── id_esercizio (INT AUTO_INCREMENT)
├── id_categoria (INT FK REFERENCES categorie_esercizi)
├── nome_esercizio (VARCHAR 150 NOT NULL)
├── descrizione_esercizio (TEXT NOT NULL)
├── data_creazione (VARCHAR 19)
├── stato_esercizio (ENUM: attivo/sospeso/archiviato)
└── link (VARCHAR 255) → Auto-generato: "/training_cognitivo/[categoria]/[esercizio]/"
```

#### Indicizzazione Performance
```sql
CREATE INDEX `idx_categorie_link` ON `categorie_esercizi` (`link`);
CREATE INDEX `idx_esercizi_link` ON `esercizi` (`link`);
```

### 🎯 Interfacce Utente

#### Pagina Master (/training_cognitivo/)
- **Sidebar Categorie**: Lista dinamica da database
- **Area Esercizi**: Visualizzazione per categoria selezionata
- **Design Responsive**: Bootstrap 5 con animazioni
- **Loading States**: Spinner durante caricamento API

#### Admin Panel Aggiornato
- **Colonne Link**: Visualizza link generati per categorie ed esercizi
- **Bottoni Azione**: Apertura diretta app generate in nuova tab
- **Status Visivo**: Badge colorati per stati (attivo/sospeso/archiviato)

### 🔧 API Enhancement

#### Categorie con Auto-Generazione
```php
POST api/api_categorie_esercizi.php (action: create_categoria)
├── Validazione input e duplicati
├── Sanitizzazione nome per cartella (caratteri speciali → underscore)
├── Creazione cartella: ../training_cognitivo/[nome_sanitizzato]/
├── Generazione index.html con template Bootstrap
├── Inserimento database con link auto-generato
└── Response con dettagli cartella creata
```

#### Esercizi con Flutter Template
```php
POST api/api_esercizi.php (action: create_esercizio)
├── Validazione input e categoria esistente
├── Sanitizzazione nome per cartella Flutter
├── Creazione struttura completa:
│   ├── createFlutterExerciseStructure()
│   ├── createPubspecTemplate()
│   ├── createMainDartTemplate()
│   ├── createWebIndexTemplate()
│   ├── createManifestTemplate()
│   └── createAnalysisOptionsTemplate()
├── Inserimento database con link auto-generato
└── Response con dettagli app Flutter creata
```

### 🎮 Flusso Utilizzo Completo

1. **Sviluppatore**: Accede admin panel → Crea categoria "Attenzione"
2. **Sistema**: Auto-genera `/training_cognitivo/attenzione/` + index.html
3. **Sviluppatore**: Crea esercizio "Focus Visivo" in categoria "Attenzione"
4. **Sistema**: Auto-genera app Flutter completa in `/training_cognitivo/attenzione/focus_visivo/`
5. **Educatori**: Navigano `/training_cognitivo/` → Selezionano categoria → Vedono esercizi
6. **Educatori**: Cliccano "Focus Visivo" → Lanciano app Flutter PWA
7. **Pazienti**: Utilizzano app installata come PWA nativa su dispositivi

### 💡 Vantaggi Sistema

#### Per Sviluppatori
- **Zero setup manuale**: Tutto auto-generato istantaneamente
- **Template standardizzati**: Codice coerente e manutenibile
- **Scaling automatico**: Nuovi esercizi senza effort tecnico

#### Per Educatori
- **Interfaccia unificata**: Navigazione intuitiva categorie/esercizi
- **Deploy immediato**: Nuovi esercizi subito disponibili
- **Cross-device**: Stesso esercizio su desktop, tablet, mobile

#### Per Pazienti
- **PWA Native**: Installazione come app reale
- **Offline Access**: Funzionamento senza internet
- **Performance**: Velocità nativa Flutter

### 📋 Deployment Training Cognitivo

#### Script SQL Richiesto
```sql
-- Eseguire su http://mysql.aruba.it
-- File: script_sql/add_link_fields.sql
ALTER TABLE `categorie_esercizi` ADD COLUMN `link` varchar(255);
ALTER TABLE `esercizi` ADD COLUMN `link` varchar(255);
CREATE INDEX `idx_categorie_link` ON `categorie_esercizi` (`link`);
CREATE INDEX `idx_esercizi_link` ON `esercizi` (`link`);
```

#### File da Uploadare
- `/api/api_categorie_esercizi.php` - Enhanced con auto-gen cartelle
- `/api/api_esercizi.php` - Enhanced con auto-gen Flutter
- `/training_cognitivo/index.html` - Pagina master navigazione
- `/admin/index.html` - Aggiornato con colonne link
- `/script_sql/add_link_fields.sql` - Script database

✅ **Sistema pronto per produzione e scaling infinito!**

## 🎯 Sviluppo Futuro

### Roadmap Tecnica
- **Password hashing** con bcrypt
- **Sistema sessioni** server-side
- **API REST** complete con JWT
- **Dashboard analytics** avanzate
- **Notifiche push** PWA

## 🎯 Note di Sviluppo Importanti

### Convenzioni Codice
- **Lingua**: Tutto in italiano (codice, commenti, UI, documentazione)
- **Frontend**: Bootstrap 5 per sito principale, Material Design per Flutter
- **Backend**: PHP moderno con PDO, validazione input completa
- **Database**: Date in formato italiano (dd/mm/yyyy), password ancora in chiaro

### Workflow di Sviluppo
1. **Modifiche locali** con test in browser/Flutter
2. **Build Flutter** se necessario: `flutter build web`
3. **Deploy via FTP** mantenendo struttura directory
4. **Script SQL** su http://mysql.aruba.it se richiesti
5. **Test produzione** sugli URL finali

### Troubleshooting Comune
- **Errore FTP 530**: Configurare filtro accessi FTP in pannello Aruba
- **CORS API**: Verificare headers Access-Control-Allow-Origin in file PHP
- **Flutter build errors**: Eseguire `dart run build_runner build --delete-conflicting-outputs`
- **Database errors**: Verificare date formato italiano e foreign key constraints