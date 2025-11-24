# 🚀 Guida Deployment AssistiveTech su Aruba

**Data**: 21 Ottobre 2025
**Versione**: 2.0 - Con Auto-Detection BASE_PATH
**Status**: ✅ Pronto per deployment

---

## 📋 Pre-Requisiti Completati

### ✅ Modifiche Codice
- [x] Auto-detection BASE_PATH implementata in tutti i file JavaScript
- [x] File Flutter obsoleti eliminati (~500 MB liberati)
- [x] Esercizi convertiti a JavaScript vanilla funzionanti
- [x] Database locale testato e funzionante

### ✅ File Preparati
- [x] Database esportato: `SQL/aruba_import_ready.sql` (45 KB)
- [x] Codice JavaScript con auto-detection ambiente
- [x] Documentazione organizzata in cartelle MD/ e SQL/

---

## 🔐 Credenziali Aruba

### FTP
- **Host**: ftp.assistivetech.it
- **Username**: 7985805@aruba.it
- **Password**: Filohori33!
- **Porta**: 21
- **Protocollo**: FTP (standard)

### MySQL Database
- **Host**: 31.11.39.242
- **Username**: Sql1073852
- **Password**: 5k58326940
- **Database**: Sql1073852_1
- **Pannello**: http://mysql.aruba.it

---

## 📦 STEP 1: Importazione Database

### 1.1 Accedi al Pannello MySQL Aruba
1. Vai su: http://mysql.aruba.it
2. Login con:
   - **Username**: Sql1073852
   - **Password**: 5k58326940

### 1.2 Seleziona Database
- Clicca su database: `Sql1073852_1` (nella sidebar sinistra)

### 1.3 Importa File SQL
1. Clicca tab **"Importa"** (in alto)
2. Clicca **"Scegli file"**
3. Seleziona: `C:\MAMP\htdocs\Assistivetech\SQL\aruba_import_ready.sql`
4. Verifica che formato sia: **SQL**
5. Clicca **"Esegui"** (in basso)
6. Attendi conferma: "Importazione eseguita correttamente"

### 1.4 Verifica Tabelle Importate
Esegui questa query per verificare:
```sql
SHOW TABLES;
```

**Tabelle attese** (13 totali):
- ✅ `registrazioni` - Utenti sistema
- ✅ `sedi` - Sedi operative
- ✅ `educatori` - Profili educatori
- ✅ `pazienti` - Profili pazienti
- ✅ `educatori_pazienti` - Associazioni
- ✅ `categorie_esercizi` - Categorie training cognitivo
- ✅ `esercizi` - Esercizi training cognitivo
- ✅ `risultati_esercizi` - Risultati esercizi
- ✅ `log_accessi` - Log autenticazione
- ✅ `sequenze_pittogrammi` - Agenda pittogrammi
- ✅ `agenda` - (se presente)
- ✅ `utenti` - (se presente - agenda Flutter)
- ✅ `attivita` - (se presente - agenda Flutter)

### 1.5 Test Query Veloce
```sql
SELECT COUNT(*) as totale_utenti FROM registrazioni;
SELECT COUNT(*) as totale_esercizi FROM esercizi;
SELECT COUNT(*) as totale_categorie FROM categorie_esercizi;
```

**Output atteso**:
- Utenti: >= 1 (sviluppatore)
- Esercizi: >= 2 (ordina_lettere, cerca_colore, ecc.)
- Categorie: >= 2 (sequenze_logiche, trascina_immagini, ecc.)

---

## 📁 STEP 2: Upload File via FTP

### 2.1 Configurazione Filtro IP Aruba (IMPORTANTE!)
**PRIMA di connetterti via FTP**, devi configurare il filtro accessi:

1. Vai su: https://admin.aruba.it
2. Login con: 7985805@aruba.it / Filohori33!
3. Sezione: **"Servizi" → "Hosting Linux"**
4. Pannello: **"Sicurezza" → "Limita accesso FTP"**
5. Clicca: **"Aggiungi IP corrente"**
6. Conferma e attendi 5 minuti per propagazione

### 2.2 Opzione A: Upload con FileZilla (Raccomandato)

#### Download FileZilla
- Scarica da: https://filezilla-project.org/download.php?type=client
- Installa versione Client (non Server)

#### Configurazione Connessione
1. Apri FileZilla
2. File → Gestore Siti → Nuovo Sito
3. Configurazione:
   ```
   Protocollo: FTP
   Host: ftp.assistivetech.it
   Porta: 21
   Tipo di accesso: Normale
   Utente: 7985805@aruba.it
   Password: Filohori33!
   ```
4. Clicca **"Connetti"**

#### Upload Cartelle
**Pannello sinistro** (locale): `C:\MAMP\htdocs\Assistivetech`
**Pannello destro** (remoto): `/htdocs/` (root Aruba)

**Upload queste cartelle/file**:
1. ✅ `/api/` - Tutti i file PHP
2. ✅ `/training_cognitivo/` - Tutti gli esercizi
3. ✅ `/admin/` - Pannello amministrativo
4. ✅ `/agenda/` - App Flutter agenda (se necessario)
5. ✅ `index.html` - Homepage
6. ✅ `login.html` - Pagina login
7. ✅ `register.html` - Registrazione
8. ✅ `dashboard.html` - Dashboard educatori
9. ✅ `.htaccess` - Configurazione Apache

**NON uploadare**:
- ❌ `/MD/` - Solo documentazione locale
- ❌ `/SQL/` - Solo script database locale
- ❌ `/_*` files - File backup rinominati
- ❌ `/logs/` - Log locali
- ❌ `.git/` - Repository Git (se presente)

### 2.3 Opzione B: Upload con WinSCP

#### Download WinSCP
- Scarica da: https://winscp.net/eng/download.php
- Installa versione portable o installer

#### Configurazione
1. Nuovo Sito:
   ```
   Protocollo: FTP
   Host: ftp.assistivetech.it
   Porta: 21
   Username: 7985805@aruba.it
   Password: Filohori33!
   ```
2. Accedi
3. Drag & Drop cartelle da locale a remoto

### 2.4 Verifica Struttura Remota
Dopo upload, verifica struttura su Aruba `/htdocs/`:

```
htdocs/
├── index.html
├── login.html
├── register.html
├── dashboard.html
├── .htaccess
├── api/
│   ├── auth_login.php
│   ├── auth_registrazioni.php
│   ├── api_sedi.php
│   ├── api_esercizi.php
│   └── ...
├── training_cognitivo/
│   ├── index.html
│   ├── sequenze_logiche/
│   │   └── ordina_lettere/
│   │       ├── setup.html
│   │       ├── index.html
│   │       └── manifest.json
│   └── trascina_immagini/
│       └── cerca_colore/
│           ├── setup.html
│           ├── index.html
│           └── ...
└── admin/
    └── index.html
```

---

## 🧪 STEP 3: Test in Produzione

### 3.1 Test Homepage
1. Apri browser: https://assistivetech.it/
2. Verifica:
   - ✅ Homepage carica correttamente
   - ✅ CSS Bootstrap caricato
   - ✅ Nessun errore in console (F12)

### 3.2 Test Login
1. Vai su: https://assistivetech.it/login.html
2. Login con sviluppatore:
   - **Username**: marchettisoft@gmail.com
   - **Password**: Filohori11!
3. Verifica:
   - ✅ Redirect a `/admin/`
   - ✅ Pannello admin carica
   - ✅ Console senza errori

### 3.3 Test Database API
1. Dal pannello admin, prova a:
   - ✅ Visualizzare lista utenti
   - ✅ Visualizzare lista sedi
   - ✅ Visualizzare categorie esercizi
2. Verifica che dati siano gli stessi del locale

### 3.4 Test Esercizio "Ordina Lettere"
1. Vai su: https://assistivetech.it/training_cognitivo/sequenze_logiche/ordina_lettere/setup.html
2. Verifica:
   - ✅ Setup carica con educatori/pazienti
   - ✅ Sviluppatore pre-selezionato
   - ✅ Anonimo pre-selezionato
   - ✅ Click "Inizia Esercizio"
3. Esercizio index.html:
   - ✅ Lettere caricano
   - ✅ Drag & Drop funziona
   - ✅ Timer funziona
   - ✅ Verifica ordine funziona
   - ✅ Database salva risultato

### 3.5 Test Esercizio "Cerca Colore"
1. Vai su: https://assistivetech.it/training_cognitivo/trascina_immagini/cerca_colore/setup.html
2. Verifica:
   - ✅ Setup carica
   - ✅ ARASAAC API funziona
   - ✅ Pittogrammi scaricano
   - ✅ Esercizio funziona

### 3.6 Test Console Browser (F12)
Apri console e verifica:
- ✅ Nessun errore `404 Not Found`
- ✅ Nessun errore CORS
- ✅ BASE_PATH rilevato correttamente come `''` (vuoto)
- ⚠️ Warning estensioni browser OK (ignorabili)

**Comando test in console**:
```javascript
console.log('BASE_PATH:', BASE_PATH);
console.log('Hostname:', window.location.hostname);
```

**Output atteso**:
```
BASE_PATH:
Hostname: assistivetech.it
```

---

## 🔧 STEP 4: Configurazione .htaccess (se necessario)

Il file `.htaccess` dovrebbe già essere presente. Verifica contenuto:

```apache
# Sicurezza
<Files "*.sql">
    Order allow,deny
    Deny from all
</Files>

<Files "*.md">
    Order allow,deny
    Deny from all
</Files>

# Headers sicurezza
Header set X-Frame-Options "SAMEORIGIN"
Header set X-XSS-Protection "1; mode=block"
Header set X-Content-Type-Options "nosniff"

# Compressione
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>

# Cache
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType text/css "access plus 1 week"
    ExpiresByType application/javascript "access plus 1 week"
</IfModule>
```

---

## 📊 STEP 5: Verifica Finale

### Checklist Deployment
- [ ] Database importato su mysql.aruba.it
- [ ] Tabelle verificate (13 totali)
- [ ] File uploadati via FTP
- [ ] Homepage carica: https://assistivetech.it/
- [ ] Login funziona
- [ ] Admin panel funziona
- [ ] Esercizio "Ordina Lettere" funziona
- [ ] Esercizio "Cerca Colore" funziona
- [ ] BASE_PATH auto-rilevato correttamente
- [ ] Console senza errori critici
- [ ] Database salva risultati correttamente

### Test Cross-Browser
- [ ] Chrome/Edge: https://assistivetech.it/
- [ ] Firefox: https://assistivetech.it/
- [ ] Safari (iOS): https://assistivetech.it/ (se disponibile)

### Test Mobile
- [ ] Android Chrome: Login + Esercizio
- [ ] iOS Safari: Login + Esercizio (se disponibile)

---

## 🐛 Troubleshooting Comuni

### Errore: 530 Login authentication failed
**Causa**: IP non autorizzato
**Soluzione**: Configura filtro IP su admin.aruba.it

### Errore: 404 Not Found su API
**Causa**: Path API errato
**Soluzione**: Verifica BASE_PATH in console:
```javascript
console.log('API URL:', `${BASE_PATH}/api/auth_login.php`);
```
**Atteso**: `/api/auth_login.php` (senza /Assistivetech)

### Errore: Database connection failed
**Causa**: Credenziali database errate
**Soluzione**: Verifica in `api/*.php` le credenziali:
```php
$host = '31.11.39.242';
$username = 'Sql1073852';
$password = '5k58326940';
$database = 'Sql1073852_1';
```

### Errore: CORS policy blocked
**Causa**: Headers mancanti
**Soluzione**: Aggiungi in ogni `api/*.php`:
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
```

### Errore: CSS/JS non caricano
**Causa**: CDN bloccato o path errato
**Soluzione**: Verifica in console Network (F12) quali file falliscono

---

## 📝 Post-Deployment

### Backup Automatico
Configura backup settimanale del database:
1. Pannello Aruba → Backup
2. Abilita backup automatico MySQL
3. Frequenza: Settimanale

### Monitoraggio
- **Uptime**: Configura monitor su uptime.com o pingdom.com
- **Errori**: Verifica log Apache su pannello Aruba
- **Performance**: Google PageSpeed Insights

### Aggiornamenti Futuri
Quando modifichi codice in locale:
1. Testa in locale: http://localhost:8888/Assistivetech/
2. Upload solo file modificati via FTP
3. Test immediato in produzione
4. Rollback se necessario (ri-upload versione precedente)

---

## ✅ Deployment Completato!

**URL Finali**:
- 🏠 Homepage: https://assistivetech.it/
- 🔐 Login: https://assistivetech.it/login.html
- 👨‍💼 Admin: https://assistivetech.it/admin/
- 📊 Dashboard: https://assistivetech.it/dashboard.html
- 🧠 Training: https://assistivetech.it/training_cognitivo/
- 📱 Agenda: https://assistivetech.it/agenda/

**Credenziali Sviluppatore**:
- Username: marchettisoft@gmail.com
- Password: Filohori11!

---

**Guida compilata**: 21 Ottobre 2025, ore 21:40
**Autore**: Claude Code + Team AssistiveTech
**Versione**: 2.0 - Auto-Detection BASE_PATH
