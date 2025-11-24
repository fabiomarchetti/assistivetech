# 🚀 Generatore Esercizi Autonomi

Script per creare nuovi esercizi **completamente autonomi** basati sul template "Comunicatore".

## ✨ Caratteristiche

Ogni esercizio generato è **totalmente indipendente** e include:

- ✅ Propri file PHP (config.php, API)
- ✅ Propri file JavaScript
- ✅ Manifest e Service Worker PWA
- ✅ Tabelle database dedicate
- ✅ Icone e assets
- ✅ README documentazione
- ✅ **Nessuna dipendenza** da file comuni

## 📦 Struttura Generata

```
[categoria]/[nome_esercizio]/
│
├── index.html                # Landing page
├── gestione.html             # Interfaccia educatore
├── esercizio.html            # Interfaccia paziente
├── manifest.json             # PWA config
├── service-worker.js         # Offline support
├── README.md                 # Documentazione esercizio
│
├── api/                      # Backend autonomo
│   ├── config.php           # DB connection
│   ├── pagine.php           # CRUD pagine
│   ├── items.php            # CRUD items
│   ├── upload_image.php     # Upload immagini
│   └── setup_database.sql   # Script SQL tabelle
│
├── js/                       # JavaScript autonomo
│   ├── api-client.js
│   ├── esercizio-app.js
│   ├── educatore-app.js
│   ├── db-local.js
│   ├── arasaac-service.js
│   └── swipe-handler.js
│
├── css/                      # Stili autonomi
│   ├── esercizio.css
│   └── educatore.css
│
└── assets/                   # Risorse
    ├── icons/
    │   ├── icon-192.png
    │   └── icon-512.png
    └── images/
```

## 🎯 Utilizzo Script

### Sintassi

```bash
php create_exercise_from_template.php [categoria] [nome_esercizio] [descrizione]
```

### Esempi

```bash
# Esempio 1: Esercizio di memoria
php create_exercise_from_template.php memoria sequenze_colori "Esercizio di memoria con sequenze colorate"

# Esempio 2: Esercizio di attenzione
php create_exercise_from_template.php attenzione trova_differenze "Trova le differenze tra due immagini"

# Esempio 3: Esercizio di linguaggio
php create_exercise_from_template.php linguaggio completa_frase "Completa la frase con la parola corretta"

# Esempio 4: Duplica esercizio esistente con personalizzazioni
php create_exercise_from_template.php categorizzazione animali_farm "Categorizzazione specifico animali fattoria"
```

### Percorsi PHP MAMP Windows

```bash
# PHP 7 (consigliato)
/c/MAMP/bin/php/php7.0.31/php.exe create_exercise_from_template.php [args]

# Se hai versioni diverse, trova con:
find /c/MAMP/bin/php -name "php.exe"
```

## 📋 Workflow Completo

### 1. Genera Esercizio

```bash
cd C:\MAMP\htdocs\Assistivetech\training_cognitivo
/c/MAMP/bin/php/php7.0.31/php.exe create_exercise_from_template.php memoria test_visivo "Test di memoria visiva"
```

### 2. Setup Database

Esegui in phpMyAdmin (locale o Aruba):

```sql
-- File: memoria/test_visivo/api/setup_database.sql
```

### 3. Test Locale

Apri in browser:

```
http://localhost/Assistivetech/training_cognitivo/memoria/test_visivo/
```

### 4. Personalizza

Modifica secondo necessità:

- **Logica esercizio:** `js/esercizio-app.js`
- **Grafica paziente:** `css/esercizio.css`
- **Grafica educatore:** `css/educatore.css`
- **API custom:** `api/*.php`

### 5. Deploy Aruba

Upload via FTP mantenendo struttura:

```
/training_cognitivo/[categoria]/[esercizio]/
```

## 🎨 Personalizzazioni Automatiche

Lo script personalizza automaticamente:

### Nomi e Titoli

- `Comunicatore` → Nome esercizio (es: "Sequenze colori")
- Titoli pagine HTML
- Descrizioni manifest PWA

### Path e Riferimenti

- Path API relativi corretti
- Import JavaScript aggiornati
- Link CSS personalizzati

### Database

- Tabelle: `[categoria]_[esercizio]_pagine`
- Tabelle: `[categoria]_[esercizio]_items`
- Tabelle: `[categoria]_[esercizio]_log`
- Foreign key e constraints

### PWA

- Cache name: `[esercizio]-v1.0.0`
- IndexedDB: `[esercizio]_local_db`
- Manifest personalizzato

## 🗑️ File Rimossi Automaticamente

Lo script rimuove file di sviluppo non necessari:

- Tutti i file `.md` (tranne README generato)
- File `test_*.php` e `test_*.html`
- Script SQL template originali
- File JavaScript deprecati
- Assets sorgente (icone generate manualmente)

## ✅ Vantaggi Approccio

### Per Sviluppatori

- ⚡ **Rapidità**: Nuovo esercizio in secondi
- 🔄 **Riusabilità**: Template testato e funzionante
- 🎯 **Consistenza**: Stessa struttura per tutti
- 📦 **Autonomia**: Nessuna dipendenza esterna

### Per Personalizzazione

- 🎨 **Libertà totale**: Modifica qualsiasi file
- 🔧 **Isolamento**: Cambio non impatta altri esercizi
- 📱 **PWA Ready**: Installabile immediatamente
- 💾 **Offline**: Funziona senza connessione

### Per Deploy

- 🚀 **Deploy singolo**: Solo cartella esercizio
- 🗄️ **DB separato**: Tabelle dedicate
- 🔒 **Sicurezza**: Nessuna interferenza tra esercizi
- 📊 **Scaling**: Infiniti esercizi possibili

## 🔍 Verifica Esercizio Generato

### Checklist Post-Generazione

```bash
# 1. Verifica struttura cartelle
ls -la memoria/test_visivo/

# 2. Verifica file API esistono
ls memoria/test_visivo/api/

# 3. Verifica personalizzazioni
grep "test_visivo" memoria/test_visivo/manifest.json
grep "memoria_test_visivo" memoria/test_visivo/api/setup_database.sql

# 4. Verifica icone PWA
ls memoria/test_visivo/assets/icons/
```

### Test Funzionalità

1. ✅ **Landing page** carica correttamente
2. ✅ **Gestione educatore** accessibile
3. ✅ **Esercizio paziente** accessibile
4. ✅ **SQL setup** eseguibile senza errori
5. ✅ **PWA installabile** da Chrome mobile

## 🆘 Troubleshooting

### Errore: "Template sorgente non trovato"

**Problema**: Script non trova cartella comunicatore
**Soluzione**: Verifica percorso in `$TEMPLATE_SOURCE`

```php
$TEMPLATE_SOURCE = __DIR__ . '/strumenti/comunicatore';
```

### Errore: "PHP version"

**Problema**: Sintassi PHP 7+ non supportata da PHP 5
**Soluzione**: Usa PHP 7 o superiore

```bash
/c/MAMP/bin/php/php7.0.31/php.exe create_exercise_from_template.php [args]
```

### Esercizio già esistente

**Domanda**: "⚠️  Esercizio già esistente, sovrascrivere? (y/n)"
**Risposta**:
- `y` = Elimina e ricrea completamente
- `n` = Annulla operazione

### Permessi cartelle Windows

Se errori di scrittura:

1. Click destro cartella `training_cognitivo`
2. Proprietà → Sicurezza
3. Modifica → Aggiungi "Everyone" con controllo completo

## 📚 Risorse

### File Principali

- **Script generatore**: `create_exercise_from_template.php`
- **Template sorgente**: `strumenti/comunicatore/`
- **Documentazione**: `GENERATORE_ESERCIZI.md` (questo file)

### Esempi Generati

- `memoria/sequenze_colori/` - Esempio funzionante
- Ogni esercizio ha proprio `README.md` con doc specifica

### Database

- Schema tabelle in `api/setup_database.sql` di ogni esercizio
- Naming convention: `[categoria]_[esercizio]_[tipo_tabella]`

## 🎯 Best Practices

### Naming Convention

- **Categorie**: `memoria`, `attenzione`, `linguaggio`, `categorizzazione`
- **Esercizi**: `snake_case`, descrittivi: `sequenze_colori`, `trova_differenze`
- **No spazi** nei nomi (vengono convertiti in underscore)

### Descrizioni

- Chiare e concise (max 100 caratteri)
- Descrivi obiettivo esercizio
- Evita acronimi non standard

### Organizzazione

```
training_cognitivo/
├── memoria/              # Categoria
│   ├── sequenze_colori/  # Esercizio 1
│   ├── ricorda_immagini/ # Esercizio 2
│   └── associa_coppie/   # Esercizio 3
│
├── attenzione/
│   ├── trova_intruso/
│   └── segui_percorso/
│
└── linguaggio/
    ├── completa_frase/
    └── trova_sillabe/
```

## 🚀 Roadmap Futura

### Miglioramenti Pianificati

- [ ] GUI web per generazione esercizi
- [ ] Template multipli (oltre comunicatore)
- [ ] Personalizzazione interattiva parametri
- [ ] Export/import configurazioni esercizi
- [ ] Libreria componenti riusabili
- [ ] Sistema temi grafici intercambiabili

---

**Creato**: 13/11/2024
**Versione**: 1.0.0
**Template**: Comunicatore v2.4.0
**Sistema**: AssistiveTech Training Cognitivo
