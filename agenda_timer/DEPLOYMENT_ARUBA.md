# 🚀 Guida Deployment Agenda Timer PWA su Aruba

## 📋 Pre-Requisiti

- Flutter installato localmente
- Accesso FTP ad Aruba
- Database MySQL configurato (opzionale, attualmente usa storage locale)

## 🔧 Procedura Build per Produzione

### 1. Preparazione File Sorgente

Modifica il file `web/index.html` per impostare il base href corretto:

```html
<base href="/agenda_timer/">
```

### 2. Build Flutter

```bash
cd /path/to/agenda_timer
flutter build web --release
```

Il comando creerà la cartella `build/web` con tutti i file compilati.

### 3. Copia File nella Root

Copia **TUTTO** il contenuto di `build/web/` nella root di `agenda_timer/`:

```bash
# Linux/Mac
cp -r build/web/* .

# Windows (PowerShell)
Copy-Item -Path "build\web\*" -Destination "." -Recurse -Force
```

**IMPORTANTE**: Devi copiare:
- ✅ Tutti i file `.js` (flutter.js, main.dart.js, etc.)
- ✅ Cartella `assets/`
- ✅ Cartella `canvaskit/`
- ✅ Cartella `icons/`
- ✅ File `manifest.json`
- ✅ File `index.html`
- ✅ File `favicon.png`

## 📤 Upload su Aruba via FTP

### Credenziali FTP
- **Host**: ftp.assistivetech.it
- **Username**: 7985805@aruba.it
- **Password**: 67XV57wk4R
- **Porta**: 21

### File da Uploadare

Carica **tutta la cartella `agenda_timer`** mantenendo la struttura:

```
/agenda_timer/
├── index.html
├── manifest.json
├── .htaccess          ← IMPORTANTE per PWA
├── flutter.js
├── flutter_bootstrap.js
├── flutter_service_worker.js
├── main.dart.js
├── favicon.png
├── version.json
├── assets/
├── canvaskit/
├── icons/
├── api/               ← API PHP per storage web
└── web/               ← Sorgenti (opzionale, non serve in produzione)
```

## 🌐 Test Post-Deployment

### 1. Test Base
Visita: **https://assistivetech.it/agenda_timer/**

Dovresti vedere l'app caricata correttamente.

### 2. Test PWA (Installabilità)

**Chrome Desktop:**
1. Apri DevTools (F12)
2. Tab "Application" → "Manifest"
3. Verifica che manifest.json sia caricato
4. Tab "Service Workers" → Verifica registrazione service worker
5. Dovresti vedere l'icona "Installa" nella barra indirizzi

**Chrome Mobile:**
1. Apri https://assistivetech.it/agenda_timer/
2. Menu → "Aggiungi a schermata Home"
3. L'app dovrebbe installarsi come PWA nativa

**iOS Safari:**
1. Apri https://assistivetech.it/agenda_timer/
2. Tap pulsante "Condividi"
3. "Aggiungi a Home"

### 3. Test Offline

1. Installa la PWA
2. Chiudi browser
3. Disattiva connessione internet
4. Apri la PWA dalla home screen
5. L'app dovrebbe caricarsi (il service worker serve i file cached)

### 4. Test Funzionalità

- ✅ Creazione utenti
- ✅ Creazione agende
- ✅ Aggiunta attività
- ✅ Upload immagini (via `api/upload_image.php`)
- ✅ Ricerca pittogrammi ARASAAC
- ✅ Text-to-speech
- ✅ Salvataggio dati (via `api/save_data.php`)

## 🔍 Troubleshooting

### Problema: Manifest 404
**Soluzione**: Verifica che `manifest.json` sia nella root di `agenda_timer/`

### Problema: Service Worker non si registra
**Soluzione**:
1. Verifica HTTPS attivo su Aruba
2. Controlla console browser per errori
3. Verifica che `.htaccess` sia presente

### Problema: Icone non caricate
**Soluzione**: Verifica che la cartella `icons/` contenga tutti i file:
- Icon-192.png
- Icon-512.png
- Icon-maskable-192.png
- Icon-maskable-512.png

### Problema: Upload immagini fallisce
**Soluzione**:
1. Verifica permessi cartella `api/images/` su server (chmod 755)
2. Crea cartella `agenda_timer/assets/images/` se non esiste
3. Controlla log PHP su Aruba

### Problema: Base href errato (404 su tutti i file)
**Soluzione**:
1. Controlla `index.html` → deve avere `<base href="/agenda_timer/">`
2. Rebuild con `flutter build web` dopo aver modificato `web/index.html`

## 🔒 Sicurezza su Aruba

### HTTPS (Consigliato)
Decommenta nel `.htaccess`:

```apache
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

### Permessi File
```bash
# Via FTP o SSH
chmod 644 index.html manifest.json .htaccess
chmod 755 api/
chmod 644 api/*.php
chmod 755 assets/images/  # Per upload
```

## 📱 Configurazione PWA Ottimale

### Manifest.json Verificato
```json
{
  "name": "Agenda Pittogrammi",
  "short_name": "Agenda PWA",
  "start_url": "./",
  "display": "standalone",
  "background_color": "#673AB7",
  "theme_color": "#673AB7",
  "scope": "./"
}
```

### Service Worker
Flutter genera automaticamente `flutter_service_worker.js` che gestisce:
- ✅ Caching assets
- ✅ Offline support
- ✅ Update strategy

## 🎯 URL Finali

- **Produzione**: https://assistivetech.it/agenda_timer/
- **Locale sviluppo**: http://localhost:8888/Assistivetech/agenda_timer/

## ⚙️ Comandi Utili

```bash
# Build produzione
flutter build web --release

# Copia file
cp -r build/web/* .

# Test locale (simula produzione)
python -m http.server 8000
# Poi apri: http://localhost:8000/

# Analizza dimensione build
flutter build web --analyze-size

# Debug service worker
flutter build web --source-maps
```

## 📞 Support

Per problemi:
1. Controlla console browser (F12)
2. Verifica log Apache su Aruba
3. Controlla file `.htaccess`
4. Verifica permessi cartelle

---

**✅ Deployment completato correttamente quando:**
- App caricata su https://assistivetech.it/agenda_timer/
- Icona "Installa" visibile su Chrome
- Service Worker registrato (DevTools → Application)
- Funziona offline dopo installazione
- Upload immagini funziona
- Salvataggio dati persistente
