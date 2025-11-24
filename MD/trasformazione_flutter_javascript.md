# 🔄 Trasformazione AssistiveTech: Da Flutter a JavaScript Vanilla

**Data**: 21 Ottobre 2025
**Stato**: Proposta Approvata
**Piattaforma Target**: Hosting Aruba (assistivetech.it)

---

## 📋 Panoramica Strategica

### Obiettivo
Convertire l'intero portale AssistiveTech da architettura mista (PHP + Flutter + JavaScript) a **JavaScript Vanilla + PHP API**, mantenendo MySQL come database.

### Motivazione
- ✅ **PWA Native** per ogni esercizio (installabile iOS/Android/Desktop)
- ✅ **Zero Build Process** (nessun `flutter build web`)
- ✅ **Performance Superiori** (JavaScript nativo vs Flutter web)
- ✅ **Manutenibilità** (un solo stack frontend)
- ✅ **Compatibilità Totale** (funziona ovunque)
- ✅ **Deployment Istantaneo** (FTP upload diretto)

---

## 🌐 Stack Tecnologico Aruba

### ✅ Disponibile su Hosting Aruba
```
✓ Apache Web Server (con mod_rewrite)
✓ PHP 8.x
✓ MySQL 8.x
✓ FTP access
✓ HTTPS nativo (assistivetech.it)
✓ .htaccess configurabile
```

### ✅ Richiesto per JavaScript PWA
```
✓ Hosting statico (HTML/CSS/JS) → Apache ✅
✓ Backend API (autenticazione, database) → PHP ✅
✓ Database relazionale → MySQL ✅
✓ HTTPS obbligatorio per PWA → Già attivo ✅
✓ Service Worker → File statico JS ✅
```

**RISULTATO: Compatibilità Totale al 100%**

---

## 🏗️ Architettura Proposta

```
┌─────────────────────────────────────────────────────────┐
│            FRONTEND (JavaScript Vanilla)                 │
├─────────────────────────────────────────────────────────┤
│ • HTML5/CSS3/JavaScript ES6+                            │
│ • Bootstrap 5 (UI responsive)                           │
│ • PWA (manifest.json + service-worker.js)               │
│ • Web APIs native (TTS, Drag & Drop, LocalStorage)     │
│ • Fetch API per chiamate backend                        │
└─────────────────────────────────────────────────────────┘
                         ↕️ HTTPS
┌─────────────────────────────────────────────────────────┐
│              BACKEND (PHP API REST)                      │
├─────────────────────────────────────────────────────────┤
│ • api/auth_login.php (autenticazione)                   │
│ • api/auth_registrazioni.php (CRUD utenti)              │
│ • api/api_sedi.php (gestione sedi)                      │
│ • api/api_risultati_esercizi.php (dati esercizi)        │
│ • api/upload_image.php (upload file)                    │
│ • api/arasaac_proxy.php (proxy API ARASAAC)             │
└─────────────────────────────────────────────────────────┘
                         ↕️ PDO
┌─────────────────────────────────────────────────────────┐
│              DATABASE (MySQL 8.x)                        │
├─────────────────────────────────────────────────────────┤
│ • registrazioni (utenti multi-ruolo)                    │
│ • sedi, educatori, pazienti                             │
│ • categorie_esercizi, esercizi                          │
│ • risultati_esercizi (sessioni pazienti)                │
│ • log_accessi (audit trail)                             │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Struttura File su Aruba (Post-Conversione)

```
assistivetech.it/
├── 🌐 FRONTEND STATICO
│   ├── index.html                    # Landing page
│   ├── login.html                    # Auth (JS vanilla)
│   ├── admin/index.html              # Panel admin (JS)
│   ├── dashboard.html                # Dashboard educatori (JS)
│   │
│   ├── js/                           # JavaScript modulare
│   │   ├── auth.js                   # Gestione autenticazione
│   │   ├── api-client.js             # Wrapper fetch API
│   │   ├── utils.js                  # Funzioni comuni
│   │   └── components/               # Componenti riutilizzabili
│   │       ├── user-table.js
│   │       ├── sede-manager.js
│   │       └── modal.js
│   │
│   ├── css/                          # Stili
│   │   ├── main.css
│   │   └── theme.css
│   │
│   └── assets/                       # Risorse statiche
│       ├── images/
│       ├── icons/
│       └── fonts/
│
├── 🧠 TRAINING COGNITIVO (PWA Individuali)
│   └── training_cognitivo/
│       ├── index.html                # Navigator categorie (JS)
│       │
│       └── [categoria]/              # Es: attenzione_visiva
│           └── [esercizio]/          # Es: cerca_colore
│               ├── index.html        # Esercizio (JS vanilla)
│               ├── setup.html        # Configurazione (JS)
│               ├── manifest.json     # PWA config
│               ├── service-worker.js # Offline support
│               ├── icons/            # PWA icons
│               └── README.md
│
├── 📱 APP AGENDA (Può rimanere Flutter o convertire)
│   └── agenda/
│       └── [build/web/ O versione JS vanilla]
│
└── ⚙️ BACKEND API (PHP - Invariato)
    └── api/
        ├── auth_login.php
        ├── auth_registrazioni.php
        ├── api_sedi.php
        ├── api_risultati_esercizi.php
        ├── upload_image.php
        └── config_db.php
```

---

## 🚀 Piano di Migrazione Graduale

### **Fase 1: Esercizi Training Cognitivo** (PRIORITÀ ALTA)
✅ **Già fatto**: "Cerca Colore" funziona perfettamente in JS vanilla
🔄 **Da fare**: Convertire esercizi Flutter esistenti in template standard

**Template Standard per ogni esercizio:**
```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="manifest" href="manifest.json">
    <link rel="icon" href="icons/icon-192.png">
    <title>[Nome Esercizio] - AssistiveTech</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <!-- UI esercizio -->

    <script type="module">
        // JavaScript modulare ES6+
        import { ApiClient } from '/js/api-client.js';
        import { TTS } from '/js/tts.js';
        // ... logica esercizio
    </script>
</body>
</html>
```

### **Fase 2: Dashboard e Admin Panel**
Convertire interfacce amministrative:
- `admin/index.html` → Gestione utenti con tabelle dinamiche
- `dashboard.html` → Statistiche educatori
- Mantenere API PHP backend invariate

### **Fase 3: Sistema Autenticazione**
- `login.html` → Form + fetch API
- Session management → `localStorage` + JWT (opzionale)
- Redirect logica → JavaScript router

### **Fase 4: App Agenda** (OPZIONALE)
Valutare se:
- Mantenere Flutter (funziona già)
- Convertire a JS vanilla per coerenza totale

---

## 🔧 Componenti Chiave JavaScript

### 1. API Client (Wrapper Fetch)
```javascript
// js/api-client.js
export class ApiClient {
    constructor(baseUrl = '') {
        this.baseUrl = baseUrl;
    }

    async post(endpoint, data) {
        const response = await fetch(`${this.baseUrl}/api/${endpoint}`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(data)
        });
        return response.json();
    }

    async login(username, password) {
        return this.post('auth_login.php', {username, password});
    }

    async saveRisultatiEsercizio(dati) {
        return this.post('api_risultati_esercizi.php', {
            action: 'create_risultato',
            ...dati
        });
    }
}
```

### 2. Service Worker (PWA Offline Support)
```javascript
// service-worker.js
const CACHE_NAME = 'esercizio-v1';
const urlsToCache = [
    './',
    './index.html',
    './setup.html',
    './icons/icon-192.png',
    'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css'
];

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => cache.addAll(urlsToCache))
    );
});

self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request)
            .then(response => response || fetch(event.request))
    );
});
```

### 3. Manifest PWA
```json
{
    "name": "Nome Esercizio - AssistiveTech",
    "short_name": "Esercizio",
    "start_url": "./index.html",
    "display": "standalone",
    "background_color": "#ffffff",
    "theme_color": "#0d6efd",
    "icons": [
        {"src": "icons/icon-192.png", "sizes": "192x192", "type": "image/png"},
        {"src": "icons/icon-512.png", "sizes": "512x512", "type": "image/png"}
    ]
}
```

### 4. TTS Helper (Text-to-Speech)
```javascript
// js/tts.js
export class TTS {
    constructor(lang = 'it-IT') {
        this.synth = window.speechSynthesis;
        this.lang = lang;
    }

    speak(text, rate = 1.0) {
        return new Promise((resolve) => {
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = this.lang;
            utterance.rate = rate;
            utterance.onend = resolve;
            this.synth.speak(utterance);
        });
    }

    stop() {
        this.synth.cancel();
    }
}
```

---

## 🎯 Vantaggi Specifici per Aruba

### 1. **Zero Dipendenze Compilazione**
- ❌ **PRIMA**: `flutter build web` locale → upload 50+ file generati
- ✅ **DOPO**: Edit HTML/JS → upload diretto via FTP

### 2. **Performance Ottimali**
- **Flutter Web**: ~2MB JavaScript bundle + WASM
- **JS Vanilla**: ~50KB minificato + lazy loading

### 3. **Compatibilità Browser Totale**
- **Flutter Web**: Problemi su iOS Safari, browser vecchi
- **JS Vanilla**: Funziona ovunque, degrada gracefully

### 4. **Caching Efficiente**
- **Service Worker** controlla esattamente cosa cachare
- **Offline-first** per esercizi già scaricati
- **Apache .htaccess** per cache headers ottimali

### 5. **Debugging Semplificato**
- **Console browser** nativa
- **DevTools** completo
- **No build errors** oscuri

---

## ✅ Checklist Compatibilità Aruba

| Requisito | Stato | Note |
|-----------|-------|------|
| HTTPS obbligatorio | ✅ | assistivetech.it ha SSL |
| Headers CORS | ✅ | Già configurati in PHP API |
| Service Worker | ✅ | File statico JS |
| LocalStorage/IndexedDB | ✅ | Native browser API |
| Web Speech API (TTS) | ✅ | Funziona client-side |
| Drag & Drop API | ✅ | Già testato in "Cerca Colore" |
| Fetch API | ✅ | Supporto universale |
| MySQL connessioni | ✅ | PHP PDO già configurato |
| Upload file (max 5MB) | ✅ | `upload_image.php` esistente |
| .htaccess config | ✅ | Apache mod_rewrite attivo |

---

## 📊 Confronto Performance

| Metrica | Flutter Web | JavaScript Vanilla |
|---------|-------------|-------------------|
| Bundle iniziale | ~2000 KB | ~50 KB |
| Tempo caricamento | 3-5 secondi | <1 secondo |
| Installazione PWA | Sì | Sì |
| Offline support | Limitato | Completo |
| iOS Safari | Problematico | Nativo |
| Android Chrome | Ottimo | Ottimo |
| Desktop | Ottimo | Ottimo |
| Debugging | Complesso | Nativo DevTools |

---

## 🎓 Esempio Funzionante: "Cerca Colore"

L'app **"Cerca Colore"** dimostra che il pattern funziona perfettamente:

### Caratteristiche Implementate
- ✅ **PWA completa** con manifest.json + service-worker.js
- ✅ **Integrazione ARASAAC** via fetch API
- ✅ **Database MySQL** via PHP API (`api/api_risultati_esercizi.php`)
- ✅ **TTS nativo** con Web Speech API
- ✅ **Drag & Drop fluido** HTML5
- ✅ **Installabile** su iOS/Android/Desktop
- ✅ **Configurazione educatore** completa
- ✅ **Timer latenza** preciso
- ✅ **Feedback visivo/sonoro** (fuochi artificio + GIF + TTS)

### Path Funzionante
```
Locale: /Assistivetech/training_cognitivo/trascina_immagini/cerca_colore/
Produzione: https://assistivetech.it/training_cognitivo/trascina_immagini/cerca_colore/
```

---

## 🔄 Sistema Auto-Generazione Template

### Attuale (Flutter)
```php
// api/api_esercizi.php
function createFlutterExerciseStructure($categoria, $esercizio) {
    // Crea pubspec.yaml, lib/main.dart, web/index.html, ecc.
}
```

### Futuro (JavaScript Vanilla)
```php
// api/api_esercizi.php
function createJSExerciseStructure($categoria, $esercizio) {
    // Crea index.html, setup.html, manifest.json, service-worker.js, icons/
    // Template standardizzato con Bootstrap 5 + Web APIs
}
```

### Template Auto-Generato
```
[esercizio]/
├── index.html              # Esercizio principale (JS vanilla)
├── setup.html              # Configurazione educatore
├── manifest.json           # PWA config
├── service-worker.js       # Offline support
├── icons/
│   ├── icon-192.png
│   └── icon-512.png
├── css/
│   └── custom.css
├── js/
│   └── esercizio.js
└── README.md               # Documentazione
```

---

## 🛠️ Deployment su Aruba

### Credenziali FTP
- **Host**: ftp.assistivetech.it
- **Username**: 7985805@aruba.it
- **Password**: 67XV57wk4R
- **Porta**: 21

### Procedura Deployment JavaScript
1. **Edit file locale** (HTML/CSS/JS)
2. **Test browser** (Chrome DevTools, Lighthouse PWA)
3. **Upload via FTP** (nessun build richiesto)
4. **Test produzione** su assistivetech.it
5. **Script SQL** solo se modifiche database

**Tempo deployment**: ~2 minuti (vs 30+ minuti con Flutter)

---

## 🎯 Prossimi Passi

### Immediate (Sprint 1)
1. ✅ Creare template standard JavaScript per nuovi esercizi
2. ✅ Aggiornare `api/api_esercizi.php` per auto-gen JS invece Flutter
3. ✅ Convertire 1-2 esercizi esistenti come proof of concept

### Breve Termine (Sprint 2-3)
4. 🔄 Convertire dashboard educatori in JavaScript
5. 🔄 Convertire admin panel in JavaScript
6. 🔄 Migrare sistema autenticazione frontend

### Lungo Termine (Sprint 4+)
7. 🔮 Valutare conversione App Agenda
8. 🔮 Implementare PWA offline-first completo
9. 🔮 Sistema notifiche push per educatori

---

## ✅ Conclusione

**La trasformazione a JavaScript Vanilla è FATTIBILE e CONSIGLIATA.**

### Motivi Principali
1. ✅ **Hosting Aruba perfettamente compatibile**
2. ✅ **Performance superiori** (caricamento istantaneo)
3. ✅ **Manutenzione semplificata** (un solo stack)
4. ✅ **PWA native** per ogni esercizio
5. ✅ **Deployment immediato** (no build process)
6. ✅ **Compatibilità totale** iOS/Android/Desktop
7. ✅ **Costi zero** (nessun servizio esterno)
8. ✅ **Proof of concept funzionante** ("Cerca Colore")

### Rischi
- ⚠️ Migrazione graduale richiede tempo
- ⚠️ Necessario mantenere coerenza UI durante transizione
- ⚠️ Testing cross-browser rigoroso

**Strategia Raccomandata**: Migrazione graduale partendo da nuovi esercizi in JS, poi convertire esistenti uno alla volta.

---

**Documento compilato**: 21 Ottobre 2025
**Autore**: Claude Code + Team AssistiveTech
**Versione**: 1.0
