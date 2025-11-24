# 🔍 Diagnosi Problemi Accesso Localhost - AssistiveTech

## 📋 Sommario Analisi

**Data Analisi:** 18 Ottobre 2025
**Ambiente:** MAMP su Windows (nuovo PC)
**Path Progetto:** `C:\MAMP\htdocs\Assistivetech`

---

## 🎯 Problemi Identificati

### 1. ⚠️ **DATABASE LOCALE NON CONFIGURATO** (CRITICO)

**Problema:**
Il database `assistivetech_local` non esiste ancora in MAMP.

**Evidenza:**
- File `api/config.php` configura automaticamente il database locale: `assistivetech_local`
- File SQL disponibile in `script_sql/database.sql` ma non ancora importato
- Sistema multi-ambiente funziona correttamente (locale vs produzione)

**Impatto:**
- ❌ Login non funziona (errore connessione database)
- ❌ API non possono accedere ai dati
- ❌ Applicazione non utilizzabile

**Soluzione:**
✅ **Script di setup automatico creato:** `setup_local_database.php`

---

### 2. 🔧 **PHP NON NEL PATH DI SISTEMA**

**Problema:**
PHP non è accessibile da linea di comando globale.

**Evidenza:**
```bash
$ php -v
bash: php: command not found
```

**Versioni PHP disponibili in MAMP:**
```
C:\MAMP\bin\php\
├── php5.5.38
├── php5.6.34
├── php7.0.31
├── php7.1.23
├── php7.2.18
├── php7.3.19
├── php7.4.16
├── php8.0.1
├── php8.1.0
├── php8.2.14
├── php8.3.0
└── php8.3.1
```

**Impatto:**
- ⚠️ Comandi PHP da terminale non funzionano
- ✅ MAMP interno funziona correttamente (usa Apache)

**Soluzione:**
Non critico per l'uso normale dell'applicazione. MAMP gestisce PHP tramite Apache.

---

### 3. 📁 **CONFIGURAZIONE AMBIENTE**

**Stato Attuale:**

#### ✅ Configurazione Multi-Ambiente Corretta
File `api/config.php` rileva automaticamente:
- **Locale (MAMP):**
  - Host: `localhost`
  - Username: `root`
  - Password: `root`
  - Database: `assistivetech_local`
  - Porta: `8889` (MAMP default)

- **Produzione (Aruba):**
  - Host: `31.11.39.242`
  - Username: `Sql1073852`
  - Password: `5k58326940`
  - Database: `Sql1073852_1`
  - Porta: `3306`

#### ✅ File .htaccess Corretto
- DirectoryIndex configurato
- Sicurezza headers attivi
- CORS configurato per API

---

## 🚀 Soluzione Step-by-Step

### **Passo 1: Verificare MAMP Attivo**

1. Aprire **MAMP** dall'icona sul desktop
2. Cliccare su **"Start Servers"**
3. Verificare che **Apache** e **MySQL** siano entrambi **verdi** (attivi)
4. Annotare la porta MySQL (di solito `8889`)

---

### **Passo 2: Creare Database Locale (AUTOMATICO)**

**METODO CONSIGLIATO:**

1. Aprire browser: `http://localhost:8888/Assistivetech/setup_local_database.php`
2. Seguire il wizard guidato 4-step:
   - ✅ Test connessione MySQL
   - 🗄️ Creazione database `assistivetech_local`
   - 📥 Importazione struttura tabelle
   - ✔️ Verifica setup completo

**METODO MANUALE (alternativo):**

1. Aprire phpMyAdmin: `http://localhost:8888/phpMyAdmin/`
2. Cliccare su **"Nuovo"** nella sidebar sinistra
3. Nome database: `assistivetech_local`
4. Collation: `utf8mb4_unicode_ci`
5. Cliccare **"Crea"**
6. Selezionare il database appena creato
7. Cliccare tab **"Importa"**
8. Scegliere file: `C:\MAMP\htdocs\Assistivetech\script_sql\database.sql`
9. Cliccare **"Esegui"**

---

### **Passo 3: Test Connessione**

1. Aprire: `http://localhost:8888/Assistivetech/test_connection.php`
2. Verificare:
   - ✅ Connessione database riuscita
   - ✅ Tabelle create (dovrebbero essere ~10 tabelle)
   - ✅ Utente sviluppatore presente

**Credenziali Sviluppatore:**
- Username: `marchettisoft@gmail.com`
- Password: `Filohori11!`

---

### **Passo 4: Test Login**

1. Aprire: `http://localhost:8888/Assistivetech/login.html`
2. Inserire credenziali sviluppatore
3. Cliccare **"Accedi"**
4. Dovrebbe reindirizzare a: `http://localhost:8888/Assistivetech/admin/`

---

## 🔍 Diagnostica Avanzata

### Script di Test Creati

#### 1. **test_connection.php**
**URL:** `http://localhost:8888/Assistivetech/test_connection.php`

**Funzioni:**
- ✅ Test connessione database
- 📋 Lista tabelle e conteggio righe
- 👨‍💻 Verifica utente sviluppatore
- 🐘 Info PHP e PDO MySQL

#### 2. **setup_local_database.php**
**URL:** `http://localhost:8888/Assistivetech/setup_local_database.php`

**Funzioni:**
- 🚀 Wizard setup automatico 4-step
- 🗄️ Creazione database se non esiste
- 📥 Importazione SQL automatica
- ✔️ Verifica setup completato

---

## 📊 Struttura Database

### Tabelle Principali (10 tabelle)

1. **registrazioni** - Utenti sistema (amministratori, educatori, pazienti, sviluppatori)
2. **sedi** - Sedi fisiche della organizzazione
3. **settori** - Settori all'interno delle sedi
4. **classi** - Classi all'interno dei settori
5. **educatori** - Profilo esteso educatori
6. **pazienti** - Profilo esteso pazienti
7. **educatori_pazienti** - Associazioni educatore-paziente
8. **categorie_esercizi** - Categorie training cognitivo
9. **esercizi** - Esercizi training cognitivo
10. **log_accessi** - Log accessi utenti (se presente)

### Dati Iniziali Importati

**Utenti:**
- 1 Sviluppatore (Fabio Marchetti)
- 3 Amministratori
- 3 Educatori
- 1 Paziente

**Sedi:**
- Sede Principale (Osimo, AN)
- Molfetta (Molfetta, BA)

**Settori (5):**
- Scolare
- Trattamenti Intensivi
- Centro Diagnostico
- Diurno
- Adulti

**Classi (33):**
- Distribuite nei vari settori

---

## 🌐 URLs Applicazione Locale

### Frontend
- **Homepage:** `http://localhost:8888/Assistivetech/index.html`
- **Login:** `http://localhost:8888/Assistivetech/login.html`
- **Registrazione:** `http://localhost:8888/Assistivetech/register.html`
- **Dashboard Educatori:** `http://localhost:8888/Assistivetech/dashboard.html`
- **Admin Panel:** `http://localhost:8888/Assistivetech/admin/`
- **Agenda Flutter:** `http://localhost:8888/Assistivetech/agenda/`

### API Backend
- **Login:** `http://localhost:8888/Assistivetech/api/auth_login.php`
- **Registrazioni:** `http://localhost:8888/Assistivetech/api/auth_registrazioni.php`
- **Sedi:** `http://localhost:8888/Assistivetech/api/api_sedi.php`
- **Settori/Classi:** `http://localhost:8888/Assistivetech/api/api_settori_classi.php`

### Tools Diagnostica
- **Test Connessione:** `http://localhost:8888/Assistivetech/test_connection.php`
- **Setup Database:** `http://localhost:8888/Assistivetech/setup_local_database.php`
- **phpMyAdmin:** `http://localhost:8888/phpMyAdmin/`

---

## ⚙️ Configurazione MAMP

### Impostazioni Consigliate

**Porte:**
- Apache: `8888` (default MAMP)
- MySQL: `8889` (default MAMP)

**PHP Version:**
- Consigliata: PHP 8.1 o superiore
- Minima: PHP 7.4

**Estensioni PHP Richieste:**
- ✅ `pdo_mysql` (gestione database)
- ✅ `json` (API REST)
- ✅ `mbstring` (gestione stringhe UTF-8)

**Document Root:**
- `C:\MAMP\htdocs`

---

## 🔐 Credenziali di Accesso

### Ambiente Locale (dopo setup)

**Sviluppatore:**
- Username: `marchettisoft@gmail.com`
- Password: `Filohori11!`
- Ruolo: `sviluppatore`
- Accesso: Pannello admin completo

**Amministratore:**
- Username: `ami1@gmail.com`
- Password: (vedi database)
- Ruolo: `amministratore`

**Educatore:**
- Username: `edu1@gmail.com`
- Password: `pwdedu1`
- Ruolo: `educatore`

**Paziente:**
- Username: `vincenzo@gmail.com`
- Password: `pwdvincenzo`
- Ruolo: `paziente`

---

## 🐛 Troubleshooting Comune

### Errore: "Connessione al database fallita"

**Causa:** Database locale non creato

**Soluzione:**
1. Esegui `setup_local_database.php`
2. Verifica MAMP attivo
3. Controlla porta MySQL in `api/config.php` (8889 vs 3306)

---

### Errore: "Tabelle non trovate"

**Causa:** Database esiste ma vuoto

**Soluzione:**
1. Importa `script_sql/database.sql` via phpMyAdmin
2. Oppure riesegui `setup_local_database.php`

---

### Errore: "Page Not Found" su API

**Causa:** Apache non configurato correttamente

**Soluzione:**
1. Verifica Document Root MAMP: `C:\MAMP\htdocs`
2. Controlla .htaccess presente nella root
3. Riavvia Apache da MAMP

---

### Login fallisce con credenziali corrette

**Causa:** Formato date database o password mismatch

**Soluzione:**
1. Verifica credenziali in tabella `registrazioni` via phpMyAdmin
2. Password sono in chiaro (no hash attualmente)
3. Controlla console browser per errori JavaScript

---

## 📝 Checklist Finale

Prima di considerare il sistema operativo:

- [ ] MAMP avviato (Apache + MySQL verdi)
- [ ] Database `assistivetech_local` creato
- [ ] Struttura tabelle importata (10 tabelle)
- [ ] Utente sviluppatore presente nel database
- [ ] `test_connection.php` mostra "✅ Connessione riuscita"
- [ ] `login.html` carica senza errori console
- [ ] Login con credenziali sviluppatore funziona
- [ ] Redirect a pannello admin `/admin/` avviene

---

## 🎉 Risultato Atteso

Dopo aver completato il setup:

1. ✅ **Applicazione accessibile** da `http://localhost:8888/Assistivetech/`
2. ✅ **Database locale funzionante** con dati di test
3. ✅ **Login operativo** con utente sviluppatore
4. ✅ **Pannello admin accessibile** per gestione completa sistema
5. ✅ **API responsive** per tutte le operazioni CRUD
6. ✅ **Ambiente di sviluppo** completamente configurato

---

## 📞 Note Finali

- **Ambiente locale** è completamente indipendente dalla produzione
- **Database locale** usa dati di test, non dati reali
- **Credenziali locali** possono essere diverse da produzione
- **Modifiche locali** non influenzano server Aruba
- **Sync produzione:** Usare FTP per caricare modifiche su Aruba

---

## 🔗 Link Utili

- [Documentazione MAMP](https://www.mamp.info/en/documentation/)
- [phpMyAdmin Docs](https://www.phpmyadmin.net/docs/)
- [PHP PDO MySQL](https://www.php.net/manual/en/ref.pdo-mysql.php)
- [Bootstrap 5 Docs](https://getbootstrap.com/docs/5.3/)

---

**Documento creato da:** Claude Code AI
**Ultima revisione:** 18 Ottobre 2025
