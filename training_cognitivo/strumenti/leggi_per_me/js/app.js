// App Configuration
const APP_CONFIG = {
    name: 'Leggi per me',
    id: 28,
    version: '1.0.0'
};

// State Management
let appState = {
    isStarted: false,
    settings: loadSettings()
};

// Load settings from localStorage
function loadSettings() {
    const saved = localStorage.getItem('app_settings_28');
    return saved ? JSON.parse(saved) : {
        theme: 'light',
        soundEnabled: true
    };
}

// Save settings to localStorage
function saveSettings() {
    localStorage.setItem('app_settings_28', JSON.stringify(appState.settings));
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
                    <h2>🎯 Leggi per me</h2>
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
