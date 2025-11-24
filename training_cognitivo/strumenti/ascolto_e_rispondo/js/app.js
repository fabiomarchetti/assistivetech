// Configurazione applicazione
const APP_CONFIG = {
  name: 'ascolto e rispondo',
  id: 31,
  version: '1.0.0',
};

// 🔑 PREFISSO UNICO per localStorage - differenzia da "ascolto la musica"
const STORAGE_PREFIX = 'ascolto_rispondo_';

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

const DEFAULT_SEARCH_QUERY = 'canzoni per bambini';

let appState = {
    isStarted: false,
  mode: null, // 'educator' o 'user'
  currentBrani: [], // Array di tutti i brani caricati
  youtubePlayer: null, // Istanza del player YouTube
  currentVideoId: null, // ID video corrente
  currentBranoData: null, // Dati completi del brano corrente (con tempi e domanda)
  isOnline: true, // Stato connessione (true = online con DB, false = locale)
  currentUserName: null, // Nome utente corrente (online o locale)
  isPWA: false, // True se l'app è installata come PWA (standalone)
  hasInternet: true, // True se c'è connessione internet (per YouTube)
  ttsEnabled: true, // True se TTS è abilitato
  playerStateInterval: null, // Intervallo per controllare il tempo del player
  currentBranoIndex: -1, // Indice del brano corrente nella lista
};

let ui = {
  form: null,
  utente: null,
  categoria: null,
  nome: null,
  link: null,
  inizioMin: null,
  inizioSec: null,
  fineMin: null,
  fineSec: null,
  domanda: null,
  status: null,
  playerMetaNome: null,
  playerMetaCategoria: null,
  playerMetaUtente: null,
  playerMetaTempo: null,
  playerMetaDomanda: null,
  youtubeWindow: null, // Finestra popup YouTube per ricerca
};

// Rileva se l'app è in modalità PWA (standalone)
function detectPWAMode() {
  const isStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                       window.navigator.standalone ||
                       document.referrer.includes('android-app://');
  
  appState.isPWA = isStandalone;
  
  if (isStandalone) {
    console.log('🔒 PWA INSTALLATA: Nascondo tutti i link esterni al portale');
    
    const btnBackToPortal = document.getElementById('btnBackToPortal');
    if (btnBackToPortal) {
      btnBackToPortal.style.setProperty('display', 'none', 'important');
      btnBackToPortal.disabled = true;
    }
    
    const menuBackToPortal = document.getElementById('menuBackToPortal');
    if (menuBackToPortal) {
      menuBackToPortal.style.setProperty('display', 'none', 'important');
    }
  }
}

function goBack() {
  if (appState.isPWA) {
    alert('🔒 Sei nell\'app installata "ascolto e rispondo".\n\nQuesta app è completamente autonoma e non ha link esterni.\n\nUsa il menu per tornare alla schermata iniziale.');
    return;
  }
  
  if (confirm('Vuoi davvero tornare alla home del portale AssistiveTech?')) {
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
  alert('Impostazioni in fase di sviluppo!');
    toggleMenu();
}

function resetApp() {
  if (confirm('Vuoi ricominciare da capo?')) {
    window.location.reload();
  }
}

function startEducatorMode() {
  if (appState.isStarted) {
    return;
  }
  appState.isStarted = true;
  appState.mode = 'educator';
  
  document.body.classList.add('educator-mode');
  
  const isPWAStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                          window.navigator.standalone ||
                          document.referrer.includes('android-app://');
  
  if (isPWAStandalone) {
    console.log('📱 Area Educatore (PWA): Uso utenti LOCALI (localStorage)');
    checkInternetConnection().then(hasInternet => {
      appState.isOnline = false;
      appState.hasInternet = hasInternet;
      
      renderEducatorUI();
      cacheEducatorRefs();
      loadLocalUsers();
      bindEducatorEvents();
      updatePlayerMeta();
      
      setTimeout(() => {
        detectPWAMode();
      }, 150);
    });
  } else {
    checkOnlineStatus().then(isOnline => {
      appState.isOnline = isOnline;
      appState.hasInternet = isOnline;
      console.log(`🔍 Area Educatore (Browser) - Modalità: ${isOnline ? 'ONLINE (database)' : 'OFFLINE (localStorage)'}`);
      
      renderEducatorUI();
      cacheEducatorRefs();
      
      setTimeout(() => {
        if (isOnline) {
          loadPazienti();
        } else {
          loadLocalUsers();
        }
      }, 100);
      
      bindEducatorEvents();
      updatePlayerMeta();
      
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
  
  const isPWAStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                          window.navigator.standalone ||
                          document.referrer.includes('android-app://');
  
  if (isPWAStandalone) {
    console.log('📱 Area Utente (PWA): Uso utenti LOCALI (localStorage)');
    appState.isOnline = false;
    
    const localUsers = getLocalUsers();
    
    if (localUsers.length > 0) {
      showLocalUserSelection(localUsers);
    } else {
      showLocalUserLogin();
    }
  } else {
    checkOnlineStatus().then(isOnline => {
      appState.isOnline = isOnline;
      appState.hasInternet = isOnline;
      console.log(`🔍 Area Utente (Browser) - Modalità: ${isOnline ? 'ONLINE (database)' : 'OFFLINE (localStorage)'}`);
      
      if (!isOnline) {
        const localUsers = getLocalUsers();
        
        if (localUsers.length > 0) {
          showLocalUserSelection(localUsers);
        } else {
          showLocalUserLogin();
        }
      } else {
        renderUserUI();
        cacheUserRefs();
        
        setTimeout(() => {
          loadPazientiForUser();
        }, 100);
        
        bindUserEvents();
        
        setTimeout(() => {
          detectPWAMode();
        }, 150);
      }
    });
  }
}

// Verifica connessione internet
async function checkInternetConnection() {
  if (!navigator.onLine) {
    console.log('📡 Nessuna connessione internet');
    return false;
  }
  
  try {
    const response = await fetch('https://www.google.com/favicon.ico', {
      method: 'HEAD',
      mode: 'no-cors',
      cache: 'no-cache',
      signal: AbortSignal.timeout(2000)
    });
    console.log('📡 Connessione internet attiva');
    return true;
  } catch (error) {
    console.log('📡 Connessione internet assente');
    return false;
  }
}

// Verifica se l'app è online (può accedere al DB)
async function checkOnlineStatus() {
  const isPWAStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                          window.navigator.standalone ||
                          document.referrer.includes('android-app://');
  
  const isLocalhost = window.location.hostname === 'localhost' || 
                      window.location.hostname === '127.0.0.1' ||
                      window.location.hostname.includes('assistivetech.it') ||
                      window.location.hostname.includes('.local');
  
  if (!navigator.onLine) {
    console.log(`📱 Modalità OFFLINE${isPWAStandalone ? ' (PWA)' : ''}: Nessuna connessione internet`);
    return false;
  }
  
  try {
    const response = await fetch(`${API_ENDPOINT}?action=get_pazienti`, {
      method: 'GET',
      cache: 'no-cache',
      signal: AbortSignal.timeout(3000)
    });
    
    const modeLabel = isPWAStandalone ? 'PWA' : 'Browser';
    console.log(`✅ Modalità ONLINE (${modeLabel}): Database raggiungibile`);
    return true;
    
  } catch (error) {
    if (isLocalhost) {
      console.warn('⚠️ Localhost: Assumo ONLINE per sviluppo');
      return true;
    }
    
    const modeLabel = isPWAStandalone ? 'PWA' : 'Browser';
    console.log(`📱 Modalità OFFLINE (${modeLabel}): Uso localStorage`);
    return false;
  }
}

// Ottiene lista utenti locali da localStorage
function getLocalUsers() {
  const localUsers = [];
  const prefix = STORAGE_PREFIX + 'localBrani_';
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && key.startsWith(prefix)) {
      const userName = key.replace(prefix, '');
      localUsers.push(userName);
    }
  }
  return localUsers.sort();
}

// Mostra schermata di selezione utenti locali
function showLocalUserSelection(localUsers) {
        const mainContent = document.getElementById('appMain');
  if (!mainContent) {
    return;
  }
  
  document.body.classList.remove('educator-mode');
  document.body.classList.add('user-mode-active');
  
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
        <i class="bi bi-wifi-off" style="color: #ff9800;"></i><br>
        <strong>Modalità locale attiva</strong><br>
        Seleziona il tuo nome
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
  
  localStorage.setItem(STORAGE_PREFIX + 'localUser', userName);
  appState.currentUserName = userName;
  
  renderUserUI();
  cacheUserRefs();
  loadUserBraniLocal(userName);
  bindUserEvents();
  
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
  
  const localUsers = getLocalUsers();
  if (localUsers.includes(userName)) {
    alert(`L'utente "${userName}" esiste già!`);
    nameInput?.focus();
    return;
  }
  
  localStorage.setItem(STORAGE_PREFIX + 'localUser', userName);
  appState.currentUserName = userName;
  
  const storageKey = `${STORAGE_PREFIX}localBrani_${userName}`;
  localStorage.setItem(storageKey, JSON.stringify([]));
  
  renderUserUI();
  cacheUserRefs();
  loadUserBraniLocal(userName);
  bindUserEvents();
  
  const changeUserMenuItem = document.getElementById('changeUserMenuItem');
  if (changeUserMenuItem) {
    changeUserMenuItem.style.display = 'block';
  }
}

// Mostra schermata di login per utente locale
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
        <i class="bi bi-wifi-off" style="color: #ff9800;"></i><br>
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
  
  localStorage.setItem(STORAGE_PREFIX + 'localUser', userName);
  appState.currentUserName = userName;
  
  const storageKey = `${STORAGE_PREFIX}localBrani_${userName}`;
  if (!localStorage.getItem(storageKey)) {
    localStorage.setItem(storageKey, JSON.stringify([]));
  }
  
  renderUserUI();
  cacheUserRefs();
  loadUserBraniLocal(userName);
  bindUserEvents();
  
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
  
  const storageKey = `${STORAGE_PREFIX}localBrani_${userName}`;
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
        <small>Per aggiungere brani, usa l'<strong>Area Educatore</strong>.</small>
      </p>
    `;
    return;
  }
  
  // Popolo la lista dei brani
  renderBraniList(brani, userName, true);
}

// Renderizza la lista dei brani (usato sia per online che offline)
function renderBraniList(brani, userName, isLocal = false) {
  if (!ui.userBraniList) {
    return;
  }
  
  ui.userBraniList.innerHTML = brani.map((brano, index) => {
    const tempoInizio = formatTime(brano.inizio_brano || 0);
    const tempoFine = formatTime(brano.fine_brano || 0);
    const tempoText = (brano.inizio_brano || brano.fine_brano) 
      ? `⏱️ ${tempoInizio} → ${tempoFine}` 
      : '';
    
    const domandaHTML = brano.domanda 
      ? `<div class="brano-question">
           <div class="brano-question-text">
             <strong>Domanda:</strong> ${escapeHtml(brano.domanda)}
           </div>
           <button 
             class="btn-speak-question" 
             onclick="event.stopPropagation(); speakQuestionPreview('${escapeHtml(brano.domanda).replace(/'/g, "\\'")}');"
             title="Ascolta la domanda"
             tabindex="-1"
           >
             <i class="bi bi-volume-up"></i>
           </button>
         </div>` 
      : '';
    
    const deleteFunction = isLocal 
      ? `deleteBranoLocal(${index}, '${escapeHtml(brano.nome_video)}', '${userName}')` 
      : `deleteBrano(${brano.id_video || brano.id || 'null'}, '${escapeHtml(brano.nome_video)}', '${brano.link_youtube}')`;
    
    return `
      <div 
        class="brano-item" 
        data-link="${brano.link_youtube}" 
        data-index="${index}"
        id="brano-${index}"
        tabindex="0"
        role="button"
        aria-label="Brano ${index + 1}: ${escapeHtml(brano.nome_video)}"
        onkeydown="handleBranoKeyDown(event, ${index})"
      >
        <div class="brano-info" onclick="selectBrano(${index})">
          <i class="bi bi-headphones"></i>
          <div class="brano-info-content">
            <strong>${escapeHtml(brano.nome_video)}</strong>
            <small>${escapeHtml(brano.categoria || 'Senza categoria')}</small>
            ${tempoText ? `<small style="color: var(--primary-color); font-weight: 600;">${tempoText}</small>` : ''}
          </div>
        </div>
        ${domandaHTML}
        <div class="brano-actions">
          <button class="btn-play" onclick="selectBrano(${index})" title="Riproduci brano" tabindex="-1">
            <i class="bi bi-play-circle"></i>
          </button>
          <button class="btn-delete" onclick="${deleteFunction}" title="Elimina brano" tabindex="-1">
            <i class="bi bi-trash3"></i>
          </button>
        </div>
      </div>
    `;
  }).join('');
  
  // Focus automatico sul primo brano dopo il rendering
  setTimeout(() => {
    focusFirstBrano();
  }, 100);
}

// Formatta i secondi in mm:ss
function formatTime(seconds) {
  if (!seconds) return '00:00';
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
}

// Escape HTML per sicurezza
function escapeHtml(text) {
  if (!text) return '';
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML.replace(/'/g, "\\'");
}

// Elimina un brano da localStorage
function deleteBranoLocal(branoIndex, nomeBrano, userName) {
  if (!confirm(`Vuoi davvero eliminare il brano "${nomeBrano}"?`)) {
    return;
  }
  
  const storageKey = `${STORAGE_PREFIX}localBrani_${userName}`;
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
  
  brani.splice(branoIndex, 1);
  localStorage.setItem(storageKey, JSON.stringify(brani));
  loadUserBraniLocal(userName);
  
  alert(`Brano "${nomeBrano}" eliminato con successo!`);
}

// Cambia utente locale
function changeLocalUser() {
  if (confirm('Vuoi cambiare utente? I brani rimarranno salvati.')) {
    localStorage.removeItem(STORAGE_PREFIX + 'localUser');
    appState.currentUserName = null;
    appState.currentBrani = [];
    showLocalUserLogin();
  }
}

// Salva un brano in localStorage per sincronizzazione
function saveToLocalStorageIfExists(userName, brano) {
  const storageKey = `${STORAGE_PREFIX}localBrani_${userName}`;
  const braniJSON = localStorage.getItem(storageKey);
  
  if (!braniJSON) {
    return;
  }
  
  let brani = [];
  try {
    brani = JSON.parse(braniJSON);
  } catch (error) {
    console.error('Errore parsing brani locali:', error);
    return;
  }
  
  const exists = brani.some(b => b.link_youtube === brano.link_youtube);
  if (exists) {
    console.log('Brano già presente in localStorage');
    return;
  }
  
  brani.push(brano);
  localStorage.setItem(storageKey, JSON.stringify(brani));
  console.log(`Brano sincronizzato in localStorage per utente: ${userName}`);
}

// Carica utenti locali da localStorage per Area Educatore
function loadLocalUsers() {
  const localUsers = new Set();
  const prefix = STORAGE_PREFIX + 'localBrani_';
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && key.startsWith(prefix)) {
      const userName = key.replace(prefix, '');
      localUsers.add(userName);
    }
  }
  
  const datalist = document.getElementById('localUsersDatalist');
  if (datalist) {
    datalist.innerHTML = '';
    localUsers.forEach(user => {
      const option = document.createElement('option');
      option.value = user;
      datalist.appendChild(option);
    });
  }
  
  if (ui.status) {
    showStatus('📱 MODALITÀ OFFLINE: I brani saranno salvati localmente', 'info');
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

// Passa dall'Area Educatore all'Area Utente
function switchToUserMode() {
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
  
  startUserMode();
}

// Passa dall'Area Utente all'Area Educatore
function switchToEducatorMode() {
  appState.isStarted = false;
  appState.mode = null;
  
  // Ferma player YouTube se in riproduzione
  if (appState.youtubePlayer) {
    try {
      appState.youtubePlayer.stopVideo();
    } catch (e) {
      console.log('Errore stop player:', e);
    }
  }
  
  // Ferma controllo tempo
  if (appState.playerStateInterval) {
    clearInterval(appState.playerStateInterval);
    appState.playerStateInterval = null;
  }
  
  // Chiudi menu se aperto
  const menu = document.getElementById('sideMenu');
  const overlay = document.getElementById('overlay');
  if (menu?.classList.contains('active')) {
    menu.classList.remove('active');
    overlay?.classList.remove('active');
  }
  
  startEducatorMode();
}

function renderEducatorUI() {
  const mainContent = document.getElementById('appMain');
  if (!mainContent) {
    return;
  }
  
  // Rendering condizionale del campo utente
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
         <i class="bi bi-wifi-off"></i> <strong>Modalità offline:</strong> Salvataggio locale
       </p>`;
  
  mainContent.innerHTML = `
    <div class="educator-layout-full">
      <section class="panel form-panel-full" aria-label="Form salvataggio brano">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
          <h3 style="margin: 0;">
            <i class="bi bi-headphones"></i> Crea nuovo esercizio
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
        <p class="helper-text">Compila i dati del brano, imposta i tempi di inizio/fine e scrivi la domanda.</p>
        <form id="videoForm" class="form-grid" novalidate>
          <div class="form-group">
            <label for="utenteInput">${appState.isOnline ? 'Paziente' : 'Nome Utente'} *</label>
            ${userFieldHTML}
          </div>
          <div class="form-group">
            <label for="categoriaInput">Ricerca: digita cosa cerchi ed aspetta che appaia *</label>
            <input id="categoriaInput" name="categoria" type="text" maxlength="100" required placeholder="Es: canzoni per bambini" autocomplete="off" />
            <p class="helper-text">Dopo 1 secondo, si apre YouTube a destra. Cerca il video, copia il link e incollalo sotto.</p>
          </div>
          <div class="form-group">
            <label for="linkVideoInput">Link YouTube *</label>
            <input id="linkVideoInput" name="linkVideo" type="url" maxlength="500" required placeholder="https://www.youtube.com/watch?v=..." autocomplete="off" />
          </div>
          <div class="form-group">
            <label for="nomeVideoInput">Nome brano *</label>
            <input id="nomeVideoInput" name="nomeVideo" type="text" maxlength="150" required placeholder="Es: Ninna nanna dolce" autocomplete="off" />
          </div>
          
          <!-- Campi tempo inizio -->
          <div class="form-group">
            <label>Tempo di inizio ascolto *</label>
            <div class="time-group">
              <div class="form-group">
                <label for="inizioMinInput">Minuti</label>
                <input id="inizioMinInput" name="inizioMin" type="number" min="0" max="999" value="0" required placeholder="0" />
              </div>
              <div class="form-group">
                <label for="inizioSecInput">Secondi</label>
                <input id="inizioSecInput" name="inizioSec" type="number" min="0" max="59" value="0" required placeholder="0" />
              </div>
            </div>
          </div>
          
          <!-- Campi tempo fine -->
          <div class="form-group">
            <label>Tempo di fine ascolto *</label>
            <div class="time-group">
              <div class="form-group">
                <label for="fineMinInput">Minuti</label>
                <input id="fineMinInput" name="fineMin" type="number" min="0" max="999" value="0" required placeholder="0" />
              </div>
              <div class="form-group">
                <label for="fineSecInput">Secondi</label>
                <input id="fineSecInput" name="fineSec" type="number" min="0" max="59" value="0" required placeholder="0" />
              </div>
            </div>
          </div>
          
          <!-- Campo domanda -->
          <div class="form-group">
            <label for="domandaInput">Domanda da porre al termine dell'ascolto *</label>
            <textarea id="domandaInput" name="domanda" required placeholder="Es: Quale strumento musicale hai sentito?" maxlength="500" rows="4"></textarea>
            <p class="helper-text">Questa domanda verrà letta automaticamente dopo 3 secondi dalla fine del brano</p>
          </div>
          
          <!-- Box riepilogo dati -->
          <div class="player-meta">
            <h4 style="margin: 0 0 0.75rem 0; color: var(--primary-color); font-size: 0.95rem;">
              <i class="bi bi-info-circle"></i> Riepilogo dati:
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
            <div>
              <span class="label">Tempo ascolto:</span>
              <span class="value" id="playerMetaTempo">-</span>
            </div>
            <div>
              <span class="label">Domanda:</span>
              <span class="value" id="playerMetaDomanda">-</span>
            </div>
          </div>
          
          <div class="form-actions">
            <button type="submit" class="btn-primary"><i class="bi bi-save"></i> Salva esercizio</button>
            <button type="button" class="btn-secondary" id="resetFormButton"><i class="bi bi-eraser"></i> Svuota campi</button>
          </div>
          <div id="statusMessage" class="status-message" role="status" aria-live="polite"></div>
        </form>
      </section>
    </div>
  `;
  
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
    inizioMin: document.getElementById('inizioMinInput'),
    inizioSec: document.getElementById('inizioSecInput'),
    fineMin: document.getElementById('fineMinInput'),
    fineSec: document.getElementById('fineSecInput'),
    domanda: document.getElementById('domandaInput'),
    status: document.getElementById('statusMessage'),
    resetBtn: document.getElementById('resetFormButton'),
    playerMetaNome: document.getElementById('playerMetaNome'),
    playerMetaCategoria: document.getElementById('playerMetaCategoria'),
    playerMetaUtente: document.getElementById('playerMetaUtente'),
    playerMetaTempo: document.getElementById('playerMetaTempo'),
    playerMetaDomanda: document.getElementById('playerMetaDomanda'),
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
  
  // Event listener per categoria: apre YouTube dopo 1 secondo
  ui.categoria?.addEventListener('input', (event) => {
    clearTimeout(typingTimer);
    const query = event.target.value.trim();
    
    // Aggiorna il meta
    updatePlayerMeta();
    
    // Dopo 1 secondo di inattività, apro/aggiorno YouTube
    if (query.length >= 3) {
      typingTimer = setTimeout(() => {
        openOrUpdateYouTube(query);
      }, doneTypingInterval);
    }
  });
  
  ui.nome?.addEventListener('input', () => updatePlayerMeta());
  ui.utente?.addEventListener('change', () => updatePlayerMeta());
  ui.inizioMin?.addEventListener('input', () => updatePlayerMeta());
  ui.inizioSec?.addEventListener('input', () => updatePlayerMeta());
  ui.fineMin?.addEventListener('input', () => updatePlayerMeta());
  ui.fineSec?.addEventListener('input', () => updatePlayerMeta());
  ui.domanda?.addEventListener('input', () => updatePlayerMeta());
  
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
  const inizioMin = parseInt(ui.inizioMin?.value || 0);
  const inizioSec = parseInt(ui.inizioSec?.value || 0);
  const fineMin = parseInt(ui.fineMin?.value || 0);
  const fineSec = parseInt(ui.fineSec?.value || 0);
  const domanda = ui.domanda?.value.trim();
  const videoId = extractVideoId(link || '');

  if (!nomeUtente || !categoria || !nomeVideo || !link || !domanda) {
    showStatus('Compila tutti i campi obbligatori.', 'error');
    return;
  }

  if (!videoId) {
    showStatus('Il link inserito non sembra un URL YouTube valido.', 'error');
    return;
  }
  
  // Calcolo tempi in secondi
  const inizioBrano = (inizioMin * 60) + inizioSec;
  const fineBrano = (fineMin * 60) + fineSec;
  
  if (fineBrano <= inizioBrano) {
    showStatus('Il tempo di fine deve essere maggiore del tempo di inizio!', 'error');
    return;
  }

  showStatus('Salvataggio in corso...', 'info');
  
  // Modalità offline: salva in localStorage
  if (!appState.isOnline) {
    const storageKey = `${STORAGE_PREFIX}localBrani_${nomeUtente}`;
    let brani = [];
    
    try {
      const braniJSON = localStorage.getItem(storageKey);
      if (braniJSON) {
        brani = JSON.parse(braniJSON);
      }
    } catch (error) {
      console.error('Errore parsing brani locali:', error);
    }
    
    brani.push({
      nome_video: nomeVideo,
      categoria,
      link_youtube: link,
      inizio_brano: inizioBrano,
      fine_brano: fineBrano,
      domanda: domanda,
    });
    
    localStorage.setItem(storageKey, JSON.stringify(brani));
    showStatus(`✅ Esercizio salvato localmente per ${nomeUtente}!`, 'success');
    ui.form.reset();
    updatePlayerMeta();
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
    domanda: domanda,
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
        throw new Error(data.error || 'Impossibile salvare l\'esercizio');
      }
      showStatus('Esercizio salvato correttamente!', 'success');
      
      // Sincronizzo in localStorage se esiste
      saveToLocalStorageIfExists(nomeUtente, {
        nome_video: nomeVideo,
        categoria,
        link_youtube: link,
        inizio_brano: inizioBrano,
        fine_brano: fineBrano,
        domanda: domanda,
      });
      
      ui.form.reset();
      updatePlayerMeta();
    })
    .catch((error) => {
      console.error('Errore salvataggio:', error);
      showStatus(`Errore salvataggio: ${error.message}`, 'error');
    });
}

// Apre o aggiorna la finestra YouTube per la ricerca
function openOrUpdateYouTube(query) {
  // YouTube funziona solo se c'è connessione internet
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
  showStatus('Campi puliti.', 'info');
}

// Aggiorna metadata del box riepilogo
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
  if (ui.playerMetaTempo) {
    const inizioMin = parseInt(ui.inizioMin?.value || 0);
    const inizioSec = parseInt(ui.inizioSec?.value || 0);
    const fineMin = parseInt(ui.fineMin?.value || 0);
    const fineSec = parseInt(ui.fineSec?.value || 0);
    const inizioBrano = (inizioMin * 60) + inizioSec;
    const fineBrano = (fineMin * 60) + fineSec;
    ui.playerMetaTempo.textContent = `${formatTime(inizioBrano)} → ${formatTime(fineBrano)}`;
  }
  if (ui.playerMetaDomanda) {
    const domandaText = ui.domanda?.value.trim();
    ui.playerMetaDomanda.textContent = domandaText || '-';
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
  
  document.body.classList.remove('educator-mode');
  document.body.classList.add('user-mode-active');
  
  mainContent.innerHTML = `
    <!-- Indicatore TTS -->
    <div class="tts-indicator" id="ttsIndicator">
      <i class="bi bi-volume-up"></i> Ascolta la domanda...
    </div>
    
    <div class="user-layout">
      <!-- Box selezione utente + lista brani -->
      <section class="panel user-panel">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
          <h3 style="margin: 0;"><i class="bi bi-headphones"></i> I tuoi esercizi</h3>
          <button 
            class="btn-secondary" 
            onclick="switchToEducatorMode()"
            title="Vai all'Area Educatore"
            style="padding: 0.4rem 0.8rem; font-size: 0.85rem;"
          >
            <i class="bi bi-person-workspace"></i> Educatore
          </button>
        </div>
        <p class="helper-text" id="userHelperText">${appState.isOnline ? 'Seleziona il tuo nome per vedere gli esercizi.' : `Benvenuto <strong>${appState.currentUserName || ''}</strong>!`}</p>
        
        <!-- Dropdown utenti online -->
        <div class="form-group" id="userInputGroup" style="display: ${appState.isOnline ? 'block' : 'none'};">
          <label for="userSelectInput">Il tuo nome *</label>
          <select id="userSelectInput" required>
            <option value="">Caricamento pazienti...</option>
          </select>
        </div>
        
        <div id="userBraniContainer" style="display: none; margin-top: 1.5rem;">
          <h4 style="color: var(--primary-color); margin-bottom: 1rem;">
            <i class="bi bi-music-note-list"></i> Lista esercizi
          </h4>
          <div id="userBraniList" class="brani-list">
            <!-- Lista brani -->
          </div>
        </div>
      </section>
      
      <!-- Box player -->
      <section class="user-player-panel">
        <h3 style="color: var(--primary-color); margin-bottom: 1rem;">
          <i class="bi bi-play-circle"></i> Player
        </h3>
        <p id="userCurrentSong" style="font-weight: 600; margin-bottom: 1.5rem; font-size: 1.1rem;">
          Nessun brano selezionato
        </p>
        
        <!-- Player YouTube -->
        <div class="iframe-wrapper">
          <div id="userPlayerFrame" style="display: flex; align-items: center; justify-content: center; background: #f0f0f0; color: #666; font-size: 1.2rem; text-align: center; padding: 2rem;">
            <div>
              <i class="bi bi-headphones" style="font-size: 3rem; display: block; margin-bottom: 1rem;"></i>
              <p>🎵 Seleziona un esercizio dalla lista</p>
              <small style="font-size: 0.9rem; display: block; margin-top: 0.5rem;">Il player si caricherà automaticamente</small>
            </div>
          </div>
        </div>
      </section>
    </div>
  `;
  
  // Precarico l'API YouTube
  ensureYouTubeAPILoaded();
  
  setTimeout(() => {
    detectPWAMode();
  }, 100);
}

// Assicura che l'API YouTube sia caricata
function ensureYouTubeAPILoaded() {
  if (typeof YT !== 'undefined' && typeof YT.Player !== 'undefined') {
    console.log('✅ API YouTube già caricata');
    return;
  }
  
  console.log('⏳ Precarico API YouTube...');
}

function cacheUserRefs() {
  ui = {
    userSelect: document.getElementById('userSelectInput'),
    userBraniContainer: document.getElementById('userBraniContainer'),
    userBraniList: document.getElementById('userBraniList'),
    userPlayerFrame: document.getElementById('userPlayerFrame'),
    userCurrentSong: document.getElementById('userCurrentSong'),
    ttsIndicator: document.getElementById('ttsIndicator'),
  };
}

function bindUserEvents() {
  ui.userSelect?.addEventListener('change', handleUserSelection);
}

function handleUserSelection(event) {
  const userName = event.target.value;
  if (!userName) {
    ui.userBraniContainer.style.display = 'none';
    return;
  }
  
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
        ui.userBraniList.innerHTML = '<p style="color: #666;"><i class="bi bi-music-note"></i> Nessun brano trovato.</p>';
        appState.currentBrani = [];
        return;
      }
      
      appState.currentBrani = data.data;
      renderBraniList(data.data, userName, false);
    })
    .catch((error) => {
      console.error('Errore caricamento brani:', error);
      ui.userBraniList.innerHTML = '<p style="color: #d32f2f;"><i class="bi bi-exclamation-triangle"></i> Errore nel caricamento.</p>';
      appState.currentBrani = [];
    });
}

// Seleziona un brano per la riproduzione
function selectBrano(branoIndex) {
  console.log(`🎵 selectBrano chiamato: index ${branoIndex}`);
  
  if (!appState.currentBrani || branoIndex < 0 || branoIndex >= appState.currentBrani.length) {
    alert('⚠️ Brano non valido!');
    return;
  }
  
  const brano = appState.currentBrani[branoIndex];
  const videoId = extractVideoId(brano.link_youtube);
  
  if (!videoId) {
    console.error('❌ Video ID non valido:', brano.link_youtube);
    alert('⚠️ Link YouTube non valido!');
    return;
  }
  
  if (!ui.userPlayerFrame) {
    console.error('❌ userPlayerFrame non trovato');
    alert('⚠️ Errore: Player non trovato!');
    return;
  }
  
  console.log(`✅ Video ID: ${videoId}`);
  
  // Aggiorno l'indice del brano corrente
  appState.currentBranoIndex = branoIndex;
  
  // Salvo i dati del brano corrente
  appState.currentBranoData = brano;
  appState.currentVideoId = videoId;
  
  // Aggiorno il nome del brano
  if (ui.userCurrentSong) {
    ui.userCurrentSong.textContent = `▶️ ${brano.nome_video}`;
  }
  
  // Ferma controllo tempo precedente
  if (appState.playerStateInterval) {
    clearInterval(appState.playerStateInterval);
    appState.playerStateInterval = null;
  }
  
  // Se il player esiste, carico il nuovo video
  if (appState.youtubePlayer && typeof appState.youtubePlayer.loadVideoById === 'function') {
    console.log('🔄 Player esistente, carico nuovo video...');
    try {
      const startSeconds = brano.inizio_brano || 0;
      appState.youtubePlayer.loadVideoById({
        videoId: videoId,
        startSeconds: startSeconds
      });
      console.log(`✅ Video caricato da ${startSeconds}s`);
      
      // Avvio il controllo del tempo
      startTimeMonitoring();
    } catch (error) {
      console.error('❌ Errore caricamento video:', error);
      initYouTubePlayer(videoId);
    }
  } else {
    console.log('🆕 Creo nuovo player...');
    initYouTubePlayer(videoId);
  }
}

// Inizializza il player YouTube
function initYouTubePlayer(videoId) {
  if (!ui.userPlayerFrame) {
    console.error('❌ userPlayerFrame non trovato');
    return;
  }
  
  // Verifica API YouTube
  if (typeof YT === 'undefined' || typeof YT.Player === 'undefined') {
    console.warn('⏳ API YouTube non ancora caricata');
    
    if (ui.userCurrentSong) {
      ui.userCurrentSong.textContent = '⏳ Caricamento player...';
    }
    
    let retryCount = 0;
    const maxRetries = 10;
    
    const retryInterval = setInterval(() => {
      retryCount++;
      
      if (typeof YT !== 'undefined' && typeof YT.Player !== 'undefined') {
        console.log('✅ API YouTube caricata!');
        clearInterval(retryInterval);
        initYouTubePlayer(videoId);
      } else if (retryCount >= maxRetries) {
        console.error('❌ Timeout API YouTube');
        clearInterval(retryInterval);
        alert('⚠️ Errore nel caricamento del player YouTube.\n\nRicarica la pagina.');
      }
    }, 500);
    
    return;
  }
  
  // Distruggo il player esistente
  if (appState.youtubePlayer) {
    try {
      appState.youtubePlayer.destroy();
      console.log('🗑️ Player precedente distrutto');
    } catch (e) {
      console.log('⚠️ Errore distruzione player:', e);
    }
  }
  
  console.log(`🎵 Creazione player per video: ${videoId}`);
  
  const startSeconds = appState.currentBranoData?.inizio_brano || 0;
  
  try {
    appState.youtubePlayer = new YT.Player('userPlayerFrame', {
      height: '100%',
      width: '100%',
      videoId: videoId,
      playerVars: {
        autoplay: 1,
        modestbranding: 1,
        rel: 0,
        start: startSeconds,
      },
      events: {
        onReady: onPlayerReady,
        onStateChange: onPlayerStateChange,
      },
    });
  } catch (error) {
    console.error('❌ Errore creazione player:', error);
    alert('⚠️ Errore nella creazione del player YouTube.');
  }
}

function onPlayerReady(event) {
  console.log('✅ Player YouTube pronto');
  event.target.playVideo();
  
  // Avvio il controllo del tempo
  startTimeMonitoring();
}

function onPlayerStateChange(event) {
  console.log('Stato player:', event.data);
  // 1 = playing, 2 = paused, 0 = ended
}

// Avvia il monitoraggio del tempo di riproduzione
function startTimeMonitoring() {
  // Ferma monitoraggio precedente
  if (appState.playerStateInterval) {
    clearInterval(appState.playerStateInterval);
  }
  
  if (!appState.currentBranoData || !appState.youtubePlayer) {
    return;
  }
  
  const fineBrano = appState.currentBranoData.fine_brano;
  
  // Se non c'è un tempo di fine impostato, non monitoro
  if (!fineBrano || fineBrano <= 0) {
    console.log('⚠️ Nessun tempo di fine impostato, riproduzione completa');
    return;
  }
  
  console.log(`⏱️ Avvio monitoraggio tempo - Stop a ${fineBrano}s`);
  
  // Controllo ogni 500ms
  appState.playerStateInterval = setInterval(() => {
    if (!appState.youtubePlayer || typeof appState.youtubePlayer.getCurrentTime !== 'function') {
      clearInterval(appState.playerStateInterval);
      return;
    }
    
    const currentTime = Math.floor(appState.youtubePlayer.getCurrentTime());
    
    // Se abbiamo raggiunto il tempo di fine
    if (currentTime >= fineBrano) {
      console.log(`⏹️ Tempo raggiunto: ${currentTime}s >= ${fineBrano}s - Pausa video`);
      
      // Fermo il video
      appState.youtubePlayer.pauseVideo();
      
      // Fermo il monitoraggio
      clearInterval(appState.playerStateInterval);
      appState.playerStateInterval = null;
      
      // Dopo 3 secondi, leggo la domanda con TTS
      setTimeout(() => {
        speakQuestion(appState.currentBranoData.domanda);
      }, 3000);
    }
  }, 500);
}

// Legge la domanda con TTS
function speakQuestion(domanda) {
  if (!domanda || domanda.trim() === '') {
    console.log('⚠️ Nessuna domanda da leggere');
    // Anche senza domanda, sposto il focus al brano successivo
    focusNextBrano();
    return;
  }
  
  // Verifica supporto TTS
  if (!window.speechSynthesis) {
    console.error('❌ TTS non supportato da questo browser');
    alert(`Domanda: ${domanda}`);
    // Sposto il focus al brano successivo
    focusNextBrano();
    return;
  }
  
  console.log(`🔊 TTS: "${domanda}"`);
  
  // Mostro indicatore TTS
  if (ui.ttsIndicator) {
    ui.ttsIndicator.classList.add('active');
  }
  
  // Creo l'utterance
  const utterance = new SpeechSynthesisUtterance(domanda);
  utterance.lang = 'it-IT';
  utterance.rate = 0.9; // Velocità leggermente ridotta
  utterance.pitch = 1;
  utterance.volume = 1;
  
  // Quando finisce di parlare
  utterance.onend = () => {
    console.log('✅ TTS completato');
    if (ui.ttsIndicator) {
      ui.ttsIndicator.classList.remove('active');
    }
    
    // 🎯 FOCUS AUTOMATICO: Sposto il focus al brano successivo
    setTimeout(() => {
      focusNextBrano();
    }, 500); // Piccolo delay per dare all'utente il tempo di processare
  };
  
  utterance.onerror = (error) => {
    console.error('❌ Errore TTS:', error);
    if (ui.ttsIndicator) {
      ui.ttsIndicator.classList.remove('active');
    }
    alert(`Domanda: ${domanda}`);
    // Anche in caso di errore, sposto il focus
    focusNextBrano();
  };
  
  // Avvia la sintesi vocale
  window.speechSynthesis.speak(utterance);
}

// Anteprima della domanda con TTS (senza spostare il focus)
function speakQuestionPreview(domanda) {
  if (!domanda || domanda.trim() === '') {
    console.log('⚠️ Nessuna domanda da riprodurre');
    return;
  }
  
  // Verifica supporto TTS
  if (!window.speechSynthesis) {
    console.error('❌ TTS non supportato da questo browser');
    alert(`Domanda: ${domanda}`);
    return;
  }
  
  // Ferma eventuali sintesi vocali in corso
  window.speechSynthesis.cancel();
  
  console.log(`🔊 TTS Anteprima: "${domanda}"`);
  
  // Creo l'utterance
  const utterance = new SpeechSynthesisUtterance(domanda);
  utterance.lang = 'it-IT';
  utterance.rate = 0.9; // Velocità leggermente ridotta
  utterance.pitch = 1;
  utterance.volume = 1;
  
  // Quando finisce di parlare (solo log, nessuna azione)
  utterance.onend = () => {
    console.log('✅ TTS Anteprima completato');
  };
  
  utterance.onerror = (error) => {
    console.error('❌ Errore TTS Anteprima:', error);
    alert(`Impossibile riprodurre la domanda: ${error.message}`);
  };
  
  // Avvia la sintesi vocale
  window.speechSynthesis.speak(utterance);
}

// Mette il focus sul primo brano della lista
function focusFirstBrano() {
  const firstBrano = document.getElementById('brano-0');
  if (firstBrano) {
    firstBrano.focus();
    appState.currentBranoIndex = 0;
    console.log('🎯 Focus sul primo brano (index 0)');
  }
}

// Sposta il focus al brano successivo
function focusNextBrano() {
  const nextIndex = appState.currentBranoIndex + 1;
  const nextBrano = document.getElementById(`brano-${nextIndex}`);
  
  if (nextBrano) {
    // C'è un brano successivo
    nextBrano.focus();
    appState.currentBranoIndex = nextIndex;
    console.log(`🎯 Focus spostato sul brano ${nextIndex}`);
  } else {
    // Non ci sono più brani, torno al primo
    focusFirstBrano();
    console.log('🔄 Fine lista - Focus tornato al primo brano');
  }
}

// Gestisce la pressione di tasti su un brano
function handleBranoKeyDown(event, branoIndex) {
  // Spazio o Enter attivano il brano
  if (event.key === ' ' || event.key === 'Enter') {
    event.preventDefault(); // Evito scroll della pagina con spazio
    console.log(`⌨️ Tasto ${event.key} premuto sul brano ${branoIndex}`);
    selectBrano(branoIndex);
  }
  // Freccia giù: vai al brano successivo
  else if (event.key === 'ArrowDown') {
    event.preventDefault();
    const nextIndex = branoIndex + 1;
    const nextBrano = document.getElementById(`brano-${nextIndex}`);
    if (nextBrano) {
      nextBrano.focus();
      appState.currentBranoIndex = nextIndex;
    }
  }
  // Freccia su: vai al brano precedente
  else if (event.key === 'ArrowUp') {
    event.preventDefault();
    const prevIndex = branoIndex - 1;
    if (prevIndex >= 0) {
      const prevBrano = document.getElementById(`brano-${prevIndex}`);
      if (prevBrano) {
        prevBrano.focus();
        appState.currentBranoIndex = prevIndex;
      }
    }
  }
}

// Elimina un brano dall'archivio
function deleteBrano(branoId, nomeBrano, linkYoutube) {
  if (!confirm(`Vuoi davvero eliminare:\n"${nomeBrano}"?`)) {
    return;
  }
  
  const payload = branoId 
    ? { action: 'delete', id: branoId }
    : { action: 'delete', link_youtube: linkYoutube };
  
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
        throw new Error(data.error || 'Impossibile eliminare');
      }
      
      alert('Brano eliminato con successo!');
      
      // Ricarico la lista
      const userName = ui.userSelect?.value;
      if (userName) {
        setTimeout(() => {
          loadUserBrani(userName);
        }, 500);
      }
    })
    .catch((error) => {
      console.error('Errore eliminazione:', error);
      alert(`Errore: ${error.message}`);
    });
}

// Espongo le funzioni globalmente
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
window.deleteBrano = deleteBrano;
window.saveLocalUserAndStart = saveLocalUserAndStart;
window.changeLocalUser = changeLocalUser;
window.deleteBranoLocal = deleteBranoLocal;
window.switchToUserMode = switchToUserMode;
window.switchToEducatorMode = switchToEducatorMode;
window.selectLocalUser = selectLocalUser;
window.addNewLocalUser = addNewLocalUser;
window.handleBranoKeyDown = handleBranoKeyDown;
window.focusFirstBrano = focusFirstBrano;
window.focusNextBrano = focusNextBrano;
window.speakQuestionPreview = speakQuestionPreview;

// Callback per YouTube IFrame API
window.onYouTubeIframeAPIReady = function() {
  console.log('✅ YouTube IFrame API pronta');
  window.youtubeAPIReady = true;
};

document.addEventListener('DOMContentLoaded', () => {
  console.log(`${APP_CONFIG.name} v${APP_CONFIG.version} caricato`);
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
