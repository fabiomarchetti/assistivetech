# Guida al Deployment su Server Aruba

## Configurazione Ambiente
- Il backend PHP usa `api/config.php` con auto-rilevamento locale/produzione.
- Per override in produzione, crea `api/config.override.php` (non versionato) con credenziali Aruba e opzionale `APP_TZ`.
- Timezone di default: Europe/Rome. Puoi impostare `APP_TZ` via env o override.

## Files da Caricare

### 1. Root Directory (/)
- `index.html` - Pagina principale
- `login.html` - Pagina di login
- `register.html` - Pagina di registrazione
- `dashboard.html` - Dashboard educatori
- `style.css` - CSS personalizzato (se presente)

### 2. Directory /api/
- `config.php` (auto ambiente) e opzionale `config.override.php`
- API PHP (tutte richiedono `config.php` e usano `getDbConnection()`)
- Script SQL di creazione/migrazione (`create_table_*`, `DEPLOY_*.sql`)

### 3. Directory /admin/
- `index.html` - Pannello amministrativo

### 4. Directory /agenda/ (intera cartella)
- Tutta la cartella agenda con l'app Flutter PWA
- Mantenere la struttura originale

## Procedura di Deployment

### Step 1: Upload Files via FTP
```bash
# Connettersi via FTP al server
# Caricare tutti i files mantenendo la struttura directory
```

### Step 2: Configurazione Database
1. Accedi al pannello MySQL di Aruba
2. Esegui `api/create_database.sql` o `api/DEPLOY_COMPLETE.sql`
3. Opzionale: applica fix/migrazioni `FIX_*.sql` in ordine se necessario
4. Crea `api/config.override.php` con:
```php
<?php
$host='31.11.39.242';
$username='SqlXXXX';
$password='********';
$database='SqlXXXX_1';
$port=3306;
define('APP_TZ','Europe/Rome');
```

### Step 3: Test delle Funzionalità
1. **Test Homepage**: `https://assistivetech.it/`
2. **Test Login**: `https://assistivetech.it/login.html`
   - Admin: marchettisoft@gmail.com / Filohori11!
3. **Test Registrazione**: `https://assistivetech.it/register.html`
4. **Test Agenda**: `https://assistivetech.it/agenda/`
5. **Test Admin Panel**: `https://assistivetech.it/admin/`
6. **Healthcheck API**: `https://assistivetech.it/api/health.php` (verifica connessione DB e timezone)

### Step 4: Verifiche Finali
- [ ] Homepage carica correttamente
- [ ] Login funziona con credenziali admin
- [ ] Registrazione nuovi utenti funziona
- [ ] Dashboard educatori accessibile
- [ ] Agenda Flutter PWA funziona
- [ ] Pannello admin gestisce utenti
- [ ] API rispondono correttamente

## Struttura Finale su Server
```
assistivetech.it/
├── index.html              # Homepage principale
├── login.html              # Pagina login
├── register.html           # Pagina registrazione
├── dashboard.html          # Dashboard educatori
├── api/                    # API PHP
│   ├── auth_login.php
│   ├── auth_registrazioni.php
│   └── create_database.sql
├── admin/                  # Pannello amministrativo
│   └── index.html
└── agenda/                 # App Flutter PWA
    ├── lib/
    ├── web/
    └── pubspec.yaml
```

## Note Importanti
- Le API usano `config.php`; evitare credenziali hardcoded.
- Attiva hashing password con `password_hash()` (to-do security).
- Directory `/logs/` deve esistere in produzione e avere permessi di scrittura (644/755).
- CORS aperto per sviluppo; restringere in produzione se necessario.
- Usa `api/config.override.php` (basato su `config.override.php.example`) per configurare Aruba senza toccare i sorgenti.

## Credenziali di Test
- **Admin**: marchettisoft@gmail.com / Filohori11!
- **Educatore**: maria.rossi@example.com / educatore123
- **Paziente**: luca.bianchi@example.com / paziente123