# 🚀 DEPLOYMENT ARUBA - COMUNICATORE v2.4.0

## 📋 CHECKLIST COMPLETA

### ✅ FASE 1: PREPARAZIONE DATABASE

#### 1.1 - Tabelle Principali
Accedi a **phpMyAdmin** su Aruba e seleziona il tuo database.

**Opzione A: Se le tabelle NON esistono**
```sql
-- Esegui TUTTO il contenuto di: api/setup_database.sql
-- Questo crea: comunicatore_pagine, comunicatore_items, comunicatore_log
```

**Opzione B: Se le tabelle esistono ma mancano le colonne sottopagine**
```sql
-- Esegui SOLO: api/migrate_sottopagine_ARUBA.sql
-- Questo aggiunge: tipo_item, id_pagina_riferimento
```

**Verifica Post-Installazione:**
Controlla che la tabella `comunicatore_items` abbia queste colonne:
- ✅ `id_item`
- ✅ `id_pagina`
- ✅ `posizione_griglia`
- ✅ `titolo`
- ✅ `frase_tts`
- ✅ `tipo_immagine`
- ✅ `id_arasaac`
- ✅ `url_immagine`
- ✅ **`tipo_item`** (ENUM: normale, sottopagina)
- ✅ **`id_pagina_riferimento`** (INT, NULL)
- ✅ `colore_sfondo`
- ✅ `colore_testo`
- ✅ `stato`
- ✅ `data_creazione`
- ✅ `data_modifica`

---

### ✅ FASE 2: UPLOAD FILE FTP

#### 2.1 - Cartella Principale Comunicatore
**Percorso Aruba:** `/training_cognitivo/strumenti/comunicatore/`

**File HTML:**
```
✅ index.html
✅ gestione.html
✅ comunicatore.html
```

**File PWA:**
```
✅ manifest.json
✅ service-worker.js (⚠️ IMPORTANTE: versione v2.4.0)
```

#### 2.2 - Cartella API
**Percorso:** `/training_cognitivo/strumenti/comunicatore/api/`

```
✅ pagine.php (gestione pagine)
✅ items.php (gestione items)
✅ upload_image.php (upload immagini custom)
```

**❌ NON caricare:**
```
❌ test_pagine.php
❌ install_tables.php
❌ setup_database.sql
❌ migrate_sottopagine.sql
❌ migrate_sottopagine_ARUBA.sql
```

#### 2.3 - Cartella JS
**Percorso:** `/training_cognitivo/strumenti/comunicatore/js/`

```
✅ api-client.js (⚠️ con hostname detection)
✅ arasaac-service.js
✅ comunicatore-app.js (⚠️ versione finale v2.4.0)
✅ educatore-app.js (⚠️ versione finale)
✅ db-local.js (IndexedDB per offline)
✅ swipe-handler.js
```

**❌ NON caricare:**
```
❌ app.js (vecchio)
❌ educatore-app-hybrid.js (vecchio)
```

#### 2.4 - Cartella CSS
**Percorso:** `/training_cognitivo/strumenti/comunicatore/css/`

```
✅ styles.css
✅ educatore.css
✅ comunicatore.css
```

#### 2.5 - Cartella Assets
**Percorso:** `/training_cognitivo/strumenti/comunicatore/assets/`

**Icons:**
```
✅ assets/icons/icon-192.png (⚠️ OBBLIGATORIO per PWA)
✅ assets/icons/icon-512.png (⚠️ OBBLIGATORIO per PWA)
```

**Images (se hai immagini custom):**
```
✅ assets/images/[tuoi file]
```

**❌ NON caricare:**
```
❌ assets/icons/megafono.png (sorgente)
❌ assets/icons/generate_icons.html
❌ assets/icons/create_placeholder_icons.html
❌ assets/icons/GENERATE_ICONS.md
```

#### 2.6 - Cartella Upload
**Percorso:** `/training_cognitivo/strumenti/comunicatore/uploads/`

⚠️ **CREA questa cartella se non esiste** (per immagini caricate dagli educatori)

**Permessi:** `chmod 755` o `777` se necessario

---

### ✅ FASE 3: FILE API CONDIVISI

#### 3.1 - File nella cartella `/api/` (ROOT)
**Percorso Aruba:** `/api/`

**Verifica che esistano:**
```
✅ config.php (configurazione database)
✅ get_pazienti.php (⚠️ AGGIORNATO con supporto tabella 'pazienti')
```

**Se `get_pazienti.php` NON è aggiornato, sovrascrivi con la versione da:**
```
Assistivetech/api/get_pazienti.php
```

**Contenuto minimo di `config.php` (verifica):**
```php
<?php
$host = 'localhost';
$dbname = 'Sql1073852_1'; // Il tuo database Aruba
$username = 'Sql1073852'; // Il tuo username
$password = 'XXXXXXXXXX'; // La tua password

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode([
        'success' => false,
        'message' => 'Errore connessione database: ' . $e->getMessage()
    ]));
}
```

---

### ✅ FASE 4: PERMESSI FILE (CHMOD)

Dopo l'upload, imposta i permessi:

```bash
# Cartelle
chmod 755 comunicatore/
chmod 755 comunicatore/api/
chmod 755 comunicatore/uploads/  # ⚠️ IMPORTANTE
chmod 755 comunicatore/assets/
chmod 755 comunicatore/assets/images/

# File PHP (eseguibili)
chmod 644 comunicatore/api/*.php

# File statici
chmod 644 comunicatore/*.html
chmod 644 comunicatore/*.json
chmod 644 comunicatore/js/*.js
chmod 644 comunicatore/css/*.css
```

Se le immagini non si caricano, prova:
```bash
chmod 777 comunicatore/uploads/
```

---

### ✅ FASE 5: VERIFICA POST-DEPLOYMENT

#### 5.1 - Test Database
Vai a: `https://www.assistivetech.it/training_cognitivo/strumenti/comunicatore/gestione.html`

1. ✅ **Dropdown utenti** si carica
2. ✅ Seleziona un utente → nessun errore console
3. ✅ Crea una pagina → salva correttamente
4. ✅ Aggiungi un item → appare nella griglia

#### 5.2 - Test Area Utente
Vai a: `https://www.assistivetech.it/training_cognitivo/strumenti/comunicatore/comunicatore.html`

1. ✅ Dropdown utenti si carica
2. ✅ Seleziona un utente → vedi le sue pagine
3. ✅ **Click su item** → TTS funziona
4. ✅ **Click su sottopagina** → TTS + naviga immediatamente
5. ✅ **Swipe** → cambia pagina (loop circolare)
6. ✅ **Bottone 🔙** → torna indietro da sottopagina

#### 5.3 - Test PWA
1. ✅ Apri da mobile (Chrome/Safari)
2. ✅ Appare banner "Aggiungi a Home"
3. ✅ Installa → icona corretta (megafono)
4. ✅ Apri offline → funziona con IndexedDB

#### 5.4 - Test Console
Apri DevTools (F12) e verifica:
```
✅ Nessun errore 404
✅ Nessun errore CORS
✅ Service Worker attivo
✅ API path corretto (PRODUZIONE)
```

**Console dovrebbe mostrare:**
```
📡 Ambiente: PRODUZIONE (Aruba)
📡 API BaseURL: /training_cognitivo/strumenti/comunicatore/api
✅ App inizializzata in modalità HYBRID
```

---

### ✅ FASE 6: TROUBLESHOOTING

#### Problema: "Utenti non si caricano"
**Soluzione:**
```
1. Verifica che /api/get_pazienti.php esista
2. Verifica che la tabella 'pazienti' esista nel DB
3. Controlla errori in console
```

#### Problema: "Errore 500 su pagine.php"
**Soluzione:**
```
1. Verifica che le tabelle comunicatore_* esistano
2. Controlla /api/config.php (credenziali DB)
3. Verifica permessi file (chmod 644)
```

#### Problema: "Immagini non si caricano"
**Soluzione:**
```
1. Verifica che /uploads/ esista
2. chmod 777 comunicatore/uploads/
3. Controlla che upload_image.php abbia permessi
```

#### Problema: "PWA non installa"
**Soluzione:**
```
1. Verifica HTTPS attivo
2. Verifica icon-192.png e icon-512.png esistano
3. Controlla manifest.json (start_url corretto)
4. Service Worker registrato (console)
```

#### Problema: "Click non funziona su item"
**Soluzione:**
```
1. CTRL+SHIFT+R per ricaricare cache
2. Verifica service-worker.js versione v2.4.0
3. Disattiva Service Worker e ricarica
```

---

## 📊 RIEPILOGO FILE DA CARICARE

### ✅ OBBLIGATORI (27 file)

#### HTML (3)
- index.html
- gestione.html
- comunicatore.html

#### PWA (2)
- manifest.json
- service-worker.js

#### API (3)
- api/pagine.php
- api/items.php
- api/upload_image.php

#### JavaScript (6)
- js/api-client.js
- js/arasaac-service.js
- js/comunicatore-app.js
- js/educatore-app.js
- js/db-local.js
- js/swipe-handler.js

#### CSS (3)
- css/styles.css
- css/educatore.css
- css/comunicatore.css

#### Assets (2)
- assets/icons/icon-192.png
- assets/icons/icon-512.png

#### API Root (se non presenti) (2)
- /api/config.php
- /api/get_pazienti.php

#### Database SQL (eseguire in phpMyAdmin) (2)
- setup_database.sql (se tabelle non esistono)
- migrate_sottopagine_ARUBA.sql (se tabelle esistono ma manca sottopagine)

### ❌ NON CARICARE (file di sviluppo)

```
❌ README.md
❌ CHANGELOG.md
❌ DEPLOYMENT_*.md
❌ SETUP_RAPIDO.md
❌ HYBRID_MODE.md
❌ test_*.php
❌ test_*.html
❌ install_tables.php
❌ *.sql (dopo averli eseguiti)
❌ educatore-app-hybrid.js
❌ app.js
❌ assets/icons/megafono.png
❌ assets/icons/*.html
❌ assets/icons/*.md
```

---

## 🎯 DIFFERENZE LOCALE vs ARUBA

| Aspetto | Locale (MAMP) | Aruba (Produzione) |
|---------|---------------|-------------------|
| **Hostname** | `localhost` | `www.assistivetech.it` |
| **Base Path** | `/Assistivetech/` | `/` |
| **API Path** | `/Assistivetech/training_cognitivo/strumenti/comunicatore/api` | `/training_cognitivo/strumenti/comunicatore/api` |
| **DB User** | `root` | `Sql1073852` |
| **DB Name** | `assistivetech_local` | `Sql1073852_1` |
| **Upload Path** | `C:\MAMP\htdocs\...\uploads` | `/membri/assistivetech/.../uploads` |
| **HTTPS** | ❌ (HTTP) | ✅ Obbligatorio per PWA |

⚠️ **I file JS rilevano automaticamente l'ambiente tramite `window.location.hostname`** → Nessuna modifica necessaria!

---

## ✨ NUOVE FUNZIONALITÀ v2.4.0

1. ✅ **Click Semplificato**
   - Item normale: TTS
   - Sottopagina: TTS + navigazione immediata (mentre parla)

2. ✅ **Swipe Loop Circolare**
   - Ultima pagina → swipe left → prima pagina
   - Prima pagina → swipe right → ultima pagina

3. ✅ **Navigazione Stack**
   - Bottone 🔙 per tornare indietro da sottopagine
   - Storia navigazione preservata

4. ✅ **Offline Mode**
   - IndexedDB per dati locali
   - Service Worker v2.4.0
   - PWA installabile

---

## 🆘 SUPPORTO

Se hai problemi:
1. Controlla console browser (F12)
2. Verifica file presenti su FTP
3. Testa API direttamente: `/api/get_pazienti.php`
4. Ricarica con CTRL+SHIFT+R

---

**✅ Deployment completato con successo quando tutti i test della FASE 5 passano!**

**Versione:** 2.4.0  
**Data:** 12/11/2025  
**Sistema:** Comunicatore PWA - Assistive Tech

