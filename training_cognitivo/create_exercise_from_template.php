<?php
/**
 * Generatore Esercizi Autonomi
 * Crea una nuova cartella esercizio completa basata sul template "comunicatore"
 *
 * Ogni esercizio generato è completamente autonomo con:
 * - Propri file PHP (config, API)
 * - Propri file JS
 * - Manifest e Service Worker PWA
 * - Nessuna dipendenza da file comuni
 *
 * Uso: php create_exercise_from_template.php [categoria] [nome_esercizio] [descrizione]
 */

// ============================================
// CONFIGURAZIONE
// ============================================

$TEMPLATE_SOURCE = __DIR__ . '/strumenti/comunicatore';
$BASE_DIR = __DIR__;

// ============================================
// PARSING ARGOMENTI
// ============================================

if ($argc < 3) {
    echo "❌ Uso: php create_exercise_from_template.php [categoria] [nome_esercizio] [descrizione]\n";
    echo "Esempio: php create_exercise_from_template.php memoria sequenze_colori \"Esercizio di memoria con sequenze colorate\"\n";
    exit(1);
}

$categoria = sanitizeFolderName($argv[1]);
$nomeEsercizio = sanitizeFolderName($argv[2]);
$descrizione = isset($argv[3]) ? $argv[3] : "Esercizio cognitivo";

// ============================================
// PERCORSI
// ============================================

$categoriaPath = $BASE_DIR . '/' . $categoria;
$esercizioPath = $categoriaPath . '/' . $nomeEsercizio;

echo "🚀 Generatore Esercizi Autonomi\n";
echo "================================\n";
echo "📁 Categoria: $categoria\n";
echo "📝 Esercizio: $nomeEsercizio\n";
echo "📄 Descrizione: $descrizione\n";
echo "🎯 Percorso: $esercizioPath\n";
echo "\n";

// ============================================
// VERIFICA TEMPLATE ESISTE
// ============================================

if (!file_exists($TEMPLATE_SOURCE)) {
    echo "❌ Errore: Template sorgente non trovato in $TEMPLATE_SOURCE\n";
    exit(1);
}

// ============================================
// CREA CARTELLA CATEGORIA SE NON ESISTE
// ============================================

if (!file_exists($categoriaPath)) {
    echo "📁 Creo cartella categoria: $categoria\n";
    mkdir($categoriaPath, 0755, true);
}

// ============================================
// VERIFICA ESERCIZIO NON ESISTA GIÀ
// ============================================

if (file_exists($esercizioPath)) {
    echo "⚠️  Esercizio già esistente in $esercizioPath\n";
    echo "❓ Sovrascrivere? (y/n): ";
    $handle = fopen("php://stdin", "r");
    $line = fgets($handle);
    if (trim($line) != 'y') {
        echo "❌ Operazione annullata\n";
        exit(0);
    }
    echo "🗑️  Rimuovo vecchia cartella...\n";
    removeDirectory($esercizioPath);
}

// ============================================
// COPIA RICORSIVA TEMPLATE
// ============================================

echo "📦 Copio template da comunicatore...\n";
copyDirectory($TEMPLATE_SOURCE, $esercizioPath);

// ============================================
// PERSONALIZZAZIONE FILE
// ============================================

echo "✏️  Personalizzo file per esercizio '$nomeEsercizio'...\n";

$replacements = [
    // Testi e titoli
    'Comunicatore' => ucfirst(str_replace('_', ' ', $nomeEsercizio)),
    'comunicatore' => $nomeEsercizio,
    'Sistema di comunicazione' => $descrizione,

    // Path relativi
    '../../../api/config.php' => './api/config.php',
    '../../../../api/config.php' => './api/config.php',

    // Nomi tabelle database
    'comunicatore_pagine' => $categoria . '_' . $nomeEsercizio . '_pagine',
    'comunicatore_items' => $categoria . '_' . $nomeEsercizio . '_items',
    'comunicatore_log' => $categoria . '_' . $nomeEsercizio . '_log',

    // Cache Service Worker
    'comunicatore-v' => $nomeEsercizio . '-v',

    // IndexedDB
    'comunicatore_local_db' => $nomeEsercizio . '_local_db',
];

personalizzaFileRicorsivamente($esercizioPath, $replacements);

// ============================================
// RINOMINA FILE SPECIFICI
// ============================================

echo "📝 Rinomino file specifici...\n";

$fileRenames = [
    'comunicatore.html' => 'esercizio.html',
    'comunicatore-app.js' => 'esercizio-app.js',
    'comunicatore.css' => 'esercizio.css',
];

foreach ($fileRenames as $oldName => $newName) {
    rinominaFileRicorsivo($esercizioPath, $oldName, $newName);
}

// ============================================
// AGGIORNA MANIFEST.JSON
// ============================================

echo "📱 Aggiorno manifest.json PWA...\n";

$manifestPath = $esercizioPath . '/manifest.json';
if (file_exists($manifestPath)) {
    $manifest = json_decode(file_get_contents($manifestPath), true);
    $manifest['name'] = ucfirst(str_replace('_', ' ', $nomeEsercizio)) . ' - ' . ucfirst($categoria);
    $manifest['short_name'] = ucfirst(str_replace('_', ' ', $nomeEsercizio));
    $manifest['description'] = $descrizione;
    $manifest['start_url'] = './esercizio.html';
    file_put_contents($manifestPath, json_encode($manifest, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

// ============================================
// COPIA CONFIG.PHP DENTRO API
// ============================================

echo "⚙️  Copio config.php autonomo in api/...\n";

$configSource = $BASE_DIR . '/../api/config.php';
$configDest = $esercizioPath . '/api/config.php';

if (file_exists($configSource)) {
    copy($configSource, $configDest);
} else {
    echo "⚠️  Warning: config.php non trovato in ../api/\n";
}

// ============================================
// GENERA SQL SETUP
// ============================================

echo "🗄️  Genero script SQL setup database...\n";

$sqlContent = generaSQLSetup($categoria, $nomeEsercizio);
$sqlPath = $esercizioPath . '/api/setup_database.sql';
file_put_contents($sqlPath, $sqlContent);

// ============================================
// PULIZIA FILE NON NECESSARI
// ============================================

echo "🧹 Rimuovo file di sviluppo non necessari...\n";

$fileDaRimuovere = [
    'README.md',
    'CHANGELOG.md',
    'DEPLOYMENT_ARUBA.md',
    'DEPLOYMENT_ARUBA_FINALE.md',
    'DEPLOY_CHECKLIST.md',
    'CHECKLIST_DEPLOYMENT.txt',
    'FILE_DA_CARICARE.txt',
    'SETUP_RAPIDO.md',
    'HYBRID_MODE.md',
    'NOVITA_v2.4.0.md',
    'test_api.html',
    'api/test_pagine.php',
    'api/install_tables.php',
    'api/migrate_sottopagine.sql',
    'api/migrate_sottopagine_ARUBA.sql',
    'api/setup_database.sql',
    'js/app.js',
    'js/educatore-app-hybrid.js',
    'assets/icons/megafono.png',
    'assets/icons/generate_icons.html',
    'assets/icons/create_placeholder_icons.html',
    'assets/icons/GENERATE_ICONS.md',
];

foreach ($fileDaRimuovere as $file) {
    $filePath = $esercizioPath . '/' . $file;
    if (file_exists($filePath)) {
        unlink($filePath);
    }
}

// ============================================
// CREA README ESERCIZIO
// ============================================

echo "📖 Creo README.md esercizio...\n";

$readmeContent = generaREADME($categoria, $nomeEsercizio, $descrizione);
file_put_contents($esercizioPath . '/README.md', $readmeContent);

// ============================================
// COMPLETAMENTO
// ============================================

echo "\n";
echo "✅ ============================================\n";
echo "✅ ESERCIZIO CREATO CON SUCCESSO!\n";
echo "✅ ============================================\n";
echo "\n";
echo "📁 Percorso: $esercizioPath\n";
echo "🌐 URL (locale): http://localhost/Assistivetech/training_cognitivo/$categoria/$nomeEsercizio/\n";
echo "🌐 URL (Aruba): https://assistivetech.it/training_cognitivo/$categoria/$nomeEsercizio/\n";
echo "\n";
echo "📋 Prossimi passi:\n";
echo "  1. Apri: $esercizioPath/index.html\n";
echo "  2. Esegui SQL: $esercizioPath/api/setup_database.sql su phpMyAdmin\n";
echo "  3. Personalizza grafica/logica secondo necessità\n";
echo "  4. Testa in locale\n";
echo "  5. Deploy su Aruba via FTP\n";
echo "\n";

// ============================================
// FUNZIONI HELPER
// ============================================

/**
 * Sanitizza nome per cartella (rimuove caratteri speciali)
 */
function sanitizeFolderName($name) {
    $name = strtolower($name);
    $name = preg_replace('/[^a-z0-9_-]/', '_', $name);
    $name = preg_replace('/_+/', '_', $name);
    return trim($name, '_');
}

/**
 * Copia directory ricorsivamente
 */
function copyDirectory($src, $dst) {
    if (!file_exists($dst)) {
        mkdir($dst, 0755, true);
    }

    $dir = opendir($src);
    while (($file = readdir($dir)) !== false) {
        if ($file != '.' && $file != '..') {
            $srcPath = $src . '/' . $file;
            $dstPath = $dst . '/' . $file;

            if (is_dir($srcPath)) {
                copyDirectory($srcPath, $dstPath);
            } else {
                copy($srcPath, $dstPath);
            }
        }
    }
    closedir($dir);
}

/**
 * Rimuove directory ricorsivamente
 */
function removeDirectory($dir) {
    if (!file_exists($dir)) return;

    $files = array_diff(scandir($dir), ['.', '..']);
    foreach ($files as $file) {
        $path = $dir . '/' . $file;
        is_dir($path) ? removeDirectory($path) : unlink($path);
    }
    rmdir($dir);
}

/**
 * Personalizza file ricorsivamente con sostituzioni
 */
function personalizzaFileRicorsivamente($dir, $replacements) {
    $extensions = ['php', 'js', 'html', 'css', 'json', 'sql'];

    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::SELF_FIRST
    );

    foreach ($iterator as $file) {
        if ($file->isFile()) {
            $ext = $file->getExtension();
            if (in_array($ext, $extensions)) {
                $content = file_get_contents($file->getPathname());
                $modified = str_replace(array_keys($replacements), array_values($replacements), $content);
                if ($content !== $modified) {
                    file_put_contents($file->getPathname(), $modified);
                }
            }
        }
    }
}

/**
 * Rinomina file ricorsivamente
 */
function rinominaFileRicorsivo($dir, $oldName, $newName) {
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::SELF_FIRST
    );

    foreach ($iterator as $file) {
        if ($file->isFile() && $file->getFilename() == $oldName) {
            $newPath = $file->getPath() . '/' . $newName;
            rename($file->getPathname(), $newPath);
        }
    }
}

/**
 * Genera SQL setup per l'esercizio
 */
function generaSQLSetup($categoria, $nomeEsercizio) {
    $prefix = $categoria . '_' . $nomeEsercizio;

    return <<<SQL
-- ============================================
-- Setup Database per: $categoria/$nomeEsercizio
-- Auto-generato da create_exercise_from_template.php
-- ============================================

-- Tabella Pagine/Livelli
CREATE TABLE IF NOT EXISTS `{$prefix}_pagine` (
  `id_pagina` int(11) NOT NULL AUTO_INCREMENT,
  `id_paziente` int(11) NOT NULL,
  `nome_pagina` varchar(100) NOT NULL,
  `descrizione` text,
  `numero_ordine` int(11) DEFAULT 0,
  `stato` enum('attiva','archiviata') DEFAULT 'attiva',
  `data_creazione` datetime DEFAULT CURRENT_TIMESTAMP,
  `data_modifica` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pagina`),
  KEY `idx_paziente` (`id_paziente`),
  KEY `idx_stato` (`stato`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Items/Elementi Esercizio
CREATE TABLE IF NOT EXISTS `{$prefix}_items` (
  `id_item` int(11) NOT NULL AUTO_INCREMENT,
  `id_pagina` int(11) NOT NULL,
  `posizione_griglia` int(11) NOT NULL,
  `titolo` varchar(100) NOT NULL,
  `frase_tts` text,
  `tipo_immagine` enum('arasaac','upload','nessuna') DEFAULT 'arasaac',
  `id_arasaac` int(11) DEFAULT NULL,
  `url_immagine` varchar(255) DEFAULT NULL,
  `tipo_item` enum('normale','sottopagina') DEFAULT 'normale',
  `id_pagina_riferimento` int(11) DEFAULT NULL,
  `colore_sfondo` varchar(7) DEFAULT '#FFFFFF',
  `colore_testo` varchar(7) DEFAULT '#000000',
  `stato` enum('attivo','nascosto') DEFAULT 'attivo',
  `data_creazione` datetime DEFAULT CURRENT_TIMESTAMP,
  `data_modifica` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_item`),
  KEY `idx_pagina` (`id_pagina`),
  KEY `idx_posizione` (`posizione_griglia`),
  KEY `idx_stato` (`stato`),
  CONSTRAINT `fk_{$prefix}_items_pagina` FOREIGN KEY (`id_pagina`)
    REFERENCES `{$prefix}_pagine` (`id_pagina`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Log Utilizzo
CREATE TABLE IF NOT EXISTS `{$prefix}_log` (
  `id_log` int(11) NOT NULL AUTO_INCREMENT,
  `id_paziente` int(11) NOT NULL,
  `id_item` int(11) NOT NULL,
  `data_utilizzo` datetime DEFAULT CURRENT_TIMESTAMP,
  `sessione` varchar(50),
  PRIMARY KEY (`id_log`),
  KEY `idx_paziente` (`id_paziente`),
  KEY `idx_item` (`id_item`),
  KEY `idx_data` (`data_utilizzo`),
  CONSTRAINT `fk_{$prefix}_log_item` FOREIGN KEY (`id_item`)
    REFERENCES `{$prefix}_items` (`id_item`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Setup completato!
-- ============================================
SQL;
}

/**
 * Genera README per l'esercizio
 */
function generaREADME($categoria, $nomeEsercizio, $descrizione) {
    $nomeDisplay = ucfirst(str_replace('_', ' ', $nomeEsercizio));
    $categoriaDisplay = ucfirst(str_replace('_', ' ', $categoria));

    return <<<MD
# $nomeDisplay

**Categoria:** $categoriaDisplay
**Descrizione:** $descrizione

## 📦 Struttura Esercizio Autonomo

Questo esercizio è **completamente autonomo** e contiene tutto il necessario per funzionare:

- ✅ Propri file PHP (config, API)
- ✅ Propri file JavaScript
- ✅ Manifest e Service Worker PWA
- ✅ Database tables dedicate
- ✅ Nessuna dipendenza da file comuni

## 🚀 Setup Rapido

### 1. Database
Esegui lo script SQL in phpMyAdmin:
```
api/setup_database.sql
```

### 2. Test Locale
Apri in browser:
```
http://localhost/Assistivetech/training_cognitivo/$categoria/$nomeEsercizio/
```

### 3. Deploy Aruba
Upload via FTP mantenendo la struttura:
```
/training_cognitivo/$categoria/$nomeEsercizio/
```

## 📱 PWA - Progressive Web App

L'esercizio è installabile come app standalone:

1. Apri da Chrome mobile
2. Menu → "Aggiungi a Home"
3. Usa come app nativa

## 🎯 Interfacce

### Landing Page (index.html)
- Descrizione esercizio
- Accesso interfaccia educatore
- Accesso interfaccia paziente

### Interfaccia Educatore (gestione.html)
- Crea pagine/livelli esercizio
- Aggiungi elementi griglia
- Integrazione ARASAAC pittogrammi
- Upload immagini custom

### Interfaccia Paziente (esercizio.html)
- Modalità fullscreen
- Navigazione swipe
- TTS integrato
- Funziona offline

## 🔧 Personalizzazione

Modifica i file secondo le specifiche esigenze dell'utente:

- **Logica esercizio:** `js/esercizio-app.js`
- **Grafica utente:** `css/esercizio.css`
- **Grafica educatore:** `css/educatore.css`
- **API custom:** `api/*.php`

## 📊 Database Tables

- `{$categoria}_{$nomeEsercizio}_pagine` - Pagine/livelli
- `{$categoria}_{$nomeEsercizio}_items` - Elementi esercizio
- `{$categoria}_{$nomeEsercizio}_log` - Log utilizzo

## 🆘 Supporto

Questo esercizio è stato auto-generato dal template "comunicatore".
Per problemi o personalizzazioni, consulta la documentazione principale.

---

**Generato:** {date('Y-m-d H:i:s')}
**Template:** Comunicatore v2.4.0
**Sistema:** AssistiveTech Training Cognitivo
MD;
}
