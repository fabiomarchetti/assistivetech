/**
 * Logica Applicazione Paziente - Comunicatore
 * Con griglia adattiva (1-4 items) e navigazione swipe
 */

// Inizializza API Client
const apiClient = new ApiClient();

// Stato applicazione
const appState = {
    pazienteSelezionato: null, // ID completo con prefisso: "local-1" o "server-123"
    pazienteId: null, // ID numerico puro per le query API/DB
    pagine: [],
    currentPageIndex: 0,
    touchStartX: 0,
    touchStartY: 0,
    isSwiping: false,
    ttsEnabled: true,
    isOnlineMode: true, // true = server, false = locale
    pagineStack: [], // Stack per navigazione sottopagine (torna indietro)
    swipeHandlers: [] // Array di SwipeHandler per ogni item
};

/**
 * Inizializzazione app
 */
async function init() {
    console.log('🚀 Inizializzazione Comunicatore Paziente HYBRID...');

    // Inizializza IndexedDB locale
    await localDB.init();

    // Carica pazienti (server + locali)
    await loadPazienti();

    // Nascondi home button su schermata selezione
    document.getElementById('btnHome').style.display = 'none';

    console.log('✅ App inizializzata in modalità HYBRID');
}

/**
 * Carica lista pazienti (SERVER + LOCALI)
 */
async function loadPazienti() {
    const select = document.getElementById('selectUser');
    select.innerHTML = '<option value="">-- Seleziona Utente --</option>';

    let totalePazienti = 0;

    // Prova a caricare pazienti dal SERVER
    try {
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
        console.log(`📡 Caricamento pazienti da: ${apiPath}`);
        const response = await fetch(apiPath);
        const data = await response.json();

        if (data.success && data.data.length > 0) {
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
        }
    } catch (error) {
        console.warn('⚠️ Server non raggiungibile, funzionamento in LOCALE:', error);
    }

    // Carica utenti LOCALI da IndexedDB
    try {
        const utentiLocali = await localDB.listUtenti();

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
        select.innerHTML = '<option value="">Nessun utente trovato - Vai in Gestione Educatore</option>';
    }
}

/**
 * Seleziona utente e carica pagine (HYBRID)
 */
async function selectUser() {
    const select = document.getElementById('selectUser');
    const selectedValue = select.value;

    if (!selectedValue) {
        alert('Seleziona un utente');
        return;
    }

    // Determina modalità (server o local)
    const [mode, idString] = selectedValue.split('-');
    const id = parseInt(idString);

    // Mantieni valore completo con prefisso per riconoscere utenti locali
    appState.pazienteSelezionato = selectedValue; // es: "local-1" o "server-123"
    appState.pazienteId = id; // ID numerico per le query
    appState.isOnlineMode = (mode === 'server');

    // Mostra loading
    showScreen('screenLoading');

    try {
        let pagine;

        if (appState.isOnlineMode) {
            // Modalità SERVER
            pagine = await apiClient.listPagine(id);

            if (!pagine || pagine.length === 0) {
                showError('Nessuna pagina disponibile per questo utente');
                return;
            }

            // Carica items per ogni pagina
            for (let pagina of pagine) {
                pagina.items = await apiClient.listItems(pagina.id_pagina);
            }

        } else {
            // Modalità LOCALE
            pagine = await localDB.listPagine(id);

            if (!pagine || pagine.length === 0) {
                showError('Nessuna pagina disponibile per questo utente');
                return;
            }

            // Carica items per ogni pagina
            for (let pagina of pagine) {
                pagina.items = await localDB.listItems(pagina.id_pagina);
            }
        }

        appState.pagine = pagine;
        appState.currentPageIndex = 0;

        // Renderizza pagine
        renderPagine();

        // Mostra schermata pagine
        showScreen('screenPagine');

        // Mostra home button
        document.getElementById('btnHome').style.display = 'flex';

        // Setup swipe
        setupSwipe();

        // Mostra hint swipe (se più di 1 pagina)
        if (appState.pagine.length > 1) {
            showSwipeHint();
        }

    } catch (error) {
        console.error('Errore caricamento pagine:', error);
        showError('Errore nel caricamento delle pagine: ' + error.message);
    }
}

/**
 * Renderizza tutte le pagine
 */
function renderPagine() {
    const container = document.getElementById('pagesContainer');
    const indicators = document.getElementById('pageIndicators');

    console.log('📄 Renderizzazione pagine:', appState.pagine.length);
    
    // Pulisci handlers precedenti
    cleanupSwipeHandlers();
    
    // Render pagine (tutte insieme, ma solo una visibile)
    container.innerHTML = appState.pagine.map((pagina, index) => {
        console.log(`  Pagina ${index}: "${pagina.nome_pagina}" con ${pagina.items?.length || 0} items`);
        return renderPagina(pagina, index);
    }).join('');

    console.log('✅ HTML pagine inserito, children:', container.children.length);

    // Render indicatori
    indicators.innerHTML = appState.pagine.map((_, index) => {
        return `<div class="page-indicator ${index === appState.currentPageIndex ? 'active' : ''}" data-page="${index}"></div>`;
    }).join('');
    
    // Posiziona pagina corrente DOPO il render
    setTimeout(() => {
        updatePagePosition();
        // Attacca SwipeHandler su ogni item
        attachItemHandlers();
        // Aggiorna visibilità bottone "Indietro"
        updateBackButton();
    }, 50);
}

/**
 * Renderizza singola pagina con griglia adattiva
 */
function renderPagina(pagina, pageIndex) {
    const items = pagina.items || [];
    const numItems = items.length;

    // Determina layout in base al numero di items
    let layoutClass = 'layout-1';
    if (numItems === 2) layoutClass = 'layout-2';
    else if (numItems === 3) layoutClass = 'layout-3';
    else if (numItems >= 4) layoutClass = 'layout-4';

    // Limita a 4 items max
    const visibleItems = items.slice(0, 4);

    // Classe active solo per la pagina corrente
    const activeClass = pageIndex === appState.currentPageIndex ? 'active' : '';

    return `
        <div class="page ${activeClass}" data-page-index="${pageIndex}">
            <div class="page-header">
                <h2 class="page-title">${escapeHtml(pagina.nome_pagina)}</h2>
                ${pagina.descrizione ? `<p class="page-description">${escapeHtml(pagina.descrizione)}</p>` : ''}
            </div>

            <div class="griglia-comunicatore ${layoutClass}">
                ${visibleItems.map(item => renderItem(item)).join('')}
            </div>
        </div>
    `;
}

/**
 * Renderizza singolo item
 */
function renderItem(item) {
    let imageHtml = '';

    // Genera URL immagine
    if (item.tipo_immagine === 'arasaac' && item.id_arasaac) {
        const url = arasaacService.getPictogramUrl(item.id_arasaac, 500);
        imageHtml = `<img src="${url}" class="item-image" alt="${escapeHtml(item.titolo)}">`;
    } else if (item.tipo_immagine === 'upload' && item.url_immagine) {
        imageHtml = `<img src="${item.url_immagine}" class="item-image" alt="${escapeHtml(item.titolo)}">`;
    }

    // Icona sottopagina se è di tipo sottopagina
    const sottopaginaIcon = item.tipo_item === 'sottopagina' ? 
        '<div class="sottopagina-badge">🔗</div>' : '';

    return `
        <div class="item-box" 
             data-item-id="${item.id_item}"
             data-frase="${escapeHtml(item.frase_tts)}"
             data-tipo="${item.tipo_item || 'normale'}"
             data-pagina-rif="${item.id_pagina_riferimento || ''}"
             style="background-color: ${item.colore_sfondo};">
            ${imageHtml}
            <h3 class="item-label" style="color: ${item.colore_testo};">
                ${escapeHtml(item.titolo)}
            </h3>
            ${sottopaginaIcon}
        </div>
    `;
}

/**
 * Pronuncia frase TTS
 */
function speakItem(idItem, fraseTTS) {
    if (!appState.ttsEnabled || !fraseTTS) return;

    // Effetto visivo
    const itemBox = document.querySelector(`[data-item-id="${idItem}"]`);
    if (itemBox) {
        itemBox.classList.add('speaking');
        setTimeout(() => {
            itemBox.classList.remove('speaking');
        }, 2000);
    }

    // TTS
    if ('speechSynthesis' in window) {
        // Ferma TTS precedente
        speechSynthesis.cancel();

        const utterance = new SpeechSynthesisUtterance(fraseTTS);
        utterance.lang = 'it-IT';
        utterance.rate = 0.9;
        utterance.pitch = 1.0;
        utterance.volume = 1.0;

        utterance.onend = () => {
            if (itemBox) itemBox.classList.remove('speaking');
        };

        utterance.onerror = (e) => {
            console.error('Errore TTS:', e);
            if (itemBox) itemBox.classList.remove('speaking');
        };

        speechSynthesis.speak(utterance);

        // Log utilizzo (SOLO per utenti server, NON per utenti locali)
        const isLocalUser = appState.pazienteSelezionato && appState.pazienteSelezionato.toString().startsWith('local-');

        if (!isLocalUser && idItem && idItem !== 'null' && idItem !== 'undefined' && appState.pazienteId) {
            // Utente server -> logga su database (usa ID numerico)
            apiClient.logItem(idItem, appState.pazienteId, Date.now().toString())
                .catch(error => {
                    console.warn('⚠️ Errore log item (non bloccante):', error.message);
                });
        } else if (isLocalUser) {
            console.log('📴 Utente locale - log saltato (dati già in IndexedDB)');
        }

    } else {
        console.warn('TTS non supportato dal browser');
    }
}

/**
 * Setup navigazione swipe
 */
function setupSwipe() {
    const container = document.getElementById('pagesContainer');

    // Touch events
    container.addEventListener('touchstart', handleTouchStart, { passive: true });
    container.addEventListener('touchmove', handleTouchMove, { passive: false });
    container.addEventListener('touchend', handleTouchEnd, { passive: true });

    // Mouse events (per desktop)
    container.addEventListener('mousedown', handleMouseDown);
    container.addEventListener('mousemove', handleMouseMove);
    container.addEventListener('mouseup', handleMouseUp);
    container.addEventListener('mouseleave', handleMouseUp);
}

/**
 * Touch Start
 */
function handleTouchStart(e) {
    if (appState.pagine.length <= 1) return;

    appState.touchStartX = e.touches[0].clientX;
    appState.touchStartY = e.touches[0].clientY;
    appState.isSwiping = false;
}

/**
 * Touch Move
 */
function handleTouchMove(e) {
    if (appState.pagine.length <= 1) return;

    const touchX = e.touches[0].clientX;
    const touchY = e.touches[0].clientY;
    const deltaX = touchX - appState.touchStartX;
    const deltaY = touchY - appState.touchStartY;

    // Determina se è swipe orizzontale
    if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 10) {
        appState.isSwiping = true;
        e.preventDefault(); // Previeni scroll verticale
    }
}

/**
 * Touch End
 */
function handleTouchEnd(e) {
    console.log('👆 Touch End');
    console.log('  isSwiping:', appState.isSwiping);
    console.log('  pagine.length:', appState.pagine.length);
    
    if (appState.pagine.length <= 1 || !appState.isSwiping) {
        appState.isSwiping = false;
        return;
    }

    const touchX = e.changedTouches[0].clientX;
    const deltaX = touchX - appState.touchStartX;

    console.log('  deltaX:', deltaX);
    console.log('  currentPageIndex:', appState.currentPageIndex);

    // Soglia minima per swipe
    if (Math.abs(deltaX) > 50) {
        if (deltaX > 0) {
            // Swipe right -> pagina precedente (loop)
            const newIndex = appState.currentPageIndex - 1;
            const targetIndex = newIndex < 0 ? appState.pagine.length - 1 : newIndex;
            console.log('⬅️ Swipe RIGHT -> pagina precedente:', targetIndex);
            changePage(targetIndex);
        } else if (deltaX < 0) {
            // Swipe left -> pagina successiva (loop)
            const newIndex = appState.currentPageIndex + 1;
            const targetIndex = newIndex >= appState.pagine.length ? 0 : newIndex;
            console.log('➡️ Swipe LEFT -> pagina successiva:', targetIndex);
            changePage(targetIndex);
        }
    } else {
        console.log('⚠️ Swipe troppo corto:', Math.abs(deltaX), 'px');
    }

    appState.isSwiping = false;
}

/**
 * Mouse Down (desktop)
 */
function handleMouseDown(e) {
    if (appState.pagine.length <= 1) return;

    appState.touchStartX = e.clientX;
    appState.touchStartY = e.clientY;
    appState.isSwiping = false;
}

/**
 * Mouse Move (desktop)
 */
function handleMouseMove(e) {
    if (appState.pagine.length <= 1 || e.buttons !== 1) return;

    const deltaX = e.clientX - appState.touchStartX;
    const deltaY = e.clientY - appState.touchStartY;

    if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 10) {
        appState.isSwiping = true;
    }
}

/**
 * Mouse Up (desktop)
 */
function handleMouseUp(e) {
    console.log('🖱️ Mouse Up');
    console.log('  isSwiping:', appState.isSwiping);
    
    if (appState.pagine.length <= 1 || !appState.isSwiping) {
        appState.isSwiping = false;
        return;
    }

    const deltaX = e.clientX - appState.touchStartX;
    console.log('  deltaX:', deltaX);
    console.log('  currentPageIndex:', appState.currentPageIndex);

    if (Math.abs(deltaX) > 50) {
        if (deltaX > 0) {
            // Drag right -> pagina precedente (loop)
            const newIndex = appState.currentPageIndex - 1;
            const targetIndex = newIndex < 0 ? appState.pagine.length - 1 : newIndex;
            console.log('⬅️ Mouse Drag RIGHT -> pagina precedente:', targetIndex);
            changePage(targetIndex);
        } else if (deltaX < 0) {
            // Drag left -> pagina successiva (loop)
            const newIndex = appState.currentPageIndex + 1;
            const targetIndex = newIndex >= appState.pagine.length ? 0 : newIndex;
            console.log('➡️ Mouse Drag LEFT -> pagina successiva:', targetIndex);
            changePage(targetIndex);
        }
    } else {
        console.log('⚠️ Drag troppo corto:', Math.abs(deltaX), 'px');
    }

    appState.isSwiping = false;
}

/**
 * Cambia pagina
 */
function changePage(newIndex) {
    if (newIndex < 0 || newIndex >= appState.pagine.length) return;

    console.log(`📄 Cambio pagina: ${appState.currentPageIndex} → ${newIndex}`);
    appState.currentPageIndex = newIndex;
    updatePagePosition();
    updatePageIndicators();
}

/**
 * Aggiorna visualizzazione pagine (con classi CSS)
 */
function updatePagePosition() {
    const pages = document.querySelectorAll('.page');
    
    console.log(`🔄 Aggiornamento pagine, index: ${appState.currentPageIndex}`);
    
    pages.forEach((page, index) => {
        page.classList.remove('active', 'prev', 'next');
        
        if (index === appState.currentPageIndex) {
            page.classList.add('active');
            console.log(`  ✅ Pagina ${index}: ACTIVE`);
        } else if (index < appState.currentPageIndex) {
            page.classList.add('prev');
            console.log(`  ⬅️ Pagina ${index}: PREV`);
        } else {
            page.classList.add('next');
            console.log(`  ➡️ Pagina ${index}: NEXT`);
        }
    });
}

/**
 * Aggiorna indicatori pagina
 */
function updatePageIndicators() {
    const indicators = document.querySelectorAll('.page-indicator');
    indicators.forEach((indicator, index) => {
        if (index === appState.currentPageIndex) {
            indicator.classList.add('active');
        } else {
            indicator.classList.remove('active');
        }
    });
}

/**
 * Mostra hint swipe
 */
function showSwipeHint() {
    const hint = document.getElementById('swipeHint');
    hint.classList.add('show');

    setTimeout(() => {
        hint.classList.remove('show');
    }, 3000);
}

/**
 * Torna alla schermata selezione utente
 */
function goHome() {
    // Reset stato
    appState.pazienteSelezionato = null;
    appState.pazienteId = null;
    appState.pagine = [];
    appState.currentPageIndex = 0;

    // Ferma TTS
    if ('speechSynthesis' in window) {
        speechSynthesis.cancel();
    }

    // Nascondi home button
    document.getElementById('btnHome').style.display = 'none';

    // Mostra schermata selezione
    showScreen('screenUserSelect');
}

/**
 * Mostra screen
 */
function showScreen(screenId) {
    const screens = document.querySelectorAll('.screen');
    screens.forEach(screen => {
        screen.classList.remove('active');
    });

    document.getElementById(screenId).classList.add('active');
}

/**
 * Mostra errore
 */
function showError(message) {
    document.getElementById('errorMessage').textContent = message;
    showScreen('screenError');
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

// ========== GESTIONE SOTTOPAGINE (LONG-CLICK) ==========

/**
 * Pulisce tutti gli SwipeHandler precedenti
 */
function cleanupSwipeHandlers() {
    appState.swipeHandlers.forEach(handler => {
        if (handler && handler.destroy) {
            handler.destroy();
        }
    });
    appState.swipeHandlers = [];
}

/**
 * Attacca handler su ogni item per click semplice
 * Permette propagazione eventi per swipe pagine
 */
function attachItemHandlers() {
    const items = document.querySelectorAll('.item-box');
    
    items.forEach(itemElement => {
        let startX = 0;
        let startY = 0;
        let isSwipeGesture = false;
        
        // Touch Start
        const handleTouchStart = (e) => {
            const touch = e.touches[0];
            startX = touch.clientX;
            startY = touch.clientY;
            isSwipeGesture = false;
        };
        
        // Touch Move - rileva swipe
        const handleTouchMove = (e) => {
            const touch = e.touches[0];
            const deltaX = Math.abs(touch.clientX - startX);
            const deltaY = Math.abs(touch.clientY - startY);
            
            // Se è swipe orizzontale significativo
            if (deltaX > 30 && deltaX > deltaY) {
                isSwipeGesture = true;
            }
        };
        
        // Touch End
        const handleTouchEnd = (e) => {
            // Solo se NON è swipe
            if (!isSwipeGesture) {
                e.stopPropagation(); // Blocca solo per il tap
                handleItemTap(itemElement);
            }
        };
        
        // Mouse (desktop)
        const handleMouseDown = (e) => {
            startX = e.clientX;
            startY = e.clientY;
            isSwipeGesture = false;
        };
        
        const handleMouseMove = (e) => {
            const deltaX = Math.abs(e.clientX - startX);
            const deltaY = Math.abs(e.clientY - startY);
            
            // Rileva drag orizzontale
            if (deltaX > 30 && deltaX > deltaY && e.buttons === 1) {
                isSwipeGesture = true;
            }
        };
        
        const handleMouseUp = (e) => {
            // Solo se NON è swipe
            if (!isSwipeGesture) {
                e.stopPropagation();
                handleItemTap(itemElement);
            }
        };
        
        // Attacca eventi (NON passive per permettere stopPropagation)
        itemElement.addEventListener('touchstart', handleTouchStart);
        itemElement.addEventListener('touchmove', handleTouchMove);
        itemElement.addEventListener('touchend', handleTouchEnd);
        itemElement.addEventListener('mousedown', handleMouseDown);
        itemElement.addEventListener('mousemove', handleMouseMove);
        itemElement.addEventListener('mouseup', handleMouseUp);
        
        // Salva cleanup
        appState.swipeHandlers.push({
            destroy: () => {
                itemElement.removeEventListener('touchstart', handleTouchStart);
                itemElement.removeEventListener('touchmove', handleTouchMove);
                itemElement.removeEventListener('touchend', handleTouchEnd);
                itemElement.removeEventListener('mousedown', handleMouseDown);
                itemElement.removeEventListener('mousemove', handleMouseMove);
                itemElement.removeEventListener('mouseup', handleMouseUp);
            }
        });
    });
    
    console.log(`✅ Attaccati handler a ${items.length} item`);
}

/**
 * Gestisce TAP su item (pronuncia TTS + naviga se sottopagina)
 */
async function handleItemTap(itemElement) {
    const fraseTTS = itemElement.getAttribute('data-frase');
    const itemId = itemElement.getAttribute('data-item-id');
    const tipoItem = itemElement.getAttribute('data-tipo');
    const idPaginaRif = itemElement.getAttribute('data-pagina-rif');

    console.log(`👆 TAP su item ${itemId} - Tipo: ${tipoItem}, Pagina Rif: ${idPaginaRif}`);

    // Avvia sempre TTS
    speakItem(itemId, fraseTTS);

    // Se è sottopagina, naviga immediatamente (mentre TTS parla)
    if (tipoItem === 'sottopagina' && idPaginaRif && idPaginaRif !== '' && idPaginaRif !== 'null') {
        console.log(`  🔗 Navigazione a sottopagina ${idPaginaRif}`);
        
        // Feedback visivo
        itemElement.classList.add('navigating');
        setTimeout(() => itemElement.classList.remove('navigating'), 300);
        
        // Salva stato corrente nello stack
        appState.pagineStack.push({
            paziente: appState.pazienteSelezionato,
            pageIndex: appState.currentPageIndex,
            pagine: [...appState.pagine] // Salva copia delle pagine correnti
        });
        
        console.log(`  📚 Stack aggiornato, depth: ${appState.pagineStack.length}`);
        
        // Carica la pagina riferimento
        try {
            console.log(`  🔍 Cercando pagina ${idPaginaRif} per utente ${appState.pazienteId}`);

            // Carica tutte le pagine per trovare quella riferimento
            let pagineRif;
            if (appState.isOnlineMode) {
                pagineRif = await apiClient.listPagine(appState.pazienteId);
            } else {
                pagineRif = await localDB.listPagine(appState.pazienteId);
            }

            console.log(`  📄 Pagine trovate: ${pagineRif.length}`, pagineRif.map(p => `${p.id_pagina}: ${p.nome_pagina}`));

            // Trova la pagina specifica (confronto flessibile string/number)
            const paginaRif = pagineRif.find(p => p.id_pagina == idPaginaRif || String(p.id_pagina) === String(idPaginaRif));
            
            if (!paginaRif) {
                alert('Pagina di riferimento non trovata');
                appState.pagineStack.pop();
                return;
            }
            
            // Carica items della sottopagina
            console.log(`  📦 Caricando items per pagina ${idPaginaRif}...`);
            let items;
            if (appState.isOnlineMode) {
                items = await apiClient.listItems(idPaginaRif);
            } else {
                items = await localDB.listItems(idPaginaRif);
            }

            console.log(`  📦 Items caricati: ${items.length}`);
            paginaRif.items = items;

            // Sostituisci le pagine con la sottopagina
            appState.pagine = [paginaRif];
            appState.currentPageIndex = 0;

            console.log(`  🎨 Rendering sottopagina...`);

            // Ri-renderizza
            renderPagine();

            console.log(`  ✅ Caricata sottopagina: "${paginaRif.nome_pagina}" con ${items.length} items`);
            
        } catch (error) {
            console.error('❌ Errore navigazione sottopagina:', error);
            alert('Errore nel caricamento della sottopagina');
            appState.pagineStack.pop();
        }
    }
}

/**
 * Torna alla pagina precedente (pop dallo stack)
 */
async function goBackToPreviousPage() {
    if (appState.pagineStack.length === 0) {
        console.log('⚠️ Stack vuoto, nessuna pagina precedente');
        return;
    }
    
    const previous = appState.pagineStack.pop();
    console.log(`⬅️ Torna indietro, stack depth: ${appState.pagineStack.length}`);
    
    // Ripristina le pagine salvate
    appState.pagine = previous.pagine;
    appState.currentPageIndex = previous.pageIndex;
    
    // Ri-renderizza
    renderPagine();
}

/**
 * Aggiorna visibilità bottone "Indietro"
 */
function updateBackButton() {
    const backBtn = document.getElementById('btnBack');
    if (backBtn) {
        backBtn.style.display = appState.pagineStack.length > 0 ? 'block' : 'none';
    }
}

// Inizializza al caricamento DOM
document.addEventListener('DOMContentLoaded', init);

