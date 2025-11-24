# API Reference - Agenda Strumenti

## Database Schema

### Tabella: agende_strumenti

Campo | Tipo | Descrizione
------|------|------------
`id_agenda` | INT PRIMARY KEY | Identificativo univoco agenda
`id_paziente` | INT | FK a tabella pazienti
`nome_agenda` | VARCHAR(255) | Nome dell'agenda (es. "agenda_fabio")
`descrizione` | TEXT | Descrizione agenda
`id_agenda_parent` | INT (NULL) | FK per sub-agende (multi-livello)
`posizione` | INT | Ordine di visualizzazione
`stato` | ENUM('attivo', 'archiviato', 'eliminato') | Soft delete
`data_creazione` | TIMESTAMP | Quando è stata creata
`data_modifica` | TIMESTAMP | Ultimo aggiornamento

**Indici:**
- `id_paziente` (per ricerca veloce per paziente)
- `id_agenda_parent` (per navigazione hierarchia)
- `stato` (per escludere eliminate)

---

### Tabella: agende_items

Campo | Tipo | Descrizione
------|------|------------
`id_item` | INT PRIMARY KEY | Identificativo univoco
`id_agenda` | INT | FK a agende_strumenti
`titolo` | VARCHAR(255) | Nome item (es. "Gelato")
`tipo_item` | ENUM('semplice', 'link_agenda', 'video_youtube') | Tipo di item
`fraseVocale` | TEXT | Testo pronunciato da TTS (NUOVO!)
`tipo_immagine` | ENUM('arasaac', 'upload', 'nessuna') | Sorgente immagine
`id_arasaac` | INT (NULL) | ID pittogramma ARASAAC
`url_immagine` | VARCHAR(500) (NULL) | URL immagine caricata
`id_agenda_collegata` | INT (NULL) | FK se tipo = link_agenda
`video_youtube_id` | VARCHAR(20) (NULL) | ID YouTube video
`video_youtube_title` | VARCHAR(255) (NULL) | Titolo video
`video_youtube_thumbnail` | VARCHAR(500) (NULL) | Thumbnail URL
`posizione` | INT | Ordine item in agenda
`stato` | ENUM('attivo', 'archiviato', 'eliminato') | Soft delete
`data_creazione` | TIMESTAMP | Creazione
`data_modifica` | TIMESTAMP | Ultimo aggiornamento

**Indici:**
- `id_agenda` (per ricerca item di agenda)
- `posizione` (per ordine corretto)
- `stato` (per escludere eliminate)

---

## JavaScript State Management

### agendaState (agenda-app.js)
```javascript
{
    currentAgenda: 123,                    // ID agenda corrente
    currentIndex: 0,                       // Indice item corrente
    items: [                               // Items caricati
        {
            id_item: 1,
            titolo: "Gelato",
            fraseVocale: "Voglio un gelato", // TTS
            tipo_item: "semplice",
            tipo_immagine: "arasaac",
            id_arasaac: 12345,
            posizione: 0
        }
    ],
    agendaStack: [],                       // Stack per breadcrumb
    isOnline: true,                        // Connessione disponibile
    currentUser: { id_paziente: 1, nome: "Fabio" }
}
```

### appState (educatore-app.js)
```javascript
{
    selectedPaziente: 'anonimo',           // Paziente selezionato
    selectedAgenda: 123,                   // Agenda selezionata
    currentAgendaData: {                   // Dati agenda corrente
        id_agenda: 123,
        nome_agenda: "agenda_fabio",
        items: []
    },
    isOnline: true
}
```

---

## localStorage Keys

### Per Pazienti Reali (API)
```javascript
'pazienti_cache'              // JSON array pazienti
'agende_cache_[id_paziente]'  // JSON array agende per paziente
'tts_velocity'                // Velocità TTS (0.5-2.0)
'tts_volume'                  // Volume TTS (0.3-1.0)
'userData'                    // Paziente corrente selezionato
```

### Per Utente Anonimo (Test)
```javascript
'agende_anonimo'              // JSON array agende test
'items_anonimo_[agendaId]'    // JSON array items per agenda test
'tts_velocity'                // Velocità TTS (condiviso)
'tts_volume'                  // Volume TTS (condiviso)
```

**Formato localStorage agende:**
```javascript
[
    {
        "id_agenda": 1698765432123,           // Timestamp come ID temporaneo
        "id_paziente": "anonimo",
        "nome_agenda": "agenda_test",
        "id_agenda_parent": null,
        "posizione": 0,
        "data_creazione": "31/10/2025, 18:05:30"
    }
]
```

**Formato localStorage items:**
```javascript
[
    {
        "id_item": 1698765432124,             // Timestamp come ID
        "id_agenda": 1698765432123,
        "titolo": "Gelato",
        "fraseVocale": "Voglio un gelato",   // TTS
        "tipo_item": "semplice",
        "tipo_immagine": "arasaac",
        "id_arasaac": 12345,
        "posizione": 0,
        "data_creazione": "31/10/2025, 18:05:31"
    }
]
```

---

## API Endpoints (PHP)

### Pazienti
```
GET /api/api_pazienti.php?action=list
Response: { success: true, data: [...] }
```

### Agende
```
GET /api/agende.php?action=list&id_paziente=1
GET /api/agende.php?action=get&id_agenda=123
POST /api/agende.php (body: id_paziente, nome_agenda, id_agenda_parent)
DELETE /api/agende.php?action=delete&id_agenda=123
```

### Items
```
GET /api/items.php?action=list&id_agenda=123
POST /api/items.php (body: id_agenda, titolo, fraseVocale, tipo_item, ...)
PUT /api/items.php (body: id_item, ...) - Update posizione o modifica
DELETE /api/items.php?action=delete&id_item=123
```

---

## TTS Service API

### TTSService (tts-service.js)

#### speak(testo, options)
```javascript
TTSService.speak("Voglio un gelato", {
    language: 'it-IT',      // Default
    rate: 0.9,              // Velocità (0.1-10)
    pitch: 1,               // Intonazione (0-2)
    volume: 1,              // Volume (0-1)
    onStart: () => {},      // Callback inizio
    onEnd: () => {},        // Callback fine
    onError: (err) => {}    // Callback errore
});
```

#### stop()
```javascript
TTSService.stop();  // Ferma pronuncia corrente
```

#### pause() / resume()
```javascript
TTSService.pause();   // Pausa (non tutti browser)
TTSService.resume();  // Riprendi (non tutti browser)
```

#### isSupported()
```javascript
if (TTSService.isSupported()) {
    // Browser supporta Web Speech API
}
```

---

## ARASAAC Service API

### arasaacService (arasaac-service.js)

#### getPictogramUrl(id, size)
```javascript
const url = arasaacService.getPictogramUrl(12345, 500);
// Returns: "https://api.arasaac.org/pictograms/[id]?resolution=500x500&color=false"
```

#### searchPictograms(query, language)
```javascript
const results = await arasaacService.searchPictograms("pizza", "it");
// Returns: [{ _id: 123, keywords: [...] }, ...]
```

---

## YouTube Service API

### youtubeService (youtube-service.js)

#### searchVideos(query)
```javascript
const videos = await youtubeService.searchVideos("canzoni per bambini");
// Returns: [
//   {
//     id: "dQw4w9WgXcQ",
//     title: "Rick Astley...",
//     thumbnail: "https://i.ytimg.com/..."
//   },
//   ...
// ]
```

#### getEmbedUrl(videoId)
```javascript
const embedUrl = youtubeService.getEmbedUrl("dQw4w9WgXcQ");
// Returns: "https://www.youtube.com/embed/dQw4w9WgXcQ"
```

---

## API Client (api-client.js)

### Metodi Principali

#### getPatients()
```javascript
const pazienti = await apiClient.getPatients();
```

#### getAgendas(id_paziente)
```javascript
const agende = await apiClient.getAgendas(123);
```

#### getAgenda(id_agenda)
```javascript
const agenda = await apiClient.getAgenda(123);
```

#### getItems(id_agenda)
```javascript
const items = await apiClient.getItems(123);
```

#### createAgenda(data)
```javascript
const result = await apiClient.createAgenda({
    id_paziente: 1,
    nome_agenda: "agenda_nuovo",
    id_agenda_parent: null
});
```

#### createItem(data)
```javascript
const result = await apiClient.createItem({
    id_agenda: 123,
    titolo: "Gelato",
    fraseVocale: "Voglio un gelato",  // TTS
    tipo_item: "semplice",
    tipo_immagine: "arasaac",
    id_arasaac: 12345,
    posizione: 0
});
```

#### updateItem(id_item, data)
```javascript
const result = await apiClient.updateItem(456, {
    posizione: 1  // Aggiorna posizione
});
```

#### deleteItem(id_item)
```javascript
const result = await apiClient.deleteItem(456);
```

#### uploadImage(file)
```javascript
const result = await apiClient.uploadImage(fileInput.files[0]);
// Returns: { success: true, url: "/uploads/image.png" }
```

---

## Response Format

### Success Response
```json
{
    "success": true,
    "data": { /* dati */ },
    "message": "Operazione completata"
}
```

### Error Response
```json
{
    "success": false,
    "error": "Descrizione errore",
    "code": 400
}
```

### Offline Response (Service Worker)
```json
{
    "success": false,
    "message": "Nessuna connessione disponibile",
    "offline": true
}
```

---

## Validazione Dati

### Item Obbligatori
```javascript
- titolo (non vuoto, max 255 char)
- fraseVocale (non vuoto, obbligatorio per TTS)  ← NUOVO!
- tipo_item (semplice | link_agenda | video_youtube)
- tipo_immagine (arasaac | upload | nessuna)
```

### Item Condizionali
```javascript
Se tipo_item === 'link_agenda':
  - id_agenda_collegata (obbligatorio)

Se tipo_item === 'video_youtube':
  - video_youtube_id (obbligatorio)
  - video_youtube_title
  - video_youtube_thumbnail

Se tipo_immagine === 'arasaac':
  - id_arasaac (obbligatorio)

Se tipo_immagine === 'upload':
  - url_immagine (dopo upload)
```

---

## Error Handling

### Browser Errors
```javascript
if (!TTSService.isSupported()) {
    alert('La pronuncia non è supportata nel tuo browser');
    // Mostra fallback
}
```

### Network Errors
```javascript
try {
    const result = await apiClient.getAgendas(1);
} catch (error) {
    if (error.offline) {
        // Usa localStorage cache
    } else {
        // Mostra errore rete
    }
}
```

### Validation Errors
```javascript
if (!fraseTTS.trim()) {
    showAlert('Inserisci la frase da pronunciare (TTS)', 'warning');
    return;
}
```

---

## Testing API

### curl Examples
```bash
# Get pazienti
curl "http://localhost/Assistivetech/api/api_pazienti.php?action=list"

# Get agende
curl "http://localhost/Assistivetech/api/agende.php?action=list&id_paziente=1"

# Get items
curl "http://localhost/Assistivetech/api/items.php?action=list&id_agenda=123"
```

### Browser Console
```javascript
// Test API client
await apiClient.getPatients()
await apiClient.getAgendas(1)

// Test TTS
TTSService.speak("Test pronuncia")

// Test ARASAAC
await arasaacService.searchPictograms("pizza", "it")

// Test localStorage
JSON.parse(localStorage.getItem('agende_anonimo'))
```

---

## Performance Notes

- **TTS Delay:** 300ms prima della pronuncia per assicurare DOM updated
- **Cache Size:** Service Worker caches ~1-2MB di asset statici
- **localStorage Limit:** ~5-10MB (varia per browser)
- **API Timeout:** 5 secondi (fallback a cache se lento)
- **Image Size:** ARASAAC pictograms 300x300px ottimi
- **Slider Debounce:** localStorage update immediato

---

## Browser Support

| Feature | Chrome | Firefox | Safari | Edge |
|---------|--------|---------|--------|------|
| Web Speech API | ✅ | ⚠️ | ✅ | ✅ |
| Service Worker | ✅ | ✅ | ⚠️ (iOS 11.3+) | ✅ |
| localStorage | ✅ | ✅ | ✅ | ✅ |
| Fetch API | ✅ | ✅ | ✅ | ✅ |
| PWA Install | ✅ | ✅ | ✅ (iOS) | ✅ |

⚠️ = Supporto limitato o in beta

