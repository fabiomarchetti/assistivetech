# Agenda Strumenti - PWA

Applicazione Progressive Web App per la gestione di agende multilivello con pittogrammi ARASAAC e video YouTube.

## 📋 Caratteristiche

### Funzionalità Principali
- ✅ **Agende Gerarchiche**: Crea agenda principale e sub-agende collegate
- ✅ **Pittogrammi ARASAAC**: Integrazione diretta con API ARASAAC
- ✅ **Video YouTube**: Ricerca e incorporamento video
- ✅ **Navigazione Touch**: Swipe per navigare, long-click per aprire sub-agende
- ✅ **Offline-Ready**: Funziona offline con database SQLite locale
- ✅ **PWA Installabile**: Installabile come app su dispositivi mobili e desktop

### Tipi di Item
1. **Item Semplice**: Titolo + immagine (ARASAAC o upload)
2. **Link Agenda**: Collega ad altra agenda (aperta con long-click)
3. **Video YouTube**: Incorpora video YouTube

## 🏗️ Architettura

### Frontend
- **HTML5** + **CSS3** (vanilla, no framework)
- **JavaScript ES6+** (modular)
- **Bootstrap 5.3** (solo per interfaccia educatore)
- **SortableJS** (drag & drop)

### Backend
- **PHP 8.x** (API REST)
- **MySQL** (database principale)
- **SQLite** (database locale offline via sql.js)

### APIs Esterne
- **ARASAAC API**: Pittogrammi accessibilità (https://api.arasaac.org)
- **YouTube Data API v3**: Ricerca video (richiede API Key)

## 📁 Struttura File

```
/training_cognitivo/strumenti/
├── gestione.html              # Interfaccia educatore
├── agenda.html                # Interfaccia paziente (PWA)
├── manifest.json              # PWA manifest
├── service-worker.js          # Service worker per offline
├── README.md                  # Questa documentazione
│
├── css/
│   ├── educatore.css         # Stili interfaccia educatore
│   └── agenda.css            # Stili interfaccia paziente
│
├── js/
│   ├── api-client.js         # Client API REST
│   ├── arasaac-service.js    # Servizio ARASAAC
│   ├── youtube-service.js    # Servizio YouTube
│   ├── swipe-handler.js      # Gestione touch/swipe
│   ├── db-manager.js         # Database SQLite locale
│   ├── educatore-app.js      # Logic educatore
│   └── agenda-app.js         # Logic paziente
│
├── api/
│   ├── agende.php            # CRUD agende
│   ├── items.php             # CRUD item
│   └── upload_image.php      # Upload immagini
│
├── assets/
│   ├── images/               # Immagini uploadate
│   └── icons/                # Icone PWA (192px, 512px)
│
└── lib/
    └── sql.js                # SQLite WebAssembly (da scaricare)
```

## 🚀 Installazione

### 1. Database Setup

Esegui gli script SQL in ordine:

```bash
# Su MySQL locale (MAMP/XAMPP)
mysql -u root -p assistivetech_local < script_sql/create_table_agende_strumenti.sql
mysql -u root -p assistivetech_local < script_sql/create_table_agende_items.sql

# Su Aruba (produzione)
# Esegui via phpMyAdmin o client MySQL
```

### 2. Categoria Strumenti

Crea la categoria "strumenti" nell'admin panel:
1. Accedi a `/admin/index.html`
2. Sezione "Categorie Esercizi"
3. Crea categoria "strumenti"

### 3. Libreria sql.js (per offline)

Scarica sql.js da https://sql.js.org/dist/sql-wasm.js

```bash
# Crea cartella lib se non esiste
mkdir -p training_cognitivo/strumenti/lib

# Scarica sql.js
cd training_cognitivo/strumenti/lib
wget https://sql.js.org/dist/sql-wasm.js
wget https://sql.js.org/dist/sql-wasm.wasm
```

### 4. API Key YouTube (opzionale)

Per abilitare ricerca video YouTube:

1. Vai su https://console.cloud.google.com/
2. Crea nuovo progetto
3. Abilita "YouTube Data API v3"
4. Crea credenziali (API Key)
5. Apri `js/youtube-service.js`
6. Sostituisci `YOUR_YOUTUBE_API_KEY_HERE` con la tua chiave

### 5. Icone PWA

Crea le icone per PWA (o usa placeholder):

```bash
# Crea icone 192x192 e 512x512
# Salva in assets/icons/icon-192.png e icon-512.png
```

## 📖 Utilizzo

### Interfaccia Educatore (gestione.html)

1. **Seleziona Paziente**: Dropdown nella sidebar
2. **Crea Agenda**: Click su "+" accanto a "Agende"
   - Scegli tipo: Principale o Sottomenu
   - Se sottomenu, seleziona agenda genitore
3. **Aggiungi Item**: Click su "Aggiungi Item"
   - Inserisci titolo
   - Scegli tipo: Semplice, Link Agenda, Video YouTube
   - Seleziona immagine: ARASAAC, Upload, Nessuna
4. **Riordina Item**: Drag & drop per riordinare
5. **Elimina**: Bottone "Elimina" su item o agenda

### Interfaccia Paziente (agenda.html)

1. **Seleziona Utente**: Dropdown iniziale
2. **Navigazione**:
   - **Swipe Left/Right**: Passa tra item
   - **Frecce (desktop)**: Click su frecce laterali
   - **Long-Click**: Su item con link agenda, apre sub-agenda
   - **Click**: Su video YouTube, riproduce video
3. **Bottone HOME**: Sempre visibile, torna all'agenda principale
4. **Breadcrumb**: Mostra percorso corrente

## 🔌 API Endpoints

### Agende

```bash
# Crea agenda
POST /api/agende.php?action=create
Body: { nome_agenda, id_paziente, id_educatore, id_agenda_parent? }

# Lista agende
GET /api/agende.php?action=list&id_paziente=X&solo_principali=true

# Dettagli agenda
GET /api/agende.php?action=get&id_agenda=X

# Aggiorna agenda
PUT /api/agende.php?action=update&id_agenda=X
Body: { nome_agenda }

# Elimina agenda
DELETE /api/agende.php?action=delete&id_agenda=X
```

### Item

```bash
# Crea item
POST /api/items.php?action=create
Body: { id_agenda, tipo_item, titolo, ... }

# Lista item
GET /api/items.php?action=list&id_agenda=X

# Aggiorna item
PUT /api/items.php?action=update&id_item=X
Body: { titolo?, tipo_immagine?, ... }

# Riordina items
PUT /api/items.php?action=reorder
Body: { items: [{ id_item, posizione }] }

# Elimina item
DELETE /api/items.php?action=delete&id_item=X
```

### Upload

```bash
# Upload immagine (file)
POST /api/upload_image.php
Body: FormData con campo 'image'

# Upload immagine (base64)
POST /api/upload_image.php
Body: FormData con campo 'image_base64'
```

## 🗄️ Schema Database

### Tabella: `agende_strumenti`

| Campo | Tipo | Descrizione |
|-------|------|-------------|
| id_agenda | INT PK | ID agenda |
| nome_agenda | VARCHAR(200) | Nome agenda |
| id_paziente | INT FK | ID paziente |
| id_educatore | INT FK | ID educatore |
| id_agenda_parent | INT FK NULL | ID agenda genitore (NULL = principale) |
| tipo_agenda | ENUM | principale / sottomenu |
| data_creazione | VARCHAR(19) | Data creazione |
| stato | ENUM | attiva / archiviata |

### Tabella: `agende_items`

| Campo | Tipo | Descrizione |
|-------|------|-------------|
| id_item | INT PK | ID item |
| id_agenda | INT FK | ID agenda |
| tipo_item | ENUM | semplice / link_agenda / video_youtube |
| titolo | VARCHAR(255) | Titolo item |
| posizione | INT | Posizione ordinamento |
| tipo_immagine | ENUM | arasaac / upload / nessuna |
| id_arasaac | INT NULL | ID pittogramma ARASAAC |
| url_immagine | VARCHAR(500) NULL | URL immagine upload |
| id_agenda_collegata | INT FK NULL | ID agenda collegata |
| video_youtube_id | VARCHAR(50) NULL | ID video YouTube |
| video_youtube_title | VARCHAR(255) NULL | Titolo video |
| video_youtube_thumbnail | VARCHAR(500) NULL | Thumbnail video |
| data_creazione | VARCHAR(19) | Data creazione |
| stato | ENUM | attivo / archiviato |

## 🔒 Sicurezza

- ✅ **PDO Prepared Statements**: Previene SQL injection
- ✅ **Input Validation**: Tutti gli input validati server-side
- ✅ **File Upload Validation**: Controllo MIME type e dimensione
- ✅ **CORS Headers**: Configurati per API
- ⚠️ **TODO**: Implementare autenticazione token-based
- ⚠️ **TODO**: Implementare rate limiting

## 📱 PWA Features

- ✅ **Installabile**: Manifest configurato
- ✅ **Offline**: Service worker con caching
- ✅ **Responsive**: Design mobile-first
- ✅ **Touch Optimized**: Swipe e long-click
- ✅ **Standalone**: Fullscreen senza browser UI
- ✅ **Fast**: Asset pre-caching

## 🐛 Troubleshooting

### Database Connection Error
```
Errore: Database connection failed
```
**Soluzione**: Verifica configurazione in `/api/config.php`

### ARASAAC API Non Risponde
```
Errore: Nessun risultato
```
**Soluzione**: Verifica connessione internet, API ARASAAC potrebbe essere offline

### YouTube API Key Non Configurata
```
Warning: YouTube API Key non configurata!
```
**Soluzione**: Configura API Key in `js/youtube-service.js` (vedi Installazione)

### Service Worker Non Registrato
```
Errore: Service Worker registration failed
```
**Soluzione**: HTTPS richiesto per PWA (o localhost per dev). Verifica console browser.

### SQLite Non Funziona
```
Errore: sql.js not found
```
**Soluzione**: Scarica sql.js in cartella `lib/` (vedi Installazione)

## 🎯 Roadmap

### v1.1 (Future)
- [ ] Sincronizzazione bidirezionale online/offline
- [ ] Text-to-Speech per lettura item
- [ ] Timer e gestione tempo per attività
- [ ] Statistiche utilizzo agenda
- [ ] Export/Import agende in JSON
- [ ] Multi-lingua (IT, EN, ES)

### v1.2 (Future)
- [ ] Registrazione audio custom
- [ ] Notifiche push per promemoria
- [ ] Modalità dark mode
- [ ] Condivisione agende tra educatori
- [ ] Report attività paziente

## 👥 Crediti

- **ARASAAC**: Pittogrammi (http://www.arasaac.org)
- **Bootstrap**: UI Framework (https://getbootstrap.com)
- **SortableJS**: Drag & Drop (https://sortablejs.github.io/Sortable/)
- **sql.js**: SQLite in Browser (https://sql.js.org)

## 📄 Licenza

Progetto proprietario - AssistiveTech.it © 2025

## 📞 Supporto

Per supporto tecnico o domande:
- Email: assistivetech.it@gmail.com
- Documentazione: `/MD/` folder

---

**Versione**: 1.0.0
**Data Rilascio**: 2025-10-28
**Autore**: Sviluppato con Claude Code
