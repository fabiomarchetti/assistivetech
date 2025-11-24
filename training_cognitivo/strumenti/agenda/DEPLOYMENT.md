# DEPLOYMENT GUIDE - Agenda Strumenti PWA

## 🚀 Pre-Deployment Checklist

- [ ] Tutti i test in TESTING.md superati
- [ ] Console JavaScript pulita (no errors)
- [ ] Service Worker caching verificato
- [ ] localStorage test completati
- [ ] TTS funzionante su tutti i browser target
- [ ] Icons PWA presenti (192x192, 512x512)
- [ ] manifest.json validato
- [ ] API endpoints verificati
- [ ] Database backup creato
- [ ] SSL/HTTPS configurato

---

## 1. AMBIENTE LOCALE → STAGING

### 1.1 Preparazione File

```bash
# Directory struttura FINALE
agenda/
├── index.html                 # Redirect a agenda.html
├── agenda.html               # App paziente
├── gestione.html             # App educatore
├── manifest.json             # PWA manifest
├── service-worker.js         # Service Worker
├── README.md                 # Documentazione
├── TESTING.md               # Guida test
├── API_REFERENCE.md         # API docs
├── DEPLOYMENT.md            # Questo file
├── css/
│   ├── agenda.css           # Stili paziente
│   └── educatore.css        # Stili educatore
├── js/
│   ├── agenda-app.js        # App paziente
│   ├── educatore-app.js     # App educatore
│   ├── api-client.js        # API client
│   ├── arasaac-service.js   # ARASAAC integration
│   ├── youtube-service.js   # YouTube integration
│   ├── swipe-handler.js     # Touch gestures
│   ├── db-manager.js        # Database management
│   └── tts-service.js       # Text-to-speech
├── assets/
│   ├── icons/
│   │   ├── icon-192.png     # PWA icon piccola
│   │   └── icon-512.png     # PWA icon grande
│   └── images/              # Immagini aggiuntive (opzionale)
└── api/                      # Opzionale: API proxy
    └── config.php           # Configurazione API
```

### 1.2 Cleanup Progetto

```bash
# Rimuovere file di test/debug
rm -rf:
  - *.log
  - .env.local
  - node_modules/            (se presente)
  - /uploads/temp/*          (file temporanei)

# Verificare che nessun hardcoded credentials
grep -r "localhost" js/ css/ html/
grep -r "password" js/ api/
grep -r "token" js/ api/
```

### 1.3 Ottimizzazione File

```bash
# Minimizzare CSS (opzionale per produzione)
# Usando: cssnano, clean-css, o online minifier

# Minimizzare JS (opzionale)
# Usando: uglify-js, terser, o webpack

# Comprimere immagini
# Usando: TinyPNG, ImageOptim, o pngquant
pngquant 256 icon-512.png -o icon-512-opt.png
```

### 1.4 Configurazione API URL

**In `js/api-client.js`, verificare il basePath:**

```javascript
const basePath = window.location.pathname.includes('/Assistivetech/')
    ? '/Assistivetech'
    : '';

// Per STAGING/PRODUCTION, assicurare che sia corretto
// Opzione 1: Hardcode per produzione
const API_BASE = 'https://tuodominio.it/Assistivetech/api';

// Opzione 2: Rilevare automaticamente
const API_BASE = `${window.location.origin}/Assistivetech/api`;
```

---

## 2. STAGING → PRODUCTION (Aruba)

### 2.1 Preparazione Hosting Aruba

#### Accesso FTP
```bash
Host: ftp.tuodominio.it
Username: nomeutente
Password: password
Cartella radice: /http.www/                    # O cartella configurata
```

#### Struttura Directory Aruba
```
/http.www/
├── index.html                     # Home site
├── Assistivetech/
│   ├── api/
│   │   ├── agende.php            # Endpoint API
│   │   ├── items.php
│   │   ├── api_pazienti.php
│   │   └── config.php            # Config database
│   ├── training_cognitivo/
│   │   └── strumenti/
│   │       └── agenda/           # ← COPIA QUI
│   │           ├── agenda.html
│   │           ├── gestione.html
│   │           ├── service-worker.js
│   │           ├── manifest.json
│   │           ├── css/
│   │           ├── js/
│   │           ├── assets/
│   │           └── [altri file]
```

### 2.2 Upload FTP

```bash
# Tool: FileZilla, WinSCP, Cyber Duck
1. Connetti a FTP Aruba
2. Naviga a /Assistivetech/training_cognitivo/strumenti/
3. Crea cartella "agenda" se non esiste
4. Carica TUTTI i file:
   - Preserva struttura directory
   - Codifica UTF-8 per file di testo
   - Modo binario per immagini (.png)
5. Verifica upload completato
6. Controlla permessi file (644 per file, 755 per dir)
```

### 2.3 Verificare Setup Aruba

#### SSH Access (se disponibile)
```bash
ssh tuo_username@server_aruba
cd /http.www/Assistivetech/training_cognitivo/strumenti/agenda

# Verificare file
ls -la
cat manifest.json | head -5

# Verificare permessi
chmod 644 *.html *.json *.js
chmod 755 css/ js/ assets/
```

#### Configurazione Database

**File: `/Assistivetech/api/config.php`**
```php
<?php
// Configurazione PRODUZIONE Aruba

define('DB_HOST', 'dbXXXX.aruba.it');  // Host fornito da Aruba
define('DB_NAME', 'tuo_database');
define('DB_USER', 'tuo_user');
define('DB_PASS', 'tua_password');

// Verificare che il database abbia tabelle:
// - agende_strumenti
// - agende_items
// (Vedere schema in API_REFERENCE.md)
```

### 2.4 Abilitare HTTPS

**Obbligatorio per:**
- Service Worker (richiede HTTPS)
- Web Speech API (alcuni browser)
- PWA Installation

#### Passaggi Aruba
1. Accedi a Pannello Controllo Aruba
2. Certificati SSL → Attiva HTTPS
3. Rinnova certificato Let's Encrypt (gratuito)
4. Reindirizza HTTP → HTTPS

**File: `.htaccess` (in `/http.www/`)**
```apache
# Forza HTTPS
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>

# Abilita compressione gzip
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
</IfModule>
```

### 2.5 Configurazione Service Worker

**Importante:** Service Worker richiede HTTPS

Verificare in browser (dopo HTTPS setup):
```
F12 → Application → Service Workers
Dovrebbe mostrare: "activated and running"
```

Se non funziona:
1. Cancella cache (Application → Clear storage)
2. Reload pagina
3. Controlla console per errori

---

## 3. VERIFICA POST-DEPLOYMENT

### 3.1 Test URL Produzione

```
✅ Paziente:  https://tuodominio.it/Assistivetech/training_cognitivo/strumenti/agenda/agenda.html
✅ Educatore: https://tuodominio.it/Assistivetech/training_cognitivo/strumenti/agenda/gestione.html
```

### 3.2 Checklist Funzionamento

```
□ Pagine HTML caricano senza errori
□ CSS caricato correttamente (colori, layout)
□ JavaScript non ha errori (Console F12)
□ Manifest.json accessibile
□ Icons PWA caricate
□ Service Worker registrato
□ API endpoints raggiungibili
□ Database pazienti carica
□ TTS funziona (testa pronuncia)
□ Slider TTS funzionano
□ localStorage persiste
□ Offline mode funziona
```

### 3.3 Test Performance

```bash
# Usando Google Lighthouse (F12 in Chrome)
1. Apri agenda.html
2. F12 → Lighthouse (o alt+cmd+i)
3. Esegui audit
4. Controlla:
   - Performance: > 80
   - Accessibility: > 80
   - Best Practices: > 80
   - SEO: > 80
   - PWA: ✅ Installabile
```

### 3.4 Test Browser

```
Testare su:
✅ Chrome/Chromium (ultimissima versione)
✅ Firefox (ultimissima)
✅ Safari (macOS/iOS)
✅ Edge (ultimissima)

Testare su Device:
✅ Desktop (1920x1080)
✅ Tablet (768px)
✅ Mobile (375px)
```

### 3.5 Monitoraggio Log

**File: `/Assistivetech/api/error_log.php`** (Creare se non esiste)

```php
<?php
// Log errori API
function logError($message, $context = []) {
    $log = [
        'timestamp' => date('Y-m-d H:i:s'),
        'message' => $message,
        'context' => $context,
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
        'ip' => $_SERVER['REMOTE_ADDR'] ?? ''
    ];

    file_put_contents(
        '/http.www/Assistivetech/api/logs/error.log',
        json_encode($log) . "\n",
        FILE_APPEND
    );
}
```

Controllare regolarmente:
```bash
tail -f /http.www/Assistivetech/api/logs/error.log
```

---

## 4. GESTIONE DATABASE

### 4.1 Backup Pre-Deployment

```bash
# SSH in Aruba
mysqldump -h dbXXXX.aruba.it -u user -p database > backup_prod_YYYY-MM-DD.sql

# Salvare localmente
scp user@aruba:/http.www/backup_prod_*.sql ./backups/
```

### 4.2 Migrazione Dati (se necessario)

```sql
-- Se agende_items NON ha colonna fraseVocale, aggiungere:
ALTER TABLE agende_items ADD COLUMN fraseVocale TEXT NULL AFTER titolo;

-- Se agende_strumenti NON ha colonna id_agenda_parent, aggiungere:
ALTER TABLE agende_strumenti ADD COLUMN id_agenda_parent INT NULL;
ALTER TABLE agende_strumenti ADD FOREIGN KEY (id_agenda_parent) REFERENCES agende_strumenti(id_agenda);
```

### 4.3 Test Query API

```bash
# SSH Terminal
mysql -h dbXXXX.aruba.it -u user -p database

mysql> SELECT COUNT(*) FROM agende_strumenti;
mysql> SELECT COUNT(*) FROM agende_items WHERE fraseVocale IS NOT NULL;
mysql> SHOW COLUMNS FROM agende_items;
```

---

## 5. SICUREZZA

### 5.1 Input Validation

**In `api/agende.php` e `api/items.php`:**

```php
// Validare tutti gli input
function validateInput($data) {
    $data['titolo'] = htmlspecialchars($data['titolo']);
    $data['fraseVocale'] = htmlspecialchars($data['fraseVocale']);

    // Verificare lunghezze
    if (strlen($data['titolo']) > 255) {
        throw new Exception('Titolo troppo lungo');
    }

    return $data;
}

// Usare prepared statements per query
$stmt = $pdo->prepare("SELECT * FROM agende_strumenti WHERE id_agenda = ? AND stato != ?");
$stmt->execute([$id, 'eliminato']);
```

### 5.2 CORS Headers

**In `api/config.php`:**

```php
<?php
// Abilita CORS se necessario
header("Access-Control-Allow-Origin: https://tuodominio.it");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Prevent clickjacking
header("X-Frame-Options: SAMEORIGIN");

// Prevent MIME type sniffing
header("X-Content-Type-Options: nosniff");
```

### 5.3 Proteggere .env e config

```bash
# File config.php NON dovrebbe essere accessibile via HTTP
# Aggiungere a .htaccess:

<Files "config.php">
    Order allow,deny
    Deny from all
</Files>
```

### 5.4 Rate Limiting (opzionale)

```php
// In API endpoints, implementare rate limiting
function checkRateLimit($ip, $limit = 100, $window = 3600) {
    $key = "ratelimit_$ip";
    $current = apcu_fetch($key) ?: 0;

    if ($current >= $limit) {
        http_response_code(429);
        throw new Exception('Too many requests');
    }

    apcu_store($key, $current + 1, $window);
}
```

---

## 6. MAINTENANCE POST-DEPLOYMENT

### 6.1 Monitoraggio Quotidiano

```
☐ Controllare error log API
☐ Verificare disponibilità sito (curl/pingdom)
☐ Monitorare performance (Google Analytics)
☐ Controllare Service Worker cache hits
```

### 6.2 Update Regolari

```bash
# Ogni mese: aggiornare manifest se cambiano asset
# Ogni 3 mesi: aggiornare Service Worker cache version
# Ogni 6 mesi: rifare icons PWA se needed
```

### 6.3 Backup Settimanali

```bash
# Script cron giornaliero (crontab -e)
0 2 * * * mysqldump -h dbXXXX -u user -p db > /backups/db_$(date +\%Y-\%m-\%d).sql

# Mantieni ultimi 30 giorni
0 3 * * * find /backups -name "db_*.sql" -mtime +30 -delete
```

### 6.4 Rollback Plan

Se qualcosa va male:

```bash
# 1. Torna a versione precedente
cd /http.www/Assistivetech/training_cognitivo/strumenti/agenda/
git checkout HEAD~1 .

# O manualmente ripristina da backup FTP

# 2. Pulisci cache Service Worker
# Aumenta CACHE_NAME in service-worker.js
const CACHE_NAME = 'agenda-strumenti-v2';  // Era v1

# 3. Ripristina database se necessario
mysql < /backups/db_backup.sql
```

---

## 7. CHECKLIST DEPLOYMENT FINALE

### Prima di andare LIVE

- [ ] Backup database creato
- [ ] File HTML, CSS, JS validati
- [ ] Icons presenti
- [ ] manifest.json validato
- [ ] service-worker.js testato
- [ ] API endpoints verificati
- [ ] Database schema aggiornato
- [ ] HTTPS abilitato
- [ ] .htaccess configurato
- [ ] Monitoraggio log setup
- [ ] Test su vari browser/device
- [ ] Performance > 80 (Lighthouse)
- [ ] Nessun hardcoded credential
- [ ] Error handling implementato
- [ ] Disaster recovery plan definito

### Dopo LIVE

- [ ] Smoke test su produzione
- [ ] Verifica alert email configurati
- [ ] Backup cron job attivo
- [ ] Monitoring tools configurati
- [ ] Team notificato del deployment
- [ ] Changelog aggiornato
- [ ] Documentazione aggiornata

---

## 8. CONTATTI SUPPORTO ARUBA

```
Email: supporto@aruba.it
Telefono: +39 0574 594500
Pannello Controllo: https://www.aruba.it/assistenza/
```

**Requisiti hosting Aruba per questa PWA:**
- PHP 7.4+ ✅
- MySQL 5.7+ ✅
- HTTPS (Let's Encrypt) ✅
- 50MB+ spazio ✅
- Accesso FTP ✅

---

## 9. VERSIONING

Mantenere traccia delle versioni nel file `VERSION`:

```
1.0.0 - 2025-10-31 - Initial release
  - TTS implementato
  - Multi-level agendas
  - PWA offline support
```

---

## NOTE FINALI

- Mantenere questo file aggiornato con le procedure usate
- Documentare ogni cambio deployment
- Fare backup prima di ogni update
- Testare sempre in staging prima di produzione
- Comunicare i tempi di manutenzione all'utente

