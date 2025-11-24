<?php
/**
 * Script Migrazione Esercizi Esistenti
 * Rende autonomi tutti gli esercizi già presenti nel portale
 *
 * Per ogni esercizio esistente:
 * - Crea cartella api/ con config.php autonomo
 * - Genera setup_database.sql
 * - Aggiunge/aggiorna manifest.json PWA
 * - Aggiunge/aggiorna service-worker.js
 * - Crea README.md documentazione
 * - NON tocca la logica esistente
 */

// ============================================
// CONFIGURAZIONE
// ============================================

$BASE_DIR = __DIR__;
$CONFIG_SOURCE = __DIR__ . '/../api/config.php';

// ============================================
// SCANSIONE ESERCIZI ESISTENTI
// ============================================

echo "🔍 Scansione esercizi esistenti...\n";
echo "===================================\n\n";

$categorie = [];
$esercizi = [];

// Scansiona cartelle categorie
$categorieDir = new DirectoryIterator($BASE_DIR);
foreach ($categorieDir as $catDir) {
    if ($catDir->isDot() || !$catDir->isDir()) continue;

    $catName = $catDir->getFilename();

    // Salta cartelle speciali
    if (in_array($catName, ['strumenti', 'memoria', 'icons'])) continue;

    $catPath = $catDir->getPathname();

    // Scansiona esercizi dentro categoria
    $eserciziDir = new DirectoryIterator($catPath);
    foreach ($eserciziDir as $esDir) {
        if ($esDir->isDot() || !$esDir->isDir()) continue;

        $esName = $esDir->getFilename();

        // Salta cartelle speciali
        if (in_array($esName, ['icons', 'web', 'assets'])) continue;

        $esPath = $esDir->getPathname();

        // Verifica che abbia index.html (è un esercizio vero)
        if (file_exists($esPath . '/index.html')) {
            $esercizi[] = [
                'categoria' => $catName,
                'nome' => $esName,
                'path' => $esPath
            ];
        }
    }
}

echo "✅ Trovati " . count($esercizi) . " esercizi da migrare\n\n";

if (count($esercizi) == 0) {
    echo "⚠️  Nessun esercizio trovato. Verifica path.\n";
    exit(0);
}

// Lista esercizi trovati
echo "📋 Esercizi trovati:\n";
foreach ($esercizi as $idx => $es) {
    echo "  " . ($idx + 1) . ". {$es['categoria']}/{$es['nome']}\n";
}
echo "\n";

// Conferma
echo "❓ Procedere con migrazione? (y/n): ";
$handle = fopen("php://stdin", "r");
$line = fgets($handle);
if (trim($line) != 'y') {
    echo "❌ Operazione annullata\n";
    exit(0);
}
echo "\n";

// ============================================
// MIGRAZIONE ESERCIZI
// ============================================

$migratiOk = 0;
$migratiSkip = 0;
$migratiError = 0;

foreach ($esercizi as $idx => $esercizio) {
    $num = $idx + 1;
    $total = count($esercizi);
    $categoria = $esercizio['categoria'];
    $nome = $esercizio['nome'];
    $path = $esercizio['path'];

    echo "[$num/$total] 🔄 Migrazione: $categoria/$nome\n";

    try {
        // ============================================
        // 1. CREA CARTELLA API
        // ============================================

        $apiPath = $path . '/api';
        if (!file_exists($apiPath)) {
            mkdir($apiPath, 0755, true);
            echo "  ✅ Creata cartella api/\n";
        } else {
            echo "  ⚠️  Cartella api/ già esistente\n";
        }

        // ============================================
        // 2. COPIA CONFIG.PHP
        // ============================================

        $configDest = $apiPath . '/config.php';
        if (!file_exists($configDest)) {
            if (file_exists($CONFIG_SOURCE)) {
                copy($CONFIG_SOURCE, $configDest);
                echo "  ✅ Copiato config.php\n";
            } else {
                echo "  ⚠️  config.php sorgente non trovato\n";
            }
        } else {
            echo "  ⏭️  config.php già esistente (skip)\n";
        }

        // ============================================
        // 3. GENERA SQL SETUP
        // ============================================

        $sqlPath = $apiPath . '/setup_database.sql';
        if (!file_exists($sqlPath)) {
            $sqlContent = generaSQLSetup($categoria, $nome);
            file_put_contents($sqlPath, $sqlContent);
            echo "  ✅ Generato setup_database.sql\n";
        } else {
            echo "  ⏭️  setup_database.sql già esistente (skip)\n";
        }

        // ============================================
        // 4. MANIFEST.JSON
        // ============================================

        $manifestPath = $path . '/manifest.json';
        if (file_exists($manifestPath)) {
            // Aggiorna esistente
            $manifest = json_decode(file_get_contents($manifestPath), true);
            if ($manifest) {
                $manifest['name'] = ucfirst(str_replace('_', ' ', $nome)) . ' - ' . ucfirst($categoria);
                $manifest['short_name'] = ucfirst(str_replace('_', ' ', $nome));
                $manifest['start_url'] = './index.html';
                $manifest['scope'] = './';
                file_put_contents($manifestPath, json_encode($manifest, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
                echo "  ✅ Aggiornato manifest.json\n";
            }
        } else {
            // Crea nuovo
            $manifest = generaManifest($categoria, $nome);
            file_put_contents($manifestPath, json_encode($manifest, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
            echo "  ✅ Creato manifest.json\n";
        }

        // ============================================
        // 5. SERVICE WORKER
        // ============================================

        $swPath = $path . '/service-worker.js';
        if (!file_exists($swPath)) {
            $swContent = generaServiceWorker($categoria, $nome);
            file_put_contents($swPath, $swContent);
            echo "  ✅ Creato service-worker.js\n";
        } else {
            echo "  ⏭️  service-worker.js già esistente (skip)\n";
        }

        // ============================================
        // 6. README
        // ============================================

        $readmePath = $path . '/README.md';
        if (!file_exists($readmePath)) {
            $readme = generaREADME($categoria, $nome);
            file_put_contents($readmePath, $readme);
            echo "  ✅ Creato README.md\n";
        } else {
            echo "  ⏭️  README.md già esistente (skip)\n";
        }

        echo "  ✅ Migrazione completata!\n\n";
        $migratiOk++;

    } catch (Exception $e) {
        echo "  ❌ Errore: " . $e->getMessage() . "\n\n";
        $migratiError++;
    }
}

// ============================================
// RIEPILOGO FINALE
// ============================================

echo "\n";
echo "✅ ============================================\n";
echo "✅ MIGRAZIONE COMPLETATA!\n";
echo "✅ ============================================\n";
echo "\n";
echo "📊 Riepilogo:\n";
echo "  ✅ Migrati con successo: $migratiOk\n";
echo "  ⏭️  Saltati: $migratiSkip\n";
echo "  ❌ Errori: $migratiError\n";
echo "\n";
echo "📋 Prossimi passi:\n";
echo "  1. Verifica un esercizio migrato\n";
echo "  2. Esegui SQL setup in phpMyAdmin (se necessario)\n";
echo "  3. Testa funzionalità esercizio\n";
echo "  4. Deploy su Aruba\n";
echo "\n";

// ============================================
// FUNZIONI HELPER
// ============================================

/**
 * Genera SQL setup per esercizio
 */
function generaSQLSetup($categoria, $nomeEsercizio) {
    $prefix = $categoria . '_' . $nomeEsercizio;
    $prefixSafe = preg_replace('/[^a-z0-9_]/', '_', strtolower($prefix));

    return <<<SQL
-- ============================================
-- Setup Database per: $categoria/$nomeEsercizio
-- Auto-generato da migrate_existing_exercises.php
-- ============================================

-- NOTA: Questo è un template base.
-- Adatta le tabelle alle specifiche esigenze dell'esercizio.

-- Tabella Configurazione Esercizio
CREATE TABLE IF NOT EXISTS `{$prefixSafe}_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_paziente` int(11) NOT NULL,
  `difficolta` enum('facile','medio','difficile') DEFAULT 'medio',
  `tempo_limite` int(11) DEFAULT NULL,
  `num_tentativi` int(11) DEFAULT 3,
  `parametri_json` text,
  `data_creazione` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_paziente` (`id_paziente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Risultati Esercizio
CREATE TABLE IF NOT EXISTS `{$prefixSafe}_risultati` (
  `id_risultato` int(11) NOT NULL AUTO_INCREMENT,
  `id_paziente` int(11) NOT NULL,
  `data_esecuzione` datetime DEFAULT CURRENT_TIMESTAMP,
  `punteggio` int(11) DEFAULT 0,
  `tempo_impiegato` int(11) DEFAULT NULL,
  `errori` int(11) DEFAULT 0,
  `completato` tinyint(1) DEFAULT 0,
  `dettagli_json` text,
  PRIMARY KEY (`id_risultato`),
  KEY `idx_paziente` (`id_paziente`),
  KEY `idx_data` (`data_esecuzione`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Log Azioni
CREATE TABLE IF NOT EXISTS `{$prefixSafe}_log` (
  `id_log` int(11) NOT NULL AUTO_INCREMENT,
  `id_paziente` int(11) NOT NULL,
  `tipo_azione` varchar(50) NOT NULL,
  `dati_azione` text,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_log`),
  KEY `idx_paziente` (`id_paziente`),
  KEY `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Setup completato!
--
-- IMPORTANTE: Questo è un template generico.
-- Modifica le tabelle in base alle esigenze
-- specifiche dell'esercizio.
-- ============================================
SQL;
}

/**
 * Genera manifest.json PWA
 */
function generaManifest($categoria, $nomeEsercizio) {
    $nomeDisplay = ucfirst(str_replace('_', ' ', $nomeEsercizio));
    $categoriaDisplay = ucfirst(str_replace('_', ' ', $categoria));

    return [
        'name' => "$nomeDisplay - $categoriaDisplay",
        'short_name' => $nomeDisplay,
        'description' => "Esercizio di training cognitivo - $categoriaDisplay",
        'start_url' => './index.html',
        'display' => 'standalone',
        'background_color' => '#FFFFFF',
        'theme_color' => '#673AB7',
        'orientation' => 'any',
        'scope' => './',
        'icons' => [
            [
                'src' => 'icons/icon-192x192.png',
                'sizes' => '192x192',
                'type' => 'image/png',
                'purpose' => 'any maskable'
            ],
            [
                'src' => 'icons/icon-512x512.png',
                'sizes' => '512x512',
                'type' => 'image/png',
                'purpose' => 'any maskable'
            ]
        ],
        'categories' => ['education', 'health', 'accessibility'],
        'lang' => 'it',
        'dir' => 'ltr'
    ];
}

/**
 * Genera service worker base
 */
function generaServiceWorker($categoria, $nomeEsercizio) {
    $cacheName = strtolower($nomeEsercizio) . '-v1.0.0';

    return <<<JS
/**
 * Service Worker - $nomeEsercizio
 * Gestisce caching per funzionalità offline
 */

const CACHE_NAME = '$cacheName';
const CACHE_URLS = [
    './',
    './index.html',
    './manifest.json'
];

// Install Event
self.addEventListener('install', (event) => {
    console.log('[SW] Installing...');
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(CACHE_URLS);
        })
    );
    self.skipWaiting();
});

// Activate Event
self.addEventListener('activate', (event) => {
    console.log('[SW] Activating...');
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames.map((cacheName) => {
                    if (cacheName !== CACHE_NAME) {
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
    return self.clients.claim();
});

// Fetch Event
self.addEventListener('fetch', (event) => {
    if (!event.request.url.startsWith('http')) return;

    event.respondWith(
        caches.match(event.request).then((response) => {
            return response || fetch(event.request);
        })
    );
});

console.log('[SW] Service Worker loaded');
JS;
}

/**
 * Genera README per esercizio
 */
function generaREADME($categoria, $nomeEsercizio) {
    $nomeDisplay = ucfirst(str_replace('_', ' ', $nomeEsercizio));
    $categoriaDisplay = ucfirst(str_replace('_', ' ', $categoria));
    $prefixTable = $categoria . '_' . $nomeEsercizio;

    return <<<MD
# $nomeDisplay

**Categoria:** $categoriaDisplay
**Tipo:** Esercizio di training cognitivo

## 📦 Struttura Esercizio Autonomo

Questo esercizio è stato **migrato** per essere completamente autonomo:

- ✅ Propri file PHP (config, API)
- ✅ Manifest e Service Worker PWA
- ✅ Database tables dedicate
- ✅ Nessuna dipendenza da file comuni

## 🗄️ Database

### Setup
Esegui in phpMyAdmin:
\`\`\`
api/setup_database.sql
\`\`\`

### Tabelle
- \`{$prefixTable}_config\` - Configurazione esercizio
- \`{$prefixTable}_risultati\` - Risultati e punteggi
- \`{$prefixTable}_log\` - Log azioni utente

## 📱 PWA - Progressive Web App

L'esercizio è installabile come app:

1. Apri da Chrome mobile
2. Menu → "Aggiungi a Home"
3. Usa come app nativa

## 🚀 Deploy

Upload via FTP:
\`\`\`
/training_cognitivo/$categoria/$nomeEsercizio/
\`\`\`

## 📝 Note Migrazione

Esercizio migrato automaticamente da \`migrate_existing_exercises.php\`.
La logica originale è stata preservata, aggiunte solo:
- Autonomia file (api/, config.php)
- Supporto PWA
- Documentazione

---

**Migrato:** {date('Y-m-d H:i:s')}
**Sistema:** AssistiveTech Training Cognitivo
MD;
}
