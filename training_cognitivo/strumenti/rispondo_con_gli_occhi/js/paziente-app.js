/**
 * App Paziente - Rispondo con gli Occhi
 * Gestisce domande, TTS, eye tracking e salvataggio risposte
 */

// === STATO GLOBALE === //
const appPaziente = {
    // Utente
    idUtente: null,
    nomeUtente: '',
    
    // Domande
    domande: [],
    indiceDomandaCorrente: 0,
    domandaCorrente: null,
    
    // Eye Tracking
    dwellTime: 2000, // millisecondi per confermare risposta (2 secondi)
    dwellStartTime: null,
    dwellDirection: null,
    dwellProgress: 0,
    
    // TTS
    ttsVoice: null,
    ttsEnabled: true,
    
    // Stato
    isExerciseActive: false,
    startTime: null,
    risposte: [],
    
    // Monitor popup
    monitorWindow: null,
    
    // Flag per evitare risposte multiple
    rispostaRegistrata: false
};

// === INIZIALIZZAZIONE === //
document.addEventListener('DOMContentLoaded', () => {
    initApp();
});

const initApp = () => {
    // Carica utenti
    caricaUtenti();
    
    // Setup event listeners
    setupEventListeners();
    
    // Inizializza TTS
    initTTS();
};

// === SETUP EVENT LISTENERS === //
const setupEventListeners = () => {
    // Selezione utente
    document.getElementById('selezionaUtente').addEventListener('change', (e) => {
        appPaziente.idUtente = parseInt(e.target.value);
        appPaziente.nomeUtente = e.target.options[e.target.selectedIndex].text;
        document.getElementById('btnAvviaEsercizio').disabled = !appPaziente.idUtente;
    });
    
    // Avvia esercizio
    document.getElementById('btnAvviaEsercizio').addEventListener('click', avviaEsercizio);
    
    // Riproduci domanda
    document.getElementById('btnRiproduciDomanda').addEventListener('click', riproduciDomanda);
    
    // Termina
    document.getElementById('btnTermina').addEventListener('click', terminaEsercizio);
    
    // Torna all'area educatore
    document.getElementById('btnTornaEducatore').addEventListener('click', tornaAreaEducatore);
    
    // Ricomincia
    document.getElementById('btnRicomincia').addEventListener('click', ricominciaEsercizio);
};

// === CARICAMENTO UTENTI === //
const caricaUtenti = async () => {
    try {
        // TODO: Chiamata API per ottenere lista pazienti
        // Per ora uso dati mock
        const select = document.getElementById('selezionaUtente');
        
        // Dati simulati
        const utenti = [
            { id: 1, nome: 'Mario Rossi' },
            { id: 2, nome: 'Laura Bianchi' },
            { id: 3, nome: 'Utente Demo' }
        ];
        
        utenti.forEach(utente => {
            const option = document.createElement('option');
            option.value = utente.id;
            option.textContent = utente.nome;
            select.appendChild(option);
        });
        
    } catch (error) {
        console.error('Errore caricamento utenti:', error);
    }
};

// === AVVIA ESERCIZIO === //
const avviaEsercizio = async () => {
    try {
        // Carica domande
        await caricaDomande();
        
        if (appPaziente.domande.length === 0) {
            alert('Nessuna domanda disponibile. Crea domande nell\'interfaccia educatore.');
            return;
        }
        
        // Nascondi schermo iniziale
        const schermoIniziale = document.getElementById('schermoIniziale');
        const schermoEsercizio = document.getElementById('schermoEsercizio');
        
        // Rimuovi completamente lo schermo iniziale dal DOM
        schermoIniziale.style.setProperty('display', 'none', 'important');
        schermoIniziale.style.setProperty('visibility', 'hidden', 'important');
        schermoIniziale.style.setProperty('position', 'absolute', 'important');
        schermoIniziale.style.setProperty('z-index', '-9999', 'important');
        
        // Mostra schermo esercizio
        schermoEsercizio.style.setProperty('display', 'block', 'important');
        schermoEsercizio.style.setProperty('visibility', 'visible', 'important');
        schermoEsercizio.style.setProperty('position', 'relative', 'important');
        schermoEsercizio.style.setProperty('z-index', '1', 'important');
        
        console.log('🔄 Cambio schermata:');
        console.log('   schermoIniziale:', {
            display: window.getComputedStyle(schermoIniziale).display,
            visibility: window.getComputedStyle(schermoIniziale).visibility,
            zIndex: window.getComputedStyle(schermoIniziale).zIndex
        });
        console.log('   schermoEsercizio:', {
            display: window.getComputedStyle(schermoEsercizio).display,
            visibility: window.getComputedStyle(schermoEsercizio).visibility,
            zIndex: window.getComputedStyle(schermoEsercizio).zIndex
        });
        
        // Aggiorna UI
        document.getElementById('nomeUtente').textContent = appPaziente.nomeUtente;
        document.getElementById('totaleDomande').textContent = appPaziente.domande.length;
        
        // Apri finestra monitor
        appPaziente.monitorWindow = window.open(
            'monitor.html?v=4',
            'MonitorEyeTracking',
            'width=1100,height=1000,left=100,top=50'
        );
        
        // Aspetta che il monitor si carichi
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Invia segnale per inizializzare video nel monitor
        if (appPaziente.monitorWindow && !appPaziente.monitorWindow.closed) {
            appPaziente.monitorWindow.postMessage({
                type: 'VIDEO_STREAM'
            }, '*');
        }
        
        // Ascolta messaggi dal monitor (calibrazione e controlli)
        window.addEventListener('message', (event) => {
            if (event.data.type === 'CALIBRATION') {
                eyeTrackingService.calibrate(event.data.centroCalibrato);
                console.log('✅ Calibrazione ricevuta dal monitor:', event.data.centroCalibrato);
            } else if (event.data.type === 'SELECT_QUESTION') {
                // L'educatore ha selezionato una domanda dall'elenco
                const index = event.data.index;
                console.log(`📋 Mostro domanda selezionata: #${index + 1}`);
                resetDwell();
                appPaziente.rispostaRegistrata = false; // Reset flag
                mostraDomanda(index);
            } else if (event.data.type === 'REPEAT_QUESTION') {
                // L'educatore chiede di ripetere la domanda e resettare il blocco risposta
                console.log('🔄 Ripeto la domanda e resetto blocco risposta (comando educatore)');
                appPaziente.rispostaRegistrata = false; // ✅ Libera il blocco
                resetDwell(); // Reset del dwell time
                riproduciDomanda(); // Riproduce la domanda
            }
        });
        
        // Inizializza eye tracking
        const videoElement = document.getElementById('videoPreview');
        const canvasElement = document.getElementById('canvasOverlay');
        
        const initialized = await eyeTrackingService.init(videoElement, canvasElement);
        
        if (!initialized) {
            alert('Errore nell\'inizializzazione della webcam. Controlla i permessi.');
            return;
        }
        
        // Setup callbacks eye tracking
        eyeTrackingService.onGazeUpdate = handleGazeUpdate;
        eyeTrackingService.onFaceDetection = handleFaceDetection;
        
        // Avvia esercizio
        appPaziente.isExerciseActive = true;
        appPaziente.startTime = Date.now();
        appPaziente.indiceDomandaCorrente = -1; // Nessuna domanda selezionata
        
        // Mostra messaggio in attesa di selezione
        document.getElementById('testoDomanda').textContent = 'In attesa che l\'educatore selezioni una domanda...';
        document.getElementById('testoDomanda').style.color = '#aaa';
        document.getElementById('testoDomanda').style.fontStyle = 'italic';
        
    } catch (error) {
        console.error('Errore avvio esercizio:', error);
        alert('Errore durante l\'avvio dell\'esercizio');
    }
};

// === CARICA DOMANDE === //
const caricaDomande = async () => {
    try {
        const response = await fetch('api/domande.php');
        const data = await response.json();
        
        if (data.success && data.data) {
            appPaziente.domande = data.data.filter(d => d.stato === 'attiva');
        } else {
            appPaziente.domande = [];
        }
        
    } catch (error) {
        console.error('Errore caricamento domande:', error);
        appPaziente.domande = [];
    }
};

// === MOSTRA DOMANDA === //
const mostraDomanda = (indice) => {
    // ✅ RESET flag risposta per nuova domanda
    appPaziente.rispostaRegistrata = false;
    
    if (indice >= appPaziente.domande.length) {
        completaEsercizio();
        return;
    }
    
    const domanda = appPaziente.domande[indice];
    appPaziente.domandaCorrente = domanda;
    appPaziente.indiceDomandaCorrente = indice;
    
    console.log('🎯 Mostra domanda:', domanda);
    console.log('   URL Sinistra:', domanda.immagine_sinistra_url || 'NULL');
    console.log('   URL Destra:', domanda.immagine_destra_url || 'NULL');
    
    // Aggiorna UI
    document.getElementById('numeroDomanda').textContent = indice + 1;
    const testoDomandaEl = document.getElementById('testoDomanda');
    testoDomandaEl.textContent = domanda.testo_domanda;
    testoDomandaEl.style.color = '#2c3e50'; // Reset colore
    testoDomandaEl.style.fontStyle = 'normal'; // Reset stile
    
    // Opzione sinistra
    document.getElementById('etichettaSinistra').textContent = domanda.etichetta_sinistra;
    const imgSinistra = document.getElementById('immagineSinistra');
    const containerSinistra = imgSinistra.parentElement;
    if (domanda.immagine_sinistra_url) {
        console.log('   ✅ Mostro immagine SINISTRA');
        // Forza visibilità container
        containerSinistra.style.setProperty('display', 'flex', 'important');
        containerSinistra.style.setProperty('height', 'auto', 'important');
        containerSinistra.style.setProperty('min-height', '200px', 'important');
        // Forza visibilità immagine
        imgSinistra.style.setProperty('display', 'block', 'important');
        imgSinistra.style.setProperty('width', 'auto', 'important');
        imgSinistra.style.setProperty('height', 'auto', 'important');
        imgSinistra.style.setProperty('max-width', '100%', 'important');
        imgSinistra.style.setProperty('max-height', '300px', 'important');
        imgSinistra.setAttribute('alt', domanda.etichetta_sinistra);
        imgSinistra.src = domanda.immagine_sinistra_url;
        console.log('      Immagine e container impostati, element:', imgSinistra);
    } else {
        console.log('   ❌ Nascondo immagine SINISTRA (URL mancante)');
        imgSinistra.style.display = 'none';
        imgSinistra.src = '';
    }
    
    // Opzione destra
    document.getElementById('etichettaDestra').textContent = domanda.etichetta_destra;
    const imgDestra = document.getElementById('immagineDestra');
    const containerDestra = imgDestra.parentElement;
    if (domanda.immagine_destra_url) {
        console.log('   ✅ Mostro immagine DESTRA');
        // Forza visibilità container
        containerDestra.style.setProperty('display', 'flex', 'important');
        containerDestra.style.setProperty('height', 'auto', 'important');
        containerDestra.style.setProperty('min-height', '200px', 'important');
        // Forza visibilità immagine
        imgDestra.style.setProperty('display', 'block', 'important');
        imgDestra.style.setProperty('width', 'auto', 'important');
        imgDestra.style.setProperty('height', 'auto', 'important');
        imgDestra.style.setProperty('max-width', '100%', 'important');
        imgDestra.style.setProperty('max-height', '300px', 'important');
        imgDestra.setAttribute('alt', domanda.etichetta_destra);
        imgDestra.src = domanda.immagine_destra_url;
        console.log('      Immagine e container impostati, element:', imgDestra);
    } else {
        console.log('   ❌ Nascondo immagine DESTRA (URL mancante)');
        imgDestra.style.display = 'none';
        imgDestra.src = '';
    }
    
    // Reset progress bars
    resetProgressBars();
    
    // Riproduci automaticamente domanda
    setTimeout(() => riproduciDomanda(), 500);
};

// === TTS === //
const initTTS = () => {
    if ('speechSynthesis' in window) {
        // Carica voci disponibili
        speechSynthesis.onvoiceschanged = () => {
            const voices = speechSynthesis.getVoices();
            // Cerca voce italiana
            appPaziente.ttsVoice = voices.find(v => v.lang.startsWith('it')) || voices[0];
        };
    } else {
        console.warn('TTS non supportato dal browser');
        appPaziente.ttsEnabled = false;
    }
};

const riproduciDomanda = () => {
    if (!appPaziente.ttsEnabled || !appPaziente.domandaCorrente) return;
    
    // NON cancellare se sta ancora parlando la risposta
    // Aspetta che finisca
    if (speechSynthesis.speaking) {
        console.log('⏳ TTS in corso, aspetto che finisca...');
        // Riprova dopo 500ms
        setTimeout(riproduciDomanda, 500);
        return;
    }
    
    // Crea utterance
    const utterance = new SpeechSynthesisUtterance(appPaziente.domandaCorrente.testo_domanda);
    utterance.voice = appPaziente.ttsVoice;
    utterance.rate = 0.9; // Velocità leggermente ridotta
    utterance.pitch = 1.0;
    utterance.volume = 1.0;
    utterance.lang = 'it-IT';
    
    // Eventi
    utterance.onstart = () => {
        console.log('🔊 TTS avviato');
    };
    
    utterance.onend = () => {
        console.log('✅ TTS completato');
    };
    
    utterance.onerror = (e) => {
        console.error('❌ Errore TTS:', e);
    };
    
    // Avvia speech
    speechSynthesis.speak(utterance);
};

// === TTS RISPOSTA === //
const vocalizzaRisposta = (etichetta) => {
    console.log(`🔊 vocalizzaRisposta chiamata con: "${etichetta}"`);
    console.log(`   TTS Enabled: ${appPaziente.ttsEnabled}`);
    console.log(`   Etichetta valida: ${!!etichetta}`);
    
    if (!appPaziente.ttsEnabled) {
        console.warn('⚠️ TTS non abilitato');
        return;
    }
    
    if (!etichetta) {
        console.warn('⚠️ Etichetta vuota');
        return;
    }
    
    // Costruisci frase completa
    const frase = costruisciFraseRisposta(etichetta);
    
    console.log(`🔊 Frase costruita: "${frase}"`);
    console.log(`   Voice disponibile: ${appPaziente.ttsVoice ? appPaziente.ttsVoice.name : 'Nessuna'}`);
    
    // Funzione interna per avviare il TTS
    const avviaTTS = () => {
        // Controlla se c'è ancora qualcosa in riproduzione
        if (speechSynthesis.speaking) {
            console.log('⏳ TTS ancora in corso, aspetto 200ms...');
            setTimeout(avviaTTS, 200);
            return;
        }
        
        console.log('✅ TTS libero, avvio risposta...');
        
        // Crea utterance
        const utterance = new SpeechSynthesisUtterance(frase);
        utterance.voice = appPaziente.ttsVoice;
        utterance.rate = 0.9;
        utterance.pitch = 1.1; // Leggermente più alto per enfasi
        utterance.volume = 1.0;
        utterance.lang = 'it-IT';
        
        // Eventi
        utterance.onstart = () => {
            console.log('✅ TTS risposta INIZIATO');
        };
        
        utterance.onend = () => {
            console.log('✅ TTS risposta COMPLETATO');
        };
        
        utterance.onerror = (e) => {
            console.error('❌ Errore TTS risposta:', e);
            console.error('   Tipo errore:', e.error);
        };
        
        console.log('📢 Chiamo speechSynthesis.speak()...');
        
        // Avvia speech
        try {
            speechSynthesis.speak(utterance);
            console.log('✅ speechSynthesis.speak() eseguito');
        } catch (err) {
            console.error('❌ Eccezione in speechSynthesis.speak():', err);
        }
    };
    
    // Avvia il processo (aspetterà se necessario)
    avviaTTS();
};

// === COSTRUISCI FRASE RISPOSTA === //
const costruisciFraseRisposta = (etichetta) => {
    console.log(`📝 costruisciFraseRisposta chiamata con: "${etichetta}"`);
    
    const etichettaLower = etichetta.toLowerCase().trim();
    console.log(`   Etichetta lowercase: "${etichettaLower}"`);
    
    // Regole per articoli e preposizioni
    // "in" per luoghi che finiscono in -ia (pizzeria, gelateria, libreria)
    // "al" per luoghi maschili (ristorante, parco, cinema)
    // "alla" per luoghi femminili (spiaggia, montagna)
    
    // Lista di pattern comuni
    const usaIn = [
        'pizzeria', 'gelateria', 'libreria', 'pasticceria', 
        'rosticceria', 'birreria', 'trattoria', 'osteria',
        'palestra', 'farmacia', 'chiesa', 'scuola', 'casa'
    ];
    
    const usaAl = [
        'ristorante', 'parco', 'cinema', 'teatro', 'museo',
        'supermercato', 'bar', 'mercato', 'centro', 'mare'
    ];
    
    const usaAlla = [
        'spiaggia', 'montagna', 'piscina', 'stazione', 'fermata',
        'biblioteca', 'ludoteca', 'mostra'
    ];
    
    // Controlla pattern
    let frase = '';
    
    if (usaIn.includes(etichettaLower) || etichettaLower.endsWith('eria') || etichettaLower.endsWith('ia')) {
        frase = `Voglio andare in ${etichetta}`;
        console.log(`   ✅ Pattern "in" riconosciuto`);
    } else if (usaAlla.includes(etichettaLower)) {
        frase = `Voglio andare alla ${etichetta}`;
        console.log(`   ✅ Pattern "alla" riconosciuto`);
    } else if (usaAl.includes(etichettaLower)) {
        frase = `Voglio andare al ${etichetta}`;
        console.log(`   ✅ Pattern "al" riconosciuto`);
    } else {
        // Default generico per altre scelte
        const primaLettera = etichettaLower.charAt(0);
        const vocali = ['a', 'e', 'i', 'o', 'u'];
        
        if (vocali.includes(primaLettera)) {
            frase = `Ho scelto l'${etichetta}`;
        } else {
            frase = `Ho scelto ${etichetta}`;
        }
        console.log(`   ⚠️ Pattern generico usato`);
    }
    
    console.log(`   Frase risultante: "${frase}"`);
    return frase;
};

// === GESTIONE GAZE === //
const handleGazeUpdate = (data) => {
    // Log debug nuovo algoritmo
    if (data.debug) {
        console.log(`👁️ DIREZIONE: ${data.direction.toUpperCase()} | Confidenza: ${(data.confidence * 100).toFixed(1)}%`);
    }
    
    // Invia dati al monitor popup
    if (appPaziente.monitorWindow && !appPaziente.monitorWindow.closed) {
        appPaziente.monitorWindow.postMessage({
            type: 'GAZE_UPDATE',
            data: data
        }, '*');
    }
    
    // Gestisci dwell time (tempo di permanenza)
    if (data.direction === 'left' || data.direction === 'right') {
        // Inizia/continua dwell
        if (appPaziente.dwellDirection !== data.direction) {
            // Nuova direzione: reset
            appPaziente.dwellDirection = data.direction;
            appPaziente.dwellStartTime = Date.now();
            appPaziente.dwellProgress = 0;
        } else {
            // Stessa direzione: calcola progresso
            const elapsed = Date.now() - appPaziente.dwellStartTime;
            appPaziente.dwellProgress = Math.min(100, (elapsed / appPaziente.dwellTime) * 100);
            
            // Aggiorna progress bar
            updateProgressBar(data.direction, appPaziente.dwellProgress);
            
            // Evidenzia box attivo
            highlightRispostaBox(data.direction);
            
            // Controlla se completato
            if (appPaziente.dwellProgress >= 100) {
                registraRisposta(data.direction);
            }
        }
    } else {
        // Centro: reset dwell
        resetDwell();
    }
};

const handleFaceDetection = (detected) => {
    // Invia stato al monitor popup
    if (appPaziente.monitorWindow && !appPaziente.monitorWindow.closed) {
        appPaziente.monitorWindow.postMessage({
            type: 'FACE_DETECTION',
            detected: detected
        }, '*');
    }
    
    if (!detected) {
        resetDwell();
    }
};

// === PROGRESS BAR === //
const updateProgressBar = (direction, progress) => {
    const progressId = direction === 'left' ? 'progressSinistra' : 'progressDestra';
    const progressEl = document.getElementById(progressId);
    const progressBar = progressEl.querySelector('.progress-bar');
    
    progressEl.style.display = 'block';
    progressBar.style.width = `${progress}%`;
};

const resetProgressBars = () => {
    document.getElementById('progressSinistra').style.display = 'none';
    document.getElementById('progressDestra').style.display = 'none';
    document.querySelector('#progressSinistra .progress-bar').style.width = '0%';
    document.querySelector('#progressDestra .progress-bar').style.width = '0%';
};

const highlightRispostaBox = (direction) => {
    const boxSinistra = document.getElementById('rispostaSinistra');
    const boxDestra = document.getElementById('rispostaDestra');
    
    if (direction === 'left') {
        boxSinistra.classList.add('focus-detected');
        boxDestra.classList.remove('focus-detected');
    } else if (direction === 'right') {
        boxDestra.classList.add('focus-detected');
        boxSinistra.classList.remove('focus-detected');
    } else {
        boxSinistra.classList.remove('focus-detected');
        boxDestra.classList.remove('focus-detected');
    }
};

const resetDwell = () => {
    appPaziente.dwellDirection = null;
    appPaziente.dwellStartTime = null;
    appPaziente.dwellProgress = 0;
    resetProgressBars();
    highlightRispostaBox('center');
};

// === REGISTRA RISPOSTA === //
const registraRisposta = async (direction) => {
    // Previeni doppia registrazione
    if (!appPaziente.isExerciseActive) return;
    
    // ✅ NUOVO: Previeni risposte multiple per la stessa domanda
    if (appPaziente.rispostaRegistrata) {
        console.log('⚠️ Risposta già registrata per questa domanda, ignoro');
        return;
    }
    
    // Blocca ulteriori risposte
    appPaziente.rispostaRegistrata = true;
    
    const domanda = appPaziente.domandaCorrente;
    const etichettaRisposta = direction === 'left' ? domanda.etichetta_sinistra : domanda.etichetta_destra;
    const tempoRisposta = Date.now() - appPaziente.dwellStartTime;
    
    // Salva risposta
    const risposta = {
        id_utente: appPaziente.idUtente,
        id_domanda: domanda.id_domanda,
        domanda_fatta: domanda.testo_domanda,
        risposta_data: direction === 'left' ? 'sinistra' : 'destra',
        etichetta_risposta: etichettaRisposta,
        tempo_risposta_ms: tempoRisposta,
        confidenza: 95, // TODO: Calcolare confidenza reale
        metodo_rilevamento: 'combinato'
    };
    
    appPaziente.risposte.push(risposta);
    
    // Feedback visivo
    mostraFeedbackRisposta(direction);
    
    // 🔊 VOCALIZZA LA RISPOSTA COMPLETA
    console.log(`🎯 Sto per vocalizzare: "${etichettaRisposta}"`);
    vocalizzaRisposta(etichettaRisposta);
    
    // Salva nel database
    await salvaRisposta(risposta);
    
    // NON passa automaticamente alla prossima domanda
    // L'educatore controlla quando passare tramite pulsante nel monitor
    console.log('✅ Risposta registrata. In attesa che l\'educatore passi alla prossima.');
};

const mostraFeedbackRisposta = (direction) => {
    const boxId = direction === 'left' ? 'rispostaSinistra' : 'rispostaDestra';
    const box = document.getElementById(boxId);
    
    box.classList.add('attivo');
    
    // Riproduci conferma audio (opzionale)
    // TODO: Aggiungi suono di conferma
    
    setTimeout(() => {
        box.classList.remove('attivo');
    }, 1000);
};

const salvaRisposta = async (risposta) => {
    try {
        const response = await fetch('api/risposte.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(risposta)
        });
        
        const data = await response.json();
        
        if (data.success) {
            console.log('✅ Risposta salvata:', data.data.id_risposta);
        } else {
            console.error('❌ Errore salvataggio risposta:', data.error);
        }
        
    } catch (error) {
        console.error('❌ Errore connessione:', error);
    }
};

// === COMPLETA ESERCIZIO === //
const completaEsercizio = () => {
    appPaziente.isExerciseActive = false;
    
    // Stop eye tracking
    eyeTrackingService.stop();
    
    // Mostra schermo completamento
    document.getElementById('schermoEsercizio').style.display = 'none';
    document.getElementById('schermoCompletamento').style.display = 'flex';
    
    console.log('🎉 Esercizio completato!', appPaziente.risposte);
};

const terminaEsercizio = () => {
    if (confirm('Sei sicuro di voler terminare l\'esercizio?')) {
        completaEsercizio();
    }
};

const tornaAreaEducatore = () => {
    if (confirm('Vuoi tornare all\'area educatore? L\'esercizio verrà interrotto.')) {
        // Chiudi finestra monitor se aperta
        if (appPaziente.monitorWindow && !appPaziente.monitorWindow.closed) {
            appPaziente.monitorWindow.close();
            console.log('✅ Finestra monitor chiusa');
        }
        
        // Stop eye tracking
        if (eyeTrackingService) {
            eyeTrackingService.stop();
        }
        
        // Reindirizza all'area educatore
        window.location.href = 'gestione.html';
    }
};

const ricominciaEsercizio = () => {
    // Reset stato
    appPaziente.indiceDomandaCorrente = 0;
    appPaziente.risposte = [];
    
    // Torna allo schermo iniziale
    document.getElementById('schermoCompletamento').style.display = 'none';
    document.getElementById('schermoIniziale').style.display = 'flex';
};

// Debug info rimosso - ora nel monitor popup

