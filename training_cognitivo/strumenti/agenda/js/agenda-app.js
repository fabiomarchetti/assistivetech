/**
 * Applicazione Agenda - Navigazione Paziente
 */

// Stato globale applicazione
const agendaState = {
    selectedUser: null,
    currentAgenda: null,
    agendaPrincipale: null,
    items: [],
    currentIndex: 0,
    agendaStack: [], // Stack per navigazione agende
    isOnline: navigator.onLine
};

// Swipe handler
let swipeHandler;

// ========== INIZIALIZZAZIONE ==========

document.addEventListener('DOMContentLoaded', async () => {
    // Inizializza database locale
    try {
        await dbManager.init();
        console.log('Database locale inizializzato');
    } catch (error) {
        console.error('Errore init database:', error);
    }

    // Event listener online/offline
    window.addEventListener('online', () => {
        agendaState.isOnline = true;
        console.log('Online');
        syncData();
    });

    window.addEventListener('offline', () => {
        agendaState.isOnline = false;
        console.log('Offline');
    });

    // Inizializza slider TTS da localStorage
    initTTSSliders();

    // Carica pazienti
    await loadUsers();

    // Inizializza swipe handler sull'item display
    const itemDisplay = document.getElementById('itemDisplay');
    swipeHandler = new SwipeHandler(itemDisplay, {
        onSwipeLeft: nextItem,
        onSwipeRight: prevItem,
        onLongClick: handleLongClick,
        onTap: handleTap
    });
});

// ========== CONTROLLI TTS (Slider Velocità e Volume) ==========

/**
 * Inizializza slider TTS da localStorage
 */
function initTTSSliders() {
    const sliderVelocity = document.getElementById('sliderVelocity');
    const sliderVolume = document.getElementById('sliderVolume');
    const velocityValue = document.getElementById('velocityValue');
    const volumeValue = document.getElementById('volumeValue');

    // Carica valori da localStorage se disponibili
    const savedVelocity = localStorage.getItem('tts_velocity');
    const savedVolume = localStorage.getItem('tts_volume');

    if (savedVelocity) {
        sliderVelocity.value = savedVelocity;
        velocityValue.textContent = savedVelocity + 'x';
    }

    if (savedVolume) {
        sliderVolume.value = savedVolume;
        volumeValue.textContent = Math.round(savedVolume * 100) + '%';
    }

    // Event listener per velocità
    sliderVelocity.addEventListener('input', (e) => {
        const value = e.target.value;
        velocityValue.textContent = value + 'x';
        localStorage.setItem('tts_velocity', value);
        console.log('TTS Velocità:', value);
    });

    // Event listener per volume
    sliderVolume.addEventListener('input', (e) => {
        const value = e.target.value;
        volumeValue.textContent = Math.round(value * 100) + '%';
        localStorage.setItem('tts_volume', value);
        console.log('TTS Volume:', value);
    });
}

/**
 * Ottieni impostazioni TTS correnti
 */
function getTTSSettings() {
    const velocity = parseFloat(document.getElementById('sliderVelocity').value) || 0.9;
    const volume = parseFloat(document.getElementById('sliderVolume').value) || 1;
    return { velocity, volume };
}

// ========== GESTIONE UTENTI ==========

/**
 * Carica lista pazienti
 */
async function loadUsers() {
    try {
        let pazienti = [];

        // Rileva se siamo in locale (sviluppo)
        const isLocalhost = window.location.hostname === 'localhost' ||
                           window.location.hostname === '127.0.0.1' ||
                           window.location.hostname.includes('local');

        // In localhost, aggiungi opzione "Test" per sviluppatori
        if (isLocalhost) {
            pazienti.push({
                id_paziente: 'test',
                nome: 'Utente',
                cognome: 'Test'
            });
        }

        if (agendaState.isOnline && !isLocalhost) {
            try {
                // Carica da API con path corretto
                const basePath = window.location.pathname.includes('/Assistivetech/') ? '/Assistivetech' : '';
                const response = await fetch(`${basePath}/api/api_pazienti.php?action=list`);
                const result = await response.json();

                if (result.success && result.data) {
                    pazienti = pazienti.concat(result.data);
                }
            } catch (apiError) {
                console.warn('API non disponibile, uso cache:', apiError);
                // Fallback a cache se API non disponibile
                const cached = localStorage.getItem('pazienti_cache');
                if (cached) {
                    pazienti = pazienti.concat(JSON.parse(cached));
                }
            }
        } else if (!isLocalhost) {
            // Offline: carica da localStorage (cache)
            const cached = localStorage.getItem('pazienti_cache');
            if (cached) {
                pazienti = pazienti.concat(JSON.parse(cached));
            }
        }

        // Salva in cache (solo pazienti reali, non test)
        const realPatients = pazienti.filter(p => p.id_paziente !== 'test');
        if (realPatients.length > 0) {
            localStorage.setItem('pazienti_cache', JSON.stringify(realPatients));
        }

        // Popola select
        const select = document.getElementById('selectUser');

        if (pazienti.length === 0) {
            select.innerHTML = '<option value="">Nessun paziente disponibile</option>';
        } else {
            select.innerHTML = '<option value="">-- Seleziona --</option>';

            pazienti.forEach(p => {
                const option = document.createElement('option');
                option.value = p.id_paziente;
                option.textContent = `${p.nome} ${p.cognome}${p.id_paziente === 'test' ? ' (Test Locale)' : ''}`;
                select.appendChild(option);
            });
        }

    } catch (error) {
        console.error('Errore caricamento utenti:', error);

        // Fallback: mostra almeno opzione test in locale
        const isLocalhost = window.location.hostname === 'localhost' ||
                           window.location.hostname === '127.0.0.1';

        const select = document.getElementById('selectUser');
        if (isLocalhost) {
            select.innerHTML = '<option value="">-- Seleziona --</option><option value="test">Utente Test (Locale)</option>';
        } else {
            select.innerHTML = '<option value="">Errore caricamento - Riprova</option>';
        }
    }
}

/**
 * Seleziona utente e carica agenda principale
 */
async function selectUser() {
    const select = document.getElementById('selectUser');
    const userId = select.value;

    if (!userId) {
        alert('Seleziona un utente');
        return;
    }

    // Gestione utente test (localStorage) - usa stesso storage dell'educatore "anonimo"
    if (userId === 'test') {
        agendaState.selectedUser = 'test';
        showScreen('screenLoading');

        try {
            // Carica agende anonimo da localStorage (create dall'educatore)
            const agendeAnonimo = JSON.parse(localStorage.getItem('agende_anonimo') || '[]');

            if (agendeAnonimo.length === 0) {
                showError('Nessuna agenda trovata. Vai nell\'interfaccia educatore e crea un\'agenda con "Anonimo (Test)".');
                return;
            }

            // Prendi prima agenda principale
            const agendaPrincipale = agendeAnonimo.find(a => a.tipo_agenda === 'principale') || agendeAnonimo[0];
            agendaState.agendaPrincipale = agendaPrincipale;

            // Carica item dalla stessa chiave localStorage usata dall'educatore
            const itemsAnonimo = JSON.parse(localStorage.getItem(`items_anonimo_${agendaPrincipale.id_agenda}`) || '[]');

            if (itemsAnonimo.length === 0) {
                showError('Agenda vuota. Aggiungi item nell\'interfaccia educatore.');
                return;
            }

            // Aggiorna stato
            agendaState.currentAgenda = agendaPrincipale.id_agenda;
            agendaState.items = itemsAnonimo;
            agendaState.currentIndex = 0;

            // Mostra primo item
            showScreen('screenItem');
            updateBreadcrumb();
            displayItem(0);

        } catch (error) {
            console.error('Errore caricamento agenda test:', error);
            showError('Errore caricamento agenda test');
        }
        return;
    }

    // Utente reale (database)
    agendaState.selectedUser = parseInt(userId);

    showScreen('screenLoading');

    try {
        // Carica agenda principale
        let agende;

        if (agendaState.isOnline) {
            agende = await apiClient.listAgende(userId, true); // Solo principali
        } else {
            agende = dbManager.getAgendeLocal(userId, true);
        }

        if (agende.length === 0) {
            showError('Nessuna agenda trovata per questo utente');
            return;
        }

        // Prendi prima agenda principale
        const agendaPrincipale = agende[0];
        agendaState.agendaPrincipale = agendaPrincipale;

        // Carica item
        await loadAgenda(agendaPrincipale.id_agenda);

    } catch (error) {
        console.error('Errore caricamento agenda:', error);
        showError('Errore caricamento agenda');
    }
}

// ========== GESTIONE AGENDE ==========

/**
 * Carica agenda e item
 */
async function loadAgenda(idAgenda) {
    try {
        let items;

        if (agendaState.isOnline) {
            items = await apiClient.listItems(idAgenda);
        } else {
            items = dbManager.getItemsLocal(idAgenda);
        }

        if (items.length === 0) {
            showError('Agenda vuota');
            return;
        }

        // Aggiorna stato
        agendaState.currentAgenda = idAgenda;
        agendaState.items = items;
        agendaState.currentIndex = 0;

        // Mostra primo item
        showScreen('screenItem');
        updateBreadcrumb();
        displayItem(0);

    } catch (error) {
        console.error('Errore caricamento item:', error);
        showError('Errore caricamento item');
    }
}

/**
 * Torna all'agenda principale
 */
async function goHome() {
    agendaState.agendaStack = [];

    if (agendaState.agendaPrincipale) {
        await loadAgenda(agendaState.agendaPrincipale.id_agenda);
    } else {
        showScreen('screenUserSelect');
    }
}

// ========== NAVIGAZIONE ITEM ==========

/**
 * Visualizza item corrente
 */
function displayItem(index) {
    if (index < 0 || index >= agendaState.items.length) {
        return;
    }

    agendaState.currentIndex = index;
    const item = agendaState.items[index];

    const container = document.getElementById('itemDisplay');

    // Renderizza item in base al tipo
    if (item.tipo_item === 'video_youtube') {
        container.innerHTML = renderVideoItem(item);
    } else {
        container.innerHTML = renderStandardItem(item);
    }

    // Aggiorna progress
    document.getElementById('progressText').textContent = `${index + 1} / ${agendaState.items.length}`;

    // Aggiorna visibilità frecce
    document.getElementById('btnPrev').style.display = index > 0 ? 'flex' : 'none';
    document.getElementById('btnNext').style.display = index < agendaState.items.length - 1 ? 'flex' : 'none';

    // ===== TTS AUTOMATICO ALL'ARRIVO DELL'ITEM =====
    // Ferma il TTS precedente
    stopTTS();

    // Pronuncia automaticamente la frase se disponibile
    if (item.fraseVocale && item.fraseVocale.trim() !== '') {
        console.log('TTS Auto: Pronuncia frase dell\'item:', item.fraseVocale);
        // Piccolo delay per assicurare che il DOM sia aggiornato
        setTimeout(() => {
            playTTS(item.fraseVocale);
        }, 300);
    }
}

/**
 * Renderizza item standard
 */
function renderStandardItem(item) {
    let imageHtml = '';

    if (item.tipo_immagine === 'arasaac' && item.id_arasaac) {
        const url = arasaacService.getPictogramUrl(item.id_arasaac, 500);
        imageHtml = `<img src="${url}" alt="${item.titolo}" class="item-image">`;
    } else if (item.tipo_immagine === 'upload' && item.url_immagine) {
        imageHtml = `<img src="${item.url_immagine}" alt="${item.titolo}" class="item-image">`;
    } else {
        imageHtml = `<div class="item-placeholder"><i class="bi bi-image"></i></div>`;
    }

    let badgeHtml = '';
    if (item.tipo_item === 'link_agenda') {
        badgeHtml = `<div class="item-badge"><i class="bi bi-hand-index-thumb"></i> Tieni premuto per aprire</div>`;
    }

    // Aggiungi bottone TTS se la frase è disponibile
    let ttsButtonHtml = '';
    if (item.fraseVocale && item.fraseVocale.trim() !== '') {
        ttsButtonHtml = `<button class="btn-tts" onclick="playTTS('${item.fraseVocale.replace(/'/g, "\\'")}')">
            <i class="bi bi-volume-up-fill"></i> Ascolta
        </button>`;
    }

    return `
        ${imageHtml}
        <h1 class="item-title">${item.titolo}</h1>
        ${ttsButtonHtml}
        ${badgeHtml}
    `;
}

/**
 * Renderizza item video YouTube
 */
function renderVideoItem(item) {
    // Aggiungi bottone TTS se la frase è disponibile
    let ttsButtonHtml = '';
    if (item.fraseVocale && item.fraseVocale.trim() !== '') {
        ttsButtonHtml = `<button class="btn-tts" onclick="playTTS('${item.fraseVocale.replace(/'/g, "\\'")}')">
            <i class="bi bi-volume-up-fill"></i> Ascolta
        </button>`;
    }

    return `
        <img src="${item.video_youtube_thumbnail}" alt="${item.titolo}" class="item-image video-thumb" onclick="playVideo('${item.video_youtube_id}')">
        <h1 class="item-title">${item.titolo}</h1>
        ${ttsButtonHtml}
        <div class="item-badge">
            <i class="bi bi-play-circle-fill"></i> Clicca per guardare il video
        </div>
    `;
}

/**
 * Item successivo
 */
function nextItem() {
    if (agendaState.currentIndex < agendaState.items.length - 1) {
        displayItem(agendaState.currentIndex + 1);
    }
}

/**
 * Item precedente
 */
function prevItem() {
    if (agendaState.currentIndex > 0) {
        displayItem(agendaState.currentIndex - 1);
    }
}

// ========== GESTIONE INTERAZIONI ==========

/**
 * Gestisce longclick (apre agenda collegata)
 */
async function handleLongClick(e) {
    const currentItem = agendaState.items[agendaState.currentIndex];

    if (currentItem.tipo_item === 'link_agenda' && currentItem.id_agenda_collegata) {
        // Salva agenda corrente nello stack
        agendaState.agendaStack.push({
            id: agendaState.currentAgenda,
            index: agendaState.currentIndex
        });

        // Carica nuova agenda
        showScreen('screenLoading');
        await loadAgenda(currentItem.id_agenda_collegata);
    }
}

/**
 * Gestisce tap (placeholder per future azioni)
 */
function handleTap(e) {
    // Placeholder per azioni future
}

// ========== VIDEO YOUTUBE ==========

/**
 * Riproduci video YouTube
 */
function playVideo(videoId) {
    const embedUrl = youtubeService.getEmbedUrl(videoId, {
        autoplay: true,
        controls: true,
        modestbranding: true
    });

    const container = document.getElementById('videoContainer');
    container.innerHTML = `
        <iframe
            width="100%"
            height="100%"
            src="${embedUrl}"
            frameborder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen
        ></iframe>
    `;

    showScreen('screenVideo');
}

/**
 * Chiudi video
 */
function closeVideo() {
    document.getElementById('videoContainer').innerHTML = '';
    showScreen('screenItem');
}

// ========== TEXT-TO-SPEECH (TTS) ==========

/**
 * Pronuncia una frase (TTS)
 * @param {string} frase - Testo da pronunciare
 */
function playTTS(frase) {
    if (!frase || frase.trim() === '') {
        console.warn('TTS: Frase vuota');
        return;
    }

    // Verifica se TTS è supportato
    if (!TTSService.isSupported()) {
        console.error('TTS non supportato in questo browser');
        alert('La pronuncia non è supportata nel tuo browser');
        return;
    }

    // Ottieni impostazioni dai slider
    const settings = getTTSSettings();

    // Pronuncia la frase con le impostazioni dell'utente
    TTSService.speak(frase, {
        language: 'it-IT',      // Italiano
        rate: settings.velocity,  // Velocità dal slider
        pitch: 1,               // Intonazione neutra
        volume: settings.volume,  // Volume dal slider
        onStart: () => {
            console.log('TTS: Inizio pronuncia');
            // Opzionale: visualizza feedback all'utente
        },
        onEnd: () => {
            console.log('TTS: Fine pronuncia');
            // Opzionale: rimuovi feedback
        },
        onError: (error) => {
            console.error('TTS: Errore', error);
        }
    });
}

/**
 * Ferma la pronuncia in corso
 */
function stopTTS() {
    TTSService.stop();
    console.log('TTS: Pronuncia fermata');
}

// ========== BREADCRUMB ==========

/**
 * Aggiorna breadcrumb percorso
 */
function updateBreadcrumb() {
    const breadcrumb = document.getElementById('breadcrumbText');

    if (agendaState.agendaStack.length === 0) {
        breadcrumb.textContent = 'Home';
    } else {
        // Mostra percorso (semplificato)
        breadcrumb.textContent = `Home > ${agendaState.agendaStack.length} livello${agendaState.agendaStack.length > 1 ? 'i' : ''}`;
    }
}

// ========== GESTIONE SCHERMATE ==========

/**
 * Mostra schermata
 */
function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.remove('active');
    });

    document.getElementById(screenId).classList.add('active');

    // Visibilità bottone home
    const btnHome = document.getElementById('btnHome');
    const breadcrumb = document.getElementById('breadcrumb');

    if (screenId === 'screenItem') {
        btnHome.style.display = 'flex';
        breadcrumb.style.display = 'block';
    } else {
        btnHome.style.display = 'none';
        breadcrumb.style.display = 'none';
    }
}

/**
 * Mostra errore
 */
function showError(message) {
    document.getElementById('errorMessage').textContent = message;
    showScreen('screenError');
}

// ========== SINCRONIZZAZIONE ==========

/**
 * Sincronizza dati online/offline
 */
async function syncData() {
    if (!agendaState.isOnline) return;

    try {
        console.log('Sincronizzazione dati...');

        // Qui implementeresti la sincronizzazione bidirezionale
        // tra database locale (SQLite) e server (MySQL)

        // Esempio:
        // 1. Carica pending changes dal DB locale
        // 2. Invia al server
        // 3. Scarica updates dal server
        // 4. Aggiorna DB locale

        console.log('Sincronizzazione completata');

    } catch (error) {
        console.error('Errore sincronizzazione:', error);
    }
}

// ========== UTILITY ==========

/**
 * Precarica immagine successiva (performance)
 */
function preloadNextImage() {
    if (agendaState.currentIndex < agendaState.items.length - 1) {
        const nextItem = agendaState.items[agendaState.currentIndex + 1];

        if (nextItem.tipo_immagine === 'arasaac' && nextItem.id_arasaac) {
            const img = new Image();
            img.src = arasaacService.getPictogramUrl(nextItem.id_arasaac, 500);
        } else if (nextItem.url_immagine) {
            const img = new Image();
            img.src = nextItem.url_immagine;
        }
    }
}
