# Changelog - Tempi di Ascolto Brano

## Versione 3.3.0 - Aggiunta Gestione Tempi Inizio/Fine Brano

### Nuove Funzionalità

**1. Campi Tempo nel Form Educatore**
- Aggiunto campo "Tempo di inizio ascolto" (opzionale) con input minuti e secondi
- Aggiunto campo "Tempo di fine ascolto" (opzionale) con input minuti e secondi
- Entrambi i campi sono opzionali: se non compilati, il brano viene riprodotto per intero
- Validazione: il tempo di fine deve essere maggiore del tempo di inizio

**2. Player YouTube Intelligente**
- Il player fa automaticamente il "seek" al tempo di inizio impostato
- Il player si ferma automaticamente al tempo di fine impostato
- Monitoraggio continuo del tempo con precisione di 250ms

**3. Visualizzazione Tempi nella Lista Brani**
- I brani con tempi impostati mostrano un'icona orologio (🕐) arancione
- Formato visualizzato: "M:SS" (es: "2:30" per 2 minuti e 30 secondi)
- Tre modalità di visualizzazione:
  - Solo inizio: "Inizio: M:SS"
  - Solo fine: "Fine: M:SS"
  - Entrambi: "M:SS - M:SS"

**4. Salvataggio Dati**
- I tempi vengono salvati sia nel database MySQL (modalità online)
- I tempi vengono salvati nel localStorage (modalità offline/PWA)
- Compatibilità totale con l'app "ascolto e rispondo" (stessa tabella)

### Modifiche Tecniche

**File Modificati:**
- `js/app.js`:
  - Aggiornato `renderEducatorUI()` per includere campi tempo
  - Aggiornato `cacheEducatorRefs()` per referenziare i nuovi campi
  - Modificato `handleFormSubmit()` per calcolare e salvare i tempi in secondi
  - Aggiornato `selectBrano()` per recuperare i tempi dal brano
  - Modificato `onPlayerReady()` per fare seek al tempo iniziale
  - Modificato `onPlayerStateChange()` per gestire monitoring tempo finale
  - Aggiunte funzioni `startEndTimeMonitor()` e `stopEndTimeMonitor()`
  - Aggiornate visualizzazioni lista brani (online e locale) con formattazione tempi
  - Aggiunto `endTimeMonitorInterval` all'`appState`

**Struttura Database:**
- Colonne utilizzate nella tabella `video_yt`:
  - `inizio_brano` (INT, DEFAULT 0) - Tempo in secondi di inizio
  - `fine_brano` (INT, DEFAULT 0) - Tempo in secondi di fine
  - `domanda` (TEXT, DEFAULT NULL) - NON usata da "ascolto la musica", solo da "ascolto e rispondo"

### Compatibilità

**Condivisione Tabella con "ascolto e rispondo":**
- ✅ Le due app condividono la stessa tabella `video_yt`
- ✅ "ascolto la musica" usa SOLO i campi: `inizio_brano`, `fine_brano`
- ✅ "ascolto e rispondo" usa TUTTI i campi: `inizio_brano`, `fine_brano`, `domanda`
- ✅ Non ci sono conflitti: il campo `domanda` viene ignorato da "ascolto la musica"

**Retrocompatibilità:**
- ✅ I brani senza tempi impostati vengono riprodotti per intero
- ✅ I brani esistenti continuano a funzionare normalmente
- ✅ Modalità offline (localStorage) completamente supportata

### Deploy su Aruba

**Prima di caricare l'app aggiornata:**

1. **Eseguire lo script SQL:**
   ```bash
   UPDATE_DATABASE_ARUBA.sql
   ```

2. **Verificare che le colonne siano state create:**
   ```sql
   DESCRIBE video_yt;
   ```

3. **Caricare i file via FTP:**
   - `js/app.js` (aggiornato)
   - Altri file non modificati

**IMPORTANTE:** Lo script SQL è idempotente, può essere eseguito più volte senza problemi.

### Testing

**Test da effettuare:**

1. **Area Educatore - Online:**
   - [ ] Inserire brano senza tempi → deve salvare con inizio_brano=0, fine_brano=0
   - [ ] Inserire brano solo con tempo inizio → deve salvare solo inizio_brano
   - [ ] Inserire brano solo con tempo fine → deve salvare solo fine_brano
   - [ ] Inserire brano con entrambi i tempi → deve validare che fine > inizio

2. **Area Utente - Riproduzione:**
   - [ ] Brano senza tempi → deve partire dall'inizio e andare fino alla fine
   - [ ] Brano con tempo inizio → deve partire dal secondo specificato
   - [ ] Brano con tempo fine → deve fermarsi al secondo specificato
   - [ ] Brano con entrambi → deve partire e fermarsi ai tempi corretti

3. **Modalità Offline/PWA:**
   - [ ] Salvare brani con tempi in localStorage
   - [ ] Visualizzare brani con tempi dalla lista
   - [ ] Riprodurre brani con tempi in modalità offline

4. **Visualizzazione:**
   - [ ] I tempi appaiono nella lista brani con icona orologio arancione
   - [ ] Il formato è corretto (M:SS)

### Note per lo Sviluppatore

**Conversione Tempi:**
```javascript
// Minuti e secondi → Secondi totali
const inizioBrano = (inizioMin * 60) + inizioSec;

// Secondi totali → Formato M:SS
const formatTime = (seconds) => {
  const min = Math.floor(seconds / 60);
  const sec = seconds % 60;
  return `${min}:${sec.toString().padStart(2, '0')}`;
};
```

**Monitoraggio Tempo Fine:**
```javascript
// Controllo ogni 250ms per precisione
appState.endTimeMonitorInterval = setInterval(() => {
  const currentTime = appState.youtubePlayer.getCurrentTime();
  if (currentTime >= fineSecondi) {
    appState.youtubePlayer.pauseVideo();
    stopEndTimeMonitor();
  }
}, 250);
```

### Contatti

Per domande o problemi, consulta il team di sviluppo AssistiveTech.
