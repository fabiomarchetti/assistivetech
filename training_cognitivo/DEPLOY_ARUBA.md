# 🚀 Guida Deploy Esercizi Autonomi su Aruba

Guida completa per caricare tutti gli esercizi su Aruba via FTP.

---

## 📦 FILE DA CARICARE

### ✅ Cartella Training Cognitivo Completa

Carica l'intera cartella `training_cognitivo/` mantenendo la struttura:

```
/training_cognitivo/                    ← Percorso su Aruba
│
├── create_exercise_from_template.php   ← Script generatore (opzionale)
├── migrate_existing_exercises.php      ← Script migrazione (opzionale)
├── GENERATORE_ESERCIZI.md             ← Documentazione
├── DEPLOY_ARUBA.md                     ← Questa guida
│
├── categorizzazione/                   ← Categoria
│   ├── index.html                      ← Landing categoria (se esiste)
│   │
│   ├── animali/                        ← Esercizio
│   │   ├── index.html
│   │   ├── manifest.json
│   │   ├── service-worker.js
│   │   ├── README.md
│   │   ├── api/
│   │   │   ├── config.php
│   │   │   └── setup_database.sql
│   │   └── icons/
│   │       ├── icon-192x192.png
│   │       └── icon-512x512.png
│   │
│   ├── frutti/                         ← Altro esercizio
│   ├── veicoli/
│   └── ...
│
├── memoria/
│   └── sequenze_colori/                ← Esercizio nuovo
│
├── causa_effetto/
│   └── accendi_la_luce/
│
├── clicca_immagine/
│   └── cerca_il_colore_corrispondente/
│
├── scrivi/
│   └── scrivi_parole/
│
├── scrivi_con_le_sillabe/
│   └── scrivi_con_le_sillabe/
│
├── sequenze_logiche/
│   ├── ordina_lettere/
│   └── ordina_le_azioni_quotidiane/
│
├── test_memoria/
│   └── ricorda_sequenza/
│
├── trascina_immagini/
│   └── cerca_colore/
│
└── strumenti/
    ├── comunicatore/                   ← Template (opzionale)
    └── ...
```

---

## ❌ FILE DA NON CARICARE (Opzionale)

Puoi omettere questi file se vuoi ridurre dimensioni:

### File di Sviluppo
```
❌ *.docx                # Documentazione Word
❌ setup.docx, index.docx
❌ test_*.html           # File di test
```

### File Documentation (se non serve su produzione)
```
❌ README.md             # (Opzionale: utile per riferimento)
❌ GENERATORE_ESERCIZI.md
❌ DEPLOY_ARUBA.md
```

### Script PHP Opzionali
```
❌ create_exercise_from_template.php    # Solo se non generi su Aruba
❌ migrate_existing_exercises.php       # Solo per migrazione
```

### Template Comunicatore (se non serve)
```
❌ strumenti/comunicatore/   # Serve solo come template sorgente
```

---

## 🎯 FILE ESSENZIALI PER OGNI ESERCIZIO

**Ogni esercizio DEVE avere:**

```
[categoria]/[esercizio]/
├── ✅ index.html              # UI principale
├── ✅ manifest.json           # PWA config
├── ✅ service-worker.js       # Offline support
├── ✅ api/
│   ├── ✅ config.php         # DB connection
│   └── ⚠️  setup_database.sql # Da eseguire in phpMyAdmin
└── ✅ icons/
    ├── ✅ icon-192x192.png
    └── ✅ icon-512x512.png
```

---

## 📋 PROCEDURA DEPLOY STEP-BY-STEP

### 1️⃣ Connessione FTP

**Credenziali Aruba:**
```
Host: ftp.assistivetech.it
User: 7985805@aruba.it
Pass: 67XV57wk4R
Port: 21
```

### 2️⃣ Upload Via FTP

**Opzione A - FileZilla (Consigliato):**

1. Apri FileZilla
2. File → Site Manager
3. Nuovo Sito:
   - Host: `ftp.assistivetech.it`
   - Porta: 21
   - Protocollo: FTP
   - User: `7985805@aruba.it`
   - Password: `67XV57wk4R`
4. Connetti
5. Naviga su server: `/training_cognitivo/`
6. Trascina cartella locale `training_cognitivo/` completa
7. Attendi upload (può richiedere tempo per molti file)

**Opzione B - VS Code FTP-Sync:**

1. Installa estensione "FTP-Sync"
2. Crea `.vscode/ftp-sync.json`:

```json
{
  "protocol": "ftp",
  "host": "ftp.assistivetech.it",
  "port": 21,
  "username": "7985805@aruba.it",
  "password": "67XV57wk4R",
  "remote": "/training_cognitivo/",
  "local": "C:/MAMP/htdocs/Assistivetech/training_cognitivo/",
  "secure": false,
  "ignore": [
    "*.docx",
    "*.md",
    "test_*.html",
    "create_exercise_from_template.php",
    "migrate_existing_exercises.php"
  ]
}
```

3. Click destro cartella → Upload

**Opzione C - lftp (Linux/Mac):**

```bash
lftp -u 7985805@aruba.it,67XV57wk4R ftp.assistivetech.it
cd /
mirror -R training_cognitivo training_cognitivo
```

### 3️⃣ Setup Database

**Per OGNI esercizio**, esegui SQL in phpMyAdmin:

1. Vai su: https://mysql.aruba.it
2. Login con credenziali database:
   - User: `Sql1073852`
   - Password: `5k58326940`
   - Database: `Sql1073852_1`
3. Seleziona database `Sql1073852_1`
4. Tab "SQL"
5. Copia contenuto di ogni file `api/setup_database.sql`
6. Esegui

**Esercizi da configurare (14 + 1):**

```sql
-- 1. Categorizzazione
categorizzazione/animali/api/setup_database.sql
categorizzazione/cerca_veicoli_di_terra/api/setup_database.sql
categorizzazione/frutti/api/setup_database.sql
categorizzazione/veicoli/api/setup_database.sql
categorizzazione/veicoli_aria/api/setup_database.sql
categorizzazione/veicoli_mare/api/setup_database.sql

-- 2. Causa Effetto
causa_effetto/accendi_la_luce/api/setup_database.sql

-- 3. Clicca Immagine
clicca_immagine/cerca_il_colore_corrispondente/api/setup_database.sql

-- 4. Scrivi
scrivi/scrivi_parole/api/setup_database.sql
scrivi_con_le_sillabe/scrivi_con_le_sillabe/api/setup_database.sql

-- 5. Sequenze Logiche
sequenze_logiche/ordina_lettere/api/setup_database.sql
sequenze_logiche/ordina_le_azioni_quotidiane/api/setup_database.sql

-- 6. Test Memoria
test_memoria/ricorda_sequenza/api/setup_database.sql

-- 7. Trascina Immagini
trascina_immagini/cerca_colore/api/setup_database.sql

-- 8. Memoria (nuovo)
memoria/sequenze_colori/api/setup_database.sql
```

**Nota:** Gli SQL sono template base. Se l'esercizio ha già tabelle specifiche o non serve DB, puoi saltare.

### 4️⃣ Verifica Permessi

Verifica che le cartelle abbiano permessi corretti:

```
Cartelle: 755 (rwxr-xr-x)
File PHP: 644 (rw-r--r--)
File HTML/JS/CSS: 644 (rw-r--r--)
```

**Se errori di permessi via FTP:**
1. Panel Aruba → Gestione File
2. Click destro cartella → Permessi
3. Imposta 755 per cartelle, 644 per file

### 5️⃣ Test Funzionalità

Testa ogni esercizio su Aruba:

```
https://assistivetech.it/training_cognitivo/[categoria]/[esercizio]/

Esempi:
https://assistivetech.it/training_cognitivo/categorizzazione/animali/
https://assistivetech.it/training_cognitivo/memoria/sequenze_colori/
https://assistivetech.it/training_cognitivo/causa_effetto/accendi_la_luce/
```

**Checklist Test:**
- ✅ Pagina carica correttamente
- ✅ Nessun errore 404 console
- ✅ Grafica corretta
- ✅ Logica esercizio funziona
- ✅ PWA installabile (Chrome mobile)

---

## 🔧 CONFIGURAZIONE CONFIG.PHP

Il file `api/config.php` in ogni esercizio è già configurato per auto-rilevare ambiente.

**Verifica che contenga:**

```php
// Rileva ambiente basandosi sull'host
$current_host = $_SERVER['HTTP_HOST'] ?? 'localhost';
$is_local = (
    strpos($current_host, 'localhost') !== false ||
    strpos($current_host, '127.0.0.1') !== false ||
    strpos($current_host, '192.168.') !== false ||
    strpos($current_host, '10.0.') !== false
);

if ($is_local) {
    // LOCALE
    $host = 'localhost';
    $username = 'root';
    $password = 'root';
    $database = 'assistivetech_local';
} else {
    // PRODUZIONE ARUBA
    $host = '31.11.39.242';
    $username = 'Sql1073852';
    $password = '5k58326940';
    $database = 'Sql1073852_1';
}
```

✅ **Nessuna modifica necessaria!** Il file rileva automaticamente l'ambiente.

---

## 🆘 TROUBLESHOOTING

### Problema: Errore 404 su file

**Causa:** File non caricati o path errato
**Soluzione:**
1. Verifica via FTP che file esistano
2. Controlla case-sensitive (Linux) dei nomi file
3. Verifica path in URL browser

### Problema: Errore DB Connection

**Causa:** config.php non configurato o credenziali errate
**Soluzione:**
1. Verifica file `api/config.php` esista
2. Controlla credenziali database in config.php
3. Testa connessione DB da phpMyAdmin Aruba

### Problema: PWA non installabile

**Causa:** HTTPS mancante, manifest errato, o icone mancanti
**Soluzione:**
1. Verifica HTTPS attivo: `https://assistivetech.it/...`
2. Controlla file `manifest.json` esista
3. Verifica icone in `icons/icon-192x192.png` e `icon-512x512.png`
4. Apri DevTools → Application → Manifest (verifica errori)

### Problema: Service Worker errori

**Causa:** Cache vecchia o path errati
**Soluzione:**
1. DevTools → Application → Service Workers
2. Click "Unregister"
3. Ricarica pagina (Ctrl+Shift+R)
4. Verifica console per errori

### Problema: Upload FTP lentissimo

**Causa:** Molti file piccoli (icone, js, css)
**Soluzione:**
1. Comprimi cartella in .zip locale
2. Upload .zip via FTP
3. Estrai su server (Panel Aruba → Gestore File)

### Problema: Permessi negati PHP

**Causa:** File non eseguibili
**Soluzione:**
1. Panel Aruba → Gestione File
2. Seleziona file PHP → Permessi → 644
3. Seleziona cartelle → Permessi → 755

---

## 📊 RIEPILOGO DIMENSIONI

Stima dimensioni upload:

```
Training Cognitivo Completo:
├── Esercizi (15): ~50-100 MB
│   ├── HTML/JS/CSS: ~5 MB
│   ├── Icone PNG: ~30 MB
│   ├── Immagini esercizi: ~20-50 MB
│   └── File vari: ~5 MB
├── Template comunicatore: ~10 MB
└── Scripts + docs: ~1 MB

TOTALE: ~60-110 MB
Tempo upload (5 Mbps): ~5-10 minuti
```

---

## ✅ CHECKLIST POST-DEPLOY

Dopo deploy completo, verifica:

### File System
- [ ] Tutti esercizi presenti su FTP
- [ ] Struttura cartelle corretta
- [ ] File `api/config.php` in ogni esercizio
- [ ] Icone PWA presenti
- [ ] Permessi corretti (755/644)

### Database
- [ ] Tabelle create per ogni esercizio (se necessario)
- [ ] Connessione DB funzionante
- [ ] Query SQL eseguite senza errori

### Test Funzionali
- [ ] Ogni esercizio carica correttamente
- [ ] Nessun errore 404 console
- [ ] Grafica rendering corretto
- [ ] Logica esercizio funziona
- [ ] PWA installabile da mobile

### PWA
- [ ] Manifest.json caricato
- [ ] Service worker registrato
- [ ] Icone corrette
- [ ] Installabile da Chrome mobile
- [ ] Funziona offline

---

## 🎯 URL FINALI ESERCIZI

Dopo deploy, esercizi disponibili su:

### Categorizzazione
```
https://assistivetech.it/training_cognitivo/categorizzazione/animali/
https://assistivetech.it/training_cognitivo/categorizzazione/frutti/
https://assistivetech.it/training_cognitivo/categorizzazione/veicoli/
https://assistivetech.it/training_cognitivo/categorizzazione/veicoli_aria/
https://assistivetech.it/training_cognitivo/categorizzazione/veicoli_mare/
https://assistivetech.it/training_cognitivo/categorizzazione/cerca_veicoli_di_terra/
```

### Memoria
```
https://assistivetech.it/training_cognitivo/memoria/sequenze_colori/
```

### Causa Effetto
```
https://assistivetech.it/training_cognitivo/causa_effetto/accendi_la_luce/
```

### Altri
```
https://assistivetech.it/training_cognitivo/clicca_immagine/cerca_il_colore_corrispondente/
https://assistivetech.it/training_cognitivo/scrivi/scrivi_parole/
https://assistivetech.it/training_cognitivo/scrivi_con_le_sillabe/scrivi_con_le_sillabe/
https://assistivetech.it/training_cognitivo/sequenze_logiche/ordina_lettere/
https://assistivetech.it/training_cognitivo/sequenze_logiche/ordina_le_azioni_quotidiane/
https://assistivetech.it/training_cognitivo/test_memoria/ricorda_sequenza/
https://assistivetech.it/training_cognitivo/trascina_immagini/cerca_colore/
```

---

## 🚀 DEPLOY RAPIDO (TL;DR)

```bash
1. Connetti FTP: ftp.assistivetech.it
2. Upload: /training_cognitivo/ (intera cartella)
3. Per ogni esercizio: Esegui api/setup_database.sql in phpMyAdmin
4. Testa: https://assistivetech.it/training_cognitivo/[cat]/[es]/
5. ✅ Deploy completato!
```

---

**Data:** 13/11/2024
**Sistema:** AssistiveTech Training Cognitivo
**Esercizi Totali:** 15 autonomi + template
