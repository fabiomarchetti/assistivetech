# 🚀 Guida Rapida - Setup e Test

## ✅ Checklist Setup

### 1. Database (5 minuti)

```bash
# Apri MAMP/XAMPP e avvia MySQL

# In phpMyAdmin o MySQL Workbench:
# 1. Apri database: assistivetech_local
# 2. Esegui SQL:
```

```sql
-- File: script_sql/create_table_agende_strumenti.sql
-- Copia e incolla tutto il contenuto ed esegui

-- File: script_sql/create_table_agende_items.sql
-- Copia e incolla tutto il contenuto ed esegui
```

### 2. Categoria "strumenti" (2 minuti)

1. Apri browser: `http://localhost:8888/Assistivetech/admin/index.html`
2. Login con credenziali sviluppatore:
   - Email: `marchettisoft@gmail.com`
   - Password: `Filohori11!`
3. Sezione "Categorie Esercizi" → "Aggiungi Categoria"
4. Nome: `strumenti`
5. Descrizione: `Strumenti agenda con ARASAAC e video`
6. Salva

### 3. sql.js per Offline (GIÀ CONFIGURATO ✅)

**Nessuna azione richiesta!**

La libreria sql.js è già configurata per caricarsi da CDN.
Il database SQLite locale funzionerà automaticamente.

```javascript
// Già configurato in js/db-manager.js:
locateFile: file => `https://sql.js.org/dist/${file}`
```

### 4. YouTube API Key (GIÀ CONFIGURATO ✅)

**Nessuna azione richiesta!**

L'API Key di YouTube è già stata configurata nel sistema.
La ricerca video funzionerà immediatamente.

```javascript
// Già configurato in js/youtube-service.js:
this.apiKey = 'AIzaSyAKrM5EtCxmo_7_kSSN1rpalvb9QfDIan8';
```

**Nota**: Quota giornaliera Google: 10,000 unità/giorno (circa 100-200 ricerche)

### 5. Icone PWA (Opzionale - 2 minuti)

Crea icone placeholder:

1. Vai su: https://ui-avatars.com/api/?name=A&size=512&background=673AB7&color=fff&font-size=0.5
2. Salva immagine come: `icon-512.png`
3. Ridimensiona a 192x192 e salva come: `icon-192.png`
4. Metti entrambe in: `training_cognitivo/strumenti/assets/icons/`

## 🧪 Test Applicazione

### Test 1: Interfaccia Educatore

1. Apri: `http://localhost:8888/Assistivetech/training_cognitivo/strumenti/gestione.html`

2. **Seleziona Paziente**:
   - Dropdown: scegli un paziente esistente
   - (Se non ci sono pazienti, creane uno dall'admin panel)

3. **Crea Agenda Principale**:
   - Click su "+" accanto a "Agende"
   - Nome: `Agenda Test`
   - Tipo: `Agenda Principale`
   - Salva

4. **Aggiungi Item con ARASAAC**:
   - Click su "Aggiungi Item"
   - Titolo: `Voglio mangiare`
   - Tipo Item: `Semplice`
   - Immagine: `ARASAAC`
   - Cerca: `mangiare`
   - Seleziona un pittogramma
   - Aggiungi

5. **Aggiungi Item Link Agenda**:
   - Crea seconda agenda: `Musica`
   - Nella prima agenda, aggiungi item:
     - Titolo: `Voglio ascoltare musica`
     - Tipo: `Link ad Altra Agenda`
     - Seleziona: `Musica`
     - Aggiungi

6. **Test Drag & Drop**:
   - Trascina item per riordinare
   - Verifica che l'ordine si salvi

### Test 2: Interfaccia Paziente (PWA)

1. Apri: `http://localhost:8888/Assistivetech/training_cognitivo/strumenti/agenda.html`

2. **Seleziona Utente**:
   - Scegli paziente creato prima
   - Conferma

3. **Test Navigazione**:
   - **Swipe**: Scorri dito/mouse da destra a sinistra per item successivo
   - **Frecce**: Click su frecce laterali (desktop)
   - **Long-Click**: Tieni premuto 800ms su item con link agenda
   - **HOME**: Click su bottone HOME in alto a sinistra

4. **Test Video** (se hai API Key):
   - Crea item video YouTube nell'educatore
   - Aprilo nell'agenda paziente
   - Verifica riproduzione

### Test 3: Offline Mode

1. Apri DevTools (F12) → Network tab
2. Seleziona "Offline" dal dropdown
3. Ricarica pagina agenda
4. Verifica che Service Worker carichi da cache

## 🐛 Problemi Comuni

### ❌ "Database connection failed"

**Problema**: PHP non trova il database

**Soluzione**:
```php
// Apri: api/config.php
// Verifica la configurazione:
define('USA_DB_LOCALE', true); // deve essere true per MAMP
```

### ❌ "No pazienti in dropdown"

**Problema**: Nessun paziente nel database

**Soluzione**:
```
1. Vai all'admin panel
2. Sezione "Pazienti"
3. Crea almeno un paziente test
4. Ricarica gestione.html
```

### ❌ "CORS Error"

**Problema**: Browser blocca richieste API

**Soluzione**:
```
Verifica che tutti i file .php abbiano:
header('Access-Control-Allow-Origin: *');
```

### ❌ "ARASAAC API timeout"

**Problema**: API ARASAAC lenta/offline

**Soluzione**:
```
Riprova dopo qualche secondo
L'API ARASAAC è gratuita e può essere lenta
```

### ❌ "Service Worker not registered"

**Problema**: HTTPS richiesto per PWA

**Soluzione**:
```
Localhost funziona anche con HTTP
Per produzione serve HTTPS (Aruba ha SSL gratis)
```

## 📊 Dati di Test Suggeriti

### Agenda Esempio: "Agenda Fabio"

```
Item 1: Voglio mangiare
  - Tipo: Semplice
  - Immagine: ARASAAC "mangiare"

Item 2: Voglio giocare
  - Tipo: Semplice
  - Immagine: ARASAAC "giocare"

Item 3: Voglio ascoltare musica
  - Tipo: Link Agenda
  - Collegata a: "Musica"
```

### Sub-Agenda "Musica"

```
Item 1: Rock
  - Tipo: Video YouTube
  - Cerca: "rock music"

Item 2: Pop
  - Tipo: Video YouTube
  - Cerca: "pop music"

Item 3: Jazz
  - Tipo: Video YouTube
  - Cerca: "jazz music"
```

## 📱 Test PWA su Mobile

### Android (Chrome)

1. Apri `agenda.html` su Chrome mobile
2. Menu (⋮) → "Installa app" o "Aggiungi a schermata Home"
3. Conferma installazione
4. Apri app dalla home screen
5. Verifica funzionamento offline (attiva modalità aereo)

### iOS (Safari)

1. Apri `agenda.html` su Safari
2. Tap su icona "Condividi" (quadrato con freccia)
3. Scorri e tap su "Aggiungi a Home"
4. Conferma
5. Apri app dalla home screen

## 🎯 Flusso Utente Completo

```
1. Educatore crea agenda "Agenda_Mario"
   └─> Aggiunge item "Colazione", "Scuola", "Musica"

2. Item "Musica" è link a sub-agenda "Playlist"
   └─> "Playlist" contiene item video YouTube

3. Paziente Mario apre app
   └─> Seleziona nome
   └─> Vede item "Colazione"
   └─> Swipe → "Scuola"
   └─> Swipe → "Musica"
   └─> Long-click su "Musica"
   └─> Si apre agenda "Playlist"
   └─> Click su video → Riproduzione
   └─> Bottone HOME → Torna ad agenda principale
```

## ✨ Prossimi Passi

1. ✅ Test locale completo
2. 📤 Deploy su Aruba:
   - Carica file via FTP
   - Esegui SQL su database Aruba
   - Verifica URL produzione
3. 🎨 Personalizza icone PWA
4. 🔑 Configura YouTube API Key
5. 👥 Crea pazienti reali
6. 📊 Monitora utilizzo

## 📞 Supporto

Se hai problemi:
1. Controlla console browser (F12)
2. Controlla log PHP (MAMP/logs)
3. Verifica che tutte le tabelle siano create
4. Rileggi questo file

---

**Pronto per iniziare! 🚀**

Tempo stimato setup completo: **15 minuti**
