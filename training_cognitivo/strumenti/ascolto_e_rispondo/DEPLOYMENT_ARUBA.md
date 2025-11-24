# 🚀 Guida Deployment "ascolto e rispondo" su Aruba

## 📋 Checklist Completa

Prima di iniziare, verifica di avere:
- ✅ Accesso FTP al server Aruba
- ✅ Accesso phpMyAdmin database Aruba (`Sql1073852_1`)
- ✅ Script SQL di aggiornamento database pronto
- ✅ Cartella `ascolto_e_rispondo` completa in locale

---

## 🗄️ STEP 1: Aggiorna il Database su Aruba

### **1.1 - Accedi a phpMyAdmin**

1. Vai su: **https://www.assistivetech.it/phpMyAdmin/** (o il tuo URL phpMyAdmin)
2. Login:
   - **Username:** `Sql1073852`
   - **Password:** `5k58326940`
3. Seleziona database: **`Sql1073852_1`**

### **1.2 - Esegui lo Script SQL**

1. Clicca sulla tab **"SQL"** in alto
2. Apri il file locale: `Assistivetech/agenda_timer/api/UPDATE_video_yt_table.sql`
3. **Copia TUTTO il contenuto** del file
4. **Incolla** nella textarea di phpMyAdmin
5. Clicca **"Esegui"** (o "Go")

### **1.3 - Verifica Risultato**

Dovresti vedere messaggi come:
```
✅ Colonna inizio_brano aggiunta
✅ Colonna fine_brano aggiunta
✅ Colonna domanda aggiunta
```

**OPPURE** se i campi esistono già:
```
ℹ️ Colonna inizio_brano già esistente
ℹ️ Colonna fine_brano già esistente
ℹ️ Colonna domanda già esistente
```

### **1.4 - Verifica Manuale Struttura Tabella**

1. Nel menu a sinistra, clicca su **"video_yt"**
2. Clicca sulla tab **"Struttura"**
3. **Verifica che esistano** questi campi:
   - `id_video` (INT, PRIMARY KEY)
   - `nome_video` (VARCHAR)
   - `categoria` (VARCHAR)
   - `link_youtube` (VARCHAR)
   - `nome_utente` (VARCHAR)
   - **`inizio_brano`** (INT, DEFAULT 0) ← **NUOVO**
   - **`fine_brano`** (INT, DEFAULT 0) ← **NUOVO**
   - **`domanda`** (TEXT, DEFAULT NULL) ← **NUOVO**
   - `data_creazione` (VARCHAR)

✅ **Se tutti i campi sono presenti, il database è pronto!**

---

## 📂 STEP 2: Verifica che l'API sia Aggiornata su Aruba

### **2.1 - Controlla se l'API Esiste**

L'API dovrebbe già esistere in:
```
/agenda_timer/api/api_video_yt.php
```

**⚠️ IMPORTANTE:** Se l'API NON esiste su Aruba, devi caricarla anche quella!

### **2.2 - Carica/Aggiorna l'API (se necessario)**

**Via FTP:**

1. Connettiti al server FTP Aruba
2. Vai nella cartella: `/agenda_timer/api/`
3. Carica il file: `api_video_yt.php` dalla tua cartella locale:
   ```
   C:\MAMP\htdocs\Assistivetech\agenda_timer\api\api_video_yt.php
   ```
4. **Sovrascrivi** se esiste già

**Verifica che l'API caricate contenga:**
- ✅ Auto-detection localhost/produzione (righe ~14-33)
- ✅ Gestione campi `inizio_brano`, `fine_brano`, `domanda` (righe ~104-106)
- ✅ Query INSERT completa con i nuovi campi (righe ~125-128)
- ✅ Query SELECT completa con i nuovi campi (righe ~198-212)

---

## 📤 STEP 3: Carica l'Applicazione via FTP

### **3.1 - Connetti FTP**

**Dati connessione Aruba:**
- **Host:** `ftp.assistivetech.it` (o il tuo host FTP)
- **Username:** [il tuo username FTP]
- **Password:** [la tua password FTP]
- **Porta:** 21 (o 22 per SFTP)

### **3.2 - Identifica la Cartella di Destinazione**

Su Aruba, la struttura dovrebbe essere:
```
/
├── agenda_timer/
│   └── api/
│       └── api_video_yt.php (già caricata nello step 2)
├── training_cognitivo/
│   └── strumenti/
│       ├── ascolto_la_musica/
│       └── ascolto_e_rispondo/  ← QUI VA CARICATA!
```

**Path completo di destinazione:**
```
/training_cognitivo/strumenti/ascolto_e_rispondo/
```

### **3.3 - Carica la Cartella Completa**

**Da locale:**
```
C:\MAMP\htdocs\Assistivetech\training_cognitivo\strumenti\ascolto_e_rispondo\
```

**Carica su Aruba:**
```
/training_cognitivo/strumenti/ascolto_e_rispondo/
```

**Contenuto da caricare:**
```
ascolto_e_rispondo/
├── index.html
├── manifest.json
├── service-worker.js
├── assets/
│   ├── icons/
│   │   ├── icon-192.png
│   │   └── icon-512.png
│   ├── images/
│   │   └── ascolto.png
│   ├── crea_icone.html (opzionale)
│   ├── migrazione_storage.html (opzionale - per utenti che hanno già dati)
│   ├── ISTRUZIONI_ICONE.md (opzionale - documentazione)
│   └── README_MIGRAZIONE.md (opzionale - documentazione)
├── css/
│   └── styles.css
└── js/
    └── app.js
```

**⚠️ File Opzionali:** I file `.md`, `.html` nella cartella `assets/` sono documentazione/tool. Non sono necessari per il funzionamento dell'app, ma utili per supporto.

### **3.4 - Verifica Upload**

Dopo l'upload, verifica che tutti i file siano stati caricati:

**Via FTP:** Controlla che la struttura cartelle sia identica  
**Via Browser:** Prova ad accedere a:
```
https://www.assistivetech.it/training_cognitivo/strumenti/ascolto_e_rispondo/index.html
```

Dovresti vedere la pagina di login dell'app (seleziona modalità Educatore o Utente).

---

## ✅ STEP 4: Test Completo dell'Applicazione

### **4.1 - Test Modalità Educatore (Online)**

1. Apri: `https://www.assistivetech.it/training_cognitivo/strumenti/ascolto_e_rispondo/`
2. Clicca **"Modalità Educatore"**
3. Inserisci nome utente (es: "TestEducatore")
4. **Compila il form:**
   - Digita categoria: "test canzoni"
   - Attendi 1 secondo → **dovrebbe aprirsi YouTube** a destra
   - Copia un link YouTube (es: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`)
   - Incolla nel campo "Link YouTube"
   - Nome brano: "Test Brano"
   - Inizio: 0:10
   - Fine: 0:30
   - Domanda: "Cosa hai sentito?"
5. Clicca **"Salva esercizio"**
6. **Risultato atteso:** ✅ "Esercizio salvato con successo!"

### **4.2 - Verifica Database**

1. Torna su **phpMyAdmin**
2. Vai su tabella **"video_yt"**
3. Clicca **"Sfoglia"**
4. **Dovresti vedere** il record appena creato con:
   - `nome_utente`: TestEducatore
   - `nome_video`: Test Brano
   - `inizio_brano`: 10
   - `fine_brano`: 30
   - `domanda`: Cosa hai sentito?

✅ **Se vedi il record con tutti i campi, il salvataggio funziona!**

### **4.3 - Test Modalità Utente (Lettura)**

1. Ricarica l'app: `https://www.assistivetech.it/training_cognitivo/strumenti/ascolto_e_rispondo/`
2. Clicca **"Modalità Utente"**
3. Inserisci **lo stesso nome utente** usato prima: "TestEducatore"
4. **Dovresti vedere:**
   - Il brano "Test Brano" nella lista
   - Il testo della domanda: "Cosa hai sentito?"
   - Il bottone speaker 🔊 per ripetere la domanda
5. Clicca sul brano
6. **Dovrebbe:**
   - Caricare il video YouTube
   - Partire dal secondo 10
   - Fermarsi al secondo 30
   - Leggere la domanda con TTS: "Cosa hai sentito?"
   - Spostare il focus sul brano successivo (se esiste)

✅ **Se tutto funziona, l'app è completamente operativa!**

### **4.4 - Test Focus e Navigazione (Accessibilità)**

1. Nella modalità utente, con più brani:
2. **Premi TAB** → il primo brano dovrebbe avere il focus (bordo viola pulsante)
3. **Premi SPAZIO** → il brano si attiva
4. Dopo la domanda → il focus va automaticamente al brano successivo
5. **Premi Freccia GIÙ** → focus sul brano successivo
6. **Premi Freccia SU** → focus sul brano precedente
7. **Premi SPAZIO** → attiva il brano con focus

✅ **Se la navigazione da tastiera funziona, l'accessibilità è ok!**

---

## 🔧 STEP 5: Configurazione PWA (Opzionale ma Raccomandato)

### **5.1 - Test Installazione PWA**

1. Apri l'app in **Chrome** o **Edge**
2. Cerca l'icona **"Installa"** nella barra degli indirizzi (icona +)
3. Clicca **"Installa app"**
4. L'app dovrebbe installarsi come applicazione nativa
5. **Verifica:**
   - Le icone personalizzate sono visibili (192x192 e 512x512)
   - L'app si apre in finestra standalone (senza barra browser)
   - Funziona offline (modalità localStorage)

### **5.2 - Test Offline**

1. Con l'app aperta, **disabilita la connessione internet**
2. Ricarica la pagina
3. L'app dovrebbe:
   - ✅ Ancora caricarsi (grazie al service worker)
   - ✅ Mostrare messaggio "Modalità OFFLINE"
   - ✅ Permettere di salvare esercizi in localStorage
   - ✅ Sincronizzare quando torni online (se implementato)

---

## 🆘 TROUBLESHOOTING

### **Problema 1: "Errore di connessione al database"**

**Causa:** L'API non riesce a connettersi al database Aruba

**Soluzione:**
1. Verifica che l'API `api_video_yt.php` sia caricata in `/agenda_timer/api/`
2. Apri l'API e verifica le credenziali (righe 26-32):
   ```php
   'host' => '31.11.39.242',
   'user' => 'Sql1073852',
   'pass' => '5k58326940',
   'db'   => 'Sql1073852_1',
   ```
3. Verifica che il database sia raggiungibile da Aruba
4. Controlla i log PHP su Aruba per errori specifici

---

### **Problema 2: "I campi inizio_brano, fine_brano, domanda non si salvano"**

**Causa:** La tabella `video_yt` non ha i campi nuovi

**Soluzione:**
1. Torna su **phpMyAdmin**
2. Vai su tabella **"video_yt" → Struttura**
3. **Verifica che ci siano** i 3 campi: `inizio_brano`, `fine_brano`, `domanda`
4. Se mancano, **esegui di nuovo** lo script SQL (STEP 1.2)
5. Se lo script dà errore, aggiungi i campi manualmente:
   ```sql
   ALTER TABLE video_yt ADD COLUMN inizio_brano INT DEFAULT 0;
   ALTER TABLE video_yt ADD COLUMN fine_brano INT DEFAULT 0;
   ALTER TABLE video_yt ADD COLUMN domanda TEXT DEFAULT NULL;
   ```

---

### **Problema 3: "CORS error" o "Access-Control-Allow-Origin"**

**Causa:** L'API blocca le richieste da domini esterni

**Soluzione:**
1. Apri `api_video_yt.php` (riga 3):
   ```php
   header('Access-Control-Allow-Origin: *');
   ```
2. Se vuoi restringere solo a assistivetech.it:
   ```php
   header('Access-Control-Allow-Origin: https://www.assistivetech.it');
   ```
3. Salva e ricarica l'API su Aruba

---

### **Problema 4: "Le icone non si vedono / Icone vecchie"**

**Causa:** Cache del browser o service worker

**Soluzione:**
1. **Cancella cache browser:** `Ctrl + Shift + Delete`
2. **Disinstalla PWA** se installata
3. **Hard refresh:** `Ctrl + Shift + R`
4. Verifica che le icone siano state caricate su Aruba:
   ```
   /training_cognitivo/strumenti/ascolto_e_rispondo/assets/icons/icon-192.png
   /training_cognitivo/strumenti/ascolto_e_rispondo/assets/icons/icon-512.png
   ```
5. Se le icone non ti piacciono, usa il tool: `assets/crea_icone.html` per generarne di nuove

---

### **Problema 5: "Modalità offline sempre attiva / Non usa il database"**

**Causa:** L'app non riesce a raggiungere l'API

**Soluzione:**
1. Apri **DevTools** (`F12`) → tab **Console**
2. Cerca errori come "Failed to fetch" o "404 Not Found"
3. Verifica l'URL dell'API nel codice:
   - In `js/app.js` (riga 21) dovrebbe essere:
     ```javascript
     return '/agenda_timer/api/api_video_yt.php';
     ```
4. Verifica che l'API sia accessibile:
   ```
   https://www.assistivetech.it/agenda_timer/api/api_video_yt.php?action=get_pazienti
   ```
   Dovrebbe restituire un JSON (anche vuoto)

---

### **Problema 6: "I dati di 'ascolto la musica' si vedono in 'ascolto e rispondo'"**

**Causa:** localStorage condiviso tra le due app

**Soluzione:**
1. **L'app è già configurata** per usare chiavi separate: `ascolto_rispondo_`
2. Se hai dati vecchi, usa il tool di migrazione:
   ```
   https://www.assistivetech.it/training_cognitivo/strumenti/ascolto_e_rispondo/assets/migrazione_storage.html
   ```
3. Clicca **"Avvia Migrazione"**
4. I dati verranno copiati con le nuove chiavi separate

---

### **Problema 7: "Il video YouTube non parte / non si ferma ai tempi giusti"**

**Causa:** YouTube IFrame API non caricata o errori di timing

**Soluzione:**
1. Verifica che il link YouTube sia valido e pubblico
2. Alcuni video hanno restrizioni embed → usa un altro video
3. Controlla console per errori API YouTube
4. Verifica che i tempi siano in **secondi** (non minuti):
   - ❌ Sbagliato: `1:30` (testo)
   - ✅ Corretto: `90` (secondi)

---

## 📊 Checklist Post-Deployment

Dopo aver completato tutti gli step, verifica:

- ✅ Database aggiornato con i 3 nuovi campi
- ✅ API `api_video_yt.php` caricata e funzionante
- ✅ Applicazione `ascolto_e_rispondo` caricata in `/training_cognitivo/strumenti/`
- ✅ Modalità Educatore funziona (salvataggio con domande)
- ✅ Modalità Utente funziona (lettura e TTS)
- ✅ Focus automatico e navigazione tastiera funzionano
- ✅ Icone visibili (192x192 e 512x512)
- ✅ PWA installabile (opzionale)
- ✅ Modalità offline funziona (opzionale)
- ✅ localStorage separato da "ascolto la musica"

---

## 🎉 DEPLOYMENT COMPLETATO!

Se tutti i test sono passati, l'applicazione **"ascolto e rispondo"** è ora **live su Aruba**!

**URL pubblico:**
```
https://www.assistivetech.it/training_cognitivo/strumenti/ascolto_e_rispondo/
```

**Puoi condividere questo link con:**
- Educatori → per creare esercizi
- Utenti → per usare gli esercizi (anche offline dopo installazione PWA)

---

## 📞 Supporto

Per problemi o domande, consulta:
- **Documentazione tecnica:** `SEPARAZIONE_STORAGE.md`
- **Guida migrazione:** `assets/README_MIGRAZIONE.md`
- **Guida icone:** `assets/ISTRUZIONI_ICONE.md`
- **Tool migrazione:** `assets/migrazione_storage.html`
- **Tool creazione icone:** `assets/crea_icone.html`

---

**📅 Data guida:** 2024-11-11  
**✏️ Versione app:** 2.0.0  
**🚀 Deployment:** Aruba (assistivetech.it)

