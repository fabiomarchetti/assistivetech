// Configurazione applicazione
const APP_CONFIG = {
  name: 'ascolto la musica',
  id: 30,
  version: '3.3.0',
};

// Rilevo automaticamente il path corretto dell'API
const API_ENDPOINT = (() => {
  const hostname = window.location.hostname;
  const isLocalhost = hostname === 'localhost' || hostname === '127.0.0.1';
  
  if (isLocalhost) {
    // Localhost MAMP
    return '/Assistivetech/agenda_timer/api/api_video_yt.php';
  } else {
    // Produzione Aruba - path relativo dalla root del dominio
    return '/agenda_timer/api/api_video_yt.php';
  }
})();

const DEFAULT_SEARCH_QUERY = 'musica per bambini';

let appState = {
  isStarted: false,
  mode: null, // 'educator' o 'user'
  playMode: 'direct', // 'random', 'timed', 'persistent' o 'direct'
  timerDuration: 30, // secondi
  isTimerPaused: false,
  timerTimeoutId: null,
  isPersistentTimerActive: false, // True quando timer persistente è in corso (SPACE ibernato)
  persistentTimerStartTime: null, // Timestamp di inizio timer persistente
  currentBrani: [], // Array di tutti i brani caricati
  spaceKeyPressed: false, // Per gestire tasto SPACE tenuto premuto
  lastSelectedBrano: null, // Ultimo brano selezionato (per modalità direct)
  youtubePlayer: null, // Istanza del player YouTube
  currentVideoId: null, // ID video corrente
  currentBranoIndex: -1, // Indice del brano corrente nella lista (per modalità direct)
  isOnline: true, // Stato connessione (true = online con DB, false = locale)
  currentUserName: null, // Nome utente corrente (online o locale)
  isPWA: false, // True se l'app è installata come PWA (standalone)
  hasInternet: true, // True se c'è connessione internet (per YouTube), indipendente da DB
  endTimeMonitorInterval: null, // Interval per monitorare tempo di fine brano
};

let ui = {
  form: null,
  utente: null,
  categoria: null,
  nome: null,
  link: null,
  status: null,
  searchFrame: null,
  playerFrame: null,
  youtubeBtn: null,
  resetBtn: null,
  playerMetaNome: null,
  playerMetaCategoria: null,
  playerMetaUtente: null,
};

// Rileva se l'app è in modalità PWA (standalone)
function detectPWAMode() {
  // Verifica se l'app è in modalità standalone (installata come PWA)
  const isStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                       window.navigator.standalone || // iOS Safari
                       document.referrer.includes('android-app://'); // Android
  
  appState.isPWA = isStandalone;
  
  if (isStandalone) {
    console.log('🔒 PWA INSTALLATA: Nascondo tutti i link esterni al portale');
    
    // 1. Nascondi il pulsante "Torna indietro" nell'header (con !important per evitare override)
    const btnBackToPortal = document.getElementById('btnBackToPortal');
    if (btnBackToPortal) {
      btnBackToPortal.style.setProperty('display', 'none', 'important');
      btnBackToPortal.style.setProperty('visibility', 'hidden', 'important');
      btnBackToPortal.style.setProperty('opacity', '0', 'important');
      btnBackToPortal.style.setProperty('pointer-events', 'none', 'important');
      btnBackToPortal.disabled = true;
      btnBackToPortal.setAttribute('aria-hidden', 'true');
      console.log('  ✓ Pulsante header #btnBackToPortal nascosto');
    } else {
      console.warn('  ⚠️ Pulsante header #btnBackToPortal NON TROVATO nel DOM');
      console.warn('  📋 Elementi nel DOM:', document.body.innerHTML.substring(0, 500));
    }
    
    // 2. Nascondi la voce "Torna alla home" nel menu laterale
    const menuBackToPortal = document.getElementById('menuBackToPortal');
    if (menuBackToPortal) {
      menuBackToPortal.style.setProperty('display', 'none', 'important');
      console.log('  ✓ Voce menu #menuBackToPortal nascosta');
    } else {
      console.warn('  ⚠️ Voce menu #menuBackToPortal NON TROVATA nel DOM');
    }
    
    // 3. Nascondi TUTTI i pulsanti con classe btn-back (controllo aggiuntivo CRITICO)
    const allBackButtons = document.querySelectorAll('.btn-back');
    console.log(`  🔍 Trovati ${allBackButtons.length} pulsanti con classe .btn-back`);
    
    if (allBackButtons.length === 0) {
      console.error('  ❌ PROBLEMA: Nessun pulsante .btn-back trovato! Riprovo tra 200ms...');
      setTimeout(() => {
        const retry = document.querySelectorAll('.btn-back');
        console.log(`  🔄 Retry: Trovati ${retry.length} pulsanti .btn-back`);
        retry.forEach(btn => {
          btn.style.setProperty('display', 'none', 'important');
          btn.style.setProperty('visibility', 'hidden', 'important');
          btn.style.setProperty('opacity', '0', 'important');
          btn.style.setProperty('pointer-events', 'none', 'important');
          btn.disabled = true;
          btn.setAttribute('aria-hidden', 'true');
          console.log('  ✅ Pulsante .btn-back nascosto (retry)');
        });
      }, 200);
    } else {
      allBackButtons.forEach(btn => {
        btn.style.setProperty('display', 'none', 'important');
        btn.style.setProperty('visibility', 'hidden', 'important');
        btn.style.setProperty('opacity', '0', 'important');
        btn.style.setProperty('pointer-events', 'none', 'important');
        btn.disabled = true;
        btn.setAttribute('aria-hidden', 'true');
        console.log('  ✓ Pulsante .btn-back nascosto');
      });
    }
    
    // 4. Verifica che non ci siano altri link esterni (controllo sicurezza)
    const allLinks = document.querySelectorAll('a[href]');
    allLinks.forEach(link => {
      const href = link.getAttribute('href');
      // Se il link porta fuori dall'app (non è # o relativo interno)
      if (href && href !== '#' && !href.startsWith('#') && href.includes('../')) {
        link.style.setProperty('display', 'none', 'important');
        console.log(`  ⚠️ Link esterno nascosto: ${href}`);
      }
    });
    
    console.log('🎉 PWA completamente isolata - Controllo link esterni completato');
  } else {
    console.log('🌐 Modalità BROWSER: Link al portale visibili');
  }
}

function goBack() {
  // In modalità PWA, l'app è completamente isolata (nessun link esterno)
  if (appState.isPWA) {
    console.log('⚠️ Tentativo di uscire dalla PWA bloccato');
    alert('🔒 Sei nell\'app installata "ascolto la musica".\n\nQuesta app è completamente autonoma e non ha link esterni.\n\nUsa il menu per:\n• "Ricomincia" → Torna alla schermata iniziale\n• Chiudi l\'app dalla barra applicazioni se vuoi uscire');
    return;
  }
  
  // In modalità browser, permetti di tornare al portale principale
  if (confirm('Vuoi davvero tornare alla home del portale AssistiveTech?')) {
    console.log('↩️ Ritorno al portale principale');
    window.location.href = '../../';
  }
}

function toggleMenu() {
  const menu = document.getElementById('sideMenu');
  const overlay = document.getElementById('overlay');
  if (!menu || !overlay) {
    return;
  }
  menu.classList.toggle('active');
  overlay.classList.toggle('active');
}

function showInfo() {
  const modal = document.getElementById('infoModal');
  if (modal) {
    modal.classList.add('active');
    toggleMenu();
  }
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) {
    modal.classList.remove('active');
  }
}

function showInstructions() {
  const modal = document.getElementById('instructionsModal');
  if (modal) {
    modal.classList.add('active');
    toggleMenu();
  }
}

function showSettings() {
  alert('Impostazioni in fase di sviluppo!\n\nQui potrai aggiungere preferenze, livelli di difficoltà e altre opzioni personalizzate.');
  toggleMenu();
}

function startApp() {
  // Funzione deprecata - ora si usa startEducatorMode() o startUserMode()
  renderWelcomeScreen();
}

function startEducatorMode() {
  if (appState.isStarted) {
    return;
  }
  appState.isStarted = true;
  appState.mode = 'educator';
  
  // Aggiungo classe al body per mostrare il form a sinistra (1/3 pagina)
  document.body.classList.add('educator-mode');
  
  // REGOLA: Se è PWA installata, USA SEMPRE utenti locali (anche con internet)
  const isPWAStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                          window.navigator.standalone ||
                          document.referrer.includes('android-app://');
  
  if (isPWAStandalone) {
    // PWA installata → SEMPRE utenti locali (ma YouTube funziona se c'è internet)
    console.log('📱 Area Educatore (PWA): Uso utenti LOCALI (localStorage)');
    
    // Verifico se c'è internet per YouTube (ma uso comunque utenti locali)
    checkInternetConnection().then(hasInternet => {
      appState.isOnline = false; // Forzo offline per gestione utenti
      appState.hasInternet = hasInternet; // Salvo se c'è internet per YouTube
      
      renderEducatorUI();
      cacheEducatorRefs();
      loadLocalUsers();
      bindEducatorEvents();
      updatePlayerMeta();
      
      // Aspetto rendering completo prima di nascondere link esterni
      setTimeout(() => {
        detectPWAMode();
      }, 150);
    });
  } else {
    // Browser normale → Verifico connessione database
    checkOnlineStatus().then(isOnline => {
      appState.isOnline = isOnline;
      appState.hasInternet = isOnline;
      console.log(`🔍 Area Educatore (Browser) - Modalità: ${isOnline ? 'ONLINE (database)' : 'OFFLINE (localStorage)'}`);
      
      renderEducatorUI();
      cacheEducatorRefs();
      
      // Aspetto che il DOM sia renderizzato prima di caricare i dati
      setTimeout(() => {
        if (isOnline) {
          loadPazienti();
        } else {
          loadLocalUsers();
        }
      }, 100);
      
      bindEducatorEvents();
      updatePlayerMeta();
      
      // Aspetto rendering completo prima di gestire link esterni
      setTimeout(() => {
        detectPWAMode();
      }, 150);
    });
  }
}

function startUserMode() {
  if (appState.isStarted) {
    return;
  }
  appState.isStarted = true;
  appState.mode = 'user';
  
  // REGOLA: Se è PWA installata, USA SEMPRE utenti locali (anche con internet)
  const isPWAStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                          window.navigator.standalone ||
                          document.referrer.includes('android-app://');
  
  if (isPWAStandalone) {
    // PWA installata → SEMPRE utenti locali
    console.log('📱 Area Utente (PWA): Uso utenti LOCALI (localStorage)');
    appState.isOnline = false; // Forzo offline per gestione utenti
    
    const localUsers = getLocalUsers();
    
    if (localUsers.length > 0) {
      // Ci sono utenti locali: mostro schermata di selezione
      showLocalUserSelection(localUsers);
    } else {
      // Nessun utente locale: mostro schermata di login (primo ingresso)
      showLocalUserLogin();
    }
  } else {
    // Browser normale → Verifico connessione database
    checkOnlineStatus().then(isOnline => {
      appState.isOnline = isOnline;
      console.log(`🔍 Area Utente (Browser) - Modalità: ${isOnline ? 'ONLINE (database)' : 'OFFLINE (localStorage)'}`);
      
      if (!isOnline) {
        // Modalità locale: verifico se ci sono utenti locali esistenti
        const localUsers = getLocalUsers();
        
        if (localUsers.length > 0) {
          // Ci sono utenti locali: mostro schermata di selezione
          showLocalUserSelection(localUsers);
        } else {
          // Nessun utente locale: mostro schermata di login (primo ingresso)
          showLocalUserLogin();
        }
      } else {
        // Modalità online: uso il sistema esistente
        renderUserUI();
        cacheUserRefs();
        
        // Aspetto che il DOM sia renderizzato prima di caricare i dati
        setTimeout(() => {
          loadPazientiForUser();
        }, 100);
        
        bindUserEvents();
        updatePlayButton();
        
        // Aspetto rendering completo prima di gestire link esterni
        setTimeout(() => {
          detectPWAMode();
        }, 150);
      }
    });
  }
}

// Verifica solo se c'è connessione internet (per YouTube), senza controllare database
async function checkInternetConnection() {
  // Controllo rapido con navigator.onLine
  if (!navigator.onLine) {
    console.log('📡 Nessuna connessione internet (navigator.onLine = false)');
    return false;
  }
  
  // Provo un ping veloce a un servizio esterno affidabile
  try {
    const response = await fetch('https://www.google.com/favicon.ico', {
      method: 'HEAD',
      mode: 'no-cors',
      cache: 'no-cache',
      signal: AbortSignal.timeout(2000) // 2 secondi
    });
    console.log('📡 Connessione internet attiva (ping Google OK)');
    return true;
  } catch (error) {
    console.log('📡 Connessione internet assente o instabile');
    return false;
  }
}

// Verifica se l'app è online (può accedere al DB)
async function checkOnlineStatus() {
  // Rilevo se è PWA standalone (ma NON forzo offline!)
  const isPWAStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                          window.navigator.standalone || // iOS Safari
                          document.referrer.includes('android-app://'); // Android
  
  const isLocalhost = window.location.hostname === 'localhost' || 
                      window.location.hostname === '127.0.0.1' ||
                      window.location.hostname.includes('assistivetech.it') ||
                      window.location.hostname.includes('.local');
  
  // Se non c'è connessione internet, sicuramente offline
  if (!navigator.onLine) {
    console.log(`📱 Modalità OFFLINE${isPWAStandalone ? ' (PWA)' : ''}: Nessuna connessione internet`);
    return false;
  }
  
  try {
    // Provo a chiamare l'API per verificare accesso al database
    const response = await fetch(`${API_ENDPOINT}?action=get_pazienti`, {
      method: 'GET',
      cache: 'no-cache',
      signal: AbortSignal.timeout(3000) // 3 secondi di timeout
    });
    
    // Se arriva una risposta (anche errore HTTP), il server è raggiungibile
    const modeLabel = isPWAStandalone ? 'PWA' : 'Browser';
    console.log(`✅ Modalità ONLINE (${modeLabel}): Database raggiungibile (status: ${response.status})`);
    return true;
    
  } catch (error) {
    // Su localhost, se API non risponde assumo online (sviluppo)
    if (isLocalhost) {
      console.warn('⚠️ Localhost/Server rilevato ma API non risponde. Assumo ONLINE per sviluppo.');
      console.log('Errore API:', error.message);
      return true; // Su localhost assumo online
    }
    
    // PWA o browser esterno: se il database non è raggiungibile, usa localStorage
    const modeLabel = isPWAStandalone ? 'PWA' : 'Browser';
    console.log(`📱 Modalità OFFLINE (${modeLabel}): Database non raggiungibile - uso localStorage`);
    return false;
  }
}

// Ottiene lista utenti locali da localStorage
function getLocalUsers() {
  const localUsers = [];
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && key.startsWith('localBrani_')) {
      const userName = key.replace('localBrani_', '');
      localUsers.push(userName);
    }
  }
  return localUsers.sort(); // Ordino alfabeticamente
}

// Mostra schermata di selezione utenti locali (offline con utenti esistenti)
function showLocalUserSelection(localUsers) {
  const mainContent = document.getElementById('appMain');
  if (!mainContent) {
    return;
  }
  
  document.body.classList.remove('educator-mode');
  document.body.classList.add('user-mode-active');
  
  // Creo la lista di utenti con pulsanti
  const usersListHTML = localUsers.map(user => `
    <button 
      class="btn-primary" 
      onclick="selectLocalUser('${user}')"
      style="width: 100%; margin-bottom: 1rem; padding: 1.2rem; font-size: 1.3rem;"
    >
      <i class="bi bi-person-circle"></i> ${user}
    </button>
  `).join('');
  
  mainContent.innerHTML = `
    <div class="welcome-screen">
      <div class="welcome-icon">
        <i class="bi bi-people"></i>
      </div>
      <h2>Scegli il tuo profilo</h2>
      <p class="description" style="margin-bottom: 2rem;">
        <i class="bi bi-wifi-off" style="color: #ff9800; font-size: 1.2rem;"></i><br>
        <strong>Modalità locale attiva</strong><br>
        Seleziona il tuo nome o aggiungi un nuovo utente
      </p>
      
      <div style="max-width: 500px; margin: 0 auto;">
        <h3 style="text-align: left; margin-bottom: 1rem; color: var(--primary-color);">
          <i class="bi bi-list-ul"></i> Utenti salvati
        </h3>
        ${usersListHTML}
        
        <hr style="margin: 2rem 0; border-color: rgba(103, 58, 183, 0.2);">
        
        <h3 style="text-align: left; margin-bottom: 1rem; color: var(--primary-color);">
          <i class="bi bi-person-plus"></i> Nuovo utente
        </h3>
        <div class="form-group">
          <input 
            type="text" 
            id="newLocalUserName" 
            placeholder="Inserisci nuovo nome..." 
            required
            autocomplete="off"
            style="font-size: 1.3rem; padding: 1rem; text-align: center;"
          >
        </div>
        <button 
          class="btn-secondary" 
          onclick="addNewLocalUser()" 
          style="width: 100%; font-size: 1.2rem; padding: 1rem;"
        >
          <i class="bi bi-plus-circle"></i> Aggiungi e inizia
        </button>
      </div>
    </div>
  `;
}

// Seleziona un utente locale esistente
function selectLocalUser(userName) {
  if (!userName) {
    return;
  }
  
  localStorage.setItem('localUser', userName);
  appState.currentUserName = userName;
  
  // Renderuzzo l'UI utente e carico i brani locali
  renderUserUI();
  cacheUserRefs();
  loadUserBraniLocal(userName);
  bindUserEvents();
  updatePlayButton();
  populateLocalUserSwitcher(); // Popolo il dropdown cambia utente
  
  // Mostro il pulsante "Cambia Utente" nel menu
  const changeUserMenuItem = document.getElementById('changeUserMenuItem');
  if (changeUserMenuItem) {
    changeUserMenuItem.style.display = 'block';
  }
}

// Aggiungi un nuovo utente locale
function addNewLocalUser() {
  const nameInput = document.getElementById('newLocalUserName');
  const userName = nameInput?.value.trim();
  
  if (!userName) {
    alert('Inserisci un nome per continuare!');
    nameInput?.focus();
    return;
  }
  
  // Verifico se l'utente esiste già
  const localUsers = getLocalUsers();
  if (localUsers.includes(userName)) {
    alert(`L'utente "${userName}" esiste già! Selezionalo dalla lista o usa un nome diverso.`);
    nameInput?.focus();
    return;
  }
  
  // Salvo il nuovo utente
  localStorage.setItem('localUser', userName);
  appState.currentUserName = userName;
  
  // Creo l'archivio brani vuoto per il nuovo utente
  const storageKey = `localBrani_${userName}`;
  localStorage.setItem(storageKey, JSON.stringify([]));
  
  // Renderuzzo l'UI utente e carico i brani (vuoti)
  renderUserUI();
  cacheUserRefs();
  loadUserBraniLocal(userName);
  bindUserEvents();
  updatePlayButton();
  populateLocalUserSwitcher(); // Popolo il dropdown cambia utente
  
  // Mostro il pulsante "Cambia Utente" nel menu
  const changeUserMenuItem = document.getElementById('changeUserMenuItem');
  if (changeUserMenuItem) {
    changeUserMenuItem.style.display = 'block';
  }
}

// Gestisce il cambio utente dal dropdown
function handleLocalUserSwitch(newUserName) {
  if (!newUserName) {
    return; // Nessuna selezione
  }
  
  // Salvo il nuovo utente corrente
  localStorage.setItem('localUser', newUserName);
  appState.currentUserName = newUserName;
  
  // Ricarico i brani del nuovo utente
  loadUserBraniLocal(newUserName);
  
  // Aggiorno il messaggio di benvenuto
  const helperText = document.getElementById('userHelperText');
  if (helperText) {
    helperText.innerHTML = `Benvenuto <strong>${newUserName}</strong>!`;
  }
  
  // Resetto il dropdown alla prima opzione
  const switcher = document.getElementById('localUserSwitch');
  if (switcher) {
    switcher.selectedIndex = 0;
  }
  
  // Feedback visivo
  const statusMsg = document.createElement('div');
  statusMsg.className = 'status-message success';
  statusMsg.textContent = `✅ Caricati i brani di ${newUserName}`;
  statusMsg.style.cssText = 'position: fixed; top: 100px; left: 50%; transform: translateX(-50%); z-index: 9999; padding: 1rem 2rem; background: rgba(76,175,80,0.95); color: white; border-radius: 8px; font-weight: 600;';
  document.body.appendChild(statusMsg);
  
  setTimeout(() => {
    statusMsg.remove();
  }, 2000);
}

// Popola il dropdown per cambiare utente con tutti gli utenti locali tranne quello corrente
function populateLocalUserSwitcher() {
  const switcher = document.getElementById('localUserSwitch');
  if (!switcher || appState.isOnline) {
    return; // Solo in modalità offline
  }
  
  const localUsers = getLocalUsers();
  const currentUser = appState.currentUserName;
  
  // Filtro utente corrente dalla lista
  const otherUsers = localUsers.filter(user => user !== currentUser);
  
  // Resetto il dropdown
  switcher.innerHTML = '<option value="">-- Seleziona un altro utente --</option>';
  
  // Aggiungo gli altri utenti
  otherUsers.forEach(user => {
    const option = document.createElement('option');
    option.value = user;
    option.textContent = user;
    switcher.appendChild(option);
  });
}

// Mostra schermata di login per utente locale (offline - primo ingresso)
function showLocalUserLogin() {
  const mainContent = document.getElementById('appMain');
  if (!mainContent) {
    return;
  }
  
  document.body.classList.remove('educator-mode');
  document.body.classList.add('user-mode-active');
  
  mainContent.innerHTML = `
    <div class="welcome-screen">
      <div class="welcome-icon">
        <i class="bi bi-person-circle"></i>
      </div>
      <h2>Benvenuto!</h2>
      <p class="description" style="margin-bottom: 2rem;">
        <i class="bi bi-wifi-off" style="color: #ff9800; font-size: 1.2rem;"></i><br>
        <strong>Modalità locale attiva</strong><br>
        Inserisci il tuo nome per iniziare
      </p>
      
      <div class="form-group" style="max-width: 400px; margin: 0 auto;">
        <label for="localUserName" style="font-size: 1.3rem; font-weight: 600;">Come ti chiami?</label>
        <input 
          type="text" 
          id="localUserName" 
          placeholder="Il tuo nome..." 
          required
          autocomplete="off"
          style="font-size: 1.5rem; padding: 1rem; text-align: center;"
          autofocus
        >
      </div>
      
      <button class="btn-primary" onclick="saveLocalUserAndStart()" style="margin-top: 2rem; font-size: 1.3rem; padding: 1rem 3rem;">
        <i class="bi bi-check-circle"></i> Inizia ad ascoltare
      </button>
    </div>
  `;
}

// Salva il nome utente locale e avvia l'area utente
function saveLocalUserAndStart() {
  const nameInput = document.getElementById('localUserName');
  const userName = nameInput?.value.trim();
  
  if (!userName) {
    alert('Inserisci il tuo nome per continuare!');
    nameInput?.focus();
    return;
  }
  
  // Salvo il nome in localStorage
  localStorage.setItem('localUser', userName);
  appState.currentUserName = userName;
  
  // Creo l'archivio brani locale se non esiste
  const storageKey = `localBrani_${userName}`;
  if (!localStorage.getItem(storageKey)) {
    localStorage.setItem(storageKey, JSON.stringify([]));
  }
  
  // Renderuzzo l'UI utente e carico i brani locali
  renderUserUI();
  cacheUserRefs();
  loadUserBraniLocal(userName);
  bindUserEvents();
  updatePlayButton();
  populateLocalUserSwitcher(); // Popolo il dropdown cambia utente
  
  // Mostro il pulsante "Cambia Utente" nel menu
  const changeUserMenuItem = document.getElementById('changeUserMenuItem');
  if (changeUserMenuItem) {
    changeUserMenuItem.style.display = 'block';
  }
}

// Carica i brani da localStorage per utente locale
function loadUserBraniLocal(userName) {
  if (!ui.userBraniList) {
    return;
  }
  
  ui.userBraniList.innerHTML = '<p style="color: #666;"><i class="bi bi-hourglass-split"></i> Caricamento brani...</p>';
  ui.userBraniContainer.style.display = 'block';
  
  // Leggo i brani da localStorage
  const storageKey = `localBrani_${userName}`;
  const braniJSON = localStorage.getItem(storageKey);
  
  let brani = [];
  if (braniJSON) {
    try {
      brani = JSON.parse(braniJSON);
    } catch (error) {
      console.error('Errore parsing brani locali:', error);
      brani = [];
    }
  }
  
  appState.currentBrani = brani;
  
  if (brani.length === 0) {
    ui.userBraniList.innerHTML = `
      <p style="color: #666; line-height: 1.8;">
        <i class="bi bi-music-note"></i> Nessun brano trovato.<br><br>
        <small>Per aggiungere brani, usa l'<strong>Area Educatore</strong> quando sei connesso a internet.</small>
      </p>
    `;
    return;
  }
  
  // Popolo la lista dei brani
  ui.userBraniList.innerHTML = brani.map((brano, index) => {
    const inizioBrano = parseInt(brano.inizio_brano || 0);
    const fineBrano = parseInt(brano.fine_brano || 0);
    const hasTimeLimits = inizioBrano > 0 || fineBrano > 0;

    let timeInfo = '';
    if (hasTimeLimits) {
      const formatTime = (seconds) => {
        const min = Math.floor(seconds / 60);
        const sec = seconds % 60;
        return `${min}:${sec.toString().padStart(2, '0')}`;
      };

      if (inizioBrano > 0 && fineBrano > 0) {
        timeInfo = `<small style="color: #ff9800;"><i class="bi bi-clock"></i> ${formatTime(inizioBrano)} - ${formatTime(fineBrano)}</small>`;
      } else if (inizioBrano > 0) {
        timeInfo = `<small style="color: #ff9800;"><i class="bi bi-clock"></i> Inizio: ${formatTime(inizioBrano)}</small>`;
      } else if (fineBrano > 0) {
        timeInfo = `<small style="color: #ff9800;"><i class="bi bi-clock"></i> Fine: ${formatTime(fineBrano)}</small>`;
      }
    }

    return `
    <div class="brano-item" data-link="${brano.link_youtube}" data-index="${index}">
      <div class="brano-info" onclick="selectBrano('${brano.link_youtube}', '${brano.nome_video.replace(/'/g, "\\'")}', ${index})">
        <i class="bi bi-music-note-beamed"></i>
        <div>
          <strong>${brano.nome_video}</strong>
          <small>${brano.categoria || 'Senza categoria'}</small>
          ${timeInfo}
        </div>
      </div>
      <div class="brano-actions">
        <button class="btn-play" onclick="selectBrano('${brano.link_youtube}', '${brano.nome_video.replace(/'/g, "\\'")}', ${index})" title="Riproduci brano">
          <i class="bi bi-play-circle"></i>
        </button>
        <button class="btn-delete" onclick="deleteBranoLocal(${index}, '${brano.nome_video.replace(/'/g, "\\'")}', '${userName}')" title="Elimina brano">
          <i class="bi bi-trash3"></i>
        </button>
      </div>
    </div>
    `;
  }).join('');
}

// Elimina un brano da localStorage
function deleteBranoLocal(branoIndex, nomeBrano, userName) {
  if (!confirm(`Vuoi davvero eliminare il brano "${nomeBrano}"?`)) {
    return;
  }
  
  const storageKey = `localBrani_${userName}`;
  const braniJSON = localStorage.getItem(storageKey);
  
  let brani = [];
  if (braniJSON) {
    try {
      brani = JSON.parse(braniJSON);
    } catch (error) {
      console.error('Errore parsing brani locali:', error);
      return;
    }
  }
  
  // Rimuovo il brano dall'array
  brani.splice(branoIndex, 1);
  
  // Salvo l'array aggiornato
  localStorage.setItem(storageKey, JSON.stringify(brani));
  
  // Ricarico la lista
  loadUserBraniLocal(userName);
  
  alert(`Brano "${nomeBrano}" eliminato con successo!`);
}

// Cambia utente locale (logout)
function changeLocalUser() {
  if (confirm('Vuoi cambiare utente? I brani rimarranno salvati.')) {
    localStorage.removeItem('localUser');
    appState.currentUserName = null;
    appState.currentBrani = [];
    showLocalUserLogin();
  }
}

// Salva un brano in localStorage se esiste già un archivio locale per quell'utente
function saveToLocalStorageIfExists(userName, brano) {
  const storageKey = `localBrani_${userName}`;
  const braniJSON = localStorage.getItem(storageKey);
  
  // Se non esiste ancora, non faccio nulla (non creo archivi automaticamente)
  if (!braniJSON) {
    return;
  }
  
  let brani = [];
  try {
    brani = JSON.parse(braniJSON);
  } catch (error) {
    console.error('Errore parsing brani locali per sync:', error);
    return;
  }
  
  // Verifico se il brano esiste già (per evitare duplicati)
  const exists = brani.some(b => b.link_youtube === brano.link_youtube);
  if (exists) {
    console.log('Brano già presente in localStorage, skip sync');
    return;
  }
  
  // Aggiungo il brano
  brani.push(brano);
  localStorage.setItem(storageKey, JSON.stringify(brani));
  console.log(`Brano sincronizzato in localStorage per utente: ${userName}`);
}

// Carica utenti locali da localStorage per Area Educatore
function loadLocalUsers() {
  // Ottengo tutti gli utenti locali da localStorage
  const localUsers = new Set();
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && key.startsWith('localBrani_')) {
      const userName = key.replace('localBrani_', '');
      localUsers.add(userName);
    }
  }
  
  // Popolo il datalist con gli utenti esistenti
  const datalist = document.getElementById('localUsersDatalist');
  if (datalist) {
    datalist.innerHTML = '';
    localUsers.forEach(user => {
      const option = document.createElement('option');
      option.value = user;
      datalist.appendChild(option);
    });
  }
  
  // Mostro messaggio modalità offline
  if (ui.status) {
    showStatus('📱 MODALITÀ OFFLINE: I brani saranno salvati localmente su questo dispositivo', 'info');
  }
}

function loadPazientiForUser() {
  if (!ui.userSelect) {
    return;
  }

  fetch(`${API_ENDPOINT}?action=get_pazienti`)
    .then(async (response) => {
      if (!response.ok) {
        const text = await response.text();
        throw new Error(text || 'Errore caricamento pazienti');
      }
      return response.json();
    })
    .then((data) => {
      if (!data.success || !data.data) {
        throw new Error('Risposta non valida dal server');
      }
      
      // Popolo il dropdown
      ui.userSelect.innerHTML = '<option value="">-- Seleziona il tuo nome --</option>';
      
      data.data.forEach(paziente => {
        const option = document.createElement('option');
        option.value = `${paziente.nome_paziente} ${paziente.cognome_paziente}`;
        option.textContent = `${paziente.nome_paziente} ${paziente.cognome_paziente}`;
        ui.userSelect.appendChild(option);
      });
    })
    .catch((error) => {
      console.error('Errore caricamento pazienti:', error);
      ui.userSelect.innerHTML = '<option value="">Errore caricamento pazienti</option>';
    });
}

function resetApp() {
  if (confirm('Vuoi ricominciare da capo?')) {
    window.location.reload();
  }
}

// Passa dall'Area Educatore all'Area Utente
function switchToUserMode() {
  // Reset dello stato
  appState.isStarted = false;
  appState.mode = null;
  
  // Chiudi finestra YouTube se aperta
  if (ui.youtubeWindow && !ui.youtubeWindow.closed) {
    try {
      ui.youtubeWindow.close();
    } catch (e) {
      console.log('Impossibile chiudere finestra YouTube:', e);
    }
  }
  
  // Chiudi menu se aperto
  const menu = document.getElementById('sideMenu');
  const overlay = document.getElementById('overlay');
  if (menu?.classList.contains('active')) {
    menu.classList.remove('active');
    overlay?.classList.remove('active');
  }
  
  // Avvia Area Utente
  startUserMode();
}

// Passa dall'Area Utente all'Area Educatore
function switchToEducatorMode() {
  // Reset dello stato
  appState.isStarted = false;
  appState.mode = null;
  
  // Ferma player YouTube se in riproduzione
  if (appState.youtubePlayer) {
    try {
      appState.youtubePlayer.stopVideo();
    } catch (e) {
      console.log('Impossibile fermare player YouTube:', e);
    }
  }
  
  // Reset timer se attivo
  if (appState.timerTimeoutId) {
    clearTimeout(appState.timerTimeoutId);
    appState.timerTimeoutId = null;
  }
  
  // Chiudi menu se aperto
  const menu = document.getElementById('sideMenu');
  const overlay = document.getElementById('overlay');
  if (menu?.classList.contains('active')) {
    menu.classList.remove('active');
    overlay?.classList.remove('active');
  }
  
  // Avvia Area Educatore
  startEducatorMode();
}

function renderWelcomeScreen() {
  const mainContent = document.getElementById('appMain');
  if (!mainContent) {
    return;
  }
  mainContent.innerHTML = `
    <div class="welcome-screen">
      <div class="welcome-icon">
        <i class="bi bi-music-note-beamed"></i>
      </div>
      <h2>Benvenuto!</h2>
      <p>Questo è lo strumento <strong>ascolto la musica</strong></p>
      <p class="description">Scegli la modalità con cui vuoi accedere:</p>
      <div class="mode-selection">
        <button class="btn-mode btn-educator" onclick="startEducatorMode()">
          <i class="bi bi-person-workspace"></i>
          <span>Area Educatore</span>
        </button>
        <button class="btn-mode btn-user" onclick="startUserMode()">
          <i class="bi bi-headphones"></i>
          <span>Area Utente</span>
        </button>
      </div>
      <button class="btn-secondary" style="margin-top: 2rem;" onclick="showInfo()">
        <i class="bi bi-info-circle"></i> Informazioni
      </button>
    </div>
  `;
}

function renderEducatorUI() {
  const mainContent = document.getElementById('appMain');
  if (!mainContent) {
    return;
  }
  
  // Rendering condizionale del campo utente in base a online/offline
  const userFieldHTML = appState.isOnline 
    ? `<select id="utenteInput" name="utente" required>
         <option value="">Caricamento pazienti...</option>
       </select>`
    : `<input 
         id="utenteInput" 
         name="utente" 
         type="text" 
         required 
         placeholder="Inserisci nome utente..." 
         autocomplete="off"
         list="localUsersDatalist"
         style="font-size: 1.1rem; padding: 0.75rem;"
       />
       <datalist id="localUsersDatalist"></datalist>
       <p class="helper-text" style="color: #ff9800; margin-top: 0.5rem;">
         <i class="bi bi-wifi-off"></i> <strong>Modalità offline:</strong> Inserisci il nome e i brani saranno salvati localmente
       </p>`;
  
  mainContent.innerHTML = `
    <div class="educator-layout-full">
      <section class="panel form-panel-full" aria-label="Form salvataggio brano YouTube">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
          <h3 style="margin: 0;">
            <i class="bi bi-music-note-beamed"></i> Archivia nuovo brano
            ${!appState.isOnline ? '<span style="font-size: 0.8rem; color: #ff9800; margin-left: 1rem;"><i class="bi bi-wifi-off"></i> OFFLINE</span>' : ''}
          </h3>
          <button 
            class="btn-secondary" 
            onclick="switchToUserMode()"
            title="Vai all'Area Utente"
            style="padding: 0.5rem 1rem; font-size: 0.95rem;"
          >
            <i class="bi bi-headphones"></i> Area Utente
          </button>
        </div>
        <p class="helper-text">${appState.isOnline ? 'Compila i dati del brano. La finestra YouTube (2/3 schermo) si apre a destra per cercare e ascoltare l\'anteprima.' : 'Compila i dati del brano. Cerca il video su YouTube da un altro dispositivo e incolla qui il link.'}</p>
        <form id="videoForm" class="form-grid" novalidate>
          <div class="form-group">
            <label for="utenteInput">${appState.isOnline ? 'Paziente' : 'Nome Utente'} *</label>
            ${userFieldHTML}
          </div>
          <div class="form-group">
            <label for="categoriaInput">Ricerca: digita cosa cerchi ed aspetta che appaia *</label>
            <input id="categoriaInput" name="categoria" type="text" maxlength="100" required placeholder="Es: canzoni per dormire" autocomplete="off" />
            <p class="helper-text">Copia il link del brano ed incollalo nel campo sotto</p>
          </div>
          <div class="form-group">
            <label for="linkVideoInput">Link YouTube *</label>
            <input id="linkVideoInput" name="linkVideo" type="url" maxlength="500" required placeholder="https://www.youtube.com/watch?v=..." autocomplete="off" />
          </div>
          <div class="form-group">
            <label for="nomeVideoInput">Nome brano *</label>
            <input id="nomeVideoInput" name="nomeVideo" type="text" maxlength="150" required placeholder="Es: Ninna nanna dolce" autocomplete="off" />
          </div>

          <!-- Campi tempo inizio brano (opzionali) -->
          <div class="form-group">
            <label>Tempo di inizio ascolto (opzionale)</label>
            <div class="time-group" style="display: flex; gap: 1rem; align-items: center;">
              <div style="flex: 1;">
                <label for="inizioMin" style="font-size: 0.85rem; color: #666;">Minuti</label>
                <input id="inizioMin" name="inizioMin" type="number" min="0" max="999" placeholder="0" autocomplete="off" style="text-align: center;" />
              </div>
              <div style="flex: 1;">
                <label for="inizioSec" style="font-size: 0.85rem; color: #666;">Secondi</label>
                <input id="inizioSec" name="inizioSec" type="number" min="0" max="59" placeholder="0" autocomplete="off" style="text-align: center;" />
              </div>
            </div>
            <p class="helper-text">Lascia vuoto per iniziare dall'inizio</p>
          </div>

          <!-- Campi tempo fine brano (opzionali) -->
          <div class="form-group">
            <label>Tempo di fine ascolto (opzionale)</label>
            <div class="time-group" style="display: flex; gap: 1rem; align-items: center;">
              <div style="flex: 1;">
                <label for="fineMin" style="font-size: 0.85rem; color: #666;">Minuti</label>
                <input id="fineMin" name="fineMin" type="number" min="0" max="999" placeholder="0" autocomplete="off" style="text-align: center;" />
              </div>
              <div style="flex: 1;">
                <label for="fineSec" style="font-size: 0.85rem; color: #666;">Secondi</label>
                <input id="fineSec" name="fineSec" type="number" min="0" max="59" placeholder="0" autocomplete="off" style="text-align: center;" />
              </div>
            </div>
            <p class="helper-text">Lascia vuoto per ascoltare fino alla fine</p>
          </div>

          <!-- Box riepilogo dati prima del salvataggio -->
          <div class="player-meta">
            <h4 style="margin: 0 0 0.75rem 0; color: var(--primary-color); font-size: 0.95rem;">
              <i class="bi bi-info-circle"></i> Dati da salvare:
            </h4>
            <div>
              <span class="label">Nome Video:</span>
              <span class="value" id="playerMetaNome">-</span>
            </div>
            <div>
              <span class="label">Categoria:</span>
              <span class="value" id="playerMetaCategoria">-</span>
            </div>
            <div>
              <span class="label">Utente:</span>
              <span class="value" id="playerMetaUtente">-</span>
            </div>
          </div>
          
          <div class="form-actions">
            <button type="submit" class="btn-primary"><i class="bi bi-save"></i> Salva brano</button>
            <button type="button" class="btn-secondary" id="resetFormButton"><i class="bi bi-eraser"></i> Svuota campi</button>
          </div>
          <div id="statusMessage" class="status-message" role="status" aria-live="polite"></div>
        </form>
      </section>
    </div>
  `;
  
  // Aspetto che il DOM sia renderizzato, POI nascondo i link esterni
  setTimeout(() => {
    detectPWAMode();
  }, 100);
}

function cacheEducatorRefs() {
  // Salvo il riferimento alla finestra YouTube se esiste
  const existingYouTubeWindow = ui.youtubeWindow;

  ui = {
    form: document.getElementById('videoForm'),
    utente: document.getElementById('utenteInput'),
    categoria: document.getElementById('categoriaInput'),
    nome: document.getElementById('nomeVideoInput'),
    link: document.getElementById('linkVideoInput'),
    inizioMin: document.getElementById('inizioMin'),
    inizioSec: document.getElementById('inizioSec'),
    fineMin: document.getElementById('fineMin'),
    fineSec: document.getElementById('fineSec'),
    status: document.getElementById('statusMessage'),
    resetBtn: document.getElementById('resetFormButton'),
    playerMetaNome: document.getElementById('playerMetaNome'),
    playerMetaCategoria: document.getElementById('playerMetaCategoria'),
    playerMetaUtente: document.getElementById('playerMetaUtente'),
  };

  // Ripristino il riferimento alla finestra YouTube se esisteva
  ui.youtubeWindow = existingYouTubeWindow || null;
}

// Carica lista pazienti dal database
function loadPazienti() {
  if (!ui.utente) {
    return;
  }

  fetch(`${API_ENDPOINT}?action=get_pazienti`)
    .then(async (response) => {
      if (!response.ok) {
        const text = await response.text();
        throw new Error(text || 'Errore caricamento pazienti');
      }
      return response.json();
    })
    .then((data) => {
      if (!data.success || !data.data) {
        throw new Error('Risposta non valida dal server');
      }
      
      // Popolo il dropdown
      ui.utente.innerHTML = '<option value="">-- Seleziona un paziente --</option>';
      
      data.data.forEach(paziente => {
        const option = document.createElement('option');
        option.value = `${paziente.nome_paziente} ${paziente.cognome_paziente}`;
        option.textContent = `${paziente.cognome_paziente} ${paziente.nome_paziente}`;
        option.dataset.idPaziente = paziente.id_paziente;
        ui.utente.appendChild(option);
      });
    })
    .catch((error) => {
      console.error('Errore caricamento pazienti:', error);
      ui.utente.innerHTML = '<option value="">Errore caricamento pazienti</option>';
      showStatus('Impossibile caricare la lista pazienti. Ricarica la pagina.', 'error');
    });
}

function bindEducatorEvents() {
  let typingTimer;
  const doneTypingInterval = 1000; // 1 secondo dopo aver finito di digitare
  
  ui.categoria?.addEventListener('input', (event) => {
    clearTimeout(typingTimer);
    const query = event.target.value.trim();
    
    // Dopo 1 secondo di inattività, apro/aggiorno YouTube
    if (query.length >= 3) {
      typingTimer = setTimeout(() => {
        openOrUpdateYouTube(query);
      }, doneTypingInterval);
    }
  });

  ui.nome?.addEventListener('input', () => updatePlayerMeta());
  ui.utente?.addEventListener('change', () => updatePlayerMeta());
  ui.link?.addEventListener('input', (event) => {
    const link = event.target.value.trim();
    updatePlayerMeta();
    // Suggerisco il nome del video se il campo è vuoto
    if (link && !ui.nome?.value.trim()) {
      showStatus('Inserisci un nome per il brano prima di salvare', 'info');
    }
  });
  
  ui.form?.addEventListener('submit', handleFormSubmit);
  ui.resetBtn?.addEventListener('click', resetFormFields);
}

function handleFormSubmit(event) {
  event.preventDefault();
  if (!ui.form) {
    return;
  }

  const nomeUtente = ui.utente?.value.trim();
  const categoria = ui.categoria?.value.trim();
  const nomeVideo = ui.nome?.value.trim();
  const link = ui.link?.value.trim();
  const videoId = extractVideoId(link || '');

  // Recupero i valori dei tempi (opzionali)
  const inizioMin = parseInt(ui.inizioMin?.value || '0') || 0;
  const inizioSec = parseInt(ui.inizioSec?.value || '0') || 0;
  const fineMin = parseInt(ui.fineMin?.value || '0') || 0;
  const fineSec = parseInt(ui.fineSec?.value || '0') || 0;

  // Converto minuti:secondi → secondi totali
  const inizioBrano = (inizioMin * 60) + inizioSec;
  const fineBrano = (fineMin * 60) + fineSec;

  // Validazione tempi
  if (fineBrano > 0 && inizioBrano >= fineBrano) {
    showStatus('⚠️ Il tempo di fine deve essere maggiore del tempo di inizio!', 'error');
    return;
  }

  if (!nomeUtente || !categoria || !nomeVideo || !link) {
    showStatus('Compila tutti i campi obbligatori prima di salvare.', 'error');
    return;
  }

  if (!videoId) {
    showStatus('Il link inserito non sembra un URL YouTube valido.', 'error');
    return;
  }

  showStatus('Salvataggio in corso...', 'info');
  
  // Modalità offline: salva direttamente in localStorage
  if (!appState.isOnline) {
    const storageKey = `localBrani_${nomeUtente}`;
    let brani = [];
    
    try {
      const braniJSON = localStorage.getItem(storageKey);
      if (braniJSON) {
        brani = JSON.parse(braniJSON);
      }
    } catch (error) {
      console.error('Errore parsing brani locali:', error);
    }
    
    // Verifico se il brano esiste già
    const exists = brani.some(b => b.link_youtube === link);
    if (exists) {
      showStatus('Questo brano è già presente nella lista dell\'utente!', 'error');
      return;
    }
    
    // Aggiungo il nuovo brano
    brani.push({
      nome_video: nomeVideo,
      categoria,
      link_youtube: link,
      inizio_brano: inizioBrano,
      fine_brano: fineBrano,
    });

    // Salvo in localStorage
    localStorage.setItem(storageKey, JSON.stringify(brani));
    showStatus(`✅ Brano salvato localmente per ${nomeUtente}!`, 'success');
    ui.form.reset();
    updatePlayerMeta();

    // Ricarico la lista utenti per aggiornare l'autocompletamento
    loadLocalUsers();
    return;
  }

  // Modalità online: salva nel database
  const payload = {
    action: 'save',
    nome_video: nomeVideo,
    categoria,
    link_youtube: link,
    nome_utente: nomeUtente,
    inizio_brano: inizioBrano,
    fine_brano: fineBrano,
  };

  fetch(API_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
    body: JSON.stringify(payload),
  })
    .then(async (response) => {
      if (!response.ok) {
        const text = await response.text();
        throw new Error(text || 'Errore sconosciuto');
      }
      return response.json();
    })
    .then((data) => {
      if (!data.success) {
        throw new Error(data.error || 'Impossibile salvare il brano');
      }
      showStatus('Brano salvato correttamente!', 'success');

      // Sincronizzo anche in localStorage se esiste un utente locale con lo stesso nome
      saveToLocalStorageIfExists(nomeUtente, {
        nome_video: nomeVideo,
        categoria,
        link_youtube: link,
        inizio_brano: inizioBrano,
        fine_brano: fineBrano,
      });

      ui.form.reset();
      updatePlayerMeta();
    })
    .catch((error) => {
      console.error('Errore salvataggio video_yt:', error);
      showStatus(`Errore salvataggio: ${error.message}`, 'error');
    });
}

function openOrUpdateYouTube(query) {
  // YouTube funziona solo se c'è connessione internet (indipendente da database)
  if (!appState.hasInternet) {
    showStatus('⚠️ YouTube non disponibile senza connessione internet. Cerca il brano su un altro dispositivo, copia il link e incollalo qui.', 'info');
    return;
  }
  
  const searchQuery = query || DEFAULT_SEARCH_QUERY;
  const url = `https://www.youtube.com/results?search_query=${encodeURIComponent(searchQuery)}`;
  
  // Calcolo dimensioni per posizionamento ottimale
  const screenWidth = window.screen.availWidth;
  const screenHeight = window.screen.availHeight;
  const screenLeft = window.screen.availLeft || 0;
  
  // Rilevo se è un tablet (iPad o Android tablet)
  const isTablet = /iPad|Android/i.test(navigator.userAgent) && 
                   (window.screen.width >= 768 && window.screen.width <= 1366) &&
                   (Math.abs(window.orientation) === 90 || Math.abs(window.orientation) === 0 || window.orientation === undefined);
  
  // Su TABLET: finestra al 50% (metà schermo) sulla destra
  // Su DESKTOP: finestra al 66.67% (2/3 schermo) sulla destra
  const widthRatio = isTablet ? 0.5 : 0.667;
  const youtubeWidth = Math.floor(screenWidth * widthRatio);
  const youtubeHeight = Math.floor(screenHeight * 0.75);
  const youtubeLeft = screenLeft + Math.floor(screenWidth * (1 - widthRatio)); // Allineato a destra
  const youtubeTop = 0;
  
  console.log(`📱 Device: ${isTablet ? 'TABLET' : 'DESKTOP'} - Popup YouTube: ${youtubeWidth}x${youtubeHeight}px (${Math.round(widthRatio * 100)}% larghezza)`);
  
  // Chiudo eventuali finestre YouTube precedenti prima di aprirne/aggiornarne una
  if (ui.youtubeWindow && !ui.youtubeWindow.closed) {
    // Finestra già aperta: aggiorno solo l'URL e la porto in primo piano
    try {
      ui.youtubeWindow.location.href = url;
      ui.youtubeWindow.focus();
      return; // Esco subito per evitare di aprire una nuova finestra
    } catch (e) {
      // Se fallisce (es. finestra chiusa nel frattempo), chiudo e riapro
      console.log('Impossibile aggiornare finestra YouTube esistente, la riapro:', e.message);
      try {
        ui.youtubeWindow.close();
      } catch (closeError) {
        console.log('Errore chiusura finestra YouTube:', closeError.message);
      }
      ui.youtubeWindow = null;
    }
  }
  
  // Apro nuova finestra YouTube
  ui.youtubeWindow = window.open(
    url,
    'YouTubeSearch',
    `width=${youtubeWidth},height=${youtubeHeight},left=${youtubeLeft},top=${youtubeTop},screenX=${youtubeLeft},screenY=${youtubeTop},scrollbars=yes,resizable=yes,menubar=no,toolbar=yes,location=yes`
  );
  
  if (!ui.youtubeWindow) {
    alert('Impossibile aprire YouTube. Verifica che i popup non siano bloccati dal browser.\n\nDopo aver abilitato i popup, ricarica la pagina.');
  } else {
    // Porto in primo piano la nuova finestra
    ui.youtubeWindow.focus();
  }
}

function resetFormFields() {
  if (!ui.form) {
    return;
  }
  ui.form.reset();
  updatePlayerMeta();
  showStatus('Campi puliti. Inserisci i nuovi dati.', 'info');
}

// Aggiorna solo i metadata del box riepilogo (non c'è più iframe)
function updatePlayerMeta() {
  if (ui.playerMetaNome) {
    ui.playerMetaNome.textContent = ui.nome?.value.trim() || '-';
  }
  if (ui.playerMetaCategoria) {
    ui.playerMetaCategoria.textContent = ui.categoria?.value.trim() || '-';
  }
  if (ui.playerMetaUtente) {
    ui.playerMetaUtente.textContent = ui.utente?.value.trim() || '-';
  }
}

function showStatus(message, type) {
  if (!ui.status) {
    return;
  }
  ui.status.className = `status-message ${type}`;
  ui.status.textContent = message;
}

function extractVideoId(url) {
  if (!url) {
    return null;
  }
  try {
    const parsed = new URL(url);
    if (parsed.hostname.includes('youtu.be')) {
      return parsed.pathname.split('/').pop();
    }
    if (parsed.searchParams.has('v')) {
      return parsed.searchParams.get('v');
    }
    if (parsed.pathname.includes('/embed/')) {
      return parsed.pathname.split('/embed/')[1];
    }
  } catch (error) {
    return null;
  }
  return null;
}

// ==================== AREA UTENTE ====================

function renderUserUI() {
  const mainContent = document.getElementById('appMain');
  if (!mainContent) {
    return;
  }
  
  // Rimuovo la classe educator-mode e aggiungo user-mode-active
  document.body.classList.remove('educator-mode');
  document.body.classList.add('user-mode-active');
  
  mainContent.innerHTML = `
    <!-- Overlay per menu opzioni -->
    <div class="user-options-overlay" id="userOptionsOverlay" onclick="toggleUserOptions()"></div>
    
    <!-- Menu opzioni laterale -->
    <nav class="user-options-menu" id="userOptionsMenu">
      <h4><i class="bi bi-sliders"></i> Opzioni di ascolto</h4>
      
      <div class="options-group">
        <label>
          <input type="radio" name="playMode" value="direct" id="radioDirect" checked>
          <span>Ascolto Diretto</span>
        </label>
        
        <label>
          <input type="radio" name="playMode" value="random" id="radioRandom">
          <span>Ascolto Random</span>
        </label>
        
        <label>
          <input type="radio" name="playMode" value="timed" id="radioTimed">
          <span>Ascolto Temporizzato</span>
        </label>
        
        <label>
          <input type="radio" name="playMode" value="persistent" id="radioPersistent">
          <span>🔒 Timer Persistente</span>
        </label>
      </div>
      
      <div class="timer-controls" id="timerControlsBox">
        <label for="timerSlider">Durata ascolto (secondi)</label>
        <input type="range" id="timerSlider" min="5" max="120" value="30" step="5">
        <span class="timer-value" id="timerValue">30s</span>
        <p style="margin-top: 1rem; font-size: 0.85rem; color: #666; line-height: 1.6;">
          <i class="bi bi-info-circle"></i> Dopo questo tempo, il brano andrà in pausa. 
          Premi <strong>SPAZIO</strong> per riprendere.
        </p>
      </div>
      
      <div class="direct-info active" id="directInfoBox">
        <p style="font-size: 0.9rem; color: #666; line-height: 1.7;">
          <i class="bi bi-info-circle"></i> In modalità <strong>Ascolto Diretto</strong>, 
          seleziona un brano dalla lista oppure premi <strong>SPAZIO</strong> per riprodurre il brano successivo. 
          Ogni brano continuerà fino alla fine senza pause.
        </p>
      </div>
      
      <div class="random-info" id="randomInfoBox">
        <p style="font-size: 0.9rem; color: #666; line-height: 1.7;">
          <i class="bi bi-info-circle"></i> In modalità <strong>Ascolto Random</strong>, 
          premi <strong>SPAZIO</strong> per riprodurre un brano casuale dalla tua lista. 
          Il brano continuerà fino alla fine.
        </p>
      </div>
      
      <div class="persistent-info" id="persistentInfoBox">
        <p style="font-size: 0.9rem; color: #666; line-height: 1.7;">
          <i class="bi bi-shield-lock"></i> In modalità <strong>🔒 Timer Persistente</strong>, 
          premi <strong>SPAZIO</strong> per avviare un brano. Durante il timer, <strong>SPAZIO sarà disabilitato</strong> 
          (anche se premuto involontariamente). La musica continuerà per il tempo impostato, 
          poi si fermerà automaticamente. Ideale per deficit motori con cloni involontari del braccio.
        </p>
      </div>
      
      <div style="margin-top: 2rem; padding-top: 2rem; border-top: 2px solid rgba(103, 58, 183, 0.1);">
        <button class="btn-primary" id="playActionButton" onclick="handlePlayAction()" style="width: 100%; margin: 0;">
          <i class="bi bi-play-circle" id="playActionIcon"></i> 
          <span id="playActionText">Play Brano Diretto</span>
        </button>
        <p id="playActionDescription" style="margin-top: 0.75rem; font-size: 0.8rem; color: #666; text-align: center;">
          Avvia l'ultimo brano selezionato
        </p>
      </div>
    </nav>
    
    <!-- Indicatore SPACE -->
    <div class="space-indicator" id="spaceIndicator">
      <i class="bi bi-pause-circle"></i> Premi SPAZIO per riprendere
    </div>
    
    <div class="user-layout">
      <!-- Box selezione utente + lista brani (sinistra) -->
      <section class="panel user-panel">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
          <h3 style="margin: 0;"><i class="bi bi-headphones"></i> I tuoi brani</h3>
          <button 
            class="btn-secondary" 
            onclick="switchToEducatorMode()"
            title="Vai all'Area Educatore"
            style="padding: 0.4rem 0.8rem; font-size: 0.85rem;"
          >
            <i class="bi bi-person-workspace"></i> Educatore
          </button>
        </div>
        <p class="helper-text" id="userHelperText">${appState.isOnline ? 'Seleziona il tuo nome per vedere i brani disponibili.' : `Benvenuto <strong>${appState.currentUserName || ''}</strong>!`}</p>
        
        <!-- Dropdown utenti online (database) -->
        <div class="form-group" id="userInputGroup" style="display: ${appState.isOnline ? 'block' : 'none'};">
          <label for="userSelectInput">Il tuo nome *</label>
          <select id="userSelectInput" required>
            <option value="">Caricamento pazienti...</option>
          </select>
        </div>
        
        <!-- Dropdown cambia utente locale (PWA) -->
        <div class="form-group" id="localUserSwitchGroup" style="display: ${!appState.isOnline && appState.currentUserName ? 'block' : 'none'};">
          <label for="localUserSwitch">Cambia utente</label>
          <select id="localUserSwitch" onchange="handleLocalUserSwitch(this.value)" style="font-size: 1.1rem; padding: 0.6rem;">
            <option value="">-- Seleziona un altro utente --</option>
          </select>
          <p class="helper-text" style="margin-top: 0.5rem; font-size: 0.85rem;">
            <i class="bi bi-info-circle"></i> Oppure 
            <a href="#" onclick="event.preventDefault(); showLocalUserLogin();" style="color: var(--primary-color); font-weight: 600;">aggiungi nuovo utente</a>
          </p>
        </div>
        
        <div id="userBraniContainer" style="display: none; margin-top: 1.5rem;">
          <h4 style="color: var(--primary-color); margin-bottom: 1rem;">
            <i class="bi bi-music-note-list"></i> Lista brani
          </h4>
          <div id="userBraniList" class="brani-list">
            <!-- Lista brani verrà popolata dinamicamente -->
          </div>
        </div>
      </section>
      
      <!-- Box player (destra) -->
      <section class="user-player-panel">
        <h3 style="color: var(--primary-color); margin-bottom: 1rem;">
          <i class="bi bi-play-circle"></i> Player
        </h3>
        <p id="userCurrentSong" style="font-weight: 600; margin-bottom: 1.5rem; font-size: 1.1rem;">
          Nessun brano selezionato
        </p>
        
        <!-- Player YouTube (grande per ipovedenti) -->
        <div class="iframe-wrapper">
          <div id="userPlayerFrame" style="display: flex; align-items: center; justify-content: center; background: #f0f0f0; color: #666; font-size: 1.2rem; text-align: center; padding: 2rem;">
            <div>
              <i class="bi bi-music-note-beamed" style="font-size: 3rem; display: block; margin-bottom: 1rem;"></i>
              <p>🎵 Seleziona un brano dalla lista per iniziare</p>
              <small style="font-size: 0.9rem; display: block; margin-top: 0.5rem;">Il player si caricherà automaticamente</small>
            </div>
          </div>
        </div>
      </section>
    </div>
  `;
  
  // Precarico l'API YouTube se non è ancora stata caricata
  ensureYouTubeAPILoaded();
  
  // Aspetto che il DOM sia renderizzato, POI nascondo i link esterni
  setTimeout(() => {
    detectPWAMode();
  }, 100);
}

// Assicura che l'API YouTube sia caricata e mostra lo stato
function ensureYouTubeAPILoaded() {
  if (typeof YT !== 'undefined' && typeof YT.Player !== 'undefined') {
    console.log('✅ API YouTube già caricata');
    return;
  }
  
  console.log('⏳ Precarico API YouTube...');
  
  // Aspetto che l'API si carichi (max 10 secondi)
  let checkCount = 0;
  const maxChecks = 20; // 20 x 500ms = 10 secondi
  
  const checkInterval = setInterval(() => {
    checkCount++;
    
    if (typeof YT !== 'undefined' && typeof YT.Player !== 'undefined') {
      console.log('✅ API YouTube caricata e pronta!');
      clearInterval(checkInterval);
    } else if (checkCount >= maxChecks) {
      console.error('❌ Timeout: API YouTube non caricata dopo 10 secondi');
      console.warn('⚠️ Verifica la connessione internet o ricarica la pagina');
      clearInterval(checkInterval);
    } else {
      console.log(`⏳ Attendo API YouTube... (tentativo ${checkCount}/${maxChecks})`);
    }
  }, 500);
}

function cacheUserRefs() {
  ui = {
    userSelect: document.getElementById('userSelectInput'),
    userBraniContainer: document.getElementById('userBraniContainer'),
    userBraniList: document.getElementById('userBraniList'),
    userPlayerFrame: document.getElementById('userPlayerFrame'), // Ora è un div, non un iframe
    userCurrentSong: document.getElementById('userCurrentSong'),
    userOptionsMenu: document.getElementById('userOptionsMenu'),
    userOptionsOverlay: document.getElementById('userOptionsOverlay'),
    radioDirect: document.getElementById('radioDirect'),
    radioRandom: document.getElementById('radioRandom'),
    radioTimed: document.getElementById('radioTimed'),
    timerSlider: document.getElementById('timerSlider'),
    timerValue: document.getElementById('timerValue'),
    timerControlsBox: document.getElementById('timerControlsBox'),
    directInfoBox: document.getElementById('directInfoBox'),
    randomInfoBox: document.getElementById('randomInfoBox'),
    persistentInfoBox: document.getElementById('persistentInfoBox'),
    spaceIndicator: document.getElementById('spaceIndicator'),
    playActionButton: document.getElementById('playActionButton'),
    playActionIcon: document.getElementById('playActionIcon'),
    playActionText: document.getElementById('playActionText'),
    playActionDescription: document.getElementById('playActionDescription'),
  };
}

function bindUserEvents() {
  ui.userSelect?.addEventListener('change', handleUserSelection);
  
  // Eventi per radio button (modalità direct/random/timed)
  ui.radioDirect?.addEventListener('change', handlePlayModeChange);
  ui.radioRandom?.addEventListener('change', handlePlayModeChange);
  ui.radioTimed?.addEventListener('change', handlePlayModeChange);
  
  // Evento per slider durata timer
  ui.timerSlider?.addEventListener('input', handleTimerSliderChange);
  
  // Evento tastiera per controllo SPACE
  document.addEventListener('keydown', handleSpaceKeyDown);
  document.addEventListener('keyup', handleSpaceKeyUp);
}

function handleUserSelection(event) {
  const userName = event.target.value;
  if (!userName) {
    ui.userBraniContainer.style.display = 'none';
    ui.userPlayerContainer.style.display = 'none';
    return;
  }
  
  // Carico i brani dell'utente selezionato
  loadUserBrani(userName);
}

function loadUserBrani(userName) {
  if (!ui.userBraniList) {
    return;
  }
  
  ui.userBraniList.innerHTML = '<p style="color: #666;"><i class="bi bi-hourglass-split"></i> Caricamento brani...</p>';
  ui.userBraniContainer.style.display = 'block';
  
  fetch(`${API_ENDPOINT}?action=list&nome_utente=${encodeURIComponent(userName)}`)
    .then(async (response) => {
      if (!response.ok) {
        const text = await response.text();
        throw new Error(text || 'Errore caricamento brani');
      }
      return response.json();
    })
    .then((data) => {
      if (!data.success || !data.data) {
        throw new Error('Risposta non valida dal server');
      }
      
      if (data.data.length === 0) {
        ui.userBraniList.innerHTML = '<p style="color: #666;"><i class="bi bi-music-note"></i> Nessun brano trovato per questo utente.</p>';
        appState.currentBrani = [];
        return;
      }
      
      // Mappo id_video → id per compatibilità con il resto del codice
      const braniMapped = data.data.map(brano => ({
        ...brano,
        id: brano.id_video || brano.id // Supporto sia id_video che id
      }));
      
      // Salvo i brani nello stato per modalità random
      appState.currentBrani = braniMapped;
      
      // Popolo la lista dei brani (uso braniMapped con id mappato)
      ui.userBraniList.innerHTML = braniMapped.map((brano, index) => {
        const inizioBrano = parseInt(brano.inizio_brano || 0);
        const fineBrano = parseInt(brano.fine_brano || 0);
        const hasTimeLimits = inizioBrano > 0 || fineBrano > 0;

        let timeInfo = '';
        if (hasTimeLimits) {
          const formatTime = (seconds) => {
            const min = Math.floor(seconds / 60);
            const sec = seconds % 60;
            return `${min}:${sec.toString().padStart(2, '0')}`;
          };

          if (inizioBrano > 0 && fineBrano > 0) {
            timeInfo = `<small style="color: #ff9800;"><i class="bi bi-clock"></i> ${formatTime(inizioBrano)} - ${formatTime(fineBrano)}</small>`;
          } else if (inizioBrano > 0) {
            timeInfo = `<small style="color: #ff9800;"><i class="bi bi-clock"></i> Inizio: ${formatTime(inizioBrano)}</small>`;
          } else if (fineBrano > 0) {
            timeInfo = `<small style="color: #ff9800;"><i class="bi bi-clock"></i> Fine: ${formatTime(fineBrano)}</small>`;
          }
        }

        return `
        <div class="brano-item" data-id="${brano.id || ''}" data-link="${brano.link_youtube}" data-index="${index}">
          <div class="brano-info" onclick="selectBrano('${brano.link_youtube}', '${brano.nome_video.replace(/'/g, "\\'")}', ${index})">
            <i class="bi bi-music-note-beamed"></i>
            <div>
              <strong>${brano.nome_video}</strong>
              <small>${brano.categoria}</small>
              ${timeInfo}
            </div>
          </div>
          <div class="brano-actions">
            <button class="btn-play" onclick="selectBrano('${brano.link_youtube}', '${brano.nome_video.replace(/'/g, "\\'")}', ${index})" title="Riproduci brano">
              <i class="bi bi-play-circle"></i>
            </button>
            <button class="btn-delete" onclick="deleteBrano(${brano.id || 'null'}, '${brano.nome_video.replace(/'/g, "\\'")}', '${brano.link_youtube}')" title="Elimina brano">
              <i class="bi bi-trash3"></i>
            </button>
          </div>
        </div>
        `;
      }).join('');
      
    })
    .catch((error) => {
      console.error('Errore caricamento brani:', error);
      ui.userBraniList.innerHTML = '<p style="color: #d32f2f;"><i class="bi bi-exclamation-triangle"></i> Errore nel caricamento dei brani.</p>';
      appState.currentBrani = [];
    });
}

function selectBrano(linkYoutube, nomeBrano, branoIndex = -1) {
  console.log(`🎵 selectBrano chiamato: "${nomeBrano}" (index: ${branoIndex})`);

  const videoId = extractVideoId(linkYoutube);

  if (!videoId) {
    console.error('❌ Video ID non valido:', linkYoutube);
    alert('⚠️ Link YouTube non valido!\n\nVerifica che il link sia corretto.');
    return;
  }

  if (!ui.userPlayerFrame) {
    console.error('❌ userPlayerFrame non trovato nel DOM');
    alert('⚠️ Errore: Player non trovato!\n\nRicarica la pagina.');
    return;
  }

  console.log(`✅ Video ID estratto: ${videoId}`);

  // Recupero i tempi del brano se disponibili
  let inizioBrano = 0;
  let fineBrano = 0;

  if (branoIndex >= 0 && appState.currentBrani[branoIndex]) {
    const brano = appState.currentBrani[branoIndex];
    inizioBrano = parseInt(brano.inizio_brano || 0);
    fineBrano = parseInt(brano.fine_brano || 0);
    console.log(`⏱️ Tempi brano: inizio=${inizioBrano}s, fine=${fineBrano}s`);
  }

  // Salvo il brano selezionato per la modalità direct
  appState.lastSelectedBrano = { linkYoutube, nomeBrano, inizioBrano, fineBrano };
  appState.currentVideoId = videoId;

  // Salvo l'indice del brano se fornito (per modalità direct)
  if (branoIndex >= 0) {
    appState.currentBranoIndex = branoIndex;
  } else {
    // Se non fornito, cerco l'indice nella lista
    const index = appState.currentBrani.findIndex(b => b.link_youtube === linkYoutube);
    appState.currentBranoIndex = index >= 0 ? index : -1;
  }

  console.log(`📍 Brano index: ${appState.currentBranoIndex} di ${appState.currentBrani.length}`);
  
  // Resetto lo stato del timer
  appState.isTimerPaused = false;
  if (appState.timerTimeoutId) {
    clearTimeout(appState.timerTimeoutId);
    console.log('⏹️ Timer precedente fermato');
  }
  ui.spaceIndicator?.classList.remove('active');
  
  // Aggiorno il nome del brano con feedback visivo
  if (ui.userCurrentSong) {
    ui.userCurrentSong.textContent = `▶️ ${nomeBrano}`;
    console.log('✅ Nome brano aggiornato nell\'UI');
  }
  
  // Se il player esiste già, carico il nuovo video
  if (appState.youtubePlayer && typeof appState.youtubePlayer.loadVideoById === 'function') {
    console.log('🔄 Player esistente trovato, carico nuovo video...');
    try {
      appState.youtubePlayer.loadVideoById(videoId);
      console.log('✅ Video caricato nel player esistente');
    } catch (error) {
      console.error('❌ Errore nel caricamento video:', error);
      // Se c'è un errore, provo a ricreare il player
      console.log('🔄 Ricreo il player da zero...');
      initYouTubePlayer(videoId);
    }
  } else {
    // Altrimenti creo un nuovo player
    console.log('🆕 Player non esistente, creo nuovo player...');
    initYouTubePlayer(videoId);
  }
  
  // Se modalità temporizzata, avvio il timer
  if (appState.playMode === 'timed') {
    console.log(`⏲️ Modalità temporizzata: avvio timer di ${appState.timerDuration}s`);
    startPlayTimer(videoId, nomeBrano);
  }
  
  console.log('✅ selectBrano completato');
}

// Inizializza il player YouTube con l'API
function initYouTubePlayer(videoId) {
  if (!ui.userPlayerFrame) {
    console.error('❌ userPlayerFrame non trovato');
    return;
  }
  
  // CONTROLLO CRITICO: Verifica che l'API YouTube sia caricata
  if (typeof YT === 'undefined' || typeof YT.Player === 'undefined') {
    console.warn('⏳ API YouTube non ancora caricata, attendo...');
    
    // Mostro feedback all'utente
    if (ui.userCurrentSong) {
      ui.userCurrentSong.textContent = '⏳ Caricamento player YouTube in corso...';
    }
    
    // Riprovo dopo 500ms (max 10 tentativi = 5 secondi)
    let retryCount = 0;
    const maxRetries = 10;
    
    const retryInterval = setInterval(() => {
      retryCount++;
      
      if (typeof YT !== 'undefined' && typeof YT.Player !== 'undefined') {
        console.log('✅ API YouTube caricata! Creo il player...');
        clearInterval(retryInterval);
        initYouTubePlayer(videoId); // Richiamo la funzione ora che l'API è pronta
      } else if (retryCount >= maxRetries) {
        console.error('❌ Timeout: API YouTube non caricata dopo 5 secondi');
        clearInterval(retryInterval);
        
        if (ui.userCurrentSong) {
          ui.userCurrentSong.innerHTML = '❌ Errore caricamento YouTube. <a href="#" onclick="location.reload()">Ricarica la pagina</a>';
        }
        
        alert('⚠️ Errore nel caricamento del player YouTube.\n\nRicarica la pagina e riprova.');
      }
    }, 500);
    
    return;
  }
  
  // Distruggo il player esistente se presente
  if (appState.youtubePlayer) {
    try {
      appState.youtubePlayer.destroy();
      console.log('🗑️ Player precedente distrutto');
    } catch (e) {
      console.log('⚠️ Errore distruzione player:', e);
    }
  }
  
  console.log(`🎵 Creazione player YouTube per video: ${videoId}`);
  
  // Creo un nuovo player YouTube
  try {
    appState.youtubePlayer = new YT.Player('userPlayerFrame', {
      height: '100%',
      width: '100%',
      videoId: videoId,
      playerVars: {
        autoplay: 1,
        modestbranding: 1,
        rel: 0,
      },
      events: {
        onReady: onPlayerReady,
        onStateChange: onPlayerStateChange,
      },
    });
  } catch (error) {
    console.error('❌ Errore creazione player YouTube:', error);
    
    if (ui.userCurrentSong) {
      ui.userCurrentSong.textContent = '❌ Errore nella creazione del player';
    }
    
    alert('⚠️ Errore nella creazione del player YouTube.\n\nRicarica la pagina e riprova.');
  }
}

function onPlayerReady(event) {
  console.log('Player YouTube pronto');

  // Se c'è un tempo di inizio, faccio il seek
  if (appState.lastSelectedBrano && appState.lastSelectedBrano.inizioBrano > 0) {
    const inizioSecondi = appState.lastSelectedBrano.inizioBrano;
    console.log(`⏩ Seek al secondo ${inizioSecondi}`);
    event.target.seekTo(inizioSecondi, true);
  }

  event.target.playVideo();

  // Se c'è un tempo di fine, avvio il controllo periodico
  if (appState.lastSelectedBrano && appState.lastSelectedBrano.fineBrano > 0) {
    startEndTimeMonitor();
  }
}

function onPlayerStateChange(event) {
  // Stato player: -1 (non iniziato), 0 (finito), 1 (play), 2 (pausa), 3 (buffering), 5 (cued)
  console.log('Stato player cambiato:', event.data);

  // Se il video è in riproduzione (stato 1), monitoraggio il tempo di fine
  if (event.data === 1 && appState.lastSelectedBrano && appState.lastSelectedBrano.fineBrano > 0) {
    startEndTimeMonitor();
  } else if (event.data !== 1) {
    // Se non è in riproduzione, ferma il monitor
    stopEndTimeMonitor();
  }
}

// Monitora il tempo corrente e ferma al tempo di fine impostato
function startEndTimeMonitor() {
  // Ferma eventuali monitor precedenti
  stopEndTimeMonitor();

  if (!appState.youtubePlayer || !appState.lastSelectedBrano || appState.lastSelectedBrano.fineBrano <= 0) {
    return;
  }

  const fineSecondi = appState.lastSelectedBrano.fineBrano;

  appState.endTimeMonitorInterval = setInterval(() => {
    if (!appState.youtubePlayer || typeof appState.youtubePlayer.getCurrentTime !== 'function') {
      stopEndTimeMonitor();
      return;
    }

    const currentTime = appState.youtubePlayer.getCurrentTime();

    if (currentTime >= fineSecondi) {
      console.log(`⏹️ Raggiunto il tempo di fine (${fineSecondi}s), fermo il video`);
      appState.youtubePlayer.pauseVideo();
      stopEndTimeMonitor();

      // NON mostro l'indicatore SPAZIO quando finisce per tempo impostato
      // (diverso dal timer temporizzato che invece lo mostra)
      ui.spaceIndicator?.classList.remove('active');
    }
  }, 250); // Controllo ogni 250ms per maggiore precisione
}

function stopEndTimeMonitor() {
  if (appState.endTimeMonitorInterval) {
    clearInterval(appState.endTimeMonitorInterval);
    appState.endTimeMonitorInterval = null;
  }
}

function startPlayTimer(videoId, nomeBrano) {
  // Cancello eventuali timer precedenti
  if (appState.timerTimeoutId) {
    clearTimeout(appState.timerTimeoutId);
  }
  
  const duration = appState.timerDuration * 1000; // Converti in millisecondi
  
  appState.timerTimeoutId = setTimeout(() => {
    // Metto in pausa usando l'API YouTube
    if (appState.youtubePlayer && typeof appState.youtubePlayer.pauseVideo === 'function') {
      appState.youtubePlayer.pauseVideo();
      appState.isTimerPaused = true;
      
      // Mostro indicatore SPACE
      ui.spaceIndicator?.classList.add('active');
      
      console.log('Timer scaduto - video in pausa. Premi SPAZIO per continuare.');
    }
  }, duration);
}

function resumePlayAfterPause() {
  if (!appState.isTimerPaused) {
    return; // Non in pausa, ignoro
  }
  
  // Riprendo la riproduzione usando l'API YouTube
  if (appState.youtubePlayer && typeof appState.youtubePlayer.playVideo === 'function') {
    appState.youtubePlayer.playVideo();
    
    // Resetto lo stato
    appState.isTimerPaused = false;
    ui.spaceIndicator?.classList.remove('active');
    
    const nomeBrano = ui.userCurrentSong?.textContent.replace('Ora in riproduzione: ', '') || 'Brano';
    
    // Riavvio il timer
    if (appState.currentVideoId) {
      startPlayTimer(appState.currentVideoId, nomeBrano);
    }
  }
}

function extractVideoIdFromEmbedUrl(embedUrl) {
  try {
    const url = new URL(embedUrl);
    const pathParts = url.pathname.split('/');
    // Formato: /embed/VIDEO_ID
    if (pathParts.length >= 3 && pathParts[1] === 'embed') {
      return pathParts[2];
    }
  } catch (e) {
    console.error('Errore estrazione videoId da embed URL:', e);
  }
  return null;
}

/**
 * TIMER PERSISTENTE: Avvia un brano casuale e IBERNA il tasto SPACE per la durata del timer
 * Durante il timer, nessun press su SPACE ha effetto (protegge da cloni involontari del braccio)
 */
function playPersistentTimerBrano() {
  if (!appState.currentBrani || appState.currentBrani.length === 0) {
    alert('Nessun brano disponibile. Seleziona prima un utente e carica i brani.');
    return;
  }
  
  const randomIndex = Math.floor(Math.random() * appState.currentBrani.length);
  const brano = appState.currentBrani[randomIndex];
  
  // Chiudo il menu opzioni dopo la selezione
  ui.userOptionsMenu?.classList.remove('active');
  ui.userOptionsOverlay?.classList.remove('active');
  
  // Seleziono il brano (avvia la riproduzione)
  selectBrano(brano.link_youtube, brano.nome_video);
  
  // 🔒 ATTIVA IL TIMER PERSISTENTE - SPACE sarà completamente IBERNATO
  appState.isPersistentTimerActive = true;
  appState.persistentTimerStartTime = Date.now();
  
  console.log(`🔒 Timer Persistente ATTIVATO per ${appState.timerDuration} secondi`);
  console.log('   SPACE è ora IBERNATO - tutti i press saranno ignorati');
  
  // Mostra feedback visivo (colore arancio nel player)
  if (ui.userCurrentSong) {
    ui.userCurrentSong.style.color = '#FF6F00';
    ui.userCurrentSong.innerHTML += ' <small>🔒 SPACE DISABILITATO</small>';
  }
  
  // Aggiorna il testo del bottone per mostrare che il timer è in corso
  if (ui.playActionText) {
    ui.playActionText.textContent = '🔒 Timer in corso...';
  }
  if (ui.playActionDescription) {
    ui.playActionDescription.textContent = `SPACE disabilitato per ${appState.timerDuration}s`;
  }
  
  // Imposta il timer per sgelare il SPACE dopo la durata
  if (appState.timerTimeoutId) {
    clearTimeout(appState.timerTimeoutId);
  }
  
  appState.timerTimeoutId = setTimeout(() => {
    // Scade il timer persistente - SPACE torna attivo
    appState.isPersistentTimerActive = false;
    appState.persistentTimerStartTime = null;
    appState.timerTimeoutId = null;
    
    console.log('✅ Timer Persistente SCADUTO - SPACE è di nuovo attivo');
    
    // Pausa il brano automaticamente
    if (appState.youtubePlayer && typeof appState.youtubePlayer.pauseVideo === 'function') {
      appState.youtubePlayer.pauseVideo();
      appState.isTimerPaused = true;
      
      // Mostra indicatore pausa
      ui.spaceIndicator?.classList.add('active');
      
      // Aggiorna visualmente il song display
      if (ui.userCurrentSong) {
        ui.userCurrentSong.style.color = 'inherit';
        ui.userCurrentSong.innerHTML = ui.userCurrentSong.innerHTML
          .replace(' <small>🔒 SPACE DISABILITATO</small>', '')
          .replace('Ora in riproduzione:', 'Pausa -');
      }
    }
    
    // Ripristina il testo del bottone (da "🔒 Timer in corso..." a "🔒 Play Timer Persistente")
    if (ui.playActionText) {
      ui.playActionText.textContent = '🔒 Play Timer Persistente';
    }
    if (ui.playActionDescription) {
      ui.playActionDescription.textContent = 'Avvia con SPACE disabilitato durante il timer';
    }
  }, appState.timerDuration * 1000);
}

function selectRandomBrano() {
  if (!appState.currentBrani || appState.currentBrani.length === 0) {
    alert('Nessun brano disponibile. Seleziona prima un utente e carica i brani.');
    return;
  }
  
  const randomIndex = Math.floor(Math.random() * appState.currentBrani.length);
  const brano = appState.currentBrani[randomIndex];
  
  // Chiudo il menu opzioni dopo la selezione
  ui.userOptionsMenu?.classList.remove('active');
  ui.userOptionsOverlay?.classList.remove('active');
  
  selectBrano(brano.link_youtube, brano.nome_video);
}

// Elimina un brano dall'archivio
function deleteBrano(branoId, nomeBrano, linkYoutube) {
  // Conferma eliminazione
  if (!confirm(`Vuoi davvero eliminare il brano:\n"${nomeBrano}"?\n\nQuesta azione non può essere annullata.`)) {
    return;
  }
  
  // Se non c'è un ID, uso il link come fallback
  const payload = branoId 
    ? { action: 'delete', id: branoId }
    : { action: 'delete', link_youtube: linkYoutube };
  
  // Mostro feedback
  const statusMsg = document.createElement('div');
  statusMsg.className = 'status-message info';
  statusMsg.textContent = 'Eliminazione in corso...';
  statusMsg.style.cssText = 'position: fixed; top: 100px; left: 50%; transform: translateX(-50%); z-index: 9999; padding: 1rem 2rem; background: rgba(33,150,243,0.95); color: white; border-radius: 8px; font-weight: 600;';
  document.body.appendChild(statusMsg);
  
  fetch(API_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
    body: JSON.stringify(payload),
  })
    .then(async (response) => {
      if (!response.ok) {
        const text = await response.text();
        throw new Error(text || 'Errore eliminazione');
      }
      return response.json();
    })
    .then((data) => {
      if (!data.success) {
        throw new Error(data.error || 'Impossibile eliminare il brano');
      }
      
      // Aggiorno il feedback
      statusMsg.className = 'status-message success';
      statusMsg.style.background = 'rgba(76,175,80,0.95)';
      statusMsg.textContent = 'Brano eliminato con successo!';
      
      // Rimuovo il brano dalla lista locale
      appState.currentBrani = appState.currentBrani.filter(b => {
        if (branoId) {
          return b.id !== branoId;
        }
        return b.link_youtube !== linkYoutube;
      });
      
      // Se il brano eliminato era quello in riproduzione, resetto il player
      if (appState.lastSelectedBrano && appState.lastSelectedBrano.linkYoutube === linkYoutube) {
        appState.lastSelectedBrano = null;
        if (appState.youtubePlayer) {
          appState.youtubePlayer.stopVideo();
        }
        ui.userCurrentSong.textContent = 'Nessun brano selezionato';
      }
      
      // Ricarico la lista brani
      const userName = ui.userSelect?.value;
      if (userName) {
        setTimeout(() => {
          loadUserBrani(userName);
        }, 500);
      }
      
      // Rimuovo il messaggio dopo 2 secondi
      setTimeout(() => {
        statusMsg.remove();
      }, 2000);
    })
    .catch((error) => {
      console.error('Errore eliminazione brano:', error);
      statusMsg.className = 'status-message error';
      statusMsg.style.background = 'rgba(244,67,54,0.95)';
      statusMsg.textContent = `Errore: ${error.message}`;
      
      setTimeout(() => {
        statusMsg.remove();
      }, 3000);
    });
}

// ==================== FUNZIONI MENU OPZIONI UTENTE ====================

function toggleUserOptions() {
  ui.userOptionsMenu?.classList.toggle('active');
  ui.userOptionsOverlay?.classList.toggle('active');
}

function handlePlayModeChange(event) {
  const value = event.target.value;
  appState.playMode = value;
  
  // Mostro/nascondo controlli in base alla modalità
  if (value === 'timed' || value === 'persistent') {
    ui.timerControlsBox?.classList.add('active');
    ui.directInfoBox?.classList.remove('active');
    ui.randomInfoBox?.classList.remove('active');
    const persistentBox = document.getElementById('persistentInfoBox');
    if (persistentBox) {
      persistentBox.classList.toggle('active', value === 'persistent');
    }
  } else if (value === 'direct') {
    ui.timerControlsBox?.classList.remove('active');
    ui.directInfoBox?.classList.add('active');
    ui.randomInfoBox?.classList.remove('active');
    const persistentBox = document.getElementById('persistentInfoBox');
    if (persistentBox) persistentBox.classList.remove('active');
  } else if (value === 'random') {
    ui.timerControlsBox?.classList.remove('active');
    ui.directInfoBox?.classList.remove('active');
    ui.randomInfoBox?.classList.add('active');
    const persistentBox = document.getElementById('persistentInfoBox');
    if (persistentBox) persistentBox.classList.remove('active');
  } else {
    ui.timerControlsBox?.classList.remove('active');
    ui.directInfoBox?.classList.remove('active');
    ui.randomInfoBox?.classList.remove('active');
    const persistentBox = document.getElementById('persistentInfoBox');
    if (persistentBox) persistentBox.classList.remove('active');
  }
  
  // Se cambio modalità, cancello eventuali timer attivi
  if (appState.timerTimeoutId) {
    clearTimeout(appState.timerTimeoutId);
    appState.timerTimeoutId = null;
  }
  appState.isTimerPaused = false;
  appState.isPersistentTimerActive = false; // Reset timer persistente
  ui.spaceIndicator?.classList.remove('active');
  
  // Aggiorno il bottone play in base alla modalità
  updatePlayButton();
  
  console.log(`Modalità ascolto cambiata: ${value}`);
}

function updatePlayButton() {
  if (!ui.playActionIcon || !ui.playActionText || !ui.playActionDescription) {
    return;
  }
  
  switch (appState.playMode) {
    case 'direct':
      ui.playActionIcon.className = 'bi bi-play-circle';
      ui.playActionText.textContent = 'Play Brano Diretto';
      ui.playActionDescription.textContent = 'Avvia il prossimo brano della lista';
      break;
    case 'random':
      ui.playActionIcon.className = 'bi bi-shuffle';
      ui.playActionText.textContent = 'Play Brano Random';
      ui.playActionDescription.textContent = 'Avvia un brano casuale dalla tua lista';
      break;
    case 'timed':
      ui.playActionIcon.className = 'bi bi-clock-history';
      ui.playActionText.textContent = 'Play Brano Temporizzato';
      ui.playActionDescription.textContent = 'Avvia un brano random con timer';
      break;
    case 'persistent':
      ui.playActionIcon.className = 'bi bi-shield-lock';
      ui.playActionText.textContent = '🔒 Play Timer Persistente';
      ui.playActionDescription.textContent = 'Avvia con SPACE disabilitato durante il timer';
      break;
  }
}

function handlePlayAction() {
  switch (appState.playMode) {
    case 'direct':
      playDirectBrano();
      break;
    case 'random':
      selectRandomBrano();
      break;
    case 'timed':
      selectRandomBrano(); // In modalità timed, il timer parte automaticamente
      break;
    case 'persistent':
      playPersistentTimerBrano(); // Timer persistente con SPACE ibernato
      break;
  }
}

function playDirectBrano() {
  if (!appState.currentBrani || appState.currentBrani.length === 0) {
    alert('Nessun brano disponibile. Seleziona prima un utente e carica i brani.');
    return;
  }
  
  // Chiudo il menu
  ui.userOptionsMenu?.classList.remove('active');
  ui.userOptionsOverlay?.classList.remove('active');
  
  // Se non c'è un brano corrente o siamo all'ultimo, parto dal primo
  if (appState.currentBranoIndex < 0 || appState.currentBranoIndex >= appState.currentBrani.length - 1) {
    appState.currentBranoIndex = 0;
  } else {
    // Altrimenti passo al successivo
    appState.currentBranoIndex++;
  }
  
  const brano = appState.currentBrani[appState.currentBranoIndex];
  selectBrano(brano.link_youtube, brano.nome_video, appState.currentBranoIndex);
}

function playNextDirectBrano() {
  if (!appState.currentBrani || appState.currentBrani.length === 0) {
    return;
  }
  
  // Passo al brano successivo
  if (appState.currentBranoIndex < 0 || appState.currentBranoIndex >= appState.currentBrani.length - 1) {
    appState.currentBranoIndex = 0; // Ricomincio dal primo
  } else {
    appState.currentBranoIndex++;
  }
  
  const brano = appState.currentBrani[appState.currentBranoIndex];
  selectBrano(brano.link_youtube, brano.nome_video, appState.currentBranoIndex);
}

function handleTimerSliderChange(event) {
  const value = parseInt(event.target.value, 10);
  appState.timerDuration = value;
  
  // Aggiorno il valore visualizzato
  if (ui.timerValue) {
    ui.timerValue.textContent = `${value}s`;
  }
}

// Gestione tasto SPACE (keydown)
function handleSpaceKeyDown(event) {
  // Controllo se è SPACE e se siamo in modalità utente
  if (event.code === 'Space' && appState.mode === 'user') {
    // Previeni scroll della pagina
    event.preventDefault();
    
    // ⚠️ TIMER PERSISTENTE: Se il timer è attivo, IGNORA completamente il SPACE
    if (appState.isPersistentTimerActive) {
      console.log('🔒 Timer Persistente ATTIVO - SPACE ignorato (ibernato)');
      return; // Esce senza fare nulla
    }
    
    // Se il tasto è già premuto, ignoro (evito ripetizioni)
    if (appState.spaceKeyPressed) {
      return;
    }
    
    appState.spaceKeyPressed = true;
    
    // Comportamento diverso in base alla modalità
    if (appState.playMode === 'timed') {
      // In modalità temporizzata: riprendo dopo pausa
      resumePlayAfterPause();
    } else if (appState.playMode === 'persistent') {
      // In modalità timer persistente: avvia brano e attiva timer persistente
      playPersistentTimerBrano();
    } else if (appState.playMode === 'direct') {
      // In modalità diretta: parto con il brano successivo della lista
      playNextDirectBrano();
    } else if (appState.playMode === 'random') {
      // In modalità random: parto con un brano casuale
      selectRandomBrano();
    }
  }
}

// Gestione tasto SPACE (keyup) - per gestire tasto tenuto premuto
function handleSpaceKeyUp(event) {
  if (event.code === 'Space' && appState.mode === 'user') {
    event.preventDefault();
    appState.spaceKeyPressed = false;
  }
}

// Espongo le funzioni globalmente per l'HTML (dopo tutte le definizioni)
window.startApp = startApp;
window.startEducatorMode = startEducatorMode;
window.startUserMode = startUserMode;
window.selectBrano = selectBrano;
window.goBack = goBack;
window.toggleMenu = toggleMenu;
window.showInfo = showInfo;
window.showInstructions = showInstructions;
window.closeModal = closeModal;
window.showSettings = showSettings;
window.resetApp = resetApp;
window.toggleUserOptions = toggleUserOptions;
window.selectRandomBrano = selectRandomBrano;
window.playPersistentTimerBrano = playPersistentTimerBrano;
window.handlePlayAction = handlePlayAction;
window.playDirectBrano = playDirectBrano;
window.playNextDirectBrano = playNextDirectBrano;
window.deleteBrano = deleteBrano;
window.saveLocalUserAndStart = saveLocalUserAndStart;
window.changeLocalUser = changeLocalUser;
window.deleteBranoLocal = deleteBranoLocal;
window.switchToUserMode = switchToUserMode;
window.switchToEducatorMode = switchToEducatorMode;
window.selectLocalUser = selectLocalUser;
window.addNewLocalUser = addNewLocalUser;
window.handleLocalUserSwitch = handleLocalUserSwitch;

// Callback per YouTube IFrame API (deve essere globale)
window.onYouTubeIframeAPIReady = function() {
  console.log('YouTube IFrame API pronta');
  window.youtubeAPIReady = true;
};

document.addEventListener('DOMContentLoaded', () => {
  console.log(`${APP_CONFIG.name} v${APP_CONFIG.version} caricato con successo`);
  
  // Rileva modalità PWA (standalone) e nascondi link esterni
  detectPWAMode();
  
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
      closeModal('infoModal');
      closeModal('instructionsModal');
      const menu = document.getElementById('sideMenu');
      const overlay = document.getElementById('overlay');
      if (menu?.classList.contains('active')) {
        menu.classList.remove('active');
        overlay?.classList.remove('active');
      }
    }
  });
});

let deferredPrompt;
window.addEventListener('beforeinstallprompt', (event) => {
  event.preventDefault();
  deferredPrompt = event;
  console.log('PWA install prompt ready');
});

