# Changelog Database - AssistiveTech.it

## 📅 Modifiche Apportate (13/09/2024)

### ⚠️ IMPORTANTE
Questo script **elimina e ricrea** tutte le tabelle esistenti per garantire una struttura pulita.

### 🔄 Modifiche Principali

#### 1. **Formato Date Italiano**
- **Prima**: TIMESTAMP (formato MySQL standard)
- **Dopo**: VARCHAR con formato italiano `dd/mm/yyyy` e `dd/mm/yyyy hh:mm:ss`

**Tabelle Modificate:**
- `registrazioni.data_registrazione` → `13/09/2024`
- `registrazioni.ultimo_accesso` → `13/09/2024 15:30:45`
- `educatori_pazienti.data_associazione` → `13/09/2024`
- `log_accessi.timestamp_accesso` → `13/09/2024 15:30:45`
- `sessioni_utente.timestamp_creazione` → `13/09/2024 15:30:45`
- `sessioni_utente.timestamp_ultimo_accesso` → `13/09/2024 15:30:45`

#### 2. **Dati Iniziali**
- **Eliminati**: Utenti di esempio (Maria Rossi, Luca Bianchi)
- **Mantenuto**: Solo amministratore principale Fabio Marchetti
  - Username: `marchettisoft@gmail.com`
  - Password: `Filohori11!`
  - Ruolo: `amministratore`

#### 3. **Struttura Tabelle**
- **Eliminate** con `DROP TABLE IF EXISTS`
- **Ricreate** senza `IF NOT EXISTS` per garantire struttura pulita
- **Foreign Key** mantenute per integrità referenziale

### 📋 Procedura Deployment

1. **Backup Database** (se necessario)
2. **Esegui Script SQL** completo
3. **Verifica Creazione Tabelle**
4. **Test Login Amministratore**

### 🔧 Compatibilità API

Le API PHP sono state aggiornate per supportare il nuovo formato date:
- `auth_login.php` → Aggiorna `ultimo_accesso` in formato italiano
- `auth_registrazioni.php` → Crea `data_registrazione` in formato italiano

### ✅ Test Consigliati

1. **Login Admin**: `marchettisoft@gmail.com` / `Filohori11!`
2. **Registrazione Nuovo Utente** → Verifica formato data
3. **Log Accessi** → Verifica timestamp formato italiano
4. **Dashboard** → Verifica visualizzazione date

### 📊 Schema Finale

```sql
registrazioni:
├── id_registrazione (INT AUTO_INCREMENT)
├── nome_registrazione (VARCHAR 100)
├── cognome_registrazione (VARCHAR 100)
├── username_registrazione (VARCHAR 255 UNIQUE)
├── password_registrazione (VARCHAR 255)
├── ruolo_registrazione (ENUM)
├── data_registrazione (VARCHAR 10) → "13/09/2024"
├── ultimo_accesso (VARCHAR 19) → "13/09/2024 15:30:45"
└── stato_account (ENUM DEFAULT 'attivo')
```

### 🚨 Note Sicurezza

- Password ancora in **chiaro** (compatibilità)
- Implementare hashing in versioni future
- Log accessi attivi per monitoraggio
- Filtro FTP Aruba configurato