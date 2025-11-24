<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Gestione richieste OPTIONS per CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurazione database automatica (locale/produzione)
require_once __DIR__ . '/config.php';

// Funzione per rispondere con JSON
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Normalizza i link in base all'ambiente (aggiunge BASE_PATH in locale, rimuove in produzione)
function normalizeLink($link) {
    $base = defined('BASE_PATH') ? BASE_PATH : '';

    if ($link === null || $link === '') {
        return $link;
    }

    // PRODUZIONE (Aruba): Rimuovi /Assistivetech/ se presente, lascia link relativi
    if ($base === '') {
        // Rimuovi /Assistivetech/ all'inizio se presente
        if (strpos($link, '/Assistivetech/') === 0) {
            $link = substr($link, strlen('/Assistivetech'));
        }
        // Correzioni link storici per categorizzazione veicoli
        if (strpos($link, '/training_cognitivo/categorizzazione/cerca_veicoli_di_terra/') !== false) {
            return '/training_cognitivo/categorizzazione/veicoli/setup.html';
        }
        if (strpos($link, '/training_cognitivo/categorizzazione/cerca_veicoli_di_mare/') !== false) {
            return '/training_cognitivo/categorizzazione/veicoli_mare/setup.html';
        }
        if (strpos($link, '/training_cognitivo/categorizzazione/cerca_veicoli_di_cielo/') !== false
            || strpos($link, '/training_cognitivo/categorizzazione/cerca_veicoli_di_aria/') !== false) {
            return '/training_cognitivo/categorizzazione/veicoli_aria/setup.html';
        }
        // Mappa vecchio percorso 'scrivi_con_le_sillabe/scrivi_con_le_sillabe'
        if (strpos($link, '/training_cognitivo/scrivi_con_le_sillabe/scrivi_con_le_sillabe/') !== false) {
            return '/training_cognitivo/scrivi/scrivi_parole/setup.html';
        }
        // Se l'esercizio punta alla root della PWA, indirizza al setup
        if ($link === '/training_cognitivo/scrivi/scrivi_parole/') {
            return '/training_cognitivo/scrivi/scrivi_parole/setup.html';
        }
        return $link;
    }

    // LOCALE (MAMP): Aggiungi BASE_PATH se necessario
    // Correzioni link storici per categorizzazione veicoli (con BASE_PATH)
    if (strpos($link, '/training_cognitivo/categorizzazione/cerca_veicoli_di_terra/') !== false) {
        return $base . '/training_cognitivo/categorizzazione/veicoli/setup.html';
    }
    if (strpos($link, '/training_cognitivo/categorizzazione/cerca_veicoli_di_mare/') !== false) {
        return $base . '/training_cognitivo/categorizzazione/veicoli_mare/setup.html';
    }
    if (strpos($link, '/training_cognitivo/categorizzazione/cerca_veicoli_di_cielo/') !== false
        || strpos($link, '/training_cognitivo/categorizzazione/cerca_veicoli_di_aria/') !== false) {
        return $base . '/training_cognitivo/categorizzazione/veicoli_aria/setup.html';
    }
    // Mappa vecchio percorso 'scrivi_con_le_sillabe/scrivi_con_le_sillabe'
    if (strpos($link, '/training_cognitivo/scrivi_con_le_sillabe/scrivi_con_le_sillabe/') !== false) {
        return $base . '/training_cognitivo/scrivi/scrivi_parole/setup.html';
    }
    // Se l'esercizio punta alla root della PWA, indirizza al setup
    if ($link === '/training_cognitivo/scrivi/scrivi_parole/' || $link === $base . '/training_cognitivo/scrivi/scrivi_parole/') {
        return $base . '/training_cognitivo/scrivi/scrivi_parole/setup.html';
    }
    // Evita doppio prefisso: se già inizia con BASE_PATH, restituisci così com'è
    if (strpos($link, $base . '/') === 0) {
        return $link;
    }
    // Rimuovi /Assistivetech/ se presente prima di aggiungere BASE_PATH
    if (strpos($link, '/Assistivetech/') === 0) {
        $link = substr($link, strlen('/Assistivetech'));
    }
    // Se inizia con /training_cognitivo/, aggiungi BASE_PATH
    if (strpos($link, '/training_cognitivo/') === 0) {
        return $base . $link;
    }
    return $link;
}

// Funzione per log delle operazioni
function logOperation($action, $details, $ip) {
    $logFile = '../logs/esercizi.log';
    $logDir = dirname($logFile);

    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $action - $details - IP: $ip\n";

    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

// Funzione per impostare permessi ricorsivamente
function setPermissionsRecursive($path, $dirPermissions = 0775, $filePermissions = 0664) {
    if (!file_exists($path)) {
        return false;
    }

    // Imposta permessi per la directory corrente
    if (is_dir($path)) {
        chmod($path, $dirPermissions);

        // Scansiona tutti i file e sottodirectory
        $iterator = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($path),
            RecursiveIteratorIterator::CHILD_FIRST
        );

        foreach ($iterator as $item) {
            if ($item->getFilename() === '.' || $item->getFilename() === '..') {
                continue;
            }

            if ($item->isDir()) {
                chmod($item->getPathname(), $dirPermissions);
            } else {
                chmod($item->getPathname(), $filePermissions);
            }
        }
        return true;
    } else {
        // È un file singolo
        chmod($path, $filePermissions);
        return true;
    }
}

// Funzione per creare struttura PWA base per esercizio/strumento
function createPWAStructure($percorso_cartella, $nome_esercizio, $id_esercizio) {
    // Crea directory struttura PWA
    $directories = ['assets', 'assets/icons', 'assets/images', 'css', 'js'];
    foreach ($directories as $dir) {
        $full_path = "$percorso_cartella/$dir";
        if (!file_exists($full_path)) {
            mkdir($full_path, 0775, true);
            chmod($full_path, 0775);
        }
    }

    // Crea index.html principale PWA
    $index_html_content = createPWAIndexTemplate($nome_esercizio, $id_esercizio);
    file_put_contents("$percorso_cartella/index.html", $index_html_content);
    chmod("$percorso_cartella/index.html", 0664);

    // Crea app.js (JavaScript Vanilla)
    $app_js_content = createAppJSTemplate($nome_esercizio, $id_esercizio);
    file_put_contents("$percorso_cartella/js/app.js", $app_js_content);
    chmod("$percorso_cartella/js/app.js", 0664);

    // Crea styles.css
    $styles_css_content = createStylesCSSTemplate();
    file_put_contents("$percorso_cartella/css/styles.css", $styles_css_content);
    chmod("$percorso_cartella/css/styles.css", 0664);

    // Crea manifest.json per PWA
    $manifest_content = createManifestTemplate($nome_esercizio);
    file_put_contents("$percorso_cartella/manifest.json", $manifest_content);
    chmod("$percorso_cartella/manifest.json", 0664);

    // Crea service-worker.js per PWA offline
    $sw_content = createServiceWorkerTemplate($nome_esercizio);
    file_put_contents("$percorso_cartella/service-worker.js", $sw_content);
    chmod("$percorso_cartella/service-worker.js", 0664);

    // Crea README.md
    $readme_content = createPWAReadmeTemplate($nome_esercizio, $id_esercizio);
    file_put_contents("$percorso_cartella/README.md", $readme_content);
    chmod("$percorso_cartella/README.md", 0664);
}

// Template index.html PWA
function createPWAIndexTemplate($nome_esercizio, $id_esercizio) {
    return <<<HTML
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="theme-color" content="#673AB7">
    <meta name="description" content="$nome_esercizio - Strumento AssistiveTech per training cognitivo">

    <title>$nome_esercizio - AssistiveTech</title>

    <!-- PWA Manifest -->
    <link rel="manifest" href="manifest.json">

    <!-- Icons -->
    <link rel="icon" type="image/png" sizes="192x192" href="assets/icons/icon-192.png">
    <link rel="apple-touch-icon" href="assets/icons/icon-192.png">

    <!-- Styles -->
    <link rel="stylesheet" href="css/styles.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <!-- Header -->
    <header class="app-header">
        <div class="header-content">
            <button class="btn-back" onclick="goBack()">
                <i class="bi bi-arrow-left"></i>
            </button>
            <h1 class="app-title">$nome_esercizio</h1>
            <button class="btn-menu" onclick="toggleMenu()">
                <i class="bi bi-three-dots-vertical"></i>
            </button>
        </div>
    </header>

    <!-- Main Content -->
    <main class="app-main" id="appMain">
        <div class="welcome-screen">
            <div class="welcome-icon">
                <i class="bi bi-stars"></i>
            </div>
            <h2>Benvenuto!</h2>
            <p>Questo è lo strumento <strong>$nome_esercizio</strong></p>
            <p class="description">Pronto per iniziare? Clicca il pulsante qui sotto.</p>
            <button class="btn-primary" onclick="startApp()">
                <i class="bi bi-play-circle"></i> Inizia
            </button>
            <button class="btn-secondary" onclick="showInfo()">
                <i class="bi bi-info-circle"></i> Informazioni
            </button>
        </div>
    </main>

    <!-- Menu laterale -->
    <nav class="side-menu" id="sideMenu">
        <div class="menu-header">
            <h3>Menu</h3>
            <button class="btn-close-menu" onclick="toggleMenu()">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>
        <ul class="menu-list">
            <li><button onclick="resetApp()"><i class="bi bi-arrow-clockwise"></i> Ricomincia</button></li>
            <li><button onclick="showInfo()"><i class="bi bi-info-circle"></i> Informazioni</button></li>
            <li><button onclick="showSettings()"><i class="bi bi-gear"></i> Impostazioni</button></li>
            <li><button onclick="goBack()"><i class="bi bi-house"></i> Torna alla home</button></li>
        </ul>
    </nav>

    <!-- Overlay per menu -->
    <div class="overlay" id="overlay" onclick="toggleMenu()"></div>

    <!-- Modal Informazioni -->
    <div class="modal" id="infoModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="bi bi-info-circle"></i> Informazioni</h3>
                <button class="btn-close-modal" onclick="closeModal('infoModal')">
                    <i class="bi bi-x-lg"></i>
                </button>
            </div>
            <div class="modal-body">
                <h4>$nome_esercizio</h4>
                <p>Questo è uno strumento di training cognitivo sviluppato per AssistiveTech.it</p>
                <p><strong>ID Strumento:</strong> $id_esercizio</p>
                <p><strong>Versione:</strong> 1.0.0</p>
                <div class="info-box">
                    <i class="bi bi-lightbulb"></i>
                    <p>Personalizza questo strumento modificando i file nella cartella del progetto!</p>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-primary" onclick="closeModal('infoModal')">Chiudi</button>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="js/app.js"></script>
    <script>
        // Registra Service Worker per PWA
        if ('serviceWorker' in navigator) {
            window.addEventListener('load', () => {
                navigator.serviceWorker.register('service-worker.js')
                    .then(registration => console.log('Service Worker registrato'))
                    .catch(err => console.log('Service Worker errore:', err));
            });
        }
    </script>
</body>
</html>
HTML;
}

// Template app.js (JavaScript Vanilla)
function createAppJSTemplate($nome_esercizio, $id_esercizio) {
    return <<<'JS'
// App Configuration
const APP_CONFIG = {
    name: '$nome_esercizio',
    id: $id_esercizio,
    version: '1.0.0'
};

// State Management
let appState = {
    isStarted: false,
    settings: loadSettings()
};

// Load settings from localStorage
function loadSettings() {
    const saved = localStorage.getItem('app_settings_$id_esercizio');
    return saved ? JSON.parse(saved) : {
        theme: 'light',
        soundEnabled: true
    };
}

// Save settings to localStorage
function saveSettings() {
    localStorage.setItem('app_settings_$id_esercizio', JSON.stringify(appState.settings));
}

// Navigation
function goBack() {
    if (confirm('Vuoi davvero tornare indietro?')) {
        window.location.href = '../../';
    }
}

// Menu Toggle
function toggleMenu() {
    const menu = document.getElementById('sideMenu');
    const overlay = document.getElementById('overlay');

    if (menu.classList.contains('active')) {
        menu.classList.remove('active');
        overlay.classList.remove('active');
    } else {
        menu.classList.add('active');
        overlay.classList.add('active');
    }
}

// Modal Management
function showInfo() {
    document.getElementById('infoModal').classList.add('active');
    toggleMenu();
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

function showSettings() {
    alert('Impostazioni in fase di sviluppo!\n\nQui puoi aggiungere:\n- Preferenze utente\n- Livelli di difficoltà\n- Opzioni audio/video\n- E molto altro!');
    toggleMenu();
}

// App Logic
function startApp() {
    if (!appState.isStarted) {
        appState.isStarted = true;

        // Qui puoi implementare la logica principale dell'app
        const mainContent = document.getElementById('appMain');
        mainContent.innerHTML = `
            <div class="app-content">
                <div class="content-header">
                    <h2>🎯 $nome_esercizio</h2>
                    <p>L'app è stata avviata con successo!</p>
                </div>

                <div class="action-area">
                    <div class="placeholder-content">
                        <i class="bi bi-code-slash" style="font-size: 4rem; color: #673AB7;"></i>
                        <h3>Pronto per lo sviluppo</h3>
                        <p>Modifica il file <code>js/app.js</code> per implementare la logica specifica del tuo strumento.</p>
                        <ul style="text-align: left; max-width: 400px; margin: 20px auto;">
                            <li>Aggiungi interazioni utente</li>
                            <li>Integra API esterne</li>
                            <li>Salva progressi nel localStorage</li>
                            <li>Crea esperienze coinvolgenti</li>
                        </ul>
                    </div>
                </div>

                <button class="btn-secondary" onclick="resetApp()">
                    <i class="bi bi-arrow-clockwise"></i> Ricomincia
                </button>
            </div>
        `;
    }
}

function resetApp() {
    if (confirm('Vuoi ricominciare da capo?')) {
        appState.isStarted = false;
        location.reload();
    }
}

// Initialize app on load
document.addEventListener('DOMContentLoaded', () => {
    console.log(`${APP_CONFIG.name} v${APP_CONFIG.version} caricato con successo`);

    // Close modals on Escape key
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            const modals = document.querySelectorAll('.modal.active');
            modals.forEach(modal => modal.classList.remove('active'));

            const menu = document.getElementById('sideMenu');
            const overlay = document.getElementById('overlay');
            if (menu.classList.contains('active')) {
                menu.classList.remove('active');
                overlay.classList.remove('active');
            }
        }
    });
});

// PWA Install prompt
let deferredPrompt;
window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
    console.log('PWA install prompt ready');
});
JS;
}

// Template styles.css
function createStylesCSSTemplate() {
    return <<<'CSS'
/* Reset e base */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:root {
    --primary-color: #673AB7;
    --secondary-color: #9C27B0;
    --accent-color: #FF5722;
    --success-color: #4CAF50;
    --text-color: #333;
    --bg-color: #f5f5f5;
    --card-bg: white;
    --shadow: 0 4px 6px rgba(0,0,0,0.1);
    --shadow-hover: 0 8px 12px rgba(0,0,0,0.15);
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: var(--text-color);
    min-height: 100vh;
    overflow-x: hidden;
}

/* Header */
.app-header {
    background: var(--primary-color);
    color: white;
    padding: 1rem;
    box-shadow: 0 2px 10px rgba(0,0,0,0.2);
    position: sticky;
    top: 0;
    z-index: 100;
}

.header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1200px;
    margin: 0 auto;
}

.app-title {
    font-size: 1.5rem;
    font-weight: 600;
    flex: 1;
    text-align: center;
}

.btn-back, .btn-menu {
    background: rgba(255,255,255,0.2);
    border: none;
    color: white;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    cursor: pointer;
    transition: background 0.3s;
}

.btn-back:hover, .btn-menu:hover {
    background: rgba(255,255,255,0.3);
}

/* Main Content */
.app-main {
    max-width: 1200px;
    margin: 2rem auto;
    padding: 0 1rem;
    min-height: calc(100vh - 120px);
}

.welcome-screen, .app-content {
    background: var(--card-bg);
    border-radius: 20px;
    padding: 3rem 2rem;
    box-shadow: var(--shadow);
    text-align: center;
    animation: fadeIn 0.5s ease;
}

.welcome-icon {
    font-size: 5rem;
    color: var(--primary-color);
    margin-bottom: 1.5rem;
}

.welcome-screen h2, .content-header h2 {
    color: var(--primary-color);
    margin-bottom: 1rem;
}

.description {
    color: #666;
    font-size: 1.1rem;
    margin-bottom: 2rem;
}

/* Buttons */
.btn-primary, .btn-secondary {
    padding: 12px 30px;
    border: none;
    border-radius: 25px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    margin: 0.5rem;
    transition: all 0.3s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.btn-primary {
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    color: white;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(103, 58, 183, 0.3);
}

.btn-secondary {
    background: #f0f0f0;
    color: var(--text-color);
}

.btn-secondary:hover {
    background: #e0e0e0;
    transform: translateY(-2px);
}

/* Side Menu */
.side-menu {
    position: fixed;
    top: 0;
    right: -300px;
    width: 300px;
    height: 100vh;
    background: white;
    box-shadow: -2px 0 10px rgba(0,0,0,0.2);
    transition: right 0.3s ease;
    z-index: 1001;
    overflow-y: auto;
}

.side-menu.active {
    right: 0;
}

.menu-header {
    background: var(--primary-color);
    color: white;
    padding: 1.5rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.menu-header h3 {
    margin: 0;
}

.btn-close-menu {
    background: rgba(255,255,255,0.2);
    border: none;
    color: white;
    width: 30px;
    height: 30px;
    border-radius: 50%;
    cursor: pointer;
}

.menu-list {
    list-style: none;
    padding: 1rem 0;
}

.menu-list li {
    margin: 0;
}

.menu-list button {
    width: 100%;
    padding: 1rem 1.5rem;
    border: none;
    background: none;
    text-align: left;
    cursor: pointer;
    transition: background 0.3s;
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 1rem;
}

.menu-list button:hover {
    background: #f5f5f5;
}

/* Overlay */
.overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s;
    z-index: 1000;
}

.overlay.active {
    opacity: 1;
    visibility: visible;
}

/* Modal */
.modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s;
    z-index: 2000;
}

.modal.active {
    opacity: 1;
    visibility: visible;
}

.modal-content {
    background: white;
    border-radius: 15px;
    max-width: 500px;
    width: 90%;
    max-height: 80vh;
    overflow-y: auto;
    box-shadow: 0 10px 30px rgba(0,0,0,0.3);
    animation: slideUp 0.3s ease;
}

.modal-header {
    padding: 1.5rem;
    border-bottom: 1px solid #eee;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-header h3 {
    margin: 0;
    color: var(--primary-color);
}

.btn-close-modal {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    color: #999;
}

.modal-body {
    padding: 1.5rem;
}

.modal-body h4 {
    color: var(--primary-color);
    margin-bottom: 1rem;
}

.modal-footer {
    padding: 1rem 1.5rem;
    border-top: 1px solid #eee;
    text-align: right;
}

.info-box {
    background: #f0f7ff;
    border-left: 4px solid var(--primary-color);
    padding: 1rem;
    margin-top: 1rem;
    display: flex;
    gap: 12px;
    align-items: start;
}

.info-box i {
    color: var(--primary-color);
    font-size: 1.5rem;
}

/* Animations */
@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes slideUp {
    from {
        transform: translateY(50px);
        opacity: 0;
    }
    to {
        transform: translateY(0);
        opacity: 1;
    }
}

/* Responsive */
@media (max-width: 768px) {
    .app-title {
        font-size: 1.2rem;
    }

    .welcome-screen, .app-content {
        padding: 2rem 1rem;
    }

    .welcome-icon {
        font-size: 4rem;
    }
}

/* Utility Classes */
code {
    background: #f5f5f5;
    padding: 2px 6px;
    border-radius: 4px;
    font-family: 'Courier New', monospace;
}

.placeholder-content {
    padding: 2rem;
}

.action-area {
    margin: 2rem 0;
}

ul {
    line-height: 1.8;
}
CSS;
}

// Template service-worker.js
function createServiceWorkerTemplate($nome_esercizio) {
    $cache_name = strtolower(str_replace([' ', '-'], '_', preg_replace('/[^a-zA-Z0-9 -]/', '', $nome_esercizio)));
    return <<<JS
const CACHE_NAME = '{$cache_name}_v1';
const urlsToCache = [
    './',
    './index.html',
    './css/styles.css',
    './js/app.js',
    './manifest.json',
    'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css'
];

// Install event - cache resources
self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => {
                console.log('Cache aperta');
                return cache.addAll(urlsToCache);
            })
    );
});

// Fetch event - serve from cache
self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request)
            .then(response => {
                if (response) {
                    return response;
                }
                return fetch(event.request);
            })
    );
});

// Activate event - clean old caches
self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (cacheName !== CACHE_NAME) {
                        console.log('Eliminazione cache vecchia:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
});
JS;
}

// Template manifest.json per PWA
function createManifestTemplate($nome_esercizio) {
    return <<<JSON
{
    "name": "$nome_esercizio - AssistiveTech",
    "short_name": "$nome_esercizio",
    "start_url": "./index.html",
    "display": "standalone",
    "background_color": "#673AB7",
    "theme_color": "#673AB7",
    "description": "Strumento di training cognitivo $nome_esercizio - AssistiveTech.it",
    "orientation": "any",
    "prefer_related_applications": false,
    "icons": [
        {
            "src": "assets/icons/icon-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "any maskable"
        },
        {
            "src": "assets/icons/icon-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "any maskable"
        }
    ]
}
JSON;
}

// Template README.md per PWA
function createPWAReadmeTemplate($nome_esercizio, $id_esercizio) {
    return <<<MARKDOWN
# $nome_esercizio

Strumento di Training Cognitivo - AssistiveTech.it

## Informazioni

- **ID Strumento**: $id_esercizio
- **Nome**: $nome_esercizio
- **Tipo**: Progressive Web App (PWA) con JavaScript Vanilla
- **Generato**: Automaticamente dal sistema AssistiveTech

## Struttura Progetto

```
$nome_esercizio/
├── index.html              # Pagina principale PWA
├── manifest.json           # Configurazione PWA
├── service-worker.js       # Service Worker per funzionalità offline
├── README.md              # Questa documentazione
├── css/
│   └── styles.css         # Stili personalizzati
├── js/
│   └── app.js             # Logica applicazione (JavaScript Vanilla)
└── assets/
    ├── icons/             # Icone PWA (da aggiungere)
    └── images/            # Immagini strumento
```

## Sviluppo

Questa PWA è stata generata automaticamente. Per personalizzare lo strumento:

### 1. Modifica la Logica (js/app.js)
Implementa la logica specifica del tuo strumento modificando la funzione `startApp()`:

\`\`\`javascript
function startApp() {
    // Aggiungi qui la tua logica personalizzata
    // Esempi: quiz, esercizi memoria, giochi cognitivi, ecc.
}
\`\`\`

### 2. Personalizza gli Stili (css/styles.css)
Modifica i colori, layout e animazioni secondo le tue esigenze.

### 3. Aggiungi Risorse (assets/)
- Inserisci immagini in `assets/images/`
- Aggiungi icone PWA in `assets/icons/` (192x192 e 512x512)

## Test Locale

### Opzione 1: Server PHP
\`\`\`bash
php -S localhost:8000
\`\`\`

### Opzione 2: Server Python
\`\`\`bash
python -m http.server 8080
\`\`\`

### Opzione 3: Live Server (VS Code)
Installa l'estensione "Live Server" e clicca su "Go Live"

## Deployment

L'app viene automaticamente deployata in:
- **URL**: https://assistivetech.it/training_cognitivo/[categoria]/$nome_esercizio/
- **PWA**: Installabile come app standalone su dispositivi mobili e desktop

## Funzionalità PWA Incluse

✅ **Installabile**: Gli utenti possono installare l'app sul loro dispositivo
✅ **Offline**: Funziona anche senza connessione internet
✅ **Responsive**: Adattabile a tutti i dispositivi
✅ **Leggera**: Caricamento veloce, nessuna dipendenza pesante
✅ **Sicura**: HTTPS obbligatorio in produzione

## Note di Sviluppo

- **localStorage**: Usa `localStorage` per salvare progressi utente
- **Responsive**: Testa su mobile, tablet e desktop
- **Accessibilità**: Usa tag semantici e ARIA labels
- **Performance**: Mantieni JavaScript semplice e leggero
- **Icone**: Genera icone PWA con strumenti come [PWA Asset Generator](https://github.com/elegantapp/pwa-asset-generator)

## Esempio Integrazione API

\`\`\`javascript
// Salva progressi su server
async function saveProgress(data) {
    const response = await fetch('/api/save_progress.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ exerciseId: $id_esercizio, ...data })
    });
    return response.json();
}
\`\`\`

## Supporto Browser

- ✅ Chrome/Edge (Desktop & Mobile)
- ✅ Firefox (Desktop & Mobile)
- ✅ Safari (iOS 11.3+)
- ✅ Samsung Internet

## Risorse Utili

- [MDN PWA Guide](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)
- [Web.dev PWA](https://web.dev/progressive-web-apps/)
- [Bootstrap Icons](https://icons.getbootstrap.com/)

MARKDOWN;
}

try {
    // Connessione al database (auto ambiente)
    $pdo = getDbConnection();

    // Leggi i dati JSON dalla richiesta (gestisci body vuoto)
    $rawBody = file_get_contents('php://input');
    $input = json_decode($rawBody ?: '[]', true);
    $action = $input['action'] ?? $_GET['action'] ?? '';
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    // ===================== GESTIONE ESERCIZI =====================
    if ($action === 'get_by_patient') {
        // ✅ Recupera esercizi assegnati a un paziente
        // Attualmente: torna TUTTI gli esercizi (il paziente è "utente")
        // Nelle versioni future si potrà restringere per training cognitivo specifico

        $patient_id = intval($input['patient_id'] ?? 0);

        if ($patient_id <= 0) {
            jsonResponse(false, 'ID paziente non valido');
        }

        // Recupera tutti gli esercizi attivi, raggruppati per categoria
        $stmt = $pdo->prepare("
            SELECT
                e.id_esercizio,
                e.nome_esercizio,
                e.descrizione_esercizio,
                e.stato_esercizio,
                e.data_creazione,
                e.id_categoria,
                e.link,
                c.id_categoria,
                c.nome_categoria,
                c.descrizione_categoria
            FROM esercizi e
            LEFT JOIN categorie_esercizi c ON e.id_categoria = c.id_categoria
            WHERE e.stato_esercizio = 'attivo'
            ORDER BY c.nome_categoria ASC, e.nome_esercizio ASC
        ");
        $stmt->execute();
        $esercizi = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Normalizza i link per l'ambiente corrente
        foreach ($esercizi as &$row) {
            if (isset($row['link'])) {
                $row['link'] = normalizeLink($row['link']);
            }
        }
        unset($row);

        jsonResponse(true, 'Esercizi recuperati con successo', $esercizi);

    } elseif ($action === 'get_esercizi') {
        // Recupera esercizi con filtri opzionali
        $id_categoria = intval($input['id_categoria'] ?? $_GET['id_categoria'] ?? 0);
        $stato = trim($input['stato'] ?? $_GET['stato'] ?? '');

        $where_conditions = [];
        $params = [];

        if ($id_categoria > 0) {
            $where_conditions[] = 'e.id_categoria = :id_categoria';
            $params[':id_categoria'] = $id_categoria;
        }

        if (!empty($stato)) {
            $where_conditions[] = 'e.stato_esercizio = :stato';
            $params[':stato'] = $stato;
        }

        $where_clause = '';
        if (!empty($where_conditions)) {
            $where_clause = 'WHERE ' . implode(' AND ', $where_conditions);
        }

        $stmt = $pdo->prepare("
            SELECT
                e.id_esercizio,
                e.nome_esercizio,
                e.descrizione_esercizio,
                e.stato_esercizio,
                e.data_creazione,
                e.id_categoria,
                e.link,
                c.nome_categoria
            FROM esercizi e
            LEFT JOIN categorie_esercizi c ON e.id_categoria = c.id_categoria
            $where_clause
            ORDER BY c.nome_categoria ASC, e.nome_esercizio ASC
        ");
        $stmt->execute($params);
        $esercizi = $stmt->fetchAll(PDO::FETCH_ASSOC);
        // Aggiusta i link per l'ambiente corrente
        foreach ($esercizi as &$row) {
            if (isset($row['link'])) {
                $row['link'] = normalizeLink($row['link']);
            }
        }
        unset($row);

        jsonResponse(true, 'Esercizi recuperati con successo', $esercizi);

    } elseif ($action === 'get_esercizio') {
        // Recupera un esercizio specifico per ID
        $id_esercizio = intval($input['id'] ?? $_GET['id'] ?? 0);

        if ($id_esercizio <= 0) {
            jsonResponse(false, 'ID esercizio non valido');
        }

        $stmt = $pdo->prepare("
            SELECT
                e.id_esercizio,
                e.nome_esercizio,
                e.descrizione_esercizio,
                e.stato_esercizio,
                e.data_creazione,
                e.id_categoria,
                e.link,
                c.nome_categoria
            FROM esercizi e
            LEFT JOIN categorie_esercizi c ON e.id_categoria = c.id_categoria
            WHERE e.id_esercizio = :id
        ");
        $stmt->execute([':id' => $id_esercizio]);
        $esercizio = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($esercizio && isset($esercizio['link'])) {
            $esercizio['link'] = normalizeLink($esercizio['link']);
        }

        if ($esercizio) {
            jsonResponse(true, 'Esercizio recuperato con successo', $esercizio);
        } else {
            jsonResponse(false, 'Esercizio non trovato');
        }

    } elseif ($action === 'create_esercizio') {
        // Crea nuovo esercizio
        $nome_esercizio = trim($input['nome_esercizio'] ?? '');
        $descrizione_esercizio = trim($input['descrizione_esercizio'] ?? '');
        $id_categoria = intval($input['id_categoria'] ?? 0);
        $stato_esercizio = trim($input['stato_esercizio'] ?? 'attivo');

        if (empty($nome_esercizio)) {
            jsonResponse(false, 'Nome esercizio è obbligatorio');
        }

        if (empty($descrizione_esercizio)) {
            jsonResponse(false, 'Descrizione esercizio è obbligatoria');
        }

        if ($id_categoria <= 0) {
            jsonResponse(false, 'Categoria è obbligatoria');
        }

        // Verifica che la categoria esista
        $stmt_check_cat = $pdo->prepare("SELECT COUNT(*) as count FROM categorie_esercizi WHERE id_categoria = :id");
        $stmt_check_cat->execute([':id' => $id_categoria]);
        $cat_exists = $stmt_check_cat->fetch(PDO::FETCH_ASSOC);

        if ($cat_exists['count'] == 0) {
            jsonResponse(false, 'La categoria selezionata non esiste');
        }

        // Verifica se l'esercizio esiste già nella stessa categoria
        $stmt_check = $pdo->prepare("SELECT COUNT(*) as count FROM esercizi WHERE nome_esercizio = :nome AND id_categoria = :categoria");
        $stmt_check->execute([':nome' => $nome_esercizio, ':categoria' => $id_categoria]);
        $exists = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if ($exists['count'] > 0) {
            jsonResponse(false, 'Un esercizio con questo nome esiste già in questa categoria');
        }

        // Valida stato
        $stati_validi = ['attivo', 'sospeso', 'archiviato'];
        if (!in_array($stato_esercizio, $stati_validi)) {
            $stato_esercizio = 'attivo';
        }

        // Ottieni informazioni categoria per generare percorso
        $stmt_cat = $pdo->prepare("SELECT nome_categoria FROM categorie_esercizi WHERE id_categoria = :id");
        $stmt_cat->execute([':id' => $id_categoria]);
        $categoria_info = $stmt_cat->fetch(PDO::FETCH_ASSOC);

        if (!$categoria_info) {
            jsonResponse(false, 'Categoria non trovata');
        }

        // Genera percorso e link automatici
        $nome_cartella_categoria = strtolower(str_replace([' ', 'à', 'è', 'é', 'ì', 'ò', 'ù', 'ç'], ['_', 'a', 'e', 'e', 'i', 'o', 'u', 'c'], $categoria_info['nome_categoria']));
        $nome_cartella_categoria = preg_replace('/[^a-z0-9_]/', '', $nome_cartella_categoria);

        $nome_cartella_esercizio = strtolower(str_replace([' ', 'à', 'è', 'é', 'ì', 'ò', 'ù', 'ç'], ['_', 'a', 'e', 'e', 'i', 'o', 'u', 'c'], $nome_esercizio));
        $nome_cartella_esercizio = preg_replace('/[^a-z0-9_]/', '', $nome_cartella_esercizio);

        $base = defined('BASE_PATH') ? BASE_PATH : '';
        $link_esercizio = "$base/training_cognitivo/$nome_cartella_categoria/$nome_cartella_esercizio/";
        $percorso_cartella = "../training_cognitivo/$nome_cartella_categoria/$nome_cartella_esercizio";

        // Inserisci nuovo esercizio con link
        $data_creazione = date('d/m/Y H:i:s');
        $stmt = $pdo->prepare("
            INSERT INTO esercizi (nome_esercizio, descrizione_esercizio, id_categoria, stato_esercizio, data_creazione, link)
            VALUES (:nome, :descrizione, :categoria, :stato, :data_creazione, :link)
        ");
        $result = $stmt->execute([
            ':nome' => $nome_esercizio,
            ':descrizione' => $descrizione_esercizio,
            ':categoria' => $id_categoria,
            ':stato' => $stato_esercizio,
            ':data_creazione' => $data_creazione,
            ':link' => $link_esercizio
        ]);

        if ($result) {
            $new_id = $pdo->lastInsertId();

            // Crea automaticamente la cartella per l'esercizio
            if (!file_exists($percorso_cartella)) {
                // Assicurati che la cartella categoria esista
                $percorso_categoria = "../training_cognitivo/$nome_cartella_categoria";
                if (!file_exists($percorso_categoria)) {
                    if (!file_exists('../training_cognitivo')) {
                        mkdir('../training_cognitivo', 0775, true);
                        chmod('../training_cognitivo', 0775);
                    }
                    mkdir($percorso_categoria, 0775, true);
                    chmod($percorso_categoria, 0775);
                }

                // Crea cartella esercizio
                mkdir($percorso_cartella, 0775, true);
                chmod($percorso_cartella, 0775);

                // Crea struttura PWA base per l'esercizio
                createPWAStructure($percorso_cartella, $nome_esercizio, $new_id);

                // Imposta permessi per tutte le sottocartelle create
                setPermissionsRecursive($percorso_cartella, 0775, 0664);
            }

            logOperation('CREATE_ESERCIZIO', "Nome: $nome_esercizio, ID: $new_id, Categoria: $id_categoria, Cartella: $percorso_cartella", $ip);
            jsonResponse(true, 'Esercizio creato con successo', [
                'id_esercizio' => $new_id,
                'nome_esercizio' => $nome_esercizio,
                'link' => $link_esercizio,
                'cartella_creata' => file_exists($percorso_cartella)
            ]);
        } else {
            jsonResponse(false, 'Errore nella creazione dell\'esercizio');
        }

    } elseif ($action === 'update_esercizio') {
        // Aggiorna esercizio esistente con gestione rinominazione cartelle
        $id_esercizio = intval($input['id_esercizio'] ?? 0);
        $nome_esercizio = trim($input['nome_esercizio'] ?? '');
        $descrizione_esercizio = trim($input['descrizione_esercizio'] ?? '');
        $id_categoria = intval($input['id_categoria'] ?? 0);
        $stato_esercizio = trim($input['stato_esercizio'] ?? 'attivo');

        if ($id_esercizio <= 0) {
            jsonResponse(false, 'ID esercizio non valido');
        }

        if (empty($nome_esercizio)) {
            jsonResponse(false, 'Nome esercizio è obbligatorio');
        }

        if (empty($descrizione_esercizio)) {
            jsonResponse(false, 'Descrizione esercizio è obbligatoria');
        }

        if ($id_categoria <= 0) {
            jsonResponse(false, 'Categoria è obbligatoria');
        }

        // STEP 1: Recupera dati attuali dell'esercizio prima dell'update
        $stmt_current = $pdo->prepare("
            SELECT
                e.nome_esercizio as nome_attuale,
                e.id_categoria as categoria_attuale,
                e.link as link_attuale,
                c.nome_categoria as categoria_nome_attuale
            FROM esercizi e
            LEFT JOIN categorie_esercizi c ON e.id_categoria = c.id_categoria
            WHERE e.id_esercizio = :id
        ");
        $stmt_current->execute([':id' => $id_esercizio]);
        $dati_attuali = $stmt_current->fetch(PDO::FETCH_ASSOC);

        if (!$dati_attuali) {
            jsonResponse(false, 'Esercizio non trovato');
        }

        // Verifica che la nuova categoria esista e recupera il nome
        $stmt_check_cat = $pdo->prepare("SELECT nome_categoria FROM categorie_esercizi WHERE id_categoria = :id");
        $stmt_check_cat->execute([':id' => $id_categoria]);
        $categoria_data = $stmt_check_cat->fetch(PDO::FETCH_ASSOC);

        if (!$categoria_data) {
            jsonResponse(false, 'La categoria selezionata non esiste');
        }

        // Verifica se il nome è già utilizzato da un altro esercizio nella stessa categoria
        $stmt_check_name = $pdo->prepare("SELECT COUNT(*) as count FROM esercizi WHERE nome_esercizio = :nome AND id_categoria = :categoria AND id_esercizio != :id");
        $stmt_check_name->execute([':nome' => $nome_esercizio, ':categoria' => $id_categoria, ':id' => $id_esercizio]);
        $name_exists = $stmt_check_name->fetch(PDO::FETCH_ASSOC);

        if ($name_exists['count'] > 0) {
            jsonResponse(false, 'Un esercizio con questo nome esiste già in questa categoria');
        }

        // Valida stato
        $stati_validi = ['attivo', 'sospeso', 'archiviato'];
        if (!in_array($stato_esercizio, $stati_validi)) {
            $stato_esercizio = 'attivo';
        }

        // STEP 2: Determina se serve rinominazione/spostamento cartella
        $nome_attuale = $dati_attuali['nome_attuale'];
        $categoria_attuale = $dati_attuali['categoria_attuale'];
        $categoria_nome_attuale = $dati_attuali['categoria_nome_attuale'];
        $categoria_nome_nuova = $categoria_data['nome_categoria'];

        $serve_rinominazione = ($nome_esercizio !== $nome_attuale) || ($id_categoria !== $categoria_attuale);

        // Calcola percorsi attuali e nuovi
        $nome_attuale_sanitizzato = strtolower(str_replace([' ', '-'], '_', preg_replace('/[^a-zA-Z0-9 -]/', '', $nome_attuale)));
        $categoria_attuale_sanitizzata = strtolower(str_replace([' ', '-'], '_', preg_replace('/[^a-zA-Z0-9 -]/', '', $categoria_nome_attuale)));

        $nome_nuovo_sanitizzato = strtolower(str_replace([' ', '-'], '_', preg_replace('/[^a-zA-Z0-9 -]/', '', $nome_esercizio)));
        $categoria_nuova_sanitizzata = strtolower(str_replace([' ', '-'], '_', preg_replace('/[^a-zA-Z0-9 -]/', '', $categoria_nome_nuova)));

        $percorso_attuale = "../training_cognitivo/{$categoria_attuale_sanitizzata}/{$nome_attuale_sanitizzato}";
        $percorso_nuovo = "../training_cognitivo/{$categoria_nuova_sanitizzata}/{$nome_nuovo_sanitizzato}";
        $base = defined('BASE_PATH') ? BASE_PATH : '';
        $link_nuovo = "$base/training_cognitivo/{$categoria_nuova_sanitizzata}/{$nome_nuovo_sanitizzato}/";

        // STEP 3: Aggiorna esercizio nel database
        $stmt = $pdo->prepare("
            UPDATE esercizi
            SET nome_esercizio = :nome,
                descrizione_esercizio = :descrizione,
                id_categoria = :categoria,
                stato_esercizio = :stato,
                link = :link
            WHERE id_esercizio = :id
        ");
        $result = $stmt->execute([
            ':nome' => $nome_esercizio,
            ':descrizione' => $descrizione_esercizio,
            ':categoria' => $id_categoria,
            ':stato' => $stato_esercizio,
            ':link' => $link_nuovo,
            ':id' => $id_esercizio
        ]);

        if (!$result) {
            jsonResponse(false, 'Errore nell\'aggiornamento del database');
        }

        // STEP 4: Gestisci rinominazione/spostamento cartella se necessario
        $cartella_spostata = false;
        $file_aggiornati = false;

        if ($serve_rinominazione && file_exists($percorso_attuale)) {
            try {
                // Verifica che la cartella di destinazione categoria esista
                $cartella_categoria_nuova = "../training_cognitivo/{$categoria_nuova_sanitizzata}";
                if (!file_exists($cartella_categoria_nuova)) {
                    mkdir($cartella_categoria_nuova, 0775, true);
                    chmod($cartella_categoria_nuova, 0775);
                }

                // Sposta/rinomina la cartella dell'esercizio
                if ($percorso_attuale !== $percorso_nuovo) {
                    if (file_exists($percorso_nuovo)) {
                        // Se la destinazione esiste, rimuovila prima
                        exec("rm -rf " . escapeshellarg($percorso_nuovo));
                    }

                    $cartella_spostata = rename($percorso_attuale, $percorso_nuovo);

                    if ($cartella_spostata) {
                        // Aggiorna i file PWA con il nuovo nome
                        if (file_exists("$percorso_nuovo/index.html")) {
                            $index_html_content = createPWAIndexTemplate($nome_esercizio, $id_esercizio);
                            file_put_contents("$percorso_nuovo/index.html", $index_html_content);
                            chmod("$percorso_nuovo/index.html", 0664);
                        }

                        if (file_exists("$percorso_nuovo/js/app.js")) {
                            $app_js_content = createAppJSTemplate($nome_esercizio, $id_esercizio);
                            file_put_contents("$percorso_nuovo/js/app.js", $app_js_content);
                            chmod("$percorso_nuovo/js/app.js", 0664);
                        }

                        if (file_exists("$percorso_nuovo/manifest.json")) {
                            $manifest_content = createManifestTemplate($nome_esercizio);
                            file_put_contents("$percorso_nuovo/manifest.json", $manifest_content);
                            chmod("$percorso_nuovo/manifest.json", 0664);
                        }

                        if (file_exists("$percorso_nuovo/service-worker.js")) {
                            $sw_content = createServiceWorkerTemplate($nome_esercizio);
                            file_put_contents("$percorso_nuovo/service-worker.js", $sw_content);
                            chmod("$percorso_nuovo/service-worker.js", 0664);
                        }

                        // Imposta permessi per tutta la struttura
                        setPermissionsRecursive($percorso_nuovo, 0775, 0664);
                        $file_aggiornati = true;
                    }
                }

            } catch (Exception $e) {
                logOperation('UPDATE_ESERCIZIO_ERROR', "Errore rinominazione cartella: " . $e->getMessage(), $ip);
                // Non fare fallire l'operazione, il database è già aggiornato
            }
        } elseif (!$serve_rinominazione && file_exists($percorso_attuale)) {
            // Anche se non cambia nome/categoria, aggiorna i file se esistono
            try {
                if (file_exists("$percorso_attuale/index.html")) {
                    $index_html_content = createPWAIndexTemplate($nome_esercizio, $id_esercizio);
                    file_put_contents("$percorso_attuale/index.html", $index_html_content);
                }

                if (file_exists("$percorso_attuale/js/app.js")) {
                    $app_js_content = createAppJSTemplate($nome_esercizio, $id_esercizio);
                    file_put_contents("$percorso_attuale/js/app.js", $app_js_content);
                }

                if (file_exists("$percorso_attuale/manifest.json")) {
                    $manifest_content = createManifestTemplate($nome_esercizio);
                    file_put_contents("$percorso_attuale/manifest.json", $manifest_content);
                }

                if (file_exists("$percorso_attuale/service-worker.js")) {
                    $sw_content = createServiceWorkerTemplate($nome_esercizio);
                    file_put_contents("$percorso_attuale/service-worker.js", $sw_content);
                }

                $file_aggiornati = true;
            } catch (Exception $e) {
                logOperation('UPDATE_ESERCIZIO_FILES_ERROR', "Errore aggiornamento file: " . $e->getMessage(), $ip);
            }
        }

        logOperation('UPDATE_ESERCIZIO', "ID: $id_esercizio, Nome: $nome_esercizio, Cartella spostata: " . ($cartella_spostata ? 'SI' : 'NO'), $ip);

        jsonResponse(true, 'Esercizio aggiornato con successo', [
            'id_esercizio' => $id_esercizio,
            'nome_esercizio' => $nome_esercizio,
            'link' => $link_nuovo,
            'cartella_spostata' => $cartella_spostata,
            'file_aggiornati' => $file_aggiornati,
            'percorso_nuovo' => $percorso_nuovo
        ]);

    } elseif ($action === 'delete_esercizio') {
        // Elimina esercizio
        $id_esercizio = intval($input['id_esercizio'] ?? 0);

        if ($id_esercizio <= 0) {
            jsonResponse(false, 'ID esercizio non valido');
        }

        // Verifica che l'esercizio esista
        $stmt_exists = $pdo->prepare("SELECT nome_esercizio FROM esercizi WHERE id_esercizio = :id");
        $stmt_exists->execute([':id' => $id_esercizio]);
        $esercizio = $stmt_exists->fetch(PDO::FETCH_ASSOC);

        if (!$esercizio) {
            jsonResponse(false, 'Esercizio non trovato');
        }

        // TODO: Verifica se l'esercizio è utilizzato in altre tabelle (quando saranno create)
        // Per ora eliminiamo direttamente

        // Elimina esercizio
        $stmt = $pdo->prepare("DELETE FROM esercizi WHERE id_esercizio = :id");
        $result = $stmt->execute([':id' => $id_esercizio]);

        if ($result) {
            logOperation('DELETE_ESERCIZIO', "ID: $id_esercizio, Nome: {$esercizio['nome_esercizio']}", $ip);
            jsonResponse(true, 'Esercizio eliminato con successo');
        } else {
            jsonResponse(false, 'Errore nell\'eliminazione dell\'esercizio');
        }

    // ===================== STATISTICHE =====================
    } elseif ($action === 'get_statistics') {
        // Recupera statistiche sugli esercizi
        $stmt_count = $pdo->prepare("
            SELECT
                COUNT(*) as totale_esercizi,
                COUNT(CASE WHEN stato_esercizio = 'attivo' THEN 1 END) as esercizi_attivi,
                COUNT(CASE WHEN stato_esercizio = 'sospeso' THEN 1 END) as esercizi_sospesi,
                COUNT(CASE WHEN stato_esercizio = 'archiviato' THEN 1 END) as esercizi_archiviati
            FROM esercizi
        ");
        $stmt_count->execute();
        $stats = $stmt_count->fetch(PDO::FETCH_ASSOC);

        // Statistiche per categoria
        $stmt_categorie = $pdo->prepare("
            SELECT
                c.nome_categoria,
                COUNT(e.id_esercizio) as numero_esercizi
            FROM categorie_esercizi c
            LEFT JOIN esercizi e ON c.id_categoria = e.id_categoria
            GROUP BY c.id_categoria, c.nome_categoria
            ORDER BY numero_esercizi DESC, c.nome_categoria ASC
        ");
        $stmt_categorie->execute();
        $stats_categorie = $stmt_categorie->fetchAll(PDO::FETCH_ASSOC);

        $statistiche = [
            'totali' => $stats,
            'per_categoria' => $stats_categorie
        ];

        jsonResponse(true, 'Statistiche recuperate con successo', $statistiche);

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_esercizi.php: " . $e->getMessage());
    $msg = 'Errore temporaneo del servizio. Riprova più tardi.';
    if (defined('DEBUG_MODE') && DEBUG_MODE) {
        $msg .= ' | DEBUG: ' . $e->getMessage();
    }
    jsonResponse(false, $msg);
} catch (Exception $e) {
    error_log("Errore generale in api_esercizi.php: " . $e->getMessage());
    $msg = 'Errore del server. Riprova più tardi.';
    if (defined('DEBUG_MODE') && DEBUG_MODE) {
        $msg .= ' | DEBUG: ' . $e->getMessage();
    }
    jsonResponse(false, $msg);
}
?>