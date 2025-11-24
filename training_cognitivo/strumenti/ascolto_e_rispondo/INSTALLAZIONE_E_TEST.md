# 🚀 Guida Installazione e Test - ascolto e rispondo

## ✅ CHECKLIST PRE-INSTALLAZIONE

### 1️⃣ Database - SCRIPT SQL

**File**: `database_update.sql`

**Procedura**:
1. Apri **phpMyAdmin**
2. Seleziona il database AssistiveTech
3. Vai alla tab **SQL**
4. Copia e incolla il contenuto del file `database_update.sql`
5. Clicca **Esegui**

**Verifica**: Controlla che la tabella `video_yt` abbia i nuovi campi:
- `inizio_brano` (INT)
- `fine_brano` (INT)
- `domanda` (TEXT)

---

### 2️⃣ Struttura File

Verifica che tutti i file siano presenti:

```
ascolto_e_rispondo/
├── index.html ✅
├── database_update.sql ✅
├── README.md ✅
├── INSTALLAZIONE_E_TEST.md ✅
├── manifest.json ✅
├── service-worker.js ✅
├── css/
│   └── styles.css ✅
├── js/
│   └── app.js ✅
└── assets/
    └── icons/
        ├── icon-192.png ✅
        └── icon-512.png ✅
```

---

### 3️⃣ Verifica API Endpoint

Il file `js/app.js` usa automaticamente il path corretto:

- **Localhost MAMP**: `/Assistivetech/agenda_timer/api/api_video_yt.php`
- **Produzione Aruba**: `/agenda_timer/api/api_video_yt.php`

**Verifica**: Controlla che l'API esistente (`api_video_yt.php`) gestisca i nuovi campi:
- Deve accettare `inizio_brano`, `fine_brano`, `domanda` nel payload di salvataggio
- Deve restituire questi campi nella lista dei brani

---

## 🧪 TEST DELL'APPLICAZIONE

### Test 1: Area Educatore - Creazione Esercizio

1. Apri l'app: `http://localhost/Assistivetech/training_cognitivo/strumenti/ascolto_e_rispondo/`
2. Clicca **"Area Educatore"**
3. Compila il form:
   - **Nome utente**: Mario Rossi
   - **Categoria**: Test musica
   - **Link YouTube**: https://www.youtube.com/watch?v=dQw4w9WgXcQ
   - **Nome brano**: Test Brano
   - **Tempo inizio**: 0 minuti, 10 secondi
   - **Tempo fine**: 0 minuti, 30 secondi
   - **Domanda**: Quale strumento musicale hai sentito?
4. Clicca **"Salva esercizio"**
5. **Verifica**: Messaggio di successo "✅ Esercizio salvato!"

---

### Test 2: Verifica Database

1. Apri **phpMyAdmin**
2. Seleziona la tabella `video_yt`
3. Cerca il record appena inserito (nome_video = "Test Brano")
4. **Verifica campi**:
   - `inizio_brano` = 10
   - `fine_brano` = 30
   - `domanda` = "Quale strumento musicale hai sentito?"

---

### Test 3: Area Utente - Riproduzione

1. Torna alla home dell'app
2. Clicca **"Area Utente"**
3. Seleziona **"Mario Rossi"** dal menu
4. **Verifica**: Vedi l'esercizio nella lista con:
   - Nome brano
   - Tempo: ⏱️ 00:10 → 00:30
   - Domanda visualizzata sotto

---

### Test 4: Riproduzione con TTS

1. Clicca sul pulsante **Play** dell'esercizio
2. **Verifica**:
   - ✅ Il video parte dal secondo 10
   - ✅ Il video si ferma al secondo 30
   - ✅ Dopo 3 secondi appare l'indicatore TTS arancione
   - ✅ La domanda viene letta con sintesi vocale

**Nota**: Se il TTS non funziona:
- Verifica che il browser supporti Web Speech API (Chrome, Edge, Firefox)
- Controlla il volume del sistema
- Prova su un altro browser

---

### Test 5: Modalità Offline (localStorage)

1. Apri DevTools (F12)
2. Vai a **Network** → Seleziona **Offline**
3. Ricarica la pagina
4. Clicca **"Area Educatore"**
5. Inserisci un nuovo esercizio
6. **Verifica**: Messaggio "📱 MODALITÀ OFFLINE: Salvataggio locale"
7. Salva l'esercizio
8. Vai in **Area Utente** → Seleziona l'utente
9. **Verifica**: L'esercizio salvato localmente è visibile

---

### Test 6: PWA (Progressive Web App)

**Chrome/Edge**:
1. Apri l'app
2. Clicca sull'icona **"Installa"** nella barra degli indirizzi
3. Conferma l'installazione
4. **Verifica**: L'app si apre in finestra standalone
5. **Verifica**: Il pulsante "Torna alla home" è nascosto (PWA isolata)

**Mobile (Android/iOS)**:
1. Apri l'app in Chrome/Safari
2. Menu → **"Aggiungi a schermata Home"**
3. Apri l'app dalla home
4. **Verifica**: Funziona come app nativa

---

## 🐛 RISOLUZIONE PROBLEMI

### Problema: "Errore caricamento pazienti"

**Soluzione**:
- Verifica che l'API endpoint sia corretto
- Controlla che il database sia raggiungibile
- Verifica i permessi CORS se su dominio diverso

---

### Problema: Video non parte dal tempo corretto

**Soluzione**:
- Verifica che `inizio_brano` e `fine_brano` siano in secondi (non minuti)
- Controlla che l'API YouTube sia caricata (F12 → Console)
- Alcuni video YouTube potrebbero avere restrizioni di skip

---

### Problema: TTS non funziona

**Soluzione**:
- Verifica supporto browser: `window.speechSynthesis` (Chrome/Edge/Firefox)
- Prova a cambiare browser
- Verifica volume sistema
- Su iOS Safari, il TTS funziona solo con interazione utente

---

### Problema: PWA non si installa

**Soluzione**:
- Verifica che `manifest.json` sia accessibile
- Controlla che il Service Worker sia registrato (F12 → Application → Service Workers)
- Verifica HTTPS (PWA richiede connessione sicura, tranne localhost)

---

## 📊 MODIFICHE API (SE NECESSARIO)

Se l'API esistente (`api_video_yt.php`) NON gestisce i nuovi campi, aggiungi:

### Nel metodo `save()`:

```php
$inizio_brano = isset($data['inizio_brano']) ? intval($data['inizio_brano']) : 0;
$fine_brano = isset($data['fine_brano']) ? intval($data['fine_brano']) : 0;
$domanda = isset($data['domanda']) ? $data['domanda'] : '';

// Nella query INSERT:
INSERT INTO video_yt 
(nome_video, categoria, link_youtube, nome_utente, inizio_brano, fine_brano, domanda, ...) 
VALUES (?, ?, ?, ?, ?, ?, ?, ...)
```

### Nel metodo `list()`:

```php
SELECT id_video, nome_video, categoria, link_youtube, inizio_brano, fine_brano, domanda, ... 
FROM video_yt 
WHERE nome_utente = ?
```

---

## ✅ CHECKLIST FINALE

Prima di considerare l'installazione completa, verifica:

- [ ] Script SQL eseguito con successo
- [ ] Campi aggiunti alla tabella `video_yt`
- [ ] Area Educatore: salvataggio esercizio funzionante
- [ ] Database: record salvato con campi corretti
- [ ] Area Utente: visualizzazione esercizi
- [ ] Riproduzione: video parte e si ferma ai tempi corretti
- [ ] TTS: domanda letta automaticamente dopo 3 secondi
- [ ] Modalità offline: salvataggio in localStorage funzionante
- [ ] PWA: installazione e funzionamento standalone

---

## 🎉 COMPLETAMENTO

Se tutti i test sono superati, l'applicazione **ascolto e rispondo** è pronta per l'uso in produzione!

**Versione**: 1.0.0  
**Data completamento**: Novembre 2025

---

**Domande o problemi?** Contatta il team di sviluppo AssistiveTech.





