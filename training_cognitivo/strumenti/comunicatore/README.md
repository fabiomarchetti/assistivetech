# 🗣️ Comunicatore - Sistema di Comunicazione Adattivo

## 📋 Descrizione

**Comunicatore** è un'applicazione PWA (Progressive Web App) progettata per facilitare la comunicazione di persone con difficoltà verbali o cognitive attraverso l'uso di immagini, pittogrammi ARASAAC e sintesi vocale (TTS).

### ✨ Caratteristiche Principali

- **🔄 Modalità HYBRID**: Funziona sia online (database server) che offline (IndexedDB locale)
- **Griglia Adattiva 2x2**: Layout intelligente che si adatta automaticamente al numero di item (1-4 immagini per pagina)
- **Multi-Pagina con Swipe**: Navigazione fluida tra pagine multiple tramite swipe touch o mouse
- **Integrazione ARASAAC**: Accesso diretto a migliaia di pittogrammi gratuiti
- **Upload Personalizzato**: Possibilità di caricare immagini proprie
- **TTS Integrato**: Pronuncia automatica delle frasi associate agli item
- **Personalizzazione Colori**: Sfondo e testo personalizzabili per ogni item
- **💾 Utenti Locali**: Crea utenti direttamente nel browser senza database
- **PWA Installabile**: Funziona offline e installabile su smartphone/tablet
- **Responsive**: Ottimizzato per ogni dimensione di schermo

---

## 🏗️ Architettura

### Struttura File

```
comunicatore/
├── index.html              # Selezione interfacce (Educatore/Paziente)
├── gestione.html           # Interfaccia Educatore
├── comunicatore.html       # Interfaccia Paziente (PWA)
├── manifest.json           # Configurazione PWA
├── service-worker.js       # Service Worker per offline
├── api/
│   ├── pagine.php          # CRUD pagine
│   ├── items.php           # CRUD items
│   ├── upload_image.php    # Upload immagini
│   └── setup_database.sql  # Schema database
├── css/
│   ├── educatore.css       # Stili interfaccia educatore
│   └── comunicatore.css    # Stili interfaccia paziente
├── js/
│   ├── api-client.js       # Client API REST
│   ├── arasaac-service.js  # Servizio ARASAAC
│   ├── educatore-app.js    # Logica educatore
│   └── comunicatore-app.js # Logica paziente con swipe
└── assets/
    ├── icons/              # Icone PWA (192x192, 512x512)
    └── images/             # Immagini uploadate
```

### Database

**Tabelle:**

1. **`comunicatore_pagine`**
   - `id_pagina`, `nome_pagina`, `descrizione`
   - `id_paziente`, `id_educatore`
   - `numero_ordine`, `stato`

2. **`comunicatore_items`**
   - `id_item`, `id_pagina`, `posizione_griglia` (1-4)
   - `titolo`, `frase_tts`
   - `tipo_immagine` (arasaac/upload/nessuna)
   - `id_arasaac`, `url_immagine`
   - `colore_sfondo`, `colore_testo`

3. **`comunicatore_log`** (opzionale)
   - Statistiche utilizzo item

---

## 🚀 Installazione

### 1. Setup Database

```sql
-- Esegui setup_database.sql in phpMyAdmin
mysql -u root -p nome_database < api/setup_database.sql
```

### 2. Configurazione API

Verifica che `config.php` sia presente in `/Assistivetech/api/` con:

```php
function getDbConnection() {
    $host = 'localhost';
    $db = 'assistivetech_db';
    $user = 'root';
    $pass = 'password';
    // ...
}
```

### 3. Upload File

Carica tutti i file nella directory:
```
/Assistivetech/training_cognitivo/strumenti/comunicatore/
```

### 4. Genera Icone PWA

Segui le istruzioni in `assets/icons/GENERATE_ICONS.md` per creare:
- `icon-192.png` (192x192px)
- `icon-512.png` (512x512px)

### 5. Test Applicazione

1. Apri `http://localhost/Assistivetech/training_cognitivo/strumenti/comunicatore/`
2. Seleziona **Gestione Educatore** per creare pagine
3. Seleziona **Comunicatore Paziente** per testare navigazione

---

## 👨‍🏫 Guida Educatore

### Creare una Pagina

1. Accedi a **Gestione Educatore**
2. Seleziona un **Paziente** dal menu a sinistra
3. Clicca **+ Crea Pagina**
4. Inserisci nome e descrizione
5. Clicca **Crea Pagina**

### Aggiungere Item

1. Seleziona una pagina creata
2. Clicca su una delle **4 posizioni vuote** della griglia
3. Inserisci:
   - **Titolo**: Es. "Voglio mangiare"
   - **Frase TTS**: Es. "Voglio mangiare un gelato"
   - **Immagine**: Scegli ARASAAC o Upload personalizzato
   - **Colori**: Personalizza sfondo e testo
4. Clicca **Salva Item**

### Layout Adattivo Automatico

- **1 item**: Centrato grande
- **2 items**: Affiancati orizzontalmente
- **3 items**: 2 sopra, 1 sotto centrato
- **4 items**: Griglia 2x2 completa

### Gestire Multiple Pagine

- Crea più pagine per organizzare contenuti diversi
- Il paziente potrà navigare con **swipe**
- Ogni pagina può avere da 1 a 4 item

---

## 👤 Guida Paziente

### Avviare l'Applicazione

1. Apri **Comunicatore** dal menu principale
2. Seleziona il tuo nome dalla lista
3. Clicca **Conferma**

### Navigazione

- **Tocca un'immagine**: Ascolta la frase TTS
- **Swipe Left/Right**: Naviga tra le pagine
- **Home Button**: Torna alla selezione utente

### Indicatori Visivi

- **Pallini in basso**: Indicano pagina corrente
- **Animazione pulsante**: Feedback visivo durante TTS
- **Colori personalizzati**: Sfondo e testo configurabili

### PWA - Installazione su Mobile

#### Android (Chrome):
1. Apri l'app in Chrome
2. Menu > **Aggiungi a schermata Home**
3. L'app si comporterà come nativa

#### iOS (Safari):
1. Apri l'app in Safari
2. Tap su **Condividi** (icona quadrato con freccia)
3. **Aggiungi a Home**

---

## 🎨 Layout Adattivo - Come Funziona

### Logica CSS Grid

Il layout si adatta automaticamente in base al numero di item:

```css
/* 1 item: centrato */
.griglia-comunicatore.layout-1 {
    grid-template-columns: 1fr;
    place-items: center;
}

/* 2 items: affiancati */
.griglia-comunicatore.layout-2 {
    grid-template-columns: repeat(2, 1fr);
}

/* 3 items: 2 + 1 centrato */
.griglia-comunicatore.layout-3 {
    grid-template-columns: repeat(2, 1fr);
}
.layout-3 .item-box:nth-child(3) {
    grid-column: 1 / -1;
}

/* 4 items: griglia 2x2 */
.griglia-comunicatore.layout-4 {
    grid-template-columns: repeat(2, 1fr);
    grid-template-rows: repeat(2, 1fr);
}
```

### Swipe Gestures

- **Touch**: Supporto nativo per swipe touch
- **Mouse**: Drag & drop funziona anche su desktop
- **Soglia**: 50px di movimento minimo per trigger
- **Feedback**: Transizioni smooth tra pagine

---

## 🔧 Personalizzazione

### Modificare Colori Tema

In `css/comunicatore.css`:

```css
:root {
    --primary-color: #673AB7;  /* Viola */
    --primary-dark: #512DA8;
    --text-color: #333;
    --bg-light: #F5F5F5;
}
```

### Modificare Velocità TTS

In `js/comunicatore-app.js`:

```javascript
utterance.rate = 0.9;  // 0.5 (lento) - 2.0 (veloce)
utterance.pitch = 1.0; // 0.5 (basso) - 2.0 (alto)
utterance.volume = 1.0; // 0.0 (muto) - 1.0 (max)
```

### Aggiungere Lingue ARASAAC

In `js/arasaac-service.js`:

```javascript
this.locale = 'it'; // Cambia in: 'en', 'es', 'fr', ecc.
```

---

## 🐛 Troubleshooting

### Errore: "Nessun paziente trovato"

**Causa**: La tabella `registrazioni` è vuota o non contiene pazienti.

**Soluzione**:
```sql
INSERT INTO registrazioni (username, ruolo) 
VALUES ('Mario', 'paziente'), ('Luca', 'paziente');
```

### TTS non funziona

**Causa**: Browser non supporta `speechSynthesis` o permessi mancanti.

**Soluzione**:
- Usa Chrome/Edge/Safari (versioni recenti)
- Controlla permessi audio del browser
- Testa su HTTPS (richiesto per alcune feature)

### Immagini ARASAAC non si caricano

**Causa**: Connessione internet assente o API ARASAAC offline.

**Soluzione**:
- Verifica connessione internet
- Controlla console per errori CORS
- Usa immagini uploadate come fallback

### PWA non si installa

**Causa**: Icone mancanti o manifest.json non valido.

**Soluzione**:
- Genera icone secondo `GENERATE_ICONS.md`
- Verifica manifest.json con Chrome DevTools > Application
- Assicurati che l'app sia servita su HTTPS

### Swipe non funziona

**Causa**: Conflitto con altri event listener o browser non supportato.

**Soluzione**:
- Verifica che `touch-action: pan-x` sia applicato
- Testa su dispositivo mobile reale
- Controlla console per errori JavaScript

---

## 📱 Browser Supportati

| Browser | Versione Minima | PWA | Swipe | TTS |
|---------|----------------|-----|-------|-----|
| Chrome | 67+ | ✅ | ✅ | ✅ |
| Firefox | 62+ | ✅ | ✅ | ✅ |
| Safari | 11.1+ | ✅ | ✅ | ✅ |
| Edge | 79+ | ✅ | ✅ | ✅ |
| Opera | 54+ | ✅ | ✅ | ✅ |

---

## 🎯 Roadmap Future

- [ ] Modalità scura/chiara
- [ ] Export/Import configurazioni
- [ ] Statistiche utilizzo avanzate
- [ ] Supporto video (oltre a immagini)
- [ ] Categorie e tag per items
- [ ] Ricerca full-text
- [ ] Multi-lingua interfaccia
- [ ] Backup automatico su cloud

---

## 📄 Licenza

Questo progetto è parte della suite **AssistiveTech** ed è distribuito per uso educativo e terapeutico.

---

## 👥 Supporto

Per domande o problemi:
- Controlla la documentazione in questo README
- Verifica console browser per errori
- Consulta `API_REFERENCE.md` per dettagli API

---

**Versione**: 1.0.0  
**Data**: Novembre 2025  
**Autore**: AssistiveTech Team
