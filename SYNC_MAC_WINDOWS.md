# 🔄 Procedura Sincronizzazione Mac ↔ Windows

Questa guida spiega come **sincronizzare l'applicazione AssistiveTech tra Mac e Windows** mantenendo la piena compatibilità e senza dover riconfigurare nulla.

---

## ✅ Sistema Configurato per Portabilità Completa

Il sistema è stato configurato per **rilevare automaticamente** il sistema operativo e adattarsi senza modifiche manuali.

### 🔧 Configurazioni Auto-Rilevanti (`api/config.php`)

1. **Auto-rileva Mac vs Windows**:
   ```php
   $is_mac_os = (strtoupper(substr(PHP_OS, 0, 6)) === 'DARWIN');
   $is_windows_os = (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN');
   ```

2. **Password database uniforme**: `'root'` (funziona su entrambi)

3. **Fix socket MySQL su Mac**:
   - Mac: converte `localhost` → `127.0.0.1` automaticamente
   - Windows: usa `localhost` normalmente

4. **Fix SQL mode compatibilità**:
   - Disabilita `ONLY_FULL_GROUP_BY` (attivo su Mac, non su Windows)
   - Garantisce query SQL compatibili su entrambi

5. **Apache mod_rewrite**:
   - Abilitato su entrambi i computer per `.htaccess`

---

## 📋 Procedura di Sincronizzazione

### 🖥️ Computer 1 (Windows) → Computer 2 (Mac)

#### 1️⃣ Export Database da Windows
```bash
# In phpMyAdmin su Windows:
1. Seleziona database: assistivetech_local
2. Esporta → Metodo: Rapido → Formato: SQL
3. Salva: assistivetech_YYYYMMDD.sql
```

#### 2️⃣ Copia Cartella Applicazione
```bash
# Copia l'intera cartella AssistiveTech
# ESCLUDI (già gestito da .gitignore):
- logs/
- *.log
- .DS_Store
- test_db_connection.php
- api/.htaccess.disabled
```

#### 3️⃣ Import su Mac

**A. Copia file**:
```bash
# Copia cartella AssistiveTech in:
/Applications/MAMP/htdocs/Assistivetech
```

**B. Import database**:
```bash
# Apri phpMyAdmin Mac: http://localhost:8888/phpMyAdmin5/
1. Crea database: assistivetech_local (se non esiste)
   - Collation: utf8mb4_unicode_ci
2. Importa → Scegli file: assistivetech_YYYYMMDD.sql
3. Esegui
4. IMPORTANTE: Esegui script fix AUTO_INCREMENT:
   - Apri SQL tab in phpMyAdmin
   - Carica e esegui: script_sql/fix_categorie_esercizi_autoincrement.sql
```

**C. Avvia MAMP**:
```bash
1. Assicurati MySQL nativo sia FERMO (vedi troubleshooting)
2. Start Servers in MAMP
3. Verifica: http://localhost:8888/Assistivetech/
```

#### 4️⃣ Verifica Funzionamento
```bash
# Test connessione (opzionale):
http://localhost:8888/Assistivetech/test_db_connection.php

# Login:
http://localhost:8888/Assistivetech/login.html
Username: marchettisoft@gmail.com
Password: Filohori11!

# Dashboard:
http://localhost:8888/Assistivetech/dashboard.html
```

---

### 🍎 Computer 2 (Mac) → Computer 1 (Windows)

Stesso identico processo invertito:

1. **Export database** da phpMyAdmin Mac
2. **Copia cartella** AssistiveTech
3. **Import database** in phpMyAdmin Windows (XAMPP/WAMP)
4. **Avvia server** (XAMPP/WAMP)
5. **Verifica** su http://localhost/Assistivetech/ (o porta custom)

---

## 🎯 File da Sincronizzare

### ✅ DA SINCRONIZZARE (codice sorgente)
- `api/*.php` (tutti i file API)
- `admin/` (pannello amministrativo)
- `training_cognitivo/` (esercizi generati)
- `agenda/` (app Flutter)
- `*.html` (pagine web)
- `*.js`, `*.css` (assets)
- `CLAUDE.md`, `README.md` (documentazione)

### ❌ DA NON SINCRONIZZARE (auto-generati o locali)
- `logs/` e `*.log`
- `.DS_Store` (Mac)
- `Thumbs.db` (Windows)
- `test_*.php`, `debug_*.php`
- `api/.htaccess.disabled`
- File `*.sql` (export database)

---

## 🔧 Troubleshooting Mac

### Problema: MySQL nativo occupa porta 3306

**Sintomo**: MAMP non si avvia, dice porta occupata

**Soluzione**:
```bash
# Ferma MySQL nativo:
sudo /usr/local/mysql/support-files/mysql.server stop

# OPPURE disabilita permanentemente:
1. Apri: Impostazioni di Sistema → MySQL
2. Stop MySQL Server
3. Deseleziona "Automatically Start MySQL Server on Startup"
```

### Problema: mod_rewrite non abilitato

**Sintomo**: "Internal Server Error" sulle API

**Soluzione**:
```bash
# 1. Ferma MAMP
# 2. Apri: /Applications/MAMP/conf/apache/httpd.conf
# 3. Cerca:  #LoadModule rewrite_module modules/mod_rewrite.so
# 4. Rimuovi il # davanti
# 5. Salva e riavvia MAMP
```

---

## 🔧 Troubleshooting Windows

### Problema: Password database diversa

**Sintomo**: Errore connessione "Access denied for user 'root'"

**Verifica**:
```bash
# Apri phpMyAdmin e controlla password
# Se password vuota o diversa da 'root':
# → Modifica password MySQL a 'root' tramite phpMyAdmin
```

### Problema: Apache non parte

**Sintomo**: Porta 80 occupata (Skype, IIS, etc.)

**Soluzione**:
```bash
# Chiudi programmi che usano porta 80
# OPPURE cambia porta Apache in XAMPP/WAMP config
```

---

## 📊 Schema Configurazione Automatica

```
┌─────────────────────────────────────────────────┐
│          api/config.php (CENTRALIZZATO)         │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────┐         ┌──────────────┐      │
│  │   MACBOOK   │         │   WINDOWS    │      │
│  │   (macOS)   │         │   (Win 11)   │      │
│  └─────────────┘         └──────────────┘      │
│        ↓                        ↓               │
│  Auto-rileva:            Auto-rileva:          │
│  - PHP_OS = DARWIN       - PHP_OS = WIN        │
│  - Host: 127.0.0.1       - Host: localhost     │
│  - Password: root        - Password: root      │
│  - Port: 3306            - Port: 3306          │
│  - SQL mode: fix         - SQL mode: già OK    │
│        ↓                        ↓               │
│     FUNZIONA  ✅            FUNZIONA  ✅         │
└─────────────────────────────────────────────────┘
```

---

## 🎓 Best Practices

### 1. Sincronizzazione Regolare
- **Esporta database** prima di cambiare computer
- **Copia cartella** con rsync o tool sync cloud
- **Verifica funzionamento** dopo import

### 2. Backup Prima di Modifiche Importanti
```bash
# Prima di modifiche al database:
mysqldump -u root -p assistivetech_local > backup_$(date +%Y%m%d).sql

# Prima di modifiche al codice:
cp -r /Applications/MAMP/htdocs/Assistivetech ~/backup_assistivetech_$(date +%Y%m%d)
```

### 3. Versioning con Git (Opzionale)
```bash
# Inizializza repository Git:
cd /Applications/MAMP/htdocs/Assistivetech
git init
git add .
git commit -m "Initial commit"

# Su cambio computer:
git pull
# ... import database ...
git push
```

### 4. Verifica Dopo Sync
```bash
# Checklist post-sincronizzazione:
☑ Database importato correttamente
☑ Login funzionante
☑ Dashboard mostra dati
☑ Gestione educatori carica lista
☑ Training cognitivo accessibile
☑ Agenda Flutter carica
```

---

## 📝 Note Importanti

### File `api/config.php` - NON MODIFICARE
Questo file è configurato per funzionare automaticamente su entrambi i computer. **Non modificare** parametri come host, password o port manualmente.

### Password Database
**Entrambi i computer devono avere**:
- Username MySQL: `root`
- Password MySQL: `root`
- Porta MySQL: `3306`

### Nome Database
**Deve essere identico**:
- Database: `assistivetech_local`
- Charset: `utf8mb4`
- Collation: `utf8mb4_unicode_ci`

---

## ✅ Riepilogo Vantaggi Sistema Auto-Configurante

1. ✅ **Zero configurazione manuale** quando cambi computer
2. ✅ **Auto-rileva OS** (Mac/Windows)
3. ✅ **Fix automatici** per differenze MySQL
4. ✅ **Stessa password** su entrambi
5. ✅ **Portabilità completa** del codice
6. ✅ **Compatibilità SQL** garantita

---

**Data Creazione**: 16 Novembre 2025
**Ultima Modifica**: 16 Novembre 2025
**Versione**: 1.0
**Autore**: Claude Code + Fabio Marchetti
