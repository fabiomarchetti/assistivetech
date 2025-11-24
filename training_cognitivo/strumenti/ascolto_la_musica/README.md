# ascolto la musica

Strumento di Training Cognitivo - AssistiveTech.it

## Informazioni

- **ID Strumento**: 30
- **Nome**: ascolto la musica
- **Tipo**: Progressive Web App (PWA) con JavaScript Vanilla
- **Versione**: 3.2.5
- **Ottimizzato per**: Utenti ipovedenti e con deficit cognitivi
- **Modalità**: Online (con database) e Offline (con localStorage)
- **PWA Standalone**: Nessun link esterno quando installata come app
- **Navigazione rapida**: Switch istantaneo tra Area Educatore e Area Utente
- **PWA Ibrida**: Funziona online con internet, offline con localStorage

## Struttura Progetto

```
ascolto la musica/
├── index.html              # Pagina principale PWA
├── manifest.json           # Configurazione PWA
├── service-worker.js       # Service Worker per funzionalità offline
├── README.md              # Questa documentazione
├── css/
│   └── styles.css         # Stili personalizzati
├── js/
│   └── app.js             # Logica applicazione (JavaScript Vanilla)
└── assets/
    ├── icons/             # Icone PWA (da aggiungere)
    └── images/            # Immagini strumento
```

## Funzionalità Principali

### Modalità Educatore

**Online (con database)**:
- **Gestione brani**: Aggiungi nuovi brani YouTube per i pazienti
- **Ricerca integrata**: YouTube si apre automaticamente in una finestra separata (2/3 dello schermo)
- **Gestione pazienti**: Assegna brani specifici ai pazienti dal database
- **Dropdown pazienti**: Selezione da lista caricata dal DB
- **Preview**: Anteprima video prima del salvataggio

**Offline (modalità locale)**:
- **Campo testo utente**: Inserisci manualmente il nome utente (con autocompletamento)
- **Autocompletamento**: Suggerisce utenti già esistenti in localStorage
- **Salvataggio locale**: I brani vengono salvati direttamente in localStorage
- **Indicatore modalità**: Badge "OFFLINE" visibile nell'header
- **Nessun DB**: Funziona completamente senza connessione internet

### Modalità Utente
- **Layout ottimizzato per ipovedenti**:
  - Box lista brani a sinistra (400px fissi)
  - Player grande a destra (tutto lo spazio rimanente)
  - Font grandi e ad alto contrasto
  - Bordi e icone prominenti

- **Ascolto Diretto** (modalità default):
  - Seleziona un brano dalla lista o premi SPACE
  - Il brano parte e continua senza pause
  - Ideale per ascolto continuo e ininterrotto

- **Ascolto Random**:
  - Riproduzione casuale dalla lista brani
  - Pulsante dedicato nel menu opzioni
  - Ogni brano parte fino alla fine

- **Ascolto Temporizzato**:
  - Timer configurabile (5-120 secondi)
  - Pausa automatica dopo il tempo impostato
  - Indicatore visivo per riprendere (SPACE)
  - Gestisce tasto SPACE sia premuto che rilasciato
  - Ripresa riproduzione con nuovo timer

- **Controllo con tastiera**:
  - **SPACE in modalità Diretto**: Avvia l'ultimo brano selezionato
  - **SPACE in modalità Temporizzato**: Riprende dopo pausa timer
  - **SPACE in modalità Random**: Nessun effetto
  - Funziona anche se l'utente tiene premuto il tasto

### Menu Opzioni Laterale
- **Scelta modalità**:
  - ⚪ Ascolto Diretto (default)
  - ⚪ Ascolto Random
  - ⚪ Ascolto Temporizzato
- **Slider durata timer**: Visibile solo in modalità temporizzata
- **Info box contestuale**: Cambia in base alla modalità selezionata
- **Pulsante dinamico**: 
  - "Play Brano Diretto" → Avvia ultimo brano selezionato
  - "Play Brano Random" → Avvia brano casuale
  - "Play Brano Temporizzato" → Avvia brano random con timer
- **Overlay**: Chiusura con click esterno

## Modalità Online vs Offline

### Modalità Online (con Database)
**Quando si attiva**: L'app ha accesso al database Aruba (connessione internet disponibile)

**Funzionalità**:
- **Area Educatore**: Aggiungi e gestisci brani per i pazienti dal DB
- **Area Utente**: Seleziona nome utente da dropdown (lista dal database)
- **Sincronizzazione**: Brani salvati online vengono copiati anche in localStorage per uso offline futuro
- **Gestione completa**: CRUD completo su brani e utenti

### Modalità Offline (Locale)
**Quando si attiva**: L'app non riesce a connettersi al database (es: dispositivo portatile senza internet)

**Funzionalità**:
- **Login semplice**: Campo di testo libero per inserire il nome utente
- **Storage locale**: Tutti i brani sono salvati in localStorage del browser
- **Multi-utente**: Supporto per più utenti sullo stesso dispositivo
- **Cambia utente**: Pulsante dedicato nel menu laterale
- **Persistenza**: I dati rimangono salvati anche dopo chiusura browser

**Struttura localStorage**:
```javascript
// Utente corrente
localStorage.getItem('localUser') // "Mario"

// Brani per utente
localStorage.getItem('localBrani_Mario') // Array JSON di brani
localStorage.getItem('localBrani_Giulia') // Array JSON di brani
```

**Rilevamento automatico**:
L'app tenta di connettersi all'API all'avvio. Se fallisce (timeout 3 secondi), passa automaticamente in modalità offline.

## Accessibilità

Ottimizzato per utenti con:
- **Deficit visivi**: Font grandi, alto contrasto, video grande
- **Deficit cognitivi**: Controlli semplici, feedback visivo chiaro, gestione tasto SPACE flessibile

## Sviluppo

### Personalizzazione

#### 1. Modifica durata timer (js/app.js)
\`\`\`javascript
// Linea 15: modifica i valori min/max/default
timerDuration: 30, // secondi (default)
\`\`\`

#### 2. Personalizza colori (css/styles.css)
\`\`\`css
:root {
    --primary-color: #673AB7;
    --secondary-color: #9C27B0;
    /* Modifica i colori qui */
}
\`\`\`

#### 3. Aggiungi risorse (assets/)
- Inserisci immagini in `assets/images/`
- Aggiungi icone PWA in `assets/icons/` (192x192 e 512x512)

## Test Locale

### Opzione 1: Server PHP
\`\`\`bash
php -S localhost:8000
\`\`\`

### Opzione 2: Server Python
\`\`\`bash
python -m http.server 8080
\`\`\`

### Opzione 3: Live Server (VS Code)
Installa l'estensione "Live Server" e clicca su "Go Live"

## Deployment

L'app viene automaticamente deployata in:
- **URL**: https://assistivetech.it/training_cognitivo/[categoria]/ascolto la musica/
- **PWA**: Installabile come app standalone su dispositivi mobili e desktop

## Funzionalità PWA Incluse

✅ **Installabile**: Gli utenti possono installare l'app sul loro dispositivo
✅ **Offline**: Funziona anche senza connessione internet
✅ **Responsive**: Adattabile a tutti i dispositivi
✅ **Leggera**: Caricamento veloce, nessuna dipendenza pesante
✅ **Sicura**: HTTPS obbligatorio in produzione

## Note di Sviluppo

- **localStorage**: Usa `localStorage` per salvare progressi utente
- **Responsive**: Testa su mobile, tablet e desktop
- **Accessibilità**: Usa tag semantici e ARIA labels
- **Performance**: Mantieni JavaScript semplice e leggero
- **Icone**: Genera icone PWA con strumenti come [PWA Asset Generator](https://github.com/elegantapp/pwa-asset-generator)

## API Endpoint

L'applicazione utilizza l'API `api_video_yt.php` per:
- **GET pazienti**: `?action=get_pazienti`
- **GET brani utente**: `?action=list&nome_utente=Nome`
- **POST salva brano**: `action=save` con JSON payload

\`\`\`javascript
// Esempio salvataggio brano
const payload = {
    action: 'save',
    nome_video: 'Titolo brano',
    categoria: 'Categoria',
    link_youtube: 'https://youtube.com/...',
    nome_utente: 'Nome Paziente'
};
\`\`\`

## Tecnologie Utilizzate

- **JavaScript Vanilla ES6+**: Nessuna dipendenza esterna
- **Bootstrap Icons**: Per icone UI
- **YouTube IFrame Player API**: Per controllo avanzato del player (play/pause/resume)
- **CSS Grid/Flexbox**: Layout responsive
- **localStorage**: Salvataggio stato (opzionale)

## Icone PWA

Le icone per l'app sono state generate automaticamente nelle dimensioni:
- `assets/icons/icon-192.png` (192x192px)
- `assets/icons/icon-512.png` (512x512px)

Per rigenerare le icone da una nuova immagine sorgente:
1. Sostituisci `assets/img/icon.png` con la nuova immagine
2. Esegui: `npm run generate-icons`

Vedi [GENERATE_ICONS.md](GENERATE_ICONS.md) per maggiori dettagli.

## Changelog

### v3.2.5 (Popup YouTube Ottimizzata per Tablet) 📱✨
- 📱 **TABLET-OPTIMIZED**: Popup YouTube ottimizzata specificamente per tablet (iPad, Android)
- ✅ **Dimensioni Adattive**:
  - **Su TABLET**: Popup al **50%** della larghezza schermo (metà display)
  - **Su DESKTOP**: Popup al **66.67%** della larghezza schermo (2/3 display)
- ✅ **Rilevamento Automatico**: Identifica dispositivi tablet basandosi su:
  - User-Agent (iPad, Android)
  - Risoluzione schermo (768px - 1366px)
  - Orientamento dispositivo
- ✅ **Posizionamento Ottimale**: Popup sempre allineata sul **bordo destro** dello schermo
- ✅ **Console Log**: Mostra info dettagliate su device e dimensioni popup
  - `📱 Device: TABLET - Popup YouTube: 512x768px (50% larghezza)`
  - `📱 Device: DESKTOP - Popup YouTube: 853x768px (67% larghezza)`
- 🎯 **Caso d'uso**: Su iPad la popup non copre più tutto lo schermo, lasciando spazio all'app
- 🎯 **UX Migliorata**: L'educatore può vedere contemporaneamente app e YouTube su tablet

**Problema Risolto**:
L'utente segnalava che su iPad la popup YouTube si apriva a schermo intero, rendendo difficile copiare il link. Ora su tablet la popup occupa solo metà schermo (lato destro), permettendo di vedere sia l'app che YouTube contemporaneamente. Su desktop/laptop il comportamento rimane invariato (2/3 dello schermo).

### v3.2.3 (Fix Timing DOM + Retry Automatico) ⏱️🔧
- 🐛 **FIX CRITICO**: Risolto problema "frecce ancora visibili dopo cambio area"
- ✅ **Timing Corretto**: Aggiunto `setTimeout()` per attendere rendering completo del DOM
  - `renderEducatorUI()` → attende 100ms prima di nascondere link
  - `renderUserUI()` → attende 100ms prima di nascondere link
  - `startEducatorMode()` → attende 150ms (dopo promises async)
  - `startUserMode()` → attende 150ms (dopo promises async)
- ✅ **Sistema di Retry**: Se non trova pulsanti `.btn-back`, riprova dopo 200ms
- ✅ **Log Diagnostici Dettagliati**:
  - `🔍 Trovati X pulsanti con classe .btn-back`
  - `❌ PROBLEMA: Nessun pulsante .btn-back trovato! Riprovo...`
  - `🔄 Retry: Trovati X pulsanti .btn-back`
  - `📋 Elementi nel DOM:` (primi 500 caratteri se errore)
- ✅ **Attributi Aggiuntivi**: Oltre agli stili, ora imposto anche:
  - `disabled = true` (pulsanti non cliccabili)
  - `aria-hidden = "true"` (nascosti agli screen reader)
- ✅ **Robustezza Totale**: Il sistema riprova automaticamente se il DOM non è pronto
- 🎯 **Problema Risolto**: Frecce ora si nascondono **sempre**, anche dopo cambio area

**Problema Risolto**:
L'utente segnalava che le frecce erano ancora visibili sia nell'area educatore che utente nella PWA. Il problema era il **timing**: `detectPWAMode()` veniva chiamato troppo presto, prima che il DOM fosse completamente renderizzato. Ora aspettiamo 100-150ms e riproviamo se necessario, garantendo il nascondimento in ogni situazione.

### v3.2.2 (Fix Definitivo Freccia "Torna Indietro" in PWA) 🔒🐛
- 🐛 **FIX CRITICO**: Risolto problema "freccia ancora visibile nella PWA"
- ✅ **Nascondimento Robusto**: Uso di `setProperty()` con `!important` per evitare override CSS
- ✅ **Quadrupla Protezione** per il pulsante "Torna indietro":
  1. `display: none !important`
  2. `visibility: hidden !important`
  3. `opacity: 0 !important`
  4. `pointer-events: none !important`
- ✅ **Controllo Multiplo**: Ricerca per ID (`btnBackToPortal`) + classe (`.btn-back`)
- ✅ **Richiamo Automatico**: `detectPWAMode()` viene ora chiamato:
  - All'avvio dell'app (DOMContentLoaded)
  - Dopo `renderEducatorUI()` (ogni volta che si carica l'Area Educatore)
  - Dopo `renderUserUI()` (ogni volta che si carica l'Area Utente)
  - Dopo `startEducatorMode()` (sia online che offline)
  - Dopo `startUserMode()` (sia online che offline)
- ✅ **Log Migliorati**: Messaggi di avviso se gli elementi non vengono trovati nel DOM
- ✅ **Toleranza Zero**: Anche se il DOM viene ri-renderizzato, il pulsante viene sempre nascosto
- 🎯 **Risultato**: Freccia "← Torna indietro" **completamente invisibile e non cliccabile** nella PWA

**Problema Risolto**:
L'utente segnalava che la freccia "← Torna indietro" era ancora visibile nella PWA installata, permettendo di tornare all'applicazione radice. Ora il pulsante è nascosto in modo robusto con stili `!important` e controlli multipli, garantendo l'isolamento totale della PWA.

### v3.2.1 (Fix Brani che Non Partono - Player YouTube Robusto) 🔧
- 🐛 **FIX CRITICO**: Risolto problema "brani che non partono al click"
- ✅ **Controllo API YouTube**: Verifica che l'API sia caricata prima di creare il player
- ✅ **Sistema di Retry**: Se API non pronta, riprova automaticamente ogni 500ms (max 10 tentativi)
- ✅ **Feedback Utente**: Mostra messaggi chiari durante il caricamento
  - "⏳ Caricamento player YouTube in corso..."
  - "▶️ Nome brano" quando inizia la riproduzione
- ✅ **Gestione Errori Migliorata**: Try-catch per prevenire crash del player
- ✅ **Log Dettagliati in Console**: Per debugging e monitoraggio
  - `🎵 selectBrano chiamato: "Nome brano"`
  - `✅ Video ID estratto: ABC123`
  - `🔄 Player esistente trovato, carico nuovo video...`
  - `✅ API YouTube caricata e pronta!`
- ✅ **Precaricamento API**: All'ingresso nell'Area Utente, l'API viene precaricata
- ✅ **Messaggio Iniziale Player**: Quando l'utente entra, vede un messaggio chiaro:
  - "🎵 Seleziona un brano dalla lista per iniziare"
  - "Il player si caricherà automaticamente"
- ✅ **Gestione Fallback**: Se API non si carica, propone di ricaricare la pagina
- 🎯 **Esperienza Utente**: Click sul brano → Funziona sempre, anche al primo click

**Problema Risolto**:
Prima, se l'utente cliccava su un brano prima che l'API YouTube fosse carica, il player non si creava e il brano non partiva. Ora l'app aspetta che l'API sia pronta e riprova automaticamente, garantendo che il click funzioni sempre.

### v3.2.0 (PWA Completamente Isolata - Zero Link Esterni) 🔒
- 🔒 **Isolamento Totale PWA**: Quando installata, l'app è completamente autonoma
- ✅ **Pulsante "Torna indietro" nascosto**: Non più visibile nell'header della PWA
- ✅ **Voce "Torna alla home" nascosta**: Non più visibile nel menu laterale della PWA
- ✅ **Controllo Automatico**: Scansiona e nasconde automaticamente tutti i link `../` esterni
- ✅ **Alert Migliorato**: Se l'utente prova a uscire in PWA, riceve un messaggio chiaro
- ✅ **ID Specifici**: Aggiunto `btnBackToPortal` e `menuBackToPortal` per gestione robusta
- ✅ **Console Log Dettagliati**: 
  - `🔒 PWA INSTALLATA: Nascondo tutti i link esterni`
  - `✓ Pulsante header "Torna indietro" nascosto`
  - `✓ Voce menu "Torna alla home" nascosta`
  - `🎉 PWA completamente isolata`
- 🎯 **Esperienza Nativa**: La PWA si comporta come un'app completamente indipendente
- 🌐 **Browser Normale**: Tutti i link al portale rimangono visibili e funzionanti

**Comportamento PWA vs Browser**:
| Elemento | Browser | PWA Installata |
|----------|---------|----------------|
| Pulsante "← Torna indietro" (header) | ✅ Visibile | ❌ Nascosto |
| Voce "🏠 Torna alla home" (menu) | ✅ Visibile | ❌ Nascosto |
| Link con `../` esterni | ✅ Funzionanti | ❌ Nascosti |
| Alert se provi a uscire | ⚠️ Conferma uscita | 🔒 Blocco totale |

### v3.1.0 (Dropdown Cambia Utente Rapido) ⚡
- ✅ **Nuovo Dropdown nell'Area Utente**: Cambia utente locale senza uscire
- ✅ **Posizione Strategica**: Subito sotto il messaggio "Benvenuto [Nome]"
- ✅ **Lista Dinamica**: Mostra tutti gli utenti locali tranne quello corrente
- ✅ **Link Rapido**: "Aggiungi nuovo utente" direttamente dal dropdown
- ✅ **Feedback Visivo**: Messaggio di conferma animato al cambio utente
- ✅ **Auto-Aggiornamento**: Il dropdown si ripopola ad ogni cambio/aggiunta utente
- 🎯 **UX Migliorata**: Non serve più aprire il menu laterale per cambiare utente
- 🎯 **Accessibilità**: Font grande (1.1rem), padding aumentato per touch screen
- 🚀 **Cambio Istantaneo**: Click sul nome → Brani caricati immediatamente

### v3.0.0 (PWA con Utenti Locali + YouTube Funzionante) 🎉
- 🔄 **CAMBIO ARCHITETTURALE FONDAMENTALE**: PWA usa SEMPRE utenti locali (localStorage)
- ✅ **Separazione netta**:
  - **Browser normale** → Dropdown database utenti online
  - **PWA installata** → Campo testo + lista utenti locali (anche con internet)
- ✅ **YouTube funzionante in PWA**: Se c'è internet, popup YouTube si apre normalmente
- ✅ **Doppio check connessione**:
  - `checkInternetConnection()` → Per YouTube (ping Google)
  - `checkOnlineStatus()` → Per database (ping API)
- ✅ **Area Educatore PWA**: Campo di testo con autocompletamento utenti locali
- ✅ **Area Utente PWA**:
  - Primo ingresso → "Come ti chiami?" (campo testo)
  - Ingressi successivi → Lista utenti salvati + "Aggiungi nuovo"
- ✅ **Brani sempre locali in PWA**: Salvati in `localStorage` per ogni utente
- ✅ **Comportamento intelligente**: 
  - PWA + Internet → Utenti locali + YouTube funzionante ✅
  - PWA + No Internet → Utenti locali + YouTube bloccato ✅
  - Browser + Internet → Utenti database + YouTube funzionante ✅
- 🎯 **Caso d'uso finale perfetto**: 
  - PC portatile con PWA e WiFi: gestisce utenti in locale, cerca brani su YouTube online
  - PC portatile con PWA senza WiFi: tutto funziona in locale (utenti + brani salvati)

### v2.8.0 (PWA Ibrida - Online + Offline)
- 🔄 **CAMBIO FONDAMENTALE**: PWA non più forzata sempre offline
- ✅ **Logica intelligente**: PWA con internet → usa database + YouTube ✅
- ✅ **Fallback automatico**: Se database non raggiungibile → localStorage
- ✅ **YouTube funzionante**: Nell'Area Educatore PWA con internet, popup YouTube si apre
- ✅ **Migliore UX**: Non serve più distinguere "browser" vs "PWA installata"
- ✅ **Console chiara**: Log mostra "ONLINE (PWA)" o "OFFLINE (PWA)"
- 🎯 **Comportamento finale**: 
  - PWA + Internet + DB raggiungibile → ONLINE (database + YouTube) ✅
  - PWA + Internet + DB non raggiungibile → OFFLINE (localStorage) ✅
  - PWA + No Internet → OFFLINE (localStorage) ✅
- 💡 **Caso d'uso reale**: PC portatile con PWA installata e WiFi attivo usa normalmente database e YouTube

### v2.7.2 (Fix Eliminazione Brani)
- 🐛 **FIX CRITICO**: Implementato supporto eliminazione brani nell'API PHP
- ✅ **Azione 'delete'**: Aggiunta funzione `eliminaVideo()` in `api_video_yt.php`
- ✅ **Supporto ID e Link**: Elimina brano per `id` oppure per `link_youtube`
- ✅ **Mapping dati**: Corretto mapping `id_video` → `id` nel JavaScript
- ✅ **Feedback utente**: Messaggio di conferma eliminazione + aggiornamento lista
- ✅ **Validazione**: Ritorna errore 404 se brano non trovato
- 🎯 **Funzionalità completa**: 
  - Educatore può eliminare brani obsoleti ✅
  - Utente può eliminare brani dalla propria lista ✅

### v2.7.1 (Fix PWA + Lista Utenti Locali)
- 🐛 **FIX CRITICO**: PWA installata ora usa SEMPRE modalità locale (localStorage)
- ✅ **Rilevamento PWA standalone**: Controlla se app è installata indipendentemente dal server
- ✅ **Browser vs PWA**: Browser su localhost → ONLINE | PWA installata → OFFLINE (locale)
- ✅ **Lista utenti locali**: Dopo primo accesso, mostra lista utenti esistenti + "Aggiungi nuovo"
- ✅ **Multi-utente migliorato**: Selezione rapida tra utenti salvati localmente
- ✅ **Validazione utente**: Impedisce creazione duplicati nella lista locale
- ✅ **UX ottimizzata**: 
  - Primo ingresso PWA → Campo di testo "Come ti chiami?"
  - Ingressi successivi → Lista utenti con pulsanti grandi + Campo per nuovo utente
- 🎯 **Comportamento finale corretto**: 
  - Browser localhost/Aruba → ONLINE → Dropdown database ✅
  - PWA installata → OFFLINE → Sistema localStorage ✅

### v2.7.0 (Navigazione Rapida + Fix YouTube Offline)
- ✅ **Pulsante "Area Utente"** nell'Area Educatore per switch istantaneo
- ✅ **Pulsante "Educatore"** nell'Area Utente per switch istantaneo
- ✅ **Navigazione fluida**: Cambio area senza ricaricare la pagina
- ✅ **YouTube bloccato offline**: Messaggio chiaro invece di tentare apertura popup
- ✅ **Cleanup automatico**: Chiusura finestre/player quando si cambia area
- ✅ **UX migliorata**: Non serve più uscire dall'app per cambiare modalità
- 🎯 **Caso d'uso**: Educatore può testare immediatamente i brani nell'Area Utente

### v2.6.0 (PWA Standalone + Area Educatore Offline)
- ✅ **PWA Standalone**: Rileva quando l'app è installata e nasconde link esterni
- ✅ **Area Educatore Offline**: Funziona completamente senza connessione internet
- ✅ **Salvataggio locale educatore**: I brani vengono salvati in localStorage quando offline
- ✅ **Autocompletamento utenti**: Datalist con suggerimenti utenti già esistenti in locale
- ✅ **Nessun link esterno in PWA**: Bottone "Torna indietro" nascosto in modalità installata
- ✅ **Indicatori visivi**: Badge "OFFLINE" nell'header quando non c'è connessione
- ✅ **Esperienza app nativa**: L'app rimane self-contained quando installata
- 🎯 **Caso d'uso**: PWA completamente autonoma, senza dipendenze esterne una volta installata

### v2.5.0 (Modalità Offline + Utenti Locali)
- ✅ **Sistema ibrido Online/Offline**: L'app rileva automaticamente se ha accesso al database
- ✅ **Utenti locali**: In modalità offline, nome utente inseribile tramite campo di testo
- ✅ **Storage locale**: Brani salvati in localStorage per ogni utente locale
- ✅ **Sincronizzazione automatica**: Brani aggiunti online vengono sincronizzati anche in localStorage
- ✅ **Gestione utenti multipli**: Supporto per più utenti locali sullo stesso dispositivo
- ✅ **Pulsante "Cambia Utente"**: Aggiunto nel menu laterale per modalità offline
- ✅ **PWA completamente offline**: Funziona senza connessione dopo l'installazione
- ✅ **Schermata login semplice**: Campo di testo grande e accessibile per utenti con deficit cognitivi
- 🎯 **Caso d'uso**: Perfetto per dispositivi portatili usati in ambienti senza connessione internet

### v2.4.1 (Miglioramento UX Header + Icone PWA)
- ✅ **Icona menu opzioni spostata a sinistra** dell'header (più intuitiva e accessibile)
- ✅ **Layout header ottimizzato**: 🎚️ ← | Titolo | ⋮
- ✅ **Icone PWA generate automaticamente**: 192x192 e 512x512
- ✅ **Script Node.js** per rigenerare icone (`npm run generate-icons`)
- ✅ **Documentazione completa** in GENERATE_ICONS.md
- Migliorata raggiungibilità per utenti con difficoltà motorie

### v2.4.0 (Funzionalità SPACE per tutte le modalità)
- ✅ **Ascolto Diretto**: SPACE avvia il brano successivo della lista (sequenziale)
- ✅ **Ascolto Random**: SPACE avvia un brano casuale dalla lista
- ✅ **Ascolto Temporizzato**: SPACE riprende dopo pausa timer (già funzionante)
- ✅ **Tracciamento indice brano**: Memorizza posizione nella lista per modalità diretta
- ✅ **Info box per modalità Random**: Spiegazione dedicata con colore arancione
- ✅ **Ciclo automatico**: In modalità diretta, dopo l'ultimo brano ricomincia dal primo
- Migliorati testi descrittivi per tutte le modalità

### v2.3.1 (UI/UX Miglioramenti)
- ✅ **Bottone menu opzioni spostato nell'header** (icona slider)
- ✅ **Header ottimizzato**: Bottoni più grandi (45px) e visibili
- ✅ **Rimosso bottone fisso flottante** a sinistra (ora tutto nell'header)
- ✅ **Layout pulito**: Menu accessibile sempre dall'header superiore
- Migliorata accessibilità: bottoni header con hover effect e scaling

### v2.3.0 (Gestione Brani)
- ✅ **Aggiunto bottone elimina** per ogni brano nella lista
- ✅ **Conferma eliminazione** prima di rimuovere un brano
- ✅ **Scrolling verticale** nel pannello lista brani
- ✅ **Scrollbar personalizzata** con stile viola per migliore UX
- ✅ **Feedback visivo** durante eliminazione (messaggio temporaneo)
- ✅ **Reset automatico player** se il brano eliminato era in riproduzione
- ✅ **Ricaricamento automatico lista** dopo eliminazione
- Migliorato layout brani: testo con ellipsis, 2 bottoni (play + elimina)

### v2.2.0 (Bugfix Critico)
- ✅ **RISOLTO**: Il brano ora riprende **dal punto esatto in cui è stato messo in pausa**
- Implementata YouTube IFrame Player API per controllo nativo del player
- Uso di `pauseVideo()` e `playVideo()` invece di ricaricare l'iframe
- Migliorata esperienza utente in modalità temporizzata

### v2.1.0
- Aggiunta modalità "Ascolto Diretto" (default)
- Bottone dinamico nel menu opzioni
- Info box contestuali per ogni modalità

### v2.0.0
- Layout ottimizzato per ipovedenti
- 3 modalità di ascolto (Diretto, Random, Temporizzato)
- Menu opzioni laterale a scomparsa
- Controllo intelligente tasto SPACE

## Supporto Browser

- ✅ Chrome/Edge (Desktop & Mobile)
- ✅ Firefox (Desktop & Mobile)
- ✅ Safari (iOS 11.3+)
- ✅ Samsung Internet

## Risorse Utili

- [MDN PWA Guide](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)
- [Web.dev PWA](https://web.dev/progressive-web-apps/)
- [Bootstrap Icons](https://icons.getbootstrap.com/)
