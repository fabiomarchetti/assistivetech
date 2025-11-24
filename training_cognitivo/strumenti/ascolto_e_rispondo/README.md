# 🎵 ascolto e rispondo - AssistiveTech

## 📋 Descrizione

**ascolto e rispondo** è uno strumento di training cognitivo che permette agli utenti di ascoltare porzioni specifiche di brani musicali o audio da YouTube e rispondere a domande poste automaticamente al termine dell'ascolto.

### 🎯 Funzionalità principali

- **Area Educatore**: Permette di creare esercizi personalizzati specificando:
  - Brano YouTube
  - Tempo di inizio e fine dell'ascolto
  - Domanda da porre al termine
  
- **Area Utente**: Permette di:
  - Selezionare e riprodurre gli esercizi assegnati
  - Ascoltare automaticamente dal tempo di inizio al tempo di fine
  - Sentire la domanda letta con sintesi vocale (TTS) dopo 3 secondi dalla fine

## 🗄️ Database

### Campi aggiunti alla tabella `video_yt`

Esegui lo script SQL fornito (`database_update.sql`) su phpMyAdmin:

```sql
ALTER TABLE `video_yt` 
ADD COLUMN `inizio_brano` INT(11) NULL DEFAULT 0 COMMENT 'Tempo di inizio in secondi';

ALTER TABLE `video_yt` 
ADD COLUMN `fine_brano` INT(11) NULL DEFAULT 0 COMMENT 'Tempo di fine in secondi';

ALTER TABLE `video_yt` 
ADD COLUMN `domanda` TEXT NULL COMMENT 'Domanda da porre dopo l\'ascolto';
```

## 🚀 Installazione

1. **Esegui lo script SQL**: Apri phpMyAdmin, seleziona il database e esegui il contenuto del file `database_update.sql`

2. **Carica i file**: Assicurati che tutti i file siano nella cartella corretta:
   ```
   strumenti/ascolto_e_rispondo/
   ├── index.html
   ├── css/styles.css
   ├── js/app.js
   ├── manifest.json
   ├── service-worker.js
   ├── database_update.sql
   ├── assets/
   │   └── icons/
   │       ├── icon-192.png
   │       └── icon-512.png
   └── README.md
   ```

3. **Verifica l'API**: Assicurati che l'endpoint API sia corretto:
   - Localhost: `/Assistivetech/agenda_timer/api/api_video_yt.php`
   - Produzione: `/agenda_timer/api/api_video_yt.php`

## 📱 Modalità PWA

L'applicazione è installabile come Progressive Web App (PWA):
- Funziona offline con localStorage
- Si integra nel sistema operativo
- Nasconde automaticamente i link esterni quando installata

## 🎓 Come funziona

### Area Educatore

1. Accedi all'**Area Educatore**
2. Inserisci il **nome dell'utente**
3. Cerca il brano su YouTube e **copia il link**
4. Imposta i **tempi di inizio e fine** (minuti e secondi)
5. Scrivi la **domanda** che verrà posta al termine
6. Clicca **"Salva esercizio"**

### Area Utente

1. Accedi all'**Area Utente**
2. Seleziona il tuo nome
3. Clicca su un **esercizio dalla lista**
4. Il brano partirà automaticamente dal tempo di inizio
5. Si fermerà al tempo di fine
6. Dopo **3 secondi**, sentirai la domanda letta con sintesi vocale

## 🔊 Sintesi Vocale (TTS)

L'applicazione usa l'API Web Speech del browser per leggere automaticamente la domanda:
- **Lingua**: Italiano (it-IT)
- **Velocità**: 0.9 (leggermente ridotta per chiarezza)
- **Supporto**: Tutti i browser moderni (Chrome, Firefox, Edge, Safari)

## 🛠️ Tecnologie utilizzate

- **Frontend**: HTML5, CSS3, JavaScript ES6+
- **Player**: YouTube IFrame API
- **TTS**: Web Speech API
- **Storage**: Database MySQL + localStorage (offline)
- **PWA**: Service Worker + Manifest

## 📊 Versione

**Versione**: 1.0.0  
**ID Strumento**: 31  
**Data**: Novembre 2025

## 📄 Licenza

Sviluppato per AssistiveTech.it - Training Cognitivo

---

**Nota**: Per qualsiasi problema o domanda, contatta il team di sviluppo AssistiveTech.
