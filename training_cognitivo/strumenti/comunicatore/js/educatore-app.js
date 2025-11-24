/**
 * Logica Applicazione Educatore - Comunicatore HYBRID
 * Funziona sia con database server che con IndexedDB locale (PWA offline)
 */

// Inizializza API Client
const apiClient = new ApiClient();

// Stato applicazione
const appState = {
    pazienteSelezionato: null,
    paginaSelezionata: null,
    items: [],
    modalPagina: null,
    modalItem: null,
    currentPosizioneEdit: null,
    isOnlineMode: true, // true = server, false = locale
    utentiLocali: [],
    utentiServer: []
};

/**
 * Inizializzazione app
 */
async function init() {
    console.log('🚀 Inizializzazione Educatore App HYBRID...');

    // Inizializza IndexedDB locale
    await localDB.init();

    // Inizializza modali
    appState.modalPagina = new bootstrap.Modal(document.getElementById('modalCreaPagina'));
    appState.modalItem = new bootstrap.Modal(document.getElementById('modalAggiungiItem'));

    // Carica utenti (sia server che locali)
    await loadPazienti();

    // Event listeners per color pickers
    document.getElementById('inputColoreSfondo').addEventListener('input', (e) => {
        document.getElementById('coloreSfondoValue').textContent = e.target.value;
    });

    document.getElementById('inputColoreTesto').addEventListener('input', (e) => {
        document.getElementById('coloreTestoValue').textContent = e.target.value;
    });

    console.log('✅ App inizializzata in modalità HYBRID');
}

/**
 * Carica lista pazienti (SERVER + LOCALI)
 */
async function loadPazienti() {
    const select = document.getElementById('selectPaziente');
    select.innerHTML = '<option value="">-- Seleziona Utente --</option>';

    let totalePazienti = 0;

    // Prova a caricare pazienti dal SERVER
    try {
        console.log('🔍 Tentativo caricamento utenti da server...');
        
        // Auto-rileva path in base all'HOSTNAME (più affidabile del pathname)
        const isLocal = (
            window.location.hostname === 'localhost' ||
            window.location.hostname === '127.0.0.1' ||
            window.location.hostname.startsWith('192.168.') ||
            window.location.hostname.startsWith('10.0.')
        );
        
        let apiPath;
        if (isLocal) {
            // MAMP locale
            apiPath = '/Assistivetech/api/get_pazienti.php';
        } else {
            // Aruba o produzione
            apiPath = '/api/get_pazienti.php';
        }
        
        console.log(`📡 Ambiente: ${isLocal ? 'LOCALE' : 'PRODUZIONE'}`);
        console.log(`📡 Tentativo caricamento utenti da: ${apiPath}`);
        const response = await fetch(apiPath);
        
        console.log('📡 Risposta server:', {
            status: response.status,
            ok: response.ok,
            url: response.url
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        console.log('📦 Dati ricevuti:', data);

        if (data.success && data.data && data.data.length > 0) {
            appState.utentiServer = data.data;

            // Aggiungi gruppo server
            const optgroupServer = document.createElement('optgroup');
            optgroupServer.label = '📡 Utenti Server';

            data.data.forEach(paziente => {
                const option = document.createElement('option');
                option.value = `server-${paziente.id_registrazione}`;
                option.textContent = paziente.username;
                option.dataset.mode = 'server';
                optgroupServer.appendChild(option);
            });

            select.appendChild(optgroupServer);
            totalePazienti += data.data.length;

            console.log(`✅ ${data.data.length} utenti server caricati`);
            updateBadgeModalita('online');
        } else {
            console.warn('⚠️ Nessun utente nel database server');
            updateBadgeModalita('offline');
        }
    } catch (error) {
        console.error('❌ Errore caricamento server:', error);
        console.error('🔍 Dettagli:', error.message);
        updateBadgeModalita('offline');
    }

    // Carica utenti LOCALI da IndexedDB
    try {
        const utentiLocali = await localDB.listUtenti();
        appState.utentiLocali = utentiLocali;

        if (utentiLocali.length > 0) {
            // Aggiungi gruppo locale
            const optgroupLocal = document.createElement('optgroup');
            optgroupLocal.label = '💾 Utenti Locali (PWA)';

            utentiLocali.forEach(utente => {
                const option = document.createElement('option');
                option.value = `local-${utente.id}`;
                option.textContent = utente.nome;
                option.dataset.mode = 'local';
                optgroupLocal.appendChild(option);
            });

            select.appendChild(optgroupLocal);
            totalePazienti += utentiLocali.length;
        }
    } catch (error) {
        console.error('Errore caricamento utenti locali:', error);
    }

    // Messaggio se nessun utente
    if (totalePazienti === 0) {
        select.innerHTML = '<option value="">Nessun utente trovato - Creane uno locale</option>';
    }
}

/**
 * Toggle campo nuovo utente
 */
function toggleNuovoUtente() {
    const container = document.getElementById('nuovoUtenteContainer');
    const input = document.getElementById('inputNuovoUtente');

    if (container.style.display === 'none') {
        container.style.display = 'block';
        input.focus();
    } else {
        container.style.display = 'none';
        input.value = '';
    }
}

/**
 * Crea utente locale
 */
async function creaUtenteLocale() {
    const input = document.getElementById('inputNuovoUtente');
    const nome = input.value.trim();

    if (!nome) {
        alert('Inserisci un nome per l\'utente');
        return;
    }

    try {
        // Salva in IndexedDB
        const utente = await localDB.saveUtente(nome);

        // Ricarica lista
        await loadPazienti();

        // Seleziona il nuovo utente
        document.getElementById('selectPaziente').value = `local-${utente.id}`;

        // Nascondi campo
        toggleNuovoUtente();

        // Trigger loadPagine
        await loadPagine();

        alert(`✅ Utente "${nome}" creato in locale!`);

    } catch (error) {
        console.error('Errore creazione utente locale:', error);
        alert('Errore: ' + error.message);
    }
}

/**
 * Aggiorna badge modalità
 */
function updateBadgeModalita(mode) {
    const badge = document.getElementById('badgeModalita');

    if (mode === 'online') {
        badge.className = 'badge bg-success';
        badge.innerHTML = '<i class="bi bi-wifi"></i> Modalità Online';
    } else {
        badge.className = 'badge bg-warning text-dark';
        badge.innerHTML = '<i class="bi bi-wifi-off"></i> Modalità Offline (Locale)';
    }
}

/**
 * Carica pagine del paziente selezionato
 */
async function loadPagine() {
    const select = document.getElementById('selectPaziente');
    const selectedValue = select.value;

    if (!selectedValue) {
        // Reset completo quando nessun utente selezionato
        appState.pazienteSelezionato = null;
        appState.paginaSelezionata = null;
        
        document.getElementById('listaPagine').innerHTML = `
            <div class="text-center py-3 text-muted">
                <i class="bi bi-inbox fs-1"></i>
                <p class="mb-0">Seleziona un utente</p>
            </div>`;
        
        // Nascondi contenuto pagina
        document.getElementById('noPaginaSelected').style.display = 'block';
        document.getElementById('paginaContent').style.display = 'none';
        
        return;
    }

    // Determina modalità (server o local)
    const [mode, idString] = selectedValue.split('-');
    const id = parseInt(idString);

    // RESET stato quando cambia utente
    const utenteChanged = (appState.pazienteSelezionato !== id);
    
    appState.pazienteSelezionato = id;
    appState.isOnlineMode = (mode === 'server');
    
    if (utenteChanged) {
        // Reset pagina selezionata quando cambia utente
        appState.paginaSelezionata = null;
        console.log('👤 Cambio utente rilevato → Reset pagina selezionata');
        
        // Nascondi contenuto pagina durante il caricamento
        document.getElementById('noPaginaSelected').style.display = 'block';
        document.getElementById('paginaContent').style.display = 'none';
    }

    try {
        let pagine;

        if (appState.isOnlineMode) {
            // Modalità SERVER
            pagine = await apiClient.listPagine(id);
        } else {
            // Modalità LOCALE
            pagine = await localDB.listPagine(id);
            
            // Aggiungi conteggio items
            for (let pagina of pagine) {
                const items = await localDB.listItems(pagina.id_pagina);
                pagina.num_items = items.length;
            }
        }

        renderPagineList(pagine);

    } catch (error) {
        console.error('Errore caricamento pagine:', error);
        alert('Errore nel caricamento delle pagine: ' + error.message);
    }
}

/**
 * Renderizza lista pagine con drag & drop per riordinamento
 */
function renderPagineList(pagine) {
    const container = document.getElementById('listaPagine');

    if (!pagine || pagine.length === 0) {
        container.innerHTML = `
            <div class="text-center py-3 text-muted">
                <i class="bi bi-inbox fs-1"></i>
                <p class="mb-0">Nessuna pagina creata</p>
                <button class="btn btn-sm btn-primary mt-2" onclick="openCreatePaginaModal()">
                    <i class="bi bi-plus-circle"></i> Crea Prima Pagina
                </button>
            </div>`;
        return;
    }

    // Salva le pagine nello stato per il riordinamento
    appState.currentPagine = [...pagine];

    container.innerHTML = pagine.map((pagina, index) => `
        <div class="list-group-item pagina-card ${appState.paginaSelezionata == pagina.id_pagina ? 'active' : ''}"
             draggable="true"
             data-pagina-id="${pagina.id_pagina}"
             data-index="${index}"
             ondragstart="handleDragStart(event)"
             ondragover="handleDragOver(event)"
             ondragenter="handleDragEnter(event)"
             ondragleave="handleDragLeave(event)"
             ondrop="handleDrop(event)"
             ondragend="handleDragEnd(event)">
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center">
                    <i class="bi bi-grip-vertical text-muted me-2" style="cursor: grab;"></i>
                    <div onclick="selectPagina(${pagina.id_pagina}); event.stopPropagation();" style="cursor: pointer;">
                        <h6 class="mb-1">${escapeHtml(pagina.nome_pagina)}</h6>
                        <small class="text-muted">
                            <i class="bi bi-grid-3x3"></i> ${pagina.num_items || 0} item
                        </small>
                    </div>
                </div>
                <span class="badge bg-primary">#${pagina.numero_ordine + 1}</span>
            </div>
        </div>
    `).join('');

    // Se non c'è nessuna pagina selezionata, seleziona automaticamente la prima
    if (pagine.length > 0 && !appState.paginaSelezionata) {
        selectPagina(pagine[0].id_pagina);
    }
}

/**
 * Seleziona pagina e carica items
 */
async function selectPagina(idPagina) {
    appState.paginaSelezionata = idPagina;

    try {
        let pagina;

        if (appState.isOnlineMode) {
            // Modalità SERVER
            pagina = await apiClient.getPagina(idPagina);
        } else {
            // Modalità LOCALE
            pagina = await localDB.getPagina(idPagina);
        }

        appState.items = pagina.items || [];

        // Aggiorna UI
        document.getElementById('paginaTitle').textContent = pagina.nome_pagina;
        document.getElementById('paginaDescrizione').textContent = pagina.descrizione || '';
        document.getElementById('noPaginaSelected').style.display = 'none';
        document.getElementById('paginaContent').style.display = 'block';

        // Renderizza griglia
        renderGriglia();

        // Aggiorna lista pagine (per highlight)
        loadPagine();

    } catch (error) {
        console.error('Errore caricamento pagina:', error);
        alert('Errore nel caricamento della pagina: ' + error.message);
    }
}

/**
 * Renderizza griglia 2x2 con items
 */
function renderGriglia() {
    const slots = document.querySelectorAll('.grid-slot');

    slots.forEach((slot, index) => {
        const posizione = index + 1;
        const item = appState.items.find(i => i.posizione_griglia == posizione);

        if (item) {
            // Slot occupato
            slot.className = 'grid-slot occupied';
            slot.onclick = () => openEditItemModal(item);

            let imageHtml = '';
            if (item.tipo_immagine === 'arasaac' && item.id_arasaac) {
                const url = arasaacService.getPictogramUrl(item.id_arasaac);
                imageHtml = `<img src="${url}" class="grid-slot-image" alt="${escapeHtml(item.titolo)}">`;
            } else if (item.tipo_immagine === 'upload' && item.url_immagine) {
                imageHtml = `<img src="${item.url_immagine}" class="grid-slot-image" alt="${escapeHtml(item.titolo)}">`;
            }

            slot.innerHTML = `
                <span class="grid-slot-number">${posizione}</span>
                <div class="grid-slot-actions">
                    <button class="btn btn-sm btn-danger" onclick="event.stopPropagation(); deleteItem(${item.id_item})">
                        <i class="bi bi-trash"></i>
                    </button>
                </div>
                ${imageHtml}
                <div class="grid-slot-label">${escapeHtml(item.titolo)}</div>
                <div class="grid-slot-tts">"${escapeHtml(item.frase_tts)}"</div>
            `;

            // Applica colori personalizzati
            slot.style.backgroundColor = item.colore_sfondo;
            slot.querySelector('.grid-slot-label').style.color = item.colore_testo;

        } else {
            // Slot vuoto
            slot.className = 'grid-slot';
            slot.onclick = () => openAddItemModal(posizione);
            slot.style.backgroundColor = '';

            slot.innerHTML = `
                <span class="grid-slot-number">${posizione}</span>
                <i class="bi bi-plus-circle grid-slot-add"></i>
                <small class="text-muted">Clicca per aggiungere</small>
            `;
        }
    });
}

/**
 * Apri modal crea pagina
 */
function openCreatePaginaModal() {
    if (!appState.pazienteSelezionato) {
        alert('Seleziona prima un utente');
        return;
    }

    document.getElementById('inputNomePagina').value = '';
    document.getElementById('inputDescrizionePagina').value = '';
    appState.modalPagina.show();
}

/**
 * Crea nuova pagina (HYBRID)
 */
async function createPagina() {
    const nome = document.getElementById('inputNomePagina').value.trim();
    const descrizione = document.getElementById('inputDescrizionePagina').value.trim();

    if (!nome) {
        alert('Inserisci un nome per la pagina');
        return;
    }

    try {
        if (appState.isOnlineMode) {
            // Modalità SERVER
            await apiClient.createPagina(nome, appState.pazienteSelezionato, 1, descrizione);
        } else {
            // Modalità LOCALE
            // Calcola prossimo numero ordine
            const pagine = await localDB.listPagine(appState.pazienteSelezionato);
            const numero_ordine = pagine.length;

            await localDB.createPagina({
                nome_pagina: nome,
                descrizione: descrizione,
                id_utente: appState.pazienteSelezionato,
                numero_ordine: numero_ordine
            });
        }

        appState.modalPagina.hide();
        await loadPagine();
        
        // Seleziona automaticamente la pagina appena creata
        let pagine;
        if (appState.isOnlineMode) {
            pagine = await apiClient.listPagine(appState.pazienteSelezionato);
        } else {
            pagine = await localDB.listPagine(appState.pazienteSelezionato);
        }
        
        // Seleziona l'ultima pagina creata
        if (pagine && pagine.length > 0) {
            const ultimaPagina = pagine[pagine.length - 1];
            await selectPagina(ultimaPagina.id_pagina);
        }
        
        alert('Pagina creata con successo! Ora puoi aggiungere items.');

    } catch (error) {
        console.error('Errore creazione pagina:', error);
        alert('Errore: ' + error.message);
    }
}

/**
 * Modifica pagina corrente
 */
async function modificaPagina() {
    if (!appState.paginaSelezionata) return;

    const nuovoNome = prompt('Nuovo nome pagina:', document.getElementById('paginaTitle').textContent);
    if (!nuovoNome) return;

    try {
        if (appState.isOnlineMode) {
            await apiClient.updatePagina(appState.paginaSelezionata, { nome_pagina: nuovoNome });
        } else {
            await localDB.updatePagina(appState.paginaSelezionata, { nome_pagina: nuovoNome });
        }

        document.getElementById('paginaTitle').textContent = nuovoNome;
        await loadPagine();

    } catch (error) {
        console.error('Errore modifica pagina:', error);
        alert('Errore: ' + error.message);
    }
}

/**
 * Elimina pagina corrente
 */
async function deletePagina() {
    if (!appState.paginaSelezionata) return;

    if (!confirm('Eliminare questa pagina e tutti i suoi item?')) return;

    try {
        if (appState.isOnlineMode) {
            await apiClient.deletePagina(appState.paginaSelezionata);
        } else {
            await localDB.deletePagina(appState.paginaSelezionata);
        }

        appState.paginaSelezionata = null;
        document.getElementById('noPaginaSelected').style.display = 'block';
        document.getElementById('paginaContent').style.display = 'none';
        await loadPagine();

    } catch (error) {
        console.error('Errore eliminazione pagina:', error);
        alert('Errore: ' + error.message);
    }
}

/**
 * Apri modal aggiungi item
 */
async function openAddItemModal(posizione) {
    console.log('🔵 openAddItemModal chiamato, posizione:', posizione);
    console.log('📄 Pagina selezionata:', appState.paginaSelezionata);
    
    if (!appState.paginaSelezionata) {
        console.warn('⚠️ Nessuna pagina selezionata!');
        return;
    }

    try {
        // Reset form con debug
        const elements = {
            'editItemId': document.getElementById('editItemId'),
            'itemPosizione': document.getElementById('itemPosizione'),
            'inputTitoloItem': document.getElementById('inputTitoloItem'),
            'inputFraseTTS': document.getElementById('inputFraseTTS'),
            'radioArasaac': document.getElementById('radioArasaac'),
            'inputColoreSfondo': document.getElementById('inputColoreSfondo'),
            'inputColoreTesto': document.getElementById('inputColoreTesto'),
            'coloreSfondoValue': document.getElementById('coloreSfondoValue'),
            'coloreTestoValue': document.getElementById('coloreTestoValue'),
            'arasaacResults': document.getElementById('arasaacResults'),
            'selectedArasaacId': document.getElementById('selectedArasaacId'),
            'selectedArasaacUrl': document.getElementById('selectedArasaacUrl'),
            'uploadPreview': document.getElementById('uploadPreview'),
            'modalItemAction': document.getElementById('modalItemAction'),
            'modalItemPosizione': document.getElementById('modalItemPosizione')
        };

        // Verifica che tutti gli elementi esistano
        for (const [key, element] of Object.entries(elements)) {
            if (!element) {
                console.error(`❌ Elemento "${key}" non trovato nel DOM!`);
                alert(`Errore: Elemento "${key}" mancante. Ricarica la pagina con CTRL+SHIFT+R`);
                return;
            }
        }

        console.log('✅ Tutti gli elementi trovati, reset form...');

        // Reset form
        elements.editItemId.value = '';
        elements.itemPosizione.value = posizione;
        elements.inputTitoloItem.value = '';
        elements.inputFraseTTS.value = '';
        elements.radioArasaac.checked = true;
        elements.inputColoreSfondo.value = '#FFFFFF';
        elements.inputColoreTesto.value = '#000000';
        elements.coloreSfondoValue.textContent = '#FFFFFF';
        elements.coloreTestoValue.textContent = '#000000';
        elements.arasaacResults.innerHTML = '';
        
        // Reset sottopagina
        document.getElementById('checkSottopagina').checked = false;
        document.getElementById('fieldPaginaRiferimento').style.display = 'none';
        document.getElementById('selectPaginaRiferimento').value = '';
        elements.selectedArasaacId.value = '';
        elements.selectedArasaacUrl.value = '';
        elements.uploadPreview.innerHTML = '';
        
        // Imposta azione e posizione (non cancellare l'intero title!)
        elements.modalItemAction.textContent = 'Aggiungi';
        elements.modalItemPosizione.textContent = posizione;

        console.log('✅ Form reset completato');

        updateImageTypeFields();
        
        // Popola dropdown pagine per sottopagina
        await populatePagineDropdown();
        
        console.log('🎬 Apertura modal...');
        appState.modalItem.show();
        console.log('✅ Modal aperto');

    } catch (error) {
        console.error('❌ Errore in openAddItemModal:', error);
        alert('Errore apertura modal: ' + error.message);
    }
}

/**
 * Apri modal modifica item
 */
async function openEditItemModal(item) {
    document.getElementById('editItemId').value = item.id_item;
    document.getElementById('itemPosizione').value = item.posizione_griglia;
    document.getElementById('inputTitoloItem').value = item.titolo;
    document.getElementById('inputFraseTTS').value = item.frase_tts;
    document.getElementById('inputColoreSfondo').value = item.colore_sfondo;
    document.getElementById('inputColoreTesto').value = item.colore_testo;
    document.getElementById('coloreSfondoValue').textContent = item.colore_sfondo;
    document.getElementById('coloreTestoValue').textContent = item.colore_testo;

    // Tipo immagine
    if (item.tipo_immagine === 'arasaac') {
        document.getElementById('radioArasaac').checked = true;
        document.getElementById('selectedArasaacId').value = item.id_arasaac || '';
        document.getElementById('selectedArasaacUrl').value = item.url_immagine || '';
    } else if (item.tipo_immagine === 'upload') {
        document.getElementById('radioUpload').checked = true;
        if (item.url_immagine) {
            document.getElementById('uploadPreview').innerHTML = 
                `<img src="${item.url_immagine}" alt="Preview">`;
        }
    } else {
        document.getElementById('radioNessuna').checked = true;
    }

    // Sottopagina
    const isSottopagina = item.tipo_item === 'sottopagina';
    document.getElementById('checkSottopagina').checked = isSottopagina;
    document.getElementById('fieldPaginaRiferimento').style.display = isSottopagina ? 'block' : 'none';
    
    // Popola dropdown e seleziona pagina riferimento
    await populatePagineDropdown();
    if (item.id_pagina_riferimento) {
        document.getElementById('selectPaginaRiferimento').value = item.id_pagina_riferimento;
    }

    // Imposta azione e posizione (non cancellare l'intero title!)
    document.getElementById('modalItemAction').textContent = 'Modifica';
    document.getElementById('modalItemPosizione').textContent = item.posizione_griglia;

    updateImageTypeFields();
    appState.modalItem.show();
}

/**
 * Aggiorna campi visibili in base al tipo immagine
 */
function updateImageTypeFields() {
    const tipoImmagine = document.querySelector('input[name="tipoImmagine"]:checked').value;

    document.getElementById('fieldArasaac').style.display = tipoImmagine === 'arasaac' ? 'block' : 'none';
    document.getElementById('fieldUpload').style.display = tipoImmagine === 'upload' ? 'block' : 'none';
}

/**
 * Toggle campo selezione pagina di riferimento
 */
function toggleSottopaginaField() {
    const checkbox = document.getElementById('checkSottopagina');
    const field = document.getElementById('fieldPaginaRiferimento');
    field.style.display = checkbox.checked ? 'block' : 'none';
    
    // Reset selezione se disattivo
    if (!checkbox.checked) {
        document.getElementById('selectPaginaRiferimento').value = '';
    }
}

/**
 * Popola dropdown pagine disponibili (esclusa la pagina corrente)
 */
async function populatePagineDropdown() {
    const select = document.getElementById('selectPaginaRiferimento');
    select.innerHTML = '<option value="">-- Seleziona Pagina --</option>';
    
    if (!appState.pazienteSelezionato) return;
    
    try {
        let pagine;
        if (appState.isOnlineMode) {
            pagine = await apiClient.listPagine(appState.pazienteSelezionato);
        } else {
            pagine = await localDB.listPagine(appState.pazienteSelezionato);
        }
        
        // Escludi la pagina corrente (non può riferire a se stessa)
        pagine = pagine.filter(p => p.id_pagina !== appState.paginaSelezionata);
        
        pagine.forEach(pagina => {
            const option = document.createElement('option');
            option.value = pagina.id_pagina;
            option.textContent = pagina.nome_pagina;
            select.appendChild(option);
        });
        
        console.log(`✅ Dropdown popolato con ${pagine.length} pagine`);
    } catch (error) {
        console.error('❌ Errore caricamento pagine per dropdown:', error);
    }
}

/**
 * Cerca pittogrammi ARASAAC
 */
function searchArasaac() {
    const query = document.getElementById('inputSearchArasaac').value.trim();

    if (!query) {
        document.getElementById('arasaacResults').innerHTML = '';
        return;
    }

    arasaacService.searchWithDebounce(query, (results) => {
        renderArasaacResults(results);
    });
}

/**
 * Renderizza risultati ARASAAC
 */
function renderArasaacResults(results) {
    const container = document.getElementById('arasaacResults');

    if (!results || results.length === 0) {
        container.innerHTML = '<p class="text-muted text-center p-3">Nessun risultato</p>';
        return;
    }

    container.innerHTML = results.map(item => `
        <div class="arasaac-item" onclick="selectArasaac(${item.id}, '${item.url}')">
            <img src="${item.thumbnail}" alt="ID: ${item.id}">
            <div class="arasaac-item-id">ID: ${item.id}</div>
        </div>
    `).join('');
}

/**
 * Seleziona pittogramma ARASAAC
 */
function selectArasaac(id, url) {
    document.getElementById('selectedArasaacId').value = id;
    document.getElementById('selectedArasaacUrl').value = url;

    // Highlight selezione
    document.querySelectorAll('.arasaac-item').forEach(item => {
        item.classList.remove('selected');
    });
    event.currentTarget.classList.add('selected');
}

/**
 * Preview immagine uploadata
 */
function previewUploadImage() {
    const file = document.getElementById('inputFileImmagine').files[0];
    const preview = document.getElementById('uploadPreview');

    if (!file) {
        preview.innerHTML = '';
        return;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
        preview.innerHTML = `<img src="${e.target.result}" alt="Preview">`;
    };
    reader.readAsDataURL(file);
}

/**
 * Salva item (crea o modifica) - HYBRID
 */
async function saveItem() {
    const idItem = document.getElementById('editItemId').value;
    const posizione = parseInt(document.getElementById('itemPosizione').value);
    const titolo = document.getElementById('inputTitoloItem').value.trim();
    const fraseTTS = document.getElementById('inputFraseTTS').value.trim();
    const tipoImmagine = document.querySelector('input[name="tipoImmagine"]:checked').value;
    const coloreSfondo = document.getElementById('inputColoreSfondo').value;
    const coloreTesto = document.getElementById('inputColoreTesto').value;

    // Validazione
    if (!titolo || !fraseTTS) {
        alert('Inserisci titolo e frase TTS');
        return;
    }

    // Sottopagina
    const isSottopagina = document.getElementById('checkSottopagina').checked;
    const idPaginaRiferimento = document.getElementById('selectPaginaRiferimento').value;
    
    // Validazione sottopagina
    if (isSottopagina && !idPaginaRiferimento) {
        alert('Seleziona una pagina di riferimento per la sottopagina');
        return;
    }

    // Prepara dati
    const itemData = {
        id_pagina: appState.paginaSelezionata,
        posizione_griglia: posizione,
        titolo,
        frase_tts: fraseTTS,
        tipo_immagine: tipoImmagine,
        tipo_item: isSottopagina ? 'sottopagina' : 'normale',
        id_pagina_riferimento: isSottopagina ? parseInt(idPaginaRiferimento) : null,
        colore_sfondo: coloreSfondo,
        colore_testo: coloreTesto
    };

    // Gestione immagine
    if (tipoImmagine === 'arasaac') {
        const idArasaac = document.getElementById('selectedArasaacId').value;
        const urlArasaac = document.getElementById('selectedArasaacUrl').value;

        if (!idArasaac) {
            alert('Seleziona un pittogramma ARASAAC');
            return;
        }

        itemData.id_arasaac = parseInt(idArasaac);
        itemData.url_immagine = urlArasaac;

    } else if (tipoImmagine === 'upload') {
        const file = document.getElementById('inputFileImmagine').files[0];

        if (!idItem && !file) {
            alert('Seleziona un\'immagine da caricare');
            return;
        }

        if (file) {
            // Per locale: converti in Data URL
            if (!appState.isOnlineMode) {
                try {
                    const dataUrl = await fileToDataURL(file);
                    itemData.url_immagine = dataUrl;
                } catch (error) {
                    alert('Errore lettura immagine: ' + error.message);
                    return;
                }
            } else {
                // Per server: upload API
                try {
                    const uploadResult = await apiClient.uploadImage(file);
                    itemData.url_immagine = uploadResult.url;
                } catch (error) {
                    alert('Errore upload immagine: ' + error.message);
                    return;
                }
            }
        }
    }

    try {
        if (idItem) {
            // Modifica
            if (appState.isOnlineMode) {
                await apiClient.updateItem(parseInt(idItem), itemData);
            } else {
                await localDB.updateItem(parseInt(idItem), itemData);
            }
        } else {
            // Crea
            if (appState.isOnlineMode) {
                await apiClient.createItem(itemData);
            } else {
                await localDB.createItem(itemData);
            }
        }

        appState.modalItem.hide();
        await selectPagina(appState.paginaSelezionata);
        alert('Item salvato con successo!');

    } catch (error) {
        console.error('Errore salvataggio item:', error);
        alert('Errore: ' + error.message);
    }
}

/**
 * Elimina item
 */
async function deleteItem(idItem) {
    if (!confirm('Eliminare questo item?')) return;

    try {
        if (appState.isOnlineMode) {
            await apiClient.deleteItem(idItem);
        } else {
            await localDB.deleteItem(idItem);
        }

        await selectPagina(appState.paginaSelezionata);

    } catch (error) {
        console.error('Errore eliminazione item:', error);
        alert('Errore: ' + error.message);
    }
}

/**
 * Converti File in Data URL (per storage locale)
 */
function fileToDataURL(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target.result);
        reader.onerror = (e) => reject(e);
        reader.readAsDataURL(file);
    });
}

/**
 * Escape HTML (sicurezza XSS)
 */
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

// ========== DRAG & DROP PER RIORDINAMENTO PAGINE ==========

let dragState = {
    draggedElement: null,
    draggedIndex: null
};

/**
 * Gestisce l'inizio del drag
 */
function handleDragStart(event) {
    dragState.draggedElement = event.currentTarget;
    dragState.draggedIndex = parseInt(event.currentTarget.dataset.index);

    event.currentTarget.style.opacity = '0.5';
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/html', event.currentTarget.innerHTML);

    console.log('🔄 Drag iniziato - Index:', dragState.draggedIndex);
}

/**
 * Gestisce il drag over (necessario per permettere il drop)
 */
function handleDragOver(event) {
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
    return false;
}

/**
 * Gestisce l'ingresso su un elemento
 */
function handleDragEnter(event) {
    const target = event.currentTarget;
    if (target !== dragState.draggedElement) {
        target.classList.add('drag-over');
    }
}

/**
 * Gestisce l'uscita da un elemento
 */
function handleDragLeave(event) {
    event.currentTarget.classList.remove('drag-over');
}

/**
 * Gestisce il drop
 */
async function handleDrop(event) {
    event.stopPropagation();
    event.preventDefault();

    const target = event.currentTarget;
    target.classList.remove('drag-over');

    if (dragState.draggedElement !== target) {
        const newIndex = parseInt(target.dataset.index);
        console.log('🔄 Drop - Da index', dragState.draggedIndex, 'a index', newIndex);

        // Riordina l'array delle pagine
        const pagine = [...appState.currentPagine];
        const [removed] = pagine.splice(dragState.draggedIndex, 1);
        pagine.splice(newIndex, 0, removed);

        // Aggiorna i numero_ordine
        const ordini = pagine.map((pagina, index) => ({
            id_pagina: pagina.id_pagina,
            numero_ordine: index
        }));

        try {
            // Salva il nuovo ordine
            if (appState.isOnlineMode) {
                await apiClient.reorderPagine(ordini);
            } else {
                await localDB.reorderPagine(ordini);
            }

            // Ricarica la lista aggiornata
            await loadPagine();

            console.log('✅ Riordinamento completato');

        } catch (error) {
            console.error('❌ Errore riordinamento:', error);
            alert('Errore nel riordinamento: ' + error.message);
            await loadPagine(); // Ricarica comunque per ripristinare lo stato
        }
    }

    return false;
}

/**
 * Gestisce la fine del drag
 */
function handleDragEnd(event) {
    event.currentTarget.style.opacity = '1';

    // Rimuovi la classe drag-over da tutti gli elementi
    document.querySelectorAll('.pagina-card').forEach(card => {
        card.classList.remove('drag-over');
    });

    dragState.draggedElement = null;
    dragState.draggedIndex = null;
}

// Inizializza al caricamento DOM
document.addEventListener('DOMContentLoaded', init);

