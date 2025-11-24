/**
 * App Educatore - Rispondo con gli Occhi
 * Gestione domande e ricerca ARASAAC
 */

// === STATO GLOBALE === //
const appState = {
    domande: [],
    idEducatore: 1, // TODO: Ottenere da sessione/autenticazione
    modalInstance: null,
    immagineSelezionata: {
        sinistra: null,
        destra: null
    }
};

// === INIZIALIZZAZIONE === //
document.addEventListener('DOMContentLoaded', () => {
    init();
});

const init = async () => {
    // Inizializza modal Bootstrap
    appState.modalElement = document.getElementById('modalNuovaDomanda');
    appState.modalInstance = new bootstrap.Modal(appState.modalElement);
    
    // Carica domande esistenti
    await caricaDomande();
    
    // Setup event listeners
    setupEventListeners();
    
    // Carica nome educatore (simulato)
    document.getElementById('nomeEducatore').textContent = 'Educatore Demo';
};

// === SETUP EVENT LISTENERS === //
const setupEventListeners = () => {
    // Ricerca ARASAAC con debounce
    document.getElementById('ricercaSinistra').addEventListener('input', (e) => {
        const query = e.target.value.trim();
        arasaacService.searchWithDebounce(query, (results) => {
            mostraRisultatiArasaac('sinistra', results);
        });
    });
    
    document.getElementById('ricercaDestra').addEventListener('input', (e) => {
        const query = e.target.value.trim();
        arasaacService.searchWithDebounce(query, (results) => {
            mostraRisultatiArasaac('destra', results);
        });
    });
    
    // Previeni submit del form
    document.getElementById('formDomanda').addEventListener('submit', (e) => {
        e.preventDefault();
        console.log('🔴 Form submit bloccato');
        return false;
    });
    
    // Salva domanda
    document.getElementById('btnSalvaDomanda').addEventListener('click', (e) => {
        e.preventDefault();
        console.log('🟢 Click su Salva Domanda');
        salvaDomanda();
    });
    
    // Ricerca domande locale
    document.getElementById('cercaDomande').addEventListener('input', (e) => {
        filtraDomande(e.target.value);
    });
    
    // Filtro tipo domanda
    document.getElementById('filtroTipo').addEventListener('change', (e) => {
        filtraDomandePerTipo(e.target.value);
    });
    
    // Reset modal quando si chiude
    appState.modalElement.addEventListener('hidden.bs.modal', resetModal);
};

// === CARICAMENTO DOMANDE === //
const caricaDomande = async () => {
    try {
        showLoading(true);
        
        const response = await fetch(`api/domande.php?id_educatore=${appState.idEducatore}`);
        const data = await response.json();
        
        if (data.success) {
            appState.domande = data.data || [];
            renderDomande(appState.domande);
            aggiornaStatistiche();
        } else {
            mostraErrore('Errore nel caricamento delle domande');
        }
    } catch (error) {
        console.error('Errore caricamento domande:', error);
        mostraErrore('Errore di connessione al server');
    } finally {
        showLoading(false);
    }
};

// === RENDER DOMANDE === //
const renderDomande = (domande) => {
    const container = document.getElementById('listaDomande');
    const nessunaDomanda = document.getElementById('nessunaDomanda');
    
    if (domande.length === 0) {
        container.style.display = 'none';
        nessunaDomanda.style.display = 'block';
        return;
    }
    
    nessunaDomanda.style.display = 'none';
    container.style.display = 'flex';
    container.innerHTML = '';
    
    domande.forEach(domanda => {
        const card = creaDomandaCard(domanda);
        container.appendChild(card);
    });
};

// === CREA CARD DOMANDA === //
const creaDomandaCard = (domanda) => {
    const col = document.createElement('div');
    col.className = 'col-12 col-lg-6 fade-in';
    
    // Badge tipo domanda
    let badgeClass = 'bg-primary';
    let badgeText = 'SI/NO';
    
    if (domanda.tipo_domanda === 'scelta_immagini') {
        badgeClass = 'bg-info';
        badgeText = 'Immagini';
    } else if (domanda.tipo_domanda === 'colori') {
        badgeClass = 'bg-warning';
        badgeText = 'Colori';
    }
    
    col.innerHTML = `
        <div class="card card-domanda">
            <div class="card-header d-flex justify-content-between align-items-center">
                <span>
                    <i class="bi bi-chat-quote"></i> Domanda #${domanda.id_domanda}
                </span>
                <span class="badge ${badgeClass} badge-tipo">${badgeText}</span>
            </div>
            <div class="card-body">
                <div class="domanda-testo">
                    "${domanda.testo_domanda}"
                </div>
                
                <div class="opzioni-container">
                    <!-- Opzione Sinistra -->
                    <div class="opzione-box sinistra">
                        <div class="opzione-etichetta text-primary">
                            <i class="bi bi-arrow-left"></i> ${domanda.etichetta_sinistra}
                        </div>
                        ${domanda.immagine_sinistra_url ? 
                            `<img src="${domanda.immagine_sinistra_url}" alt="${domanda.etichetta_sinistra}" class="opzione-immagine">` : 
                            '<small class="text-muted">Nessuna immagine</small>'
                        }
                    </div>
                    
                    <!-- Opzione Destra -->
                    <div class="opzione-box destra">
                        <div class="opzione-etichetta text-success">
                            ${domanda.etichetta_destra} <i class="bi bi-arrow-right"></i>
                        </div>
                        ${domanda.immagine_destra_url ? 
                            `<img src="${domanda.immagine_destra_url}" alt="${domanda.etichetta_destra}" class="opzione-immagine">` : 
                            '<small class="text-muted">Nessuna immagine</small>'
                        }
                    </div>
                </div>
                
                <!-- Info aggiuntive -->
                <div class="mt-3 text-muted small">
                    <i class="bi bi-calendar"></i> ${formattaData(domanda.data_creazione)}
                </div>
            </div>
            <div class="card-footer bg-transparent">
                <div class="btn-action-group">
                    <button class="btn btn-sm btn-outline-primary btn-action" onclick="modificaDomanda(${domanda.id_domanda})">
                        <i class="bi bi-pencil"></i> Modifica
                    </button>
                    <button class="btn btn-sm btn-outline-danger btn-action" onclick="eliminaDomanda(${domanda.id_domanda})">
                        <i class="bi bi-trash"></i> Elimina
                    </button>
                    <button class="btn btn-sm btn-outline-info btn-action" onclick="visualizzaRisposte(${domanda.id_domanda})">
                        <i class="bi bi-graph-up"></i> Risposte
                    </button>
                </div>
            </div>
        </div>
    `;
    
    return col;
};

// === RICERCA ARASAAC === //
const mostraRisultatiArasaac = (lato, results) => {
    const containerId = lato === 'sinistra' ? 'risultatiSinistra' : 'risultatiDestra';
    const container = document.getElementById(containerId);
    
    if (results.length === 0) {
        container.style.display = 'none';
        return;
    }
    
    container.style.display = 'grid';
    container.innerHTML = '';
    
    results.forEach(pictogram => {
        const item = document.createElement('div');
        item.className = 'arasaac-item';
        item.innerHTML = `<img src="${pictogram.thumbnail}" alt="Pittogramma ${pictogram.id}">`;
        item.onclick = () => selezionaImmagine(lato, pictogram);
        container.appendChild(item);
    });
};

// === SELEZIONE IMMAGINE === //
const selezionaImmagine = (lato, pictogram) => {
    console.log(`🖼️ Selezione immagine ${lato}:`, pictogram);
    
    appState.immagineSelezionata[lato] = pictogram;
    
    // Mostra preview
    const previewId = `preview${lato.charAt(0).toUpperCase() + lato.slice(1)}`;
    const imgId = `img${lato.charAt(0).toUpperCase() + lato.slice(1)}`;
    const urlId = `url${lato.charAt(0).toUpperCase() + lato.slice(1)}`;
    const idArasaacId = `idArasaac${lato.charAt(0).toUpperCase() + lato.slice(1)}`;
    
    console.log(`   Preview ID: ${previewId}`);
    console.log(`   URL ID: ${urlId}`);
    console.log(`   Input esiste?`, document.getElementById(urlId) !== null);
    
    document.getElementById(previewId).style.display = 'block';
    document.getElementById(imgId).src = pictogram.url;
    document.getElementById(urlId).value = pictogram.url;
    document.getElementById(idArasaacId).value = pictogram.id;
    
    console.log(`   ✅ Valore impostato:`, document.getElementById(urlId).value);
    
    // Nascondi risultati
    const risultatiId = `risultati${lato.charAt(0).toUpperCase() + lato.slice(1)}`;
    document.getElementById(risultatiId).style.display = 'none';
    
    // Pulisci campo ricerca
    const ricercaId = `ricerca${lato.charAt(0).toUpperCase() + lato.slice(1)}`;
    document.getElementById(ricercaId).value = '';
};

// === RIMUOVI IMMAGINE === //
const rimuoviImmagine = (lato) => {
    appState.immagineSelezionata[lato] = null;
    
    const previewId = `preview${lato.charAt(0).toUpperCase() + lato.slice(1)}`;
    const urlId = `url${lato.charAt(0).toUpperCase() + lato.slice(1)}`;
    const idArasaacId = `idArasaac${lato.charAt(0).toUpperCase() + lato.slice(1)}`;
    
    document.getElementById(previewId).style.display = 'none';
    document.getElementById(urlId).value = '';
    document.getElementById(idArasaacId).value = '';
};

// === SALVA DOMANDA === //
const salvaDomanda = async () => {
    console.log('🔵 salvaDomanda chiamata');
    
    const idDomanda = document.getElementById('idDomandaEdit').value;
    const testoDomanda = document.getElementById('testoDomanda').value.trim();
    const etichettaSinistra = document.getElementById('etichettaSinistra').value.trim();
    const etichettaDestra = document.getElementById('etichettaDestra').value.trim();
    
    console.log('📝 Valori form:', { idDomanda, testoDomanda, etichettaSinistra, etichettaDestra });
    
    // Validazione
    if (!testoDomanda) {
        alert('Inserisci il testo della domanda');
        return;
    }
    
    // Leggi valori immagini (converti stringhe vuote in null)
    const urlSinistra = document.getElementById('urlSinistra').value.trim();
    const idSinistra = document.getElementById('idArasaacSinistra').value.trim();
    const urlDestra = document.getElementById('urlDestra').value.trim();
    const idDestra = document.getElementById('idArasaacDestra').value.trim();
    
    console.log('🔍 Lettura valori input hidden:');
    console.log('   urlSinistra:', urlSinistra || '(vuoto)');
    console.log('   urlDestra:', urlDestra || '(vuoto)');
    console.log('   idSinistra:', idSinistra || '(vuoto)');
    console.log('   idDestra:', idDestra || '(vuoto)');
    
    const domandaData = {
        id_educatore: appState.idEducatore,
        testo_domanda: testoDomanda,
        tipo_domanda: 'scelta_immagini', // Sempre scelta_immagini
        etichetta_sinistra: etichettaSinistra || 'NO',
        etichetta_destra: etichettaDestra || 'SI',
        immagine_sinistra_url: urlSinistra || null,
        immagine_sinistra_id: idSinistra || null,
        immagine_destra_url: urlDestra || null,
        immagine_destra_id: idDestra || null
    };
    
    // Se è una modifica, aggiungi l'ID
    if (idDomanda) {
        domandaData.id_domanda = parseInt(idDomanda);
    }
    
    // Debug: mostra cosa viene inviato
    console.log('📤 Dati domanda da salvare:', domandaData);
    console.log('   URL Sinistra:', domandaData.immagine_sinistra_url);
    console.log('   URL Destra:', domandaData.immagine_destra_url);
    
    try {
        // Usa PUT se è una modifica, POST se è nuova
        const method = idDomanda ? 'PUT' : 'POST';
        const response = await fetch('api/domande.php', {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(domandaData)
        });
        
        const data = await response.json();
        
        if (data.success) {
            mostraSuccesso(idDomanda ? 'Domanda modificata con successo!' : 'Domanda salvata con successo!');
            appState.modalInstance.hide();
            await caricaDomande();
        } else {
            mostraErrore(data.error || 'Errore nel salvataggio');
        }
    } catch (error) {
        console.error('Errore salvataggio:', error);
        mostraErrore('Errore di connessione al server');
    }
};

// === ELIMINA DOMANDA === //
const eliminaDomanda = async (id) => {
    if (!confirm('Sei sicuro di voler eliminare questa domanda?')) {
        return;
    }
    
    try {
        const response = await fetch(`api/domande.php?id=${id}`, { method: 'DELETE' });
        const data = await response.json();
        
        if (data.success) {
            mostraSuccesso('Domanda eliminata con successo!');
            await caricaDomande();
        } else {
            mostraErrore(data.error || 'Errore nell\'eliminazione');
        }
    } catch (error) {
        console.error('Errore eliminazione:', error);
        mostraErrore('Errore di connessione al server');
    }
};

// === MODIFICA DOMANDA === //
const modificaDomanda = async (id) => {
    // Trova la domanda da modificare
    const domanda = appState.domande.find(d => d.id_domanda == id);
    if (!domanda) {
        mostraErrore('Domanda non trovata');
        return;
    }
    
    console.log('✏️ Modifica domanda:', domanda);
    
    // Popola il form con i dati della domanda
    document.getElementById('idDomandaEdit').value = domanda.id_domanda;
    document.getElementById('testoDomanda').value = domanda.testo_domanda;
    document.getElementById('etichettaSinistra').value = domanda.etichetta_sinistra;
    document.getElementById('etichettaDestra').value = domanda.etichetta_destra;
    
    // Popola immagini sinistra
    if (domanda.immagine_sinistra_url) {
        document.getElementById('urlSinistra').value = domanda.immagine_sinistra_url;
        document.getElementById('idArasaacSinistra').value = domanda.immagine_sinistra_id || '';
        document.getElementById('imgSinistra').src = domanda.immagine_sinistra_url;
        document.getElementById('previewSinistra').style.display = 'block';
        appState.immagineSelezionata.sinistra = {
            url: domanda.immagine_sinistra_url,
            id: domanda.immagine_sinistra_id
        };
    }
    
    // Popola immagini destra
    if (domanda.immagine_destra_url) {
        document.getElementById('urlDestra').value = domanda.immagine_destra_url;
        document.getElementById('idArasaacDestra').value = domanda.immagine_destra_id || '';
        document.getElementById('imgDestra').src = domanda.immagine_destra_url;
        document.getElementById('previewDestra').style.display = 'block';
        appState.immagineSelezionata.destra = {
            url: domanda.immagine_destra_url,
            id: domanda.immagine_destra_id
        };
    }
    
    // Cambia titolo modal
    document.getElementById('titoloModal').innerHTML = '<i class="bi bi-pencil"></i> Modifica Domanda';
    
    // Apri modal
    appState.modalInstance.show();
};

// === VISUALIZZA RISPOSTE === //
const visualizzaRisposte = async (id) => {
    // TODO: Implementare visualizzazione risposte/statistiche
    alert('Funzionalità in sviluppo');
};

// === FILTRI === //
const filtraDomande = (query) => {
    query = query.toLowerCase().trim();
    
    if (!query) {
        renderDomande(appState.domande);
        return;
    }
    
    const filtrate = appState.domande.filter(d => 
        d.testo_domanda.toLowerCase().includes(query) ||
        d.etichetta_sinistra.toLowerCase().includes(query) ||
        d.etichetta_destra.toLowerCase().includes(query)
    );
    
    renderDomande(filtrate);
};

const filtraDomandePerTipo = (tipo) => {
    if (!tipo) {
        renderDomande(appState.domande);
        return;
    }
    
    const filtrate = appState.domande.filter(d => d.tipo_domanda === tipo);
    renderDomande(filtrate);
};

// === UTILITY === //
const showLoading = (show) => {
    document.getElementById('loadingDomande').style.display = show ? 'block' : 'none';
};

const aggiornaStatistiche = () => {
    const totali = appState.domande.length;
    const attive = appState.domande.filter(d => d.stato === 'attiva').length;
    
    document.getElementById('statTotali').textContent = totali;
    document.getElementById('statAttive').textContent = attive;
};

const formattaData = (dataStr) => {
    const data = new Date(dataStr);
    return data.toLocaleDateString('it-IT', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
};

const resetModal = () => {
    document.getElementById('formDomanda').reset();
    document.getElementById('idDomandaEdit').value = '';
    document.getElementById('previewSinistra').style.display = 'none';
    document.getElementById('previewDestra').style.display = 'none';
    document.getElementById('risultatiSinistra').style.display = 'none';
    document.getElementById('risultatiDestra').style.display = 'none';
    document.getElementById('titoloModal').innerHTML = '<i class="bi bi-plus-circle"></i> Nuova Domanda';
    appState.immagineSelezionata = { sinistra: null, destra: null };
};

const mostraSuccesso = (messaggio) => {
    // TODO: Implementare toast/notifica
    alert(messaggio);
};

const mostraErrore = (messaggio) => {
    // TODO: Implementare toast/notifica
    alert('Errore: ' + messaggio);
};

