# 🗄️ Guida Configurazione Database - Locale vs Cloud

## 🎯 Due Modalità di Sviluppo

Il sistema supporta **DUE modalità** per lavorare in locale con MAMP:

### **Modalità A: Database Locale** 🏠
- Usa database locale `assistivetech_local` su MAMP
- **Pro:** Sviluppo isolato, non tocchi dati reali
- **Contro:** Devi sincronizzare manualmente i dati

### **Modalità B: Database Cloud** ☁️
- Usa database remoto Aruba (`31.11.39.242`)
- **Pro:** Lavori con dati reali in tempo reale
- **Contro:** Modifiche visibili immediatamente in produzione

---

## 🔧 Come Cambiare Modalità

### File da Modificare
**Path:** `C:\MAMP\htdocs\Assistivetech\api\config.php`

### Riga da Cambiare (linea 24)
```php
define('USA_DB_LOCALE', true); // 👈 CAMBIA QUI
```

### Opzioni Disponibili

#### ✅ Usare Database Locale (CONSIGLIATO per sviluppo)
```php
define('USA_DB_LOCALE', true);
```

**Configurazione applicata:**
- Host: `localhost`
- Porta: `3306`
- Database: `assistivetech_local`
- Username: `root`
- Password: `root`

#### ☁️ Usare Database Cloud Aruba (per lavoro con dati reali)
```php
define('USA_DB_LOCALE', false);
```

**Configurazione applicata:**
- Host: `31.11.39.242`
- Porta: `3306`
- Database: `Sql1073852_1`
- Username: `Sql1073852`
- Password: `5k58326940`

---

## 📋 Setup Database Locale (se usi Modalità A)

Se hai scelto `USA_DB_LOCALE = true`, il database locale deve esistere.

### Verifica Database Esiste

1. Apri phpMyAdmin: http://localhost/phpMyAdmin5/
2. Cerca database `assistivetech_local` nella sidebar sinistra
3. Se esiste: ✅ Sei pronto!
4. Se NON esiste: Segui il setup sotto

### Setup Automatico (CONSIGLIATO)

```
1. Apri: http://localhost/setup_local_database.php
2. Clicca "Avvia Setup"
3. Segui i 4 step del wizard
4. Verifica completamento
```

### Setup Manuale (alternativo)

```sql
-- 1. Crea database
CREATE DATABASE IF NOT EXISTS assistivetech_local
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. Importa struttura
-- Vai in phpMyAdmin > assistivetech_local > Importa
-- Seleziona file: C:\MAMP\htdocs\Assistivetech\script_sql\database.sql
-- Clicca "Esegui"
```

---

## ☁️ Vantaggi Database Cloud in Locale

### Quando Usarlo
- ✅ Vuoi testare con dati reali
- ✅ Non vuoi duplicare i dati
- ✅ Stai facendo debug di problemi produzione
- ✅ Vuoi sincronizzazione automatica con il server

### Cosa Puoi Fare
- Modificare dati (visibili immediatamente online)
- Testare API con dati reali
- Debug problemi produzione
- Sviluppo rapido senza import/export

### ⚠️ ATTENZIONE
- Le modifiche al database sono **IMMEDIATE** in produzione
- Altri utenti vedranno le tue modifiche in tempo reale
- NON cancellare dati importanti durante il test
- Fai backup prima di modifiche strutturali

---

## 🧪 Test Configurazione

### Verifica Configurazione Attiva

**URL Test:** http://localhost/test_connection.php

**Cosa Verificare:**

#### Se USA_DB_LOCALE = true (Database Locale)
```
✅ Ambiente rilevato: LOCALE (MAMP)
✅ Database: assistivetech_local
✅ Host DB: localhost
```

#### Se USA_DB_LOCALE = false (Database Cloud)
```
✅ Ambiente rilevato: LOCALE (MAMP)
✅ Database: Sql1073852_1
✅ Host DB: 31.11.39.242
```

---

## 🔄 Workflow Consigliato

### Per Sviluppo Normale
```
1. Usa Database Locale (USA_DB_LOCALE = true)
2. Importa dump da produzione (se serve)
3. Sviluppa e testa localmente
4. Quando pronto, deploya su Aruba via FTP
```

### Per Debug Produzione
```
1. Usa Database Cloud (USA_DB_LOCALE = false)
2. Testa direttamente con dati reali
3. Risolvi il problema
4. Torna a Database Locale per sviluppo normale
```

---

## 📊 Confronto Modalità

| Caratteristica | DB Locale 🏠 | DB Cloud ☁️ |
|----------------|--------------|-------------|
| **Velocità** | ⚡ Molto veloce | 🐌 Dipende da rete |
| **Dati reali** | ❌ No (dati test) | ✅ Sì |
| **Sicurezza** | ✅ Isolato | ⚠️ Modifiche in produzione |
| **Sincronizzazione** | ❌ Manuale | ✅ Automatica |
| **Offline** | ✅ Funziona | ❌ Serve internet |
| **Consigliato per** | Sviluppo quotidiano | Debug/Testing reale |

---

## 🔐 Credenziali Database

### Database Locale (MAMP)
```
Host: localhost
Porta: 3306
Database: assistivetech_local
Username: root
Password: root
```

### Database Cloud (Aruba)
```
Host: 31.11.39.242
Porta: 3306
Database: Sql1073852_1
Username: Sql1073852
Password: 5k58326940
```

---

## 🛠️ Troubleshooting

### Errore: "Connection refused" con DB Locale

**Causa:** MAMP MySQL non è avviato o usa porta diversa

**Soluzione:**
```
1. Apri MAMP
2. Verifica MySQL sia verde (running)
3. Controlla porta MySQL in MAMP (deve essere 3306)
4. Se usi porta diversa, modifica $port in config.php
```

### Errore: "Access denied" con DB Cloud

**Causa:** IP non autorizzato su Aruba o credenziali sbagliate

**Soluzione:**
```
1. Verifica credenziali in config.php
2. Controlla che il tuo IP sia autorizzato sul pannello Aruba
3. Aggiungi il tuo IP alle whitelist MySQL su Aruba
```

### Errore: "Unknown database" con DB Locale

**Causa:** Database `assistivetech_local` non esiste

**Soluzione:**
```
1. Esegui setup_local_database.php
2. Oppure crea manualmente via phpMyAdmin
3. Importa structure da script_sql/database.sql
```

### Test_connection.php mostra database sbagliato

**Causa:** Cache browser o configurazione non salvata

**Soluzione:**
```
1. Salva modifiche a config.php
2. Ricarica pagina con CTRL+F5 (hard refresh)
3. Verifica il valore di USA_DB_LOCALE nella riga 24
```

---

## 💡 Consigli Best Practice

### Durante lo Sviluppo
1. ✅ Usa Database Locale di default
2. ✅ Fai commit frequenti del codice
3. ✅ Mantieni backup del database locale
4. ✅ Documenta le modifiche alla struttura DB

### Prima del Deploy
1. ✅ Testa con Database Cloud per validare
2. ✅ Verifica che non ci siano query hardcoded con dati locali
3. ✅ Controlla che tutte le API rispondano correttamente
4. ✅ Esporta SQL delle modifiche struttura se necessario

### Dopo Modifiche Struttura DB
1. ✅ Crea script SQL delle modifiche
2. ✅ Salvalo in `script_sql/` con nome descrittivo
3. ✅ Esegui su entrambi i database (locale e cloud)
4. ✅ Testa su entrambi prima di considerare completo

---

## 🔗 Link Utili

- **phpMyAdmin Locale:** http://localhost/phpMyAdmin5/
- **Test Connessione:** http://localhost/test_connection.php
- **Setup Database:** http://localhost/setup_local_database.php
- **Login App:** http://localhost/login.html

---

## ✅ Checklist Veloce

Prima di iniziare a lavorare:

- [ ] Ho scelto la modalità (locale/cloud) in `config.php`
- [ ] Se locale: database `assistivetech_local` esiste
- [ ] Se cloud: ho internet attivo e IP autorizzato
- [ ] MAMP è avviato (Apache + MySQL verdi)
- [ ] `test_connection.php` mostra configurazione corretta
- [ ] Login funziona con credenziali sviluppatore

---

**Ultima revisione:** 18 Ottobre 2025
**Creato da:** Claude Code AI
