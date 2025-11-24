# 🚀 Deployment Comunicatore su Aruba

## 📦 Checklist Deployment

### 1️⃣ **Upload Files**

#### A. Cartella Principale
Carica l'intera cartella `comunicatore/` su Aruba in:
```
/training_cognitivo/strumenti/comunicatore/
```

#### B. File Condivisi (se non esistono già)
Verifica e carica in `/api/`:
- `config.php` ✅ (gestisce automaticamente ambiente Aruba)
- `get_pazienti.php` (se non esiste)

**Struttura finale su Aruba:**
```
/
├── api/
│   ├── config.php              ← DEVE ESISTERE
│   └── get_pazienti.php        ← Verifica se esiste
├── training_cognitivo/
│   └── strumenti/
│       └── comunicatore/       ← CARICA QUESTA CARTELLA
│           ├── api/
│           ├── assets/
│           ├── css/
│           ├── js/
│           ├── index.html
│           ├── gestione.html
│           ├── comunicatore.html
│           ├── manifest.json
│           └── service-worker.js
```

---

### 2️⃣ **Database**

#### A. Esegui Script SQL
Accedi a phpMyAdmin su Aruba e:

1. Seleziona database: `Sql1073852_1`
2. Vai su **SQL** tab
3. Carica o incolla il contenuto di:
   ```
   comunicatore/api/setup_database.sql
   ```
4. Clicca **Esegui**

**Tabelle create:**
- `comunicatore_pagine`
- `comunicatore_items`
- `comunicatore_log`

#### B. Verifica Tabella Pazienti
Assicurati che esista una tabella `pazienti` o `registrazioni` con campi:
- `id_paziente` o `id_registrazione`
- `nome_paziente` + `cognome_paziente` o `username`

---

### 3️⃣ **Icone PWA** ⚠️ IMPORTANTE!

Le icone **NON esistono** nella cartella! Devi generarle.

#### Opzione A: Genera Online (Veloce)
1. Vai su: https://www.pwabuilder.com/imageGenerator
2. Carica un'immagine 512x512 con:
   - Griglia 2x2 stilizzata
   - Colore viola (#673AB7)
   - Simbolo comunicazione
3. Scarica il pacchetto
4. Estrai `icon-192.png` e `icon-512.png`
5. Carica in `/comunicatore/assets/icons/`

#### Opzione B: Usa Placeholder Temporaneo
Se vuoi testare subito, crea due file PNG con ImageMagick o Photoshop:

**icon-192.png** (192x192px):
- Sfondo viola #673AB7
- Testo bianco "COM" centrato

**icon-512.png** (512x512px):
- Come sopra ma più grande

#### Opzione C: Usa Template SVG
Vedi file `assets/icons/GENERATE_ICONS.md` per template SVG completo.

---

### 4️⃣ **Permessi Cartelle**

Via FTP, imposta permessi **755** o **775** per:
```bash
/comunicatore/assets/images/      # Upload immagini custom
```

Se gli upload falliscono, cambia permessi a **777** (meno sicuro ma funziona).

---

### 5️⃣ **Verifica Config.php**

Il file `/api/config.php` è già configurato per Aruba.

**NON modificarlo manualmente!** Rileva automaticamente:
- Host: `31.11.39.242`
- Database: `Sql1073852_1`
- Username: `Sql1073852`
- Password: `5k58326940`

Se vuoi verificare, controlla che contenga:
```php
if ($is_local) {
    // ... config locale
} else {
    // CONFIGURAZIONE PRODUZIONE (ARUBA)
    $host = '31.11.39.242';
    $username = 'Sql1073852';
    $password = '5k58326940';
    $database = 'Sql1073852_1';
}
```

---

## 🧪 Test Funzionalità

Dopo il deployment, testa:

### 1. **Accesso Base**
```
https://tuosito.it/training_cognitivo/strumenti/comunicatore/
```
Dovresti vedere la schermata di selezione ruolo.

### 2. **Test API**
```
https://tuosito.it/training_cognitivo/strumenti/comunicatore/api/pagine.php?action=list&id_paziente=1
```
Risposta attesa:
```json
{
  "success": true,
  "message": "Pagine caricate",
  "data": []
}
```

### 3. **Test Database**
Vai su:
```
https://tuosito.it/training_cognitivo/strumenti/comunicatore/api/install_tables.php
```
Dovresti vedere conferma tabelle esistenti.

### 4. **Test Educatore**
1. Vai su `gestione.html`
2. Seleziona utente
3. Crea pagina
4. Aggiungi item con immagine ARASAAC
5. Verifica salvataggio

### 5. **Test Paziente**
1. Vai su `comunicatore.html`
2. Seleziona utente
3. Verifica visualizzazione pagine
4. **Testa SWIPE** tra pagine (se più di una)
5. Clicca item per TTS

### 6. **Test PWA**
1. Apri con Chrome mobile
2. Menu → Installa app
3. Verifica icona home screen
4. Testa offline mode (disabilita rete)

---

## 🐛 Troubleshooting

### Errore: "Config file not found"
- Verifica che `/api/config.php` esista su Aruba
- Controlla permessi lettura (644 o 755)

### Errore: "Column not found" o "Table doesn't exist"
- Esegui `setup_database.sql` su phpMyAdmin
- Verifica nome database: `Sql1073852_1`

### Icone PWA non appaiono
- Verifica che esistano in `/assets/icons/`
- Controlla `manifest.json` (path corretti)
- Cancella cache browser e ricarica

### Upload immagini fallisce
- Verifica permessi `/assets/images/` (755 o 777)
- Controlla dimensione max upload PHP (di solito 2MB)

### Swipe non funziona
- Ricarica con `CTRL+SHIFT+R`
- Cancella cache PWA
- Verifica Service Worker in DevTools

### Nessun utente nel dropdown
- Controlla tabella `pazienti` su phpMyAdmin
- Verifica che esistano record
- Controlla `/api/get_pazienti.php`

---

## 📱 PWA: Installazione Mobile

### Android (Chrome)
1. Apri sito con Chrome
2. Menu (⋮) → "Installa app" o "Aggiungi a Home"
3. Conferma

### iOS (Safari)
1. Apri sito con Safari
2. Tap su icona condivisione (↑)
3. "Aggiungi a schermata Home"
4. Conferma

---

## 🔐 Sicurezza

### Raccomandazioni:
1. ✅ Config.php è fuori da DocumentRoot? → Ideale
2. ✅ DEBUG_MODE disattivato in produzione? → Auto-disattivato
3. ⚠️ HTTPS attivo? → Necessario per PWA e Service Worker
4. ⚠️ Backup database regolari? → Configura su Aruba

---

## 📊 Monitoraggio

### Log Errori
Controlla:
```
/error_log  (root Aruba)
```

### Performance
Service Worker cache:
- Verifica in DevTools → Application → Cache Storage
- Nome cache: `comunicatore-v2.0.0`

---

## 🔄 Aggiornamenti Futuri

Per aggiornare l'app:

1. **Modifica versione** in `service-worker.js`:
   ```javascript
   const CACHE_NAME = 'comunicatore-v2.0.1'; // Incrementa
   ```

2. **Carica file modificati** via FTP

3. **Gli utenti** riceveranno l'aggiornamento automaticamente al prossimo caricamento

---

## ✅ Deployment Completato!

Se hai seguito tutti i passaggi, l'applicazione è ora:
- ✅ Online su Aruba
- ✅ Collegata al database cloud
- ✅ Installabile come PWA
- ✅ Funzionante offline (con dati locali)
- ✅ Swipe tra pagine attivo

---

## 📞 Supporto

Per problemi specifici, controlla:
- `README.md` - Documentazione principale
- `HYBRID_MODE.md` - Modalità online/offline
- `SETUP_RAPIDO.md` - Setup veloce locale

---

**Ultima revisione**: Novembre 2025

