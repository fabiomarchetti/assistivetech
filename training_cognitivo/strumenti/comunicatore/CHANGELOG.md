# 📝 Changelog - Comunicatore

Tutte le modifiche notevoli al progetto sono documentate in questo file.

---

## [1.1.0] - 2025-11-12 - HYBRID MODE 🔄

### ✨ Nuove Funzionalità

- **Modalità HYBRID**: Supporto completo per database locale (IndexedDB) e server
- **Utenti Locali**: Possibilità di creare utenti direttamente nel browser senza database MySQL
- **Funzionamento Offline**: App completamente funzionante senza connessione internet
- **Badge Modalità**: Indicatore visivo online/offline nell'interfaccia educatore
- **Auto-detect**: Rilevamento automatico connessione server e fallback a locale

### 📦 File Aggiunti

- `js/db-local.js` - Gestore database IndexedDB locale
- `HYBRID_MODE.md` - Documentazione modalità ibrida
- `CHANGELOG.md` - Questo file

### 🔄 File Modificati

#### Interfaccia Educatore
- `gestione.html`:
  - Aggiunto campo input per creazione utenti locali
  - Aggiunto badge indicatore modalità (Online/Offline)
  - Gruppo dropdown utenti separato: Server vs Locali

- `js/educatore-app.js`:
  - Refactoring completo per supporto dual-mode
  - Funzioni `loadPazienti()`, `createPagina()`, `saveItem()` ora supportano entrambe le modalità
  - Gestione automatica upload immagini: API server o Data URL locale

#### Interfaccia Paziente
- `comunicatore.html`:
  - Importato `db-local.js`

- `js/comunicatore-app.js`:
  - Supporto caricamento utenti da server e locali
  - Funzione `selectUser()` rileva automaticamente modalità
  - Caricamento pagine/items da source appropriata

#### PWA
- `service-worker.js`:
  - Cache aggiornata alla versione v1.1.0
  - Aggiunto `db-local.js` ai file cachati

### 📚 Documentazione

- `README.md`: Aggiunta sezione modalità HYBRID
- `SETUP_RAPIDO.md`: Aggiunta Opzione B (Setup locale senza database)

### 🐛 Bug Fixes

- **Dropdown vuoto**: Risolto problema dropdown utenti vuoto quando server non disponibile
- **Fallback graceful**: App non crasha se database server mancante

### 🔧 Miglioramenti Tecnici

- **IndexedDB Structure**: 3 stores (utenti, pagine, items)
- **Unified API**: Stesso codice client per entrambe le modalità
- **Data URL Support**: Upload immagini convertito in Data URL per storage locale
- **Export/Import**: Funzioni per backup/restore dati locali

### 📊 Comparazione Versioni

| Versione | Database | Offline | Utenti Locali | IndexedDB |
|----------|----------|---------|---------------|-----------|
| 1.0.0 | ✅ Solo Server | ❌ No | ❌ No | ❌ No |
| 1.1.0 | ✅ Server + Locale | ✅ Completo | ✅ Sì | ✅ Sì |

---

## [1.0.0] - 2025-11-11 - Release Iniziale 🎉

### ✨ Caratteristiche Principali

- **Griglia Adattiva 2x2**: Layout intelligente (1-4 immagini)
- **Multi-Pagina con Swipe**: Navigazione fluida tra pagine
- **Integrazione ARASAAC**: Accesso pittogrammi
- **Upload Immagini**: Caricamento personalizzato
- **TTS**: Sintesi vocale italiana
- **Colori Personalizzabili**: Sfondo e testo per item
- **PWA**: Progressive Web App installabile
- **Responsive**: Ottimizzato per ogni schermo

### 📦 Struttura Iniziale

```
comunicatore/
├── index.html
├── gestione.html (Educatore)
├── comunicatore.html (Paziente)
├── api/
│   ├── setup_database.sql
│   ├── pagine.php
│   ├── items.php
│   └── upload_image.php
├── css/
│   ├── educatore.css
│   └── comunicatore.css
├── js/
│   ├── api-client.js
│   ├── arasaac-service.js
│   ├── educatore-app.js
│   └── comunicatore-app.js
├── manifest.json
└── service-worker.js
```

### 🗄️ Database

**Tabelle create:**
- `comunicatore_pagine` - Pagine multi-pagina
- `comunicatore_items` - Items con posizioni griglia (1-4)
- `comunicatore_log` - Log utilizzo (opzionale)

### 📱 PWA Features

- Service Worker con cache offline
- Manifest configurato
- Installabile su mobile (Android/iOS)
- Icons 192x192 e 512x512

---

## 🔮 Roadmap Futura

### Versione 1.2.0 (Pianificata)
- [ ] **Sincronizzazione**: Merge automatico dati locale ↔ server
- [ ] **Multi-lingua**: Interfaccia in inglese/spagnolo
- [ ] **Categorie**: Organizzazione items per categorie
- [ ] **Statistiche**: Dashboard utilizzo comunicatore

### Versione 1.3.0 (Pianificata)
- [ ] **Video Items**: Supporto video oltre a immagini
- [ ] **Ricerca Full-Text**: Cerca items per parola chiave
- [ ] **Temi**: Dark mode / High contrast
- [ ] **Voce personalizzata**: Registrazione vocale custom

### Versione 2.0.0 (Futuro)
- [ ] **Cloud Sync**: Google Drive / Dropbox backup
- [ ] **Multi-educatore**: Collaborazione tempo reale
- [ ] **AI Suggestions**: Suggerimenti item basati su ML
- [ ] **Analytics**: Insights utilizzo avanzati

---

## 📄 Convenzioni Versioning

Usiamo [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.x.x): Cambiamenti incompatibili API
- **MINOR** (x.1.x): Nuove funzionalità compatibili
- **PATCH** (x.x.1): Bug fixes

---

## 🙏 Contributors

- **Sviluppo Iniziale**: AssistiveTech Team
- **Modalità HYBRID**: AssistiveTech Team (Nov 2025)

---

## 📞 Supporto

Per domande o bug report:
- Consulta `README.md`
- Verifica `HYBRID_MODE.md` per modalità ibrida
- Leggi `SETUP_RAPIDO.md` per installazione

**Ultimo Aggiornamento**: 12 Novembre 2025

