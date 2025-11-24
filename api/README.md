# AssistiveTech.it - Sistema Completo

Sistema completo per la gestione di assistive technology con autenticazione multi-ruolo, gestione sedi multi-location e applicazione agenda con pittogrammi ARASAAC.

## 🎯 Architettura del Sistema

```
AssistiveTech.it
├── 🏠 Sito Principale (Root)
│   ├── Homepage con presentazione
│   ├── Sistema autenticazione completo multi-ruolo
│   ├── Dashboard educatori personalizzata
│   ├── Pannello amministrativo con gestione sedi
│   └── API complete per gestione utenti/sedi
│
└── 📱 App Agenda (/agenda/)
    ├── PWA Flutter per gestione pittogrammi ARASAAC
    ├── Text-to-Speech integrato
    ├── Supporto multi-utente
    └── Storage cross-platform
```

## 🚀 Componenti Principali

### 1. Sito Web Principale
- **Homepage** (`index.html`) - Landing page professionale con Bootstrap 5
- **Login** (`login.html`) - Autenticazione con redirect basato su ruolo
- **Registrazione** (`register.html`) - Creazione nuovi utenti (admin/educatori)
- **Dashboard** (`dashboard.html`) - Pannello personalizzato per educatori
- **Admin Panel** (`admin/`) - Gestione completa utenti e sedi

### 2. Sistema Autenticazione e Gestione
- **Database MySQL** - Tabelle per utenti, sedi, associazioni, log, sessioni
- **API PHP** - Endpoints per login, registrazione, gestione utenti e sedi
- **Ruoli Utente**:
  - 🔴 **Amministratore** - Accesso completo: utenti, sedi, statistiche
  - 🟡 **Educatore** - Gestisce pazienti assegnati, associato a sede/settore/classe
  - 🟢 **Paziente** - Utilizza agenda pittogrammi, associato a sede/settore/classe

### 2.1. Gestione Sedi Multi-Location
- **Creazione sedi** - Nome, indirizzo, città, contatti
- **Associazione utenti** - Ogni educatore/paziente appartiene a una sede
- **Gestione CRUD** - Create, Read, Update per sedi attive/sospese

### 3. App Agenda Flutter
- **PWA completa** con supporto offline
- **Pittogrammi ARASAAC** - Integrazione API per simboli accessibilità
- **Text-to-Speech** - Pronuncia frasi e parole
- **Multi-utente** - Gestione separata per ogni paziente
- **Cross-platform** - Web + mobile

## 🔧 Tecnologie Utilizzate

### Frontend
- **HTML5/CSS3/JavaScript** - Sito principale
- **Bootstrap 5** - Framework CSS responsive
- **Bootstrap Icons** - Iconografia
- **Flutter** - App agenda (Dart)

### Backend
- **PHP** - API e gestione server
- **MySQL** - Database principale
- **Apache** - Server web con .htaccess

### DevOps
- **Aruba Hosting** - Deployment produzione
- **FTP** - Upload file
- **Git** - Version control (locale)

## 📱 Utilizzo del Sistema

### Per Amministratori
1. Login con credenziali admin
2. Accesso al pannello amministrativo completo
3. **Gestione Utenti**: Creazione, modifica, eliminazione con assegnazione sede
4. **Gestione Sedi**: Creazione/modifica sedi con dati completi
5. **Statistiche Sistema**: Panoramica generale utenti per ruolo

### Per Educatori
1. Login con credenziali educatore
2. Dashboard con statistiche personali
3. Gestione pazienti assegnati
4. Accesso all'agenda per creare sequenze

### Per Pazienti
1. Accesso diretto all'agenda (senza login)
2. Selezione del proprio profilo
3. Visualizzazione sequenze create
4. Interazione con pittogrammi e TTS

## 🗄️ Database Schema

### Tabelle Principali

#### `registrazioni` - Autenticazione Base
```sql
- id_registrazione (PK)
- nome_registrazione, cognome_registrazione
- username_registrazione (UNIQUE)
- password_registrazione
- ruolo_registrazione (amministratore/educatore/paziente)
- data_registrazione, ultimo_accesso
- stato_account (attivo/sospeso/eliminato)
```

#### `sedi` - Gestione Multi-Location
```sql
- id_sede (PK)
- nome_sede (UNIQUE)
- indirizzo, citta, provincia, cap
- telefono, email
- stato_sede (attiva/sospesa/chiusa)
- data_creazione
```

#### `educatori` - Profili Educatori
```sql
- id_educatore (PK)
- id_registrazione (FK UNIQUE)
- nome, cognome, settore, classe
- id_sede (FK)
- telefono, email_contatto
- note_professionali
- stato_educatore, data_creazione
```

#### `pazienti` - Profili Pazienti
```sql
- id_paziente (PK)
- id_registrazione (FK UNIQUE)
- nome, cognome, settore, classe
- id_sede (FK)
- data_creazione
```

#### `educatori_pazienti` - Associazioni
```sql
- id_associazione (PK)
- id_educatore (FK)
- id_paziente (FK)
- data_associazione
- is_attiva, note
```

## 📁 Struttura File

```
/assistivetech.it/
├── index.html                 # Homepage principale
├── login.html                 # Pagina login
├── register.html              # Pagina registrazione
├── dashboard.html             # Dashboard educatori
├── .htaccess                  # Configurazione Apache
├── api/                       # API PHP Complete
│   ├── auth_login.php              # Endpoint autenticazione
│   ├── auth_registrazioni.php      # CRUD utenti con sedi
│   ├── api_sedi.php               # API gestione sedi
│   ├── create_database.sql        # Schema database base
│   ├── create_table_sedi.sql      # Script creazione sedi
│   ├── create_table_pazienti.sql  # Script creazione pazienti
│   ├── update_table_educatori.sql # Aggiornamento educatori
│   ├── add_id_sede_to_tables.sql  # Aggiunta foreign key sedi
│   └── insert_existing_users.sql  # Migrazione utenti esistenti
├── admin/                     # Pannello amministrativo
│   └── index.html
├── agenda/                    # App Flutter PWA
│   ├── lib/                   # Codice Dart
│   ├── web/                   # Build web
│   └── build/                 # Output build
└── logs/                      # Log sistema (creata dinamicamente)
```

## 🌐 Deployment su Aruba

### Credenziali Server
- **FTP**: ftp.assistivetech.it
- **Database**: 31.11.39.242
- **User**: Sql1073852
- **Database**: Sql1073852_1

### Procedura Deploy
1. **Upload file** via FTP mantenendo struttura directory
2. **Esecuzione script SQL** (in ordine specifico):
   - `create_table_sedi.sql` - Crea tabella sedi con sede principale
   - `update_table_educatori.sql` - Aggiorna struttura educatori
   - `create_table_pazienti.sql` - Crea tabella pazienti
   - `add_id_sede_to_tables.sql` - Aggiunge foreign key verso sedi
   - `insert_existing_users.sql` - Migra utenti esistenti nelle nuove tabelle
3. **Test funzionalità**:
   - Login multi-ruolo
   - Gestione sedi (creazione/modifica)
   - Registrazione utenti con associazione sede
   - App Flutter agenda
4. **Verifica integrità database** - Controllo foreign key e associazioni

### URL Finali
- **Homepage**: https://assistivetech.it/
- **Login**: https://assistivetech.it/login.html
- **Admin**: https://assistivetech.it/admin/
- **Agenda**: https://assistivetech.it/agenda/

## 🔐 Sicurezza

### Misure Implementate
- Validazione input completa
- Protezione XSS/CSRF
- Log accessi e operazioni
- File sensibili bloccati (.htaccess)
- Headers sicurezza (X-Frame-Options, etc.)

### Credenziali Default
- **Admin**: marchettisoft@gmail.com / Filohori11!
- **Educatore**: maria.rossi@example.com / educatore123
- **Paziente**: luca.bianchi@example.com / paziente123

## 🚀 Funzionalità Future

### In Roadmap
- **Hash password sicuro** (bcrypt per sicurezza avanzata)
- **Sistema sessioni server-side** (JWT token)
- **API REST complete** con versioning
- **Dashboard analytics** con grafici e metriche avanzate
- **Reporting sistema** per esportazione dati sedi/utenti
- **Notifiche push PWA** per comunicazioni
- **Backup automatico** database e log
- **Multi-tenancy** per istanze separate per organizzazione

## 📞 Supporto

Per supporto tecnico:
- **Email**: support@assistivetech.it
- **Telefono**: +39 123 456 7890
- **Developer**: Fabio Marchetti

## 📜 License

Sistema proprietario sviluppato per AssistiveTech.it
© 2024 AssistiveTech.it - Tutti i diritti riservati