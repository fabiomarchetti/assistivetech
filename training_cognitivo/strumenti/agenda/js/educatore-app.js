/**
 * Applicazione Educatore - Gestione Agende
 */

// AUTO-DETECTION BASE_PATH
const BASE_PATH = window.location.pathname.includes('/Assistivetech/') ? '/Assistivetech' : '';

// Stato globale applicazione
const appState = {
    currentUser: null,
    selectedPaziente: null,
    selectedAgenda: null,
    agende: [],
    items: [],
    pazienti: []
};

// Modali Bootstrap
let modalCreaAgenda, modalAggiungiItem;

// ========== INIZIALIZZAZIONE ==========

document.addEventListener('DOMContentLoaded', async () => {
    // Inizializza modali
    modalCreaAgenda = new bootstrap.Modal(document.getElementById('modalCreaAgenda'));
    modalAggiungiItem = new bootstrap.Modal(document.getElementById('modalAggiungiItem'));

    // Event listener tipo agenda
    document.querySelectorAll('input[name="tipoAgenda"]').forEach(radio => {
        radio.addEventListener('change', toggleParentAgendaSelect);
    });

    // Carica utente corrente dalla sessione
    loadCurrentUser();

    // Carica lista pazienti
    await loadPazienti();
});

/**
 * Carica utente corrente dal localStorage
 */
function loadCurrentUser() {
    const userData = localStorage.getItem('userData');
    if (userData) {
        try {
            appState.currentUser = JSON.parse(userData);
        } catch (e) {
            console.error('Errore parsing userData:', e);
        }
    }

    // Se non c'è utente e siamo in ambiente locale (sviluppo), imposta sviluppatore di default
    if (!appState.currentUser && (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' || window.location.hostname.includes('local'))) {
        console.warn('Nessun utente in sessione - Caricamento modalità sviluppatore per test locale');
        appState.currentUser = {
            ruolo_registrazione: 'sviluppatore',
            id_registrazione: 1,
            nome_registrazione: 'Sviluppatore',
            cognome_registrazione: 'Test',
            username_registrazione: 'dev@test.local'
        };
    }

    if (!appState.currentUser) {
        // Se non c'è utente in produzione, mostra messaggio di login
        console.warn('Nessun utente in sessione - Richiesto login');
    }
}

// ========== CARICAMENTO PAZIENTI ==========

/**
 * Carica lista pazienti dal database
 * Con fallback a "Anonimo" per sviluppatori se API fallisce
 */
async function loadPazienti() {
    try {
        const userRole = appState.currentUser?.ruolo_registrazione;
        const userId = appState.currentUser?.id_registrazione;

        console.log('LoadPazienti - Ruolo:', userRole, 'ID:', userId);

        let pazientiData = [];

        // Se sviluppatore/admin: mostra tutti + opzione "anonimo"
        if (userRole === 'sviluppatore' || userRole === 'amministratore') {
            try {
                const response = await fetch(`${BASE_PATH}/api/api_pazienti.php?action=list`);

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }

                const result = await response.json();

                console.log('API Response:', result);

                // Controlla se l'API ha ritornato un errore
                if (!result.success) {
                    throw new Error(result.message || 'API ha ritornato un errore');
                }

                if (result.data && Array.isArray(result.data)) {
                    pazientiData = result.data;
                }
            } catch (apiError) {
                console.warn('Errore API pazienti:', apiError);
                // Se sviluppatore, continua con fallback anonimo
                // Se admin, mostrerà alert di errore
                if (userRole !== 'sviluppatore') {
                    throw apiError;
                }
            }

            const select = document.getElementById('selectPaziente');

            // Opzione "Anonimo" di default per sviluppatore
            if (userRole === 'sviluppatore') {
                select.innerHTML = '<option value="anonimo" selected>👤 Anonimo (Test - Dev)</option>';
            } else {
                select.innerHTML = '<option value="">-- Seleziona Paziente --</option>';
            }

            // Aggiungi tutti i pazienti (se la API ha funzionato)
            if (pazientiData.length > 0) {
                pazientiData.forEach(paziente => {
                    const option = document.createElement('option');
                    option.value = paziente.id_paziente;
                    option.textContent = `${paziente.nome} ${paziente.cognome}`;
                    select.appendChild(option);
                });
            }

            // Se sviluppatore, seleziona automaticamente "anonimo"
            if (userRole === 'sviluppatore') {
                appState.selectedPaziente = 'anonimo';
                // Carica subito le agende anonimo
                loadAgende();
            }

        }
        // Se educatore: mostra solo pazienti assegnati
        else if (userRole === 'educatore') {
            try {
                // API che torna solo pazienti assegnati all'educatore
                const response = await fetch(`${BASE_PATH}/api/api_pazienti.php?action=list_by_educatore&id_educatore=${userId}`);

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }

                const result = await response.json();

                if (!result.success) {
                    throw new Error(result.message || 'API ha ritornato un errore');
                }

                if (result.data && Array.isArray(result.data)) {
                    pazientiData = result.data;
                }
            } catch (apiError) {
                console.warn('Errore API educatore:', apiError);
                throw apiError;
            }

            const select = document.getElementById('selectPaziente');

            if (pazientiData.length === 0) {
                select.innerHTML = '<option value="">Nessun paziente assegnato</option>';
            } else {
                select.innerHTML = '<option value="">-- Seleziona Paziente --</option>';

                pazientiData.forEach(paziente => {
                    const option = document.createElement('option');
                    option.value = paziente.id_paziente;
                    option.textContent = `${paziente.nome} ${paziente.cognome}`;
                    select.appendChild(option);
                });
            }
        }
        // Altro (paziente o nessun utente): non dovrebbe vedere questa interfaccia
        else {
            const select = document.getElementById('selectPaziente');
            if (!appState.currentUser) {
                select.innerHTML = '<option value="">Effettua il login per continuare</option>';
                // Mostra alert con link al login
                showLoginAlert();
            } else {
                select.innerHTML = '<option value="">Accesso non consentito per il tuo ruolo</option>';
            }
            select.disabled = true;
        }

        appState.pazienti = pazientiData;

    } catch (error) {
        console.error('ERRORE loadPazienti:', error);

        // Se sviluppatore, mostra comunque opzione anonimo anche in caso di errore API
        const userRole = appState.currentUser?.ruolo_registrazione;
        const select = document.getElementById('selectPaziente');

        if (userRole === 'sviluppatore') {
            console.warn('Fallback anonimo per sviluppatore');
            select.innerHTML = '<option value="anonimo" selected>👤 Anonimo (Test - Dev)</option>';
            appState.selectedPaziente = 'anonimo';
            // Carica automaticamente le agende in modalità anonimo
            loadAgende();
        } else {
            select.innerHTML = '<option value="">Errore caricamento pazienti</option>';
            select.disabled = true;
            showAlert('Errore caricamento pazienti. Riprova.', 'danger');
        }
    }
}

// ========== GESTIONE AGENDE ==========

/**
 * Carica agende del paziente selezionato
 */
async function loadAgende() {
    const selectPaziente = document.getElementById('selectPaziente');
    const idPaziente = selectPaziente.value;

    if (!idPaziente) {
        document.getElementById('listaAgende').innerHTML = `
            <div class="text-center py-3 text-muted">
                <i class="bi bi-inbox fs-1"></i>
                <p class="mb-0">Seleziona un paziente</p>
            </div>
        `;
        hideAgendaContent();
        return;
    }

    // Gestione "anonimo" per sviluppatore
    if (idPaziente === 'anonimo') {
        appState.selectedPaziente = 'anonimo';

        // Carica agende da localStorage per test anonimo
        const agendeAnonimo = JSON.parse(localStorage.getItem('agende_anonimo') || '[]');
        appState.agende = agendeAnonimo;

        renderAgende(agendeAnonimo);
        return;
    }

    appState.selectedPaziente = parseInt(idPaziente);

    try {
        const agende = await apiClient.listAgende(idPaziente, true); // Solo principali
        appState.agende = agende;

        renderAgende(agende);

    } catch (error) {
        console.error('Errore caricamento agende:', error);
        showAlert('Errore caricamento agende', 'danger');
    }
}

/**
 * Renderizza lista agende
 */
function renderAgende(agende) {
    const container = document.getElementById('listaAgende');

    if (agende.length === 0) {
        container.innerHTML = `
            <div class="text-center py-3 text-muted">
                <i class="bi bi-folder-x fs-1"></i>
                <p class="mb-0">Nessuna agenda</p>
            </div>
        `;
        return;
    }

    container.innerHTML = agende.map(agenda => `
        <button class="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                onclick="selectAgenda(${agenda.id_agenda})">
            <div>
                <i class="bi bi-folder${agenda.tipo_agenda === 'principale' ? '' : '2'}"></i>
                <strong>${agenda.nome_agenda}</strong>
                <br>
                <small class="text-muted">${agenda.num_items || 0} item</small>
            </div>
            <i class="bi bi-chevron-right"></i>
        </button>
    `).join('');
}

/**
 * Seleziona agenda e carica item
 * Supporta sia API reale che localStorage per anonimo
 */
async function selectAgenda(idAgenda) {
    appState.selectedAgenda = idAgenda;

    try {
        let agenda, items;

        // Se è anonimo, carica da localStorage
        if (appState.selectedPaziente === 'anonimo') {
            const agendeAnonimo = JSON.parse(localStorage.getItem('agende_anonimo') || '[]');
            agenda = agendeAnonimo.find(a => a.id_agenda === idAgenda);

            if (!agenda) {
                throw new Error('Agenda non trovata in localStorage');
            }

            // Carica item da localStorage con chiave specifica
            const itemsKey = `items_anonimo_${idAgenda}`;
            items = JSON.parse(localStorage.getItem(itemsKey) || '[]');

            console.log('Caricato agenda anonimo:', agenda, 'Items:', items.length);

        } else {
            // Carica da API per pazienti reali
            agenda = await apiClient.getAgenda(idAgenda);
            items = await apiClient.listItems(idAgenda);
        }

        appState.items = items;

        // Mostra contenuto agenda
        document.getElementById('noAgendaSelected').style.display = 'none';
        document.getElementById('agendaContent').style.display = 'block';

        document.getElementById('agendaTitle').textContent = agenda.nome_agenda;

        // Per anonimo, usa "Anonimo" come nome paziente
        const nomePaziente = appState.selectedPaziente === 'anonimo'
            ? 'Anonimo'
            : (agenda.nome_paziente || '');
        const cognomePaziente = appState.selectedPaziente === 'anonimo'
            ? '(Test)'
            : (agenda.cognome_paziente || '');

        document.getElementById('agendaBreadcrumb').innerHTML = `
            <small>
                <i class="bi bi-folder"></i>
                ${nomePaziente} ${cognomePaziente} › ${agenda.nome_agenda}
            </small>
        `;

        renderItems(items);

    } catch (error) {
        console.error('Errore caricamento agenda:', error);
        showAlert('Errore caricamento agenda', 'danger');
    }
}

/**
 * Nasconde contenuto agenda
 */
function hideAgendaContent() {
    document.getElementById('noAgendaSelected').style.display = 'block';
    document.getElementById('agendaContent').style.display = 'none';
    appState.selectedAgenda = null;
}

// ========== GESTIONE ITEM ==========

/**
 * Renderizza lista item con drag & drop
 */
function renderItems(items) {
    const container = document.getElementById('listaItems');

    if (items.length === 0) {
        container.innerHTML = `
            <div class="col-12 text-center py-5 text-muted">
                <i class="bi bi-inbox fs-1"></i>
                <p class="mb-0">Nessun item. Clicca "Aggiungi Item" per iniziare.</p>
            </div>
        `;
        return;
    }

    container.innerHTML = items.map(item => `
        <div class="col-md-6 col-lg-4" data-id="${item.id_item}">
            <div class="card h-100 item-card">
                <div class="card-body">
                    ${renderItemImage(item)}
                    <h5 class="card-title mt-3">${item.titolo}</h5>
                    ${renderItemBadges(item)}
                </div>
                <div class="card-footer bg-transparent border-top-0">
                    <button class="btn btn-sm btn-outline-danger" onclick="deleteItem(${item.id_item})">
                        <i class="bi bi-trash"></i> Elimina
                    </button>
                </div>
            </div>
        </div>
    `).join('');

    // Abilita drag & drop con SortableJS
    new Sortable(container, {
        animation: 150,
        ghostClass: 'sortable-ghost',
        handle: '.card',
        onEnd: handleReorder
    });
}

/**
 * Renderizza immagine item
 */
function renderItemImage(item) {
    if (item.tipo_item === 'video_youtube') {
        return `<img src="${item.video_youtube_thumbnail}" class="card-img-top" alt="Video" loading="lazy">`;
    }

    if (item.tipo_immagine === 'arasaac' && item.id_arasaac) {
        const id_arasaac = typeof item.id_arasaac === 'string' ? parseInt(item.id_arasaac) : item.id_arasaac;

        // Debug log
        console.debug('ARASAAC Image Debug:', {
            id_arasaac: item.id_arasaac,
            id_arasaac_parsed: id_arasaac,
            tipo_immagine: item.tipo_immagine
        });

        if (id_arasaac && !isNaN(id_arasaac)) {
            const url = arasaacService.getPictogramUrl(id_arasaac, 300);
            return `<img src="${url}" class="card-img-top" alt="ARASAAC" loading="lazy" onerror="console.error('Errore caricamento immagine ARASAAC:', this.src)">`;
        }
    }

    if (item.tipo_immagine === 'upload' && item.url_immagine) {
        return `<img src="${item.url_immagine}" class="card-img-top" alt="Immagine" loading="lazy">`;
    }

    return `<div class="text-center py-4 bg-light"><i class="bi bi-image fs-1 text-muted"></i></div>`;
}

/**
 * Renderizza badge item
 */
function renderItemBadges(item) {
    let badges = `<span class="badge bg-primary">${item.tipo_item}</span> `;

    if (item.tipo_item === 'link_agenda') {
        badges += `<span class="badge bg-success"><i class="bi bi-link"></i> ${item.nome_agenda_collegata || 'Agenda'}</span>`;
    }

    return `<div class="mt-2">${badges}</div>`;
}

/**
 * Gestisce riordinamento item
 * Supporta sia API reale che localStorage per anonimo
 */
async function handleReorder(evt) {
    const container = document.getElementById('listaItems');
    const itemElements = container.querySelectorAll('[data-id]');

    const reorderedItems = Array.from(itemElements).map((el, index) => ({
        id_item: parseInt(el.dataset.id),
        posizione: index
    }));

    try {
        // Se anonimo, aggiorna in localStorage
        if (appState.selectedPaziente === 'anonimo') {
            const itemsKey = `items_anonimo_${appState.selectedAgenda}`;
            const items = JSON.parse(localStorage.getItem(itemsKey) || '[]');

            // Aggiorna posizioni
            reorderedItems.forEach(reordered => {
                const item = items.find(i => i.id_item === reordered.id_item);
                if (item) {
                    item.posizione = reordered.posizione;
                }
            });

            // Salva in localStorage
            localStorage.setItem(itemsKey, JSON.stringify(items));

            console.log('Item anonimo riordinati:', items);

        } else {
            // Usa API per pazienti reali
            await apiClient.reorderItems(reorderedItems);
        }

        showAlert('Ordine aggiornato', 'success');

    } catch (error) {
        console.error('Errore riordinamento:', error);
        showAlert('Errore riordinamento', 'danger');
    }
}

// ========== MODALE CREA AGENDA ==========

/**
 * Apri modale creazione agenda
 */
function openCreateAgendaModal() {
    if (!appState.selectedPaziente) {
        showAlert('Seleziona prima un paziente', 'warning');
        return;
    }

    document.getElementById('inputNomeAgenda').value = '';
    document.getElementById('radioPrincipale').checked = true;
    document.getElementById('selectParentAgendaContainer').style.display = 'none';

    modalCreaAgenda.show();
}

/**
 * Toggle select agenda parent
 */
function toggleParentAgendaSelect() {
    const isSottomenu = document.getElementById('radioSottomenu').checked;
    const container = document.getElementById('selectParentAgendaContainer');

    if (isSottomenu) {
        container.style.display = 'block';
        // Popola select con agende esistenti
        const select = document.getElementById('selectParentAgenda');
        select.innerHTML = '<option value="">-- Seleziona --</option>' +
            appState.agende.map(a => `<option value="${a.id_agenda}">${a.nome_agenda}</option>`).join('');
    } else {
        container.style.display = 'none';
    }
}

/**
 * Crea nuova agenda
 */
async function createAgenda() {
    const nome = document.getElementById('inputNomeAgenda').value.trim();
    const isSottomenu = document.getElementById('radioSottomenu').checked;
    const idParent = isSottomenu ? document.getElementById('selectParentAgenda').value : null;

    if (!nome) {
        showAlert('Inserisci il nome dell\'agenda', 'warning');
        return;
    }

    if (isSottomenu && !idParent) {
        showAlert('Seleziona l\'agenda genitore', 'warning');
        return;
    }

    try {
        // Gestione "anonimo" (solo localStorage, no database)
        if (appState.selectedPaziente === 'anonimo') {
            const agendeAnonimo = JSON.parse(localStorage.getItem('agende_anonimo') || '[]');

            const newAgenda = {
                id_agenda: Date.now(), // ID temporaneo
                nome_agenda: nome,
                tipo_agenda: isSottomenu ? 'sottomenu' : 'principale',
                id_agenda_parent: idParent ? parseInt(idParent) : null,
                num_items: 0
            };

            agendeAnonimo.push(newAgenda);
            localStorage.setItem('agende_anonimo', JSON.stringify(agendeAnonimo));

            modalCreaAgenda.hide();
            showAlert('Agenda test creata (localStorage)', 'success');
            loadAgende();
            return;
        }

        // Creazione normale su database
        const idEducatore = appState.currentUser?.id_registrazione || 1;

        await apiClient.createAgenda(
            nome,
            appState.selectedPaziente,
            idEducatore,
            idParent ? parseInt(idParent) : null
        );

        modalCreaAgenda.hide();
        showAlert('Agenda creata con successo', 'success');
        loadAgende();

    } catch (error) {
        console.error('Errore creazione agenda:', error);
        showAlert('Errore creazione agenda', 'danger');
    }
}

// ========== MODALE AGGIUNGI ITEM ==========

/**
 * Apri modale aggiungi item
 */
function openAddItemModal() {
    if (!appState.selectedAgenda) {
        showAlert('Seleziona prima un\'agenda', 'warning');
        return;
    }

    // Reset form
    document.getElementById('inputTitoloItem').value = '';
    document.getElementById('inputFraseTTS').value = '';  // Reset frase TTS
    document.getElementById('radioItemSemplice').checked = true;
    document.getElementById('radioArasaac').checked = true;
    document.getElementById('inputSearchArasaac').value = '';
    document.getElementById('arasaacResults').innerHTML = '';
    document.getElementById('selectedArasaacId').value = '';

    updateItemTypeFields();
    updateImageTypeFields();

    modalAggiungiItem.show();
}

/**
 * Aggiorna visibilità campi in base al tipo item
 */
function updateItemTypeFields() {
    const tipo = document.querySelector('input[name="tipoItem"]:checked').value;

    document.getElementById('fieldLinkAgenda').style.display = tipo === 'link_agenda' ? 'block' : 'none';
    document.getElementById('fieldVideoYoutube').style.display = tipo === 'video_youtube' ? 'block' : 'none';
    document.getElementById('fieldImmagine').style.display = tipo === 'video_youtube' ? 'none' : 'block';

    // Popola select agende per link
    if (tipo === 'link_agenda') {
        const select = document.getElementById('selectAgendaCollegata');
        select.innerHTML = '<option value="">-- Seleziona --</option>' +
            appState.agende.map(a => `<option value="${a.id_agenda}">${a.nome_agenda}</option>`).join('');
    }

    // Reset immagine se video
    if (tipo === 'video_youtube') {
        updateImageTypeFields();
    }
}

/**
 * Aggiorna visibilità campi immagine
 */
function updateImageTypeFields() {
    const tipo = document.querySelector('input[name="tipoImmagine"]:checked')?.value || 'nessuna';

    document.getElementById('fieldArasaac').style.display = tipo === 'arasaac' ? 'block' : 'none';
    document.getElementById('fieldUpload').style.display = tipo === 'upload' ? 'block' : 'none';
}

// ========== RICERCA ARASAAC ==========

/**
 * Cerca pittogrammi ARASAAC
 */
function searchArasaac() {
    const query = document.getElementById('inputSearchArasaac').value;

    arasaacService.searchWithDebounce(query, (results) => {
        const container = document.getElementById('arasaacResults');

        if (results.length === 0) {
            container.innerHTML = '<p class="text-muted">Nessun risultato</p>';
            return;
        }

        container.innerHTML = results.map(p => `
            <div class="arasaac-item" onclick="selectArasaac(${p.id})">
                <img src="${p.thumbnail}" alt="Pittogramma">
            </div>
        `).join('');
    });
}

/**
 * Seleziona pittogramma ARASAAC
 */
function selectArasaac(id) {
    document.getElementById('selectedArasaacId').value = id;

    // Visual feedback
    document.querySelectorAll('.arasaac-item').forEach(el => el.classList.remove('selected'));
    event.currentTarget.classList.add('selected');
}

// ========== RICERCA YOUTUBE ==========

/**
 * Cerca video YouTube
 */
async function searchYoutube() {
    const query = document.getElementById('inputSearchYoutube').value.trim();

    if (!query) return;

    try {
        const results = await youtubeService.searchVideos(query, 6);
        const container = document.getElementById('youtubeResults');

        if (results.length === 0) {
            container.innerHTML = '<p class="text-muted">Nessun risultato</p>';
            return;
        }

        container.innerHTML = results.map(v => `
            <div class="youtube-item" onclick='selectYoutube(${JSON.stringify(v).replace(/'/g, "&apos;")})'>
                <img src="${v.thumbnail.medium}" alt="${v.title}">
                <div class="youtube-item-info">
                    <strong>${v.title.substring(0, 50)}${v.title.length > 50 ? '...' : ''}</strong>
                    <small class="text-muted">${v.channelTitle}</small>
                </div>
            </div>
        `).join('');

    } catch (error) {
        console.error('Errore ricerca YouTube:', error);
        showAlert('Errore ricerca video', 'danger');
    }
}

/**
 * Seleziona video YouTube
 */
function selectYoutube(video) {
    document.getElementById('selectedYoutubeId').value = video.id;
    document.getElementById('selectedYoutubeTitle').value = video.title;
    document.getElementById('selectedYoutubeThumbnail').value = video.thumbnail.high;

    // Visual feedback
    document.querySelectorAll('.youtube-item').forEach(el => el.classList.remove('selected'));
    event.currentTarget.classList.add('selected');
}

// ========== CREA ITEM ==========

/**
 * Crea nuovo item
 * Supporta sia API reale che localStorage per anonimo
 */
async function createItem() {
    const titolo = document.getElementById('inputTitoloItem').value.trim();
    const fraseTTS = document.getElementById('inputFraseTTS').value.trim();
    const tipoItem = document.querySelector('input[name="tipoItem"]:checked').value;

    if (!titolo) {
        showAlert('Inserisci il titolo', 'warning');
        return;
    }

    if (!fraseTTS) {
        showAlert('Inserisci la frase da pronunciare (TTS)', 'warning');
        return;
    }

    const itemData = {
        id_agenda: appState.selectedAgenda,
        tipo_item: tipoItem,
        titolo: titolo,
        fraseVocale: fraseTTS  // Aggiungi frase TTS
    };

    try {
        // Gestione tipo item specifico
        if (tipoItem === 'link_agenda') {
            const idCollegata = document.getElementById('selectAgendaCollegata').value;
            if (!idCollegata) {
                showAlert('Seleziona l\'agenda da collegare', 'warning');
                return;
            }
            itemData.id_agenda_collegata = parseInt(idCollegata);
            itemData.tipo_immagine = 'nessuna';

        } else if (tipoItem === 'video_youtube') {
            const youtubeId = document.getElementById('selectedYoutubeId').value;
            if (!youtubeId) {
                showAlert('Seleziona un video YouTube', 'warning');
                return;
            }
            itemData.video_youtube_id = youtubeId;
            itemData.video_youtube_title = document.getElementById('selectedYoutubeTitle').value;
            itemData.video_youtube_thumbnail = document.getElementById('selectedYoutubeThumbnail').value;

        } else {
            // Item semplice - gestione immagine
            const tipoImmagine = document.querySelector('input[name="tipoImmagine"]:checked').value;
            itemData.tipo_immagine = tipoImmagine;

            if (tipoImmagine === 'arasaac') {
                const arasaacId = document.getElementById('selectedArasaacId').value;
                if (arasaacId) {
                    itemData.id_arasaac = parseInt(arasaacId);
                    console.log('DEBUG: ARASAAC selezionato - ID:', itemData.id_arasaac);
                } else {
                    console.log('DEBUG: ARASAAC selezionato ma nessun ID trovato!');
                }
            } else if (tipoImmagine === 'upload') {
                const fileInput = document.getElementById('inputFileImmagine');
                if (fileInput.files.length > 0) {
                    // Upload immagine
                    const uploadResult = await apiClient.uploadImage(fileInput.files[0]);
                    itemData.url_immagine = uploadResult.url;
                }
            }
        }

        // Crea item - Se anonimo usa localStorage, altrimenti API
        if (appState.selectedPaziente === 'anonimo') {
            // Carica item anonimo da localStorage
            const itemsKey = `items_anonimo_${appState.selectedAgenda}`;
            const items = JSON.parse(localStorage.getItem(itemsKey) || '[]');

            // Crea ID temporaneo
            const newItem = {
                id_item: Date.now(),
                ...itemData,
                posizione: items.length,
                data_creazione: new Date().toLocaleString('it-IT')
            };

            // Aggiungi alla lista
            items.push(newItem);

            // Salva in localStorage
            localStorage.setItem(itemsKey, JSON.stringify(items));

            console.log('Item anonimo creato:', newItem);

        } else {
            // Crea su API per pazienti reali
            console.log('DEBUG: Invio item al backend:', itemData);
            await apiClient.createItem(itemData);
        }

        modalAggiungiItem.hide();
        showAlert('Item aggiunto con successo', 'success');

        // Ricarica item
        selectAgenda(appState.selectedAgenda);

    } catch (error) {
        console.error('Errore creazione item:', error);
        showAlert('Errore creazione item: ' + error.message, 'danger');
    }
}

// ========== ELIMINAZIONE ==========

/**
 * Elimina agenda
 * Supporta sia API reale che localStorage per anonimo
 */
async function deleteAgenda() {
    if (!appState.selectedAgenda) return;

    if (!confirm('Sei sicuro di voler eliminare questa agenda?')) return;

    try {
        // Se anonimo, elimina da localStorage
        if (appState.selectedPaziente === 'anonimo') {
            let agendeAnonimo = JSON.parse(localStorage.getItem('agende_anonimo') || '[]');

            // Filtra per rimuovere l'agenda
            agendeAnonimo = agendeAnonimo.filter(a => a.id_agenda !== appState.selectedAgenda);

            // Salva in localStorage
            localStorage.setItem('agende_anonimo', JSON.stringify(agendeAnonimo));

            // Elimina anche i suoi item
            localStorage.removeItem(`items_anonimo_${appState.selectedAgenda}`);

            console.log('Agenda anonimo eliminata:', appState.selectedAgenda);

        } else {
            // Elimina da API per pazienti reali
            await apiClient.deleteAgenda(appState.selectedAgenda);
        }

        showAlert('Agenda eliminata', 'success');
        hideAgendaContent();
        loadAgende();

    } catch (error) {
        console.error('Errore eliminazione agenda:', error);
        showAlert('Errore eliminazione agenda', 'danger');
    }
}

/**
 * Elimina item
 * Supporta sia API reale che localStorage per anonimo
 */
async function deleteItem(idItem) {
    if (!confirm('Sei sicuro di voler eliminare questo item?')) return;

    try {
        // Se anonimo, elimina da localStorage
        if (appState.selectedPaziente === 'anonimo') {
            const itemsKey = `items_anonimo_${appState.selectedAgenda}`;
            let items = JSON.parse(localStorage.getItem(itemsKey) || '[]');

            // Filtra per rimuovere l'item
            items = items.filter(i => i.id_item !== idItem);

            // Riassegna posizioni
            items.forEach((item, index) => {
                item.posizione = index;
            });

            // Salva in localStorage
            localStorage.setItem(itemsKey, JSON.stringify(items));

            console.log('Item anonimo eliminato:', idItem);

        } else {
            // Elimina da API per pazienti reali
            await apiClient.deleteItem(idItem);
        }

        showAlert('Item eliminato', 'success');
        selectAgenda(appState.selectedAgenda);

    } catch (error) {
        console.error('Errore eliminazione item:', error);
        showAlert('Errore eliminazione item', 'danger');
    }
}

// ========== UTILITY ==========

/**
 * Mostra alert
 */
function showAlert(message, type = 'info') {
    const alertHtml = `
        <div class="alert alert-${type} alert-dismissible fade show position-fixed top-0 start-50 translate-middle-x mt-3" role="alert" style="z-index: 9999;">
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;

    document.body.insertAdjacentHTML('beforeend', alertHtml);

    // Auto-remove dopo 3 secondi
    setTimeout(() => {
        const alert = document.querySelector('.alert');
        if (alert) {
            alert.remove();
        }
    }, 3000);
}

/**
 * Mostra alert di login richiesto
 */
function showLoginAlert() {
    const alertHtml = `
        <div class="alert alert-warning alert-dismissible fade show position-fixed top-50 start-50 translate-middle" role="alert" style="z-index: 9999; min-width: 400px;">
            <h5 class="alert-heading"><i class="bi bi-exclamation-triangle"></i> Login Richiesto</h5>
            <p class="mb-2">Per accedere alla gestione educatore è necessario effettuare il login.</p>
            <hr>
            <div class="d-grid gap-2">
                <a href="/login.html" class="btn btn-primary">
                    <i class="bi bi-box-arrow-in-right"></i> Vai al Login
                </a>
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="alert">
                    Chiudi
                </button>
            </div>
        </div>
    `;

    document.body.insertAdjacentHTML('beforeend', alertHtml);
}
