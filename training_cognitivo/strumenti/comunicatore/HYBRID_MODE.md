# 🔄 Modalità HYBRID - Online + Offline

## 📱 Funzionamento Dual-Mode

Il **Comunicatore** ora supporta **modalità HYBRID**, funzionando sia con database server (MySQL) che con database locale (IndexedDB) per un'esperienza **PWA offline completa**.

---

## ✨ Caratteristiche

### 🌐 Modalità Online (Server)
- ✅ Connessione a database MySQL
- ✅ Utenti caricati da tabella `registrazioni`
- ✅ Dati sincronizzati tra dispositivi
- ✅ Backup automatico su server
- ✅ Badge: `🔌 Modalità Online`

### 💾 Modalità Offline (Locale)
- ✅ Database IndexedDB nel browser
- ✅ Creazione utenti locali
- ✅ Dati salvati sul dispositivo
- ✅ Funziona senza connessione internet
- ✅ Badge: `📴 Modalità Offline (Locale)`

---

## 🎯 Come Funziona

### Educatore - Gestione Utenti

#### 1. Caricamento Utenti

Al caricamento della pagina:

```javascript
// Tenta caricamento da SERVER
try {
    fetch('/Assistivetech/api/get_pazienti.php')
    // Se successo: mostra utenti server
} catch {
    // Se fallisce: passa a locale
}

// Carica utenti LOCALI da IndexedDB
localDB.listUtenti()
```

Il dropdown mostra **entrambi i gruppi**:

```
📡 Utenti Server
  - Mario (da database)
  - Luca (da database)

💾 Utenti Locali (PWA)
  - Paolo (locale)
  - Anna (locale)
```

#### 2. Creare Utente Locale

1. Clicca **+ (icona persona)** accanto a "Seleziona Utente"
2. Inserisci nome: es. `"Paolo"`
3. Clicca **✓**
4. Utente salvato in **IndexedDB**
5. Appare nel gruppo "Utenti Locali"

```javascript
// Salva in IndexedDB
await localDB.saveUtente('Paolo');

// Ricarica dropdown
await loadPazienti();
```

#### 3. Gestione Pagine/Items

**Automatico in base all'utente selezionato:**

```javascript
if (appState.isOnlineMode) {
    // Utente server: usa API PHP
    await apiClient.createPagina(...);
    await apiClient.createItem(...);
} else {
    // Utente locale: usa IndexedDB
    await localDB.createPagina(...);
    await localDB.createItem(...);
}
```

---

## 💡 Uso Pratico

### Scenario 1: Ambiente Ospedaliero (Online)

1. **Educatore**: 
   - Accede con WiFi ospedaliero
   - Vede pazienti dal database centrale
   - Crea pagine/items per ogni paziente

2. **Paziente**:
   - Usa tablet connesso
   - Seleziona il suo nome dal server
   - Naviga le pagine create dall'educatore

✅ **Vantaggi**: Dati centralizzati, accessibili da più dispositivi

### Scenario 2: Uso Domiciliare (Offline)

1. **Educatore** (setup iniziale):
   - Crea utente locale: "Marco"
   - Crea 3 pagine con immagini
   - Tutto salvato su tablet/PC

2. **Paziente** (uso quotidiano):
   - Tablet **senza internet**
   - Seleziona "Marco" (utente locale)
   - App funziona perfettamente offline

✅ **Vantaggi**: Nessuna connessione richiesta, privacy locale

### Scenario 3: Modalità Mista

1. **Educatore** in ospedale:
   - Crea pazienti online per terapie in sede
   
2. **Educatore** a casa paziente:
   - Nessuna connessione disponibile
   - Crea utente locale per dimostrazione immediata

✅ **Vantaggi**: Massima flessibilità

---

## 🗄️ Struttura Dati Locale

### IndexedDB: `comunicatore_local_db`

**Store 1: `utenti`**
```javascript
{
    id: 1,  // Auto-increment
    nome: 'Paolo',
    data_creazione: '2025-11-12T10:30:00Z'
}
```

**Store 2: `pagine`**
```javascript
{
    id_pagina: 1,
    id_utente: 1,  // FK a utenti
    nome_pagina: 'Comunicazione Base',
    descrizione: 'Pagina principale',
    numero_ordine: 0,
    stato: 'attiva',
    data_creazione: '...'
}
```

**Store 3: `items`**
```javascript
{
    id_item: 1,
    id_pagina: 1,  // FK a pagine
    posizione_griglia: 1,  // 1-4
    titolo: 'Voglio mangiare',
    frase_tts: 'Voglio mangiare un gelato',
    tipo_immagine: 'arasaac',
    id_arasaac: 2909,
    url_immagine: 'https://static.arasaac.org/...',
    colore_sfondo: '#FFFFFF',
    colore_testo: '#000000',
    stato: 'attivo'
}
```

---

## 🔧 API Unificata

### Client API Wrapper

Il codice usa sempre le stesse funzioni:

```javascript
// ❌ Non serve più preoccuparsi di dove sono i dati!

// ✅ Crea pagina (auto-detect online/offline)
if (appState.isOnlineMode) {
    await apiClient.createPagina(...);
} else {
    await localDB.createPagina(...);
}
```

### Metodi Disponibili

| Metodo | Online (apiClient) | Offline (localDB) |
|--------|-------------------|-------------------|
| `createPagina()` | ✅ POST /pagine.php | ✅ IndexedDB.add() |
| `listPagine(id)` | ✅ GET /pagine.php | ✅ IndexedDB.getAll() |
| `updatePagina()` | ✅ PUT /pagine.php | ✅ IndexedDB.put() |
| `deletePagina()` | ✅ DELETE /pagine.php | ✅ Soft delete locale |
| `createItem()` | ✅ POST /items.php | ✅ IndexedDB.add() |
| `listItems(id)` | ✅ GET /items.php | ✅ IndexedDB.getAll() |
| `updateItem()` | ✅ PUT /items.php | ✅ IndexedDB.put() |
| `deleteItem()` | ✅ DELETE /items.php | ✅ Soft delete locale |

---

## 📤 Export/Import Dati

### Export da Locale

```javascript
// Esporta tutti i dati locali
const backup = await localDB.exportData();

// Risultato:
{
    version: 1,
    exported_at: '2025-11-12T15:30:00Z',
    utenti: [...],
    pagine: [...],
    items: [...]
}

// Salva JSON su file
const blob = new Blob([JSON.stringify(backup)], {type: 'application/json'});
saveAs(blob, 'comunicatore_backup.json');
```

### Import in Locale

```javascript
// Leggi file JSON
const file = document.getElementById('fileInput').files[0];
const json = JSON.parse(await file.text());

// Importa dati
await localDB.importData(json);
```

---

## 🧹 Gestione Storage

### Pulire Dati Locali

```javascript
// Cancella tutto IndexedDB
await localDB.clearAll();
```

### Dimensioni Storage

- **IndexedDB**: Illimitato (con consenso utente)
- **Immagini Data URL**: Max ~5MB per immagine
- **Immagini ARASAAC**: Solo URL (leggere)

---

## 🚀 Best Practices

### Per Educatori

1. **Online**: Usa per pazienti in terapia regolare
2. **Offline**: Usa per dimostrazioni veloci
3. **Backup**: Esporta dati locali periodicamente
4. **Immagini**: ARASAAC richiede internet (anche offline)

### Per Sviluppatori

1. **Testare entrambe le modalità**
2. **Gestire fallback ARASAAC offline**
3. **Verificare dimensioni immagini Data URL**
4. **Implementare sincronizzazione futura** (opzionale)

---

## 🐛 Troubleshooting

### Problema: Utenti non appaiono

**Causa**: Server non raggiungibile E nessun utente locale

**Soluzione**:
```javascript
// Verifica connessione
console.log('Online:', navigator.onLine);

// Crea utente locale
await localDB.saveUtente('TestUser');
```

### Problema: Immagini non si vedono offline

**Causa**: Immagini ARASAAC richiedono internet

**Soluzione**:
1. Usa upload personalizzato (Data URL)
2. Pre-cache immagini ARASAAC nel Service Worker
3. Implementa fallback placeholder

### Problema: Dati locali persi

**Causa**: Browser cache pulita o dati cancellati

**Soluzione**:
1. Usa export regolare
2. Implementa sync automatico cloud (futuro)
3. Avvisa utente prima di cancellare cache

---

## 📊 Comparazione Modalità

| Caratteristica | Online (Server) | Offline (Locale) |
|----------------|----------------|------------------|
| **Internet** | ✅ Richiesto | ❌ Non necessario |
| **Multi-device** | ✅ Sincronizzato | ❌ Device-specific |
| **Backup** | ✅ Automatico server | 🟡 Export manuale |
| **Privacy** | 🟡 Dati su server | ✅ Solo locale |
| **Setup** | 🟡 Richiede DB MySQL | ✅ Zero config |
| **Velocità** | 🟡 Dipende da rete | ✅ Istantaneo |
| **Storage** | ✅ Illimitato | 🟡 ~50MB tipico |

---

## 🎯 Roadmap Future

- [ ] **Sincronizzazione bidirezionale**: Merge dati locale ↔ server
- [ ] **Conflict resolution**: Gestione modifiche concorrenti
- [ ] **Background sync**: Upload automatico quando torna online
- [ ] **Cloud backup**: Salvataggio automatico su Google Drive/Dropbox
- [ ] **Multi-educatore**: Collaborazione su stesso utente
- [ ] **Versioning**: Storico modifiche pagine/items

---

## 🔐 Sicurezza e Privacy

### Dati Locali

- ✅ Salvati **solo sul browser** dell'utente
- ✅ Non accessibili da altri siti
- ✅ Cancellati con cache browser
- ⚠️ Non crittografati di default (IndexedDB)

### Dati Server

- ✅ Connessione HTTPS (se configurato)
- ✅ Autenticazione educatore (implementabile)
- ✅ Backup centralizzato
- ⚠️ Accessibili da admin server

---

## 📞 Supporto

Per domande sulla modalità HYBRID:
- Consulta `README.md` per setup generale
- Verifica console browser (F12) per errori
- Testa con `localStorage` se IndexedDB fallisce

**Versione HYBRID**: 1.1.0  
**Data**: Novembre 2025

