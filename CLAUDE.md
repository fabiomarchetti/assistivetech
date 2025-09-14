
# CLAUDE.md

Questo file fornisce indicazioni a Claude Code (claude.ai/code) quando lavora con il codice in questa repository.

## 🌟 Panoramica del Progetto

**AssistiveTech.it** è un sistema completo per gestione assistive technology che include:
- **Sito web principale** con sistema autenticazione multi-ruolo
- **App Agenda Flutter PWA** per gestione pittogrammi ARASAAC
- **Sistema di amministrazione** completo per gestione utenti, sedi e ruoli
- **Gestione sedi** multi-location con associazioni utenti

Il progetto è deployato su hosting Aruba (assistivetech.it) con database MySQL e supporto PHP.

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
│   │   ├── create_database.sql     # Schema database principale
│   │   ├── create_table_*.sql      # Script creazione tabelle
│   │   └── insert_existing_users.sql # Migrazione dati esistenti
│   └── admin/                 # Pannello amministrativo
│       └── index.html         # Gestione utenti admin
│
└── 📱 APP AGENDA (Sottodirectory /agenda/)
    ├── lib/                   # Codice Dart Flutter
    ├── web/                   # Build web e API agenda
    ├── pubspec.yaml          # Dipendenze Flutter
    └── CLAUDE.md             # Documentazione specifica Flutter
```

## 👥 Sistema Multi-Ruolo

### 🔴 Amministratore
- **Accesso**: Pannello admin completo (`/admin/`)
- **Privilegi**: Gestione CRUD completa utenti, sedi, statistiche sistema
- **Funzioni**: Creazione/modifica sedi, associazione utenti-sedi, panoramica sistema
- **Credenziali**: marchettisoft@gmail.com / Filohori11!

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
├── ruolo_registrazione (ENUM: amministratore/educatore/paziente)
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

## 🚀 Comandi di Sviluppo

### Setup Iniziale
```bash
# Clonare/posizionarsi nella directory principale
cd /path/to/assistivetech.it

# Per sviluppo Flutter (app agenda)
cd agenda/
flutter pub get
flutter run -d web-server --web-port=8082
```

### Sviluppo Sito Principale
- **Test locale**: Aprire file HTML direttamente nel browser
- **Server locale**: Utilizzare live server VS Code o simili
- **API test**: Configurare proxy CORS per chiamate API

### Sviluppo App Flutter
```bash
cd agenda/
flutter pub get                    # Installa dipendenze
flutter run -d web-server         # Server sviluppo locale
flutter build web                 # Build per produzione
dart run build_runner build       # Genera codice Freezed
```

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
   - `insert_existing_users.sql` - Migra utenti esistenti
4. **Test funzionalità** su URL produzione

### URL Finali
- **Homepage**: https://assistivetech.it/
- **Login**: https://assistivetech.it/login.html
- **Admin**: https://assistivetech.it/admin/
- **Dashboard**: https://assistivetech.it/dashboard.html
- **Agenda**: https://assistivetech.it/agenda/

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

## 📱 App Agenda Flutter (Sottosistema)

L'app agenda è documentata separatamente in `agenda/CLAUDE.md` e include:
- **Gestione stato**: Riverpod con AutoDisposeAsyncNotifier
- **Modelli dati**: Freezed per classi immutabili
- **Storage**: Cross-platform (SQLite mobile, Hive + API web)
- **Integrazione**: API ARASAAC per pittogrammi
- **TTS**: Flutter Text-to-Speech
- **PWA**: Manifest completo, modalità standalone

## 🛠️ Manutenzione e Troubleshooting

### Problemi Comuni
1. **Errore FTP 530**: Configurare filtro accessi FTP in pannello Aruba
2. **CORS API**: Verificare headers Access-Control-Allow-Origin
3. **Date formato**: Sistema usa formato italiano dd/mm/yyyy
4. **Password**: Attualmente in chiaro per compatibilità

### File di Configurazione
- `.htaccess` - Configurazione Apache, sicurezza, compressione
- `DEPLOYMENT_GUIDE.md` - Guida step-by-step deployment
- `README.md` - Documentazione completa progetto
- `pre_deployment_check.html` - Tool verifica pre-deployment

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

## 🎯 Sviluppo Futuro

### Roadmap Tecnica
- **Password hashing** con bcrypt
- **Sistema sessioni** server-side
- **API REST** complete con JWT
- **Dashboard analytics** avanzate
- **Notifiche push** PWA

### Note di Sviluppo
- **Lingua**: Tutto in italiano (codice, commenti, UI)
- **Standard**: Bootstrap per UI, convenzioni PHP moderne
- **Testing**: Verificare sempre funzionalità prima deployment
- **Backup**: Backup database prima modifiche strutturali

## 📞 Supporto

- **Developer**: Fabio Marchetti
- **Email**: marchettisoft@gmail.com
- **Sistema**: Pronto per produzione e manutenzione