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
        const response = await fetch('/Assistivetech/api/get_pazienti.php');
        const data = await response.json();

        if (data.success && data.data.length > 0) {
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

            updateBadgeModalita('online');
        }
    } catch (error) {
        console.warn('⚠️ Server non raggiungibile, modalità LOCALE:', error);
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
        document.getElementById('listaPagine').innerHTML = `
            <div class="text-center py-3 text-muted">
                <i class="bi bi-inbox fs-1"></i>
                <p class="mb-0">Seleziona un utente</p>
            </div>`;
        return;
    }

    // Determina modalità (server o local)
    const [mode, idString] = selectedValue.split('-');
    const id = parseInt(idString);

    appState.pazienteSelezionato = id;
    appState.isOnlineMode = (mode === 'server');

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
 * Renderizza lista pagine
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

    container.innerHTML = pagine.map(pagina => `
        <div class="list-group-item pagina-card ${appState.paginaSelezionata == pagina.id_pagina ? 'active' : ''}"
             onclick="selectPagina(${pagina.id_pagina})">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="mb-1">${escapeHtml(pagina.nome_pagina)}</h6>
                    <small class="text-muted">
                        <i class="bi bi-grid-3x3"></i> ${pagina.num_items || 0} item
                    </small>
                </div>
                <span class="badge bg-primary">#${pagina.numero_ordine + 1}</span>
            </div>
        </div>
    `).join('');
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
        alert('Pagina creata con successo!');

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
function openAddItemModal(posizione) {
    if (!appState.paginaSelezionata) return;

    // Reset form
    document.getElementById('editItemId').value = '';
    document.getElementById('itemPosizione').value = posizione;
    document.getElementById('inputTitoloItem').value = '';
    document.getElementById('inputFraseTTS').value = '';
    document.getElementById('radioArasaac').checked = true;
    document.getElementById('inputColoreSfondo').value = '#FFFFFF';
    document.getElementById('inputColoreTesto').value = '#000000';
    document.getElementById('coloreSfondoValue').textContent = '#FFFFFF';
    document.getElementById('coloreTestoValue').textContent = '#000000';
    document.getElementById('arasaacResults').innerHTML = '';
    document.getElementById('selectedArasaacId').value = '';
    document.getElementById('selectedArasaacUrl').value = '';
    document.getElementById('uploadPreview').innerHTML = '';

    document.getElementById('modalItemTitle').textContent = `Aggiungi Item - Posizione ${posizione}`;
    document.getElementById('modalItemPosizione').textContent = posizione;

    updateImageTypeFields();
    appState.modalItem.show();
}

/**
 * Apri modal modifica item
 */
function openEditItemModal(item) {
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

    document.getElementById('modalItemTitle').textContent = `Modifica Item - Posizione ${item.posizione_griglia}`;
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

    // Prepara dati
    const itemData = {
        id_pagina: appState.paginaSelezionata,
        posizione_griglia: posizione,
        titolo,
        frase_tts: fraseTTS,
        tipo_immagine: tipoImmagine,
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

// Inizializza al caricamento DOM
document.addEventListener('DOMContentLoaded', init);

