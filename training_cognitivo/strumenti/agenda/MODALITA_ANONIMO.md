# 👤 Modalità "Anonimo" - Test Sviluppatore

## 🎯 Cos'è?

La modalità "Anonimo" è una funzionalità speciale per **sviluppatori** che permette di testare l'applicazione **senza creare pazienti** nel database.

---

## 🔑 Chi può usarla?

### ✅ Sviluppatore
- Vede automaticamente **"👤 Anonimo (Test)"** come prima opzione nel dropdown
- Selezionato di default all'apertura
- Può creare agende test che vengono salvate in **localStorage**
- Non richiede database configurato per testare
- **Auto-detect in locale**: Se apri `gestione.html` in localhost senza login, il sistema imposta automaticamente ruolo sviluppatore per test immediati

### ✅ Amministratore
- Vede **tutti i pazienti** nel dropdown
- Può selezionare pazienti reali dal database
- **NON** vede l'opzione "Anonimo"

### ✅ Educatore
- Vede **solo i pazienti assegnati** a lui
- Filtrati tramite tabella `educatori_pazienti`
- **NON** vede l'opzione "Anonimo"

---

## 💾 Come Funziona?

### Modalità Anonimo (Sviluppatore)

```javascript
// Selezione paziente: "anonimo"
appState.selectedPaziente = 'anonimo';

// Agende salvate in localStorage
localStorage.setItem('agende_anonimo', JSON.stringify([...]));

// Item salvati in localStorage
localStorage.setItem('items_anonimo_[id_agenda]', JSON.stringify([...]));
```

**Vantaggi:**
- ✅ Test immediato senza setup database
- ✅ Nessun dato sporcato nel DB
- ✅ Cancellabile facilmente (clear localStorage)
- ✅ Ideale per demo e sviluppo

**Limitazioni:**
- ⚠️ Dati solo in browser (non persistenti)
- ⚠️ Cancellati se si pulisce cache browser
- ⚠️ Non sincronizzati tra dispositivi

---

### Modalità Database (Educatore/Admin)

```javascript
// Selezione paziente reale
appState.selectedPaziente = 123; // ID numerico

// Agende salvate in MySQL
await apiClient.createAgenda(...);

// Item salvati in MySQL
await apiClient.createItem(...);
```

**Vantaggi:**
- ✅ Persistenza permanente
- ✅ Sincronizzazione online/offline
- ✅ Multi-dispositivo
- ✅ Backup automatico

---

## 🧪 Test con Modalità Anonimo

### Scenario 1: Test Rapido Sviluppatore (Senza Login)

```
1. Apri: http://localhost/Assistivetech/training_cognitivo/strumenti/gestione.html
2. Sistema rileva localhost → Auto-imposta ruolo sviluppatore ✅
3. Dropdown già su "👤 Anonimo (Test)" ✅
4. Crea agenda: "Test Agenda"
5. Aggiungi item ARASAAC
6. Testa navigazione
7. F12 → Application → Local Storage → Vedi dati
```

### Scenario 1bis: Test Sviluppatore (Con Login)

```
1. Login come sviluppatore
2. Apri: gestione.html
3. Dropdown già su "👤 Anonimo (Test)" ✅
4. Crea agenda test
5. Testa funzionalità
```

### Scenario 2: Test con Paziente Reale

```
1. Crea paziente in admin panel
2. Assegna paziente all'educatore
3. Login come educatore
4. Dropdown mostra solo pazienti assegnati
5. Crea agende normali (database)
```

---

## 🗑️ Pulire Dati Anonimo

### Da Console Browser (F12)

```javascript
// Cancella tutte le agende anonimo
localStorage.removeItem('agende_anonimo');

// Cancella tutti gli item anonimo
Object.keys(localStorage)
    .filter(key => key.startsWith('items_anonimo_'))
    .forEach(key => localStorage.removeItem(key));

// Oppure cancella tutto
localStorage.clear();
```

### Da Interfaccia

Non c'è ancora UI per cancellare, ma puoi:
1. Aprire DevTools (F12)
2. Tab "Application"
3. Local Storage → Seleziona dominio
4. Click destro → Clear

---

## 🔍 Verifica Modalità Attiva

### In Console Browser

```javascript
// Controlla quale paziente è selezionato
console.log(appState.selectedPaziente);

// Output:
// "anonimo" → Modalità Anonimo ✅
// 123 → Modalità Database (ID paziente)
```

### Visual Indicator

```html
<!-- Nel dropdown -->
<option value="anonimo" selected>👤 Anonimo (Test)</option>

<!-- Alert dopo creazione -->
"Agenda test creata (localStorage)" → Modalità Anonimo ✅
"Agenda creata con successo" → Modalità Database ✅
```

---

## 📊 Confronto Modalità

| Feature | Anonimo (Sviluppatore) | Database (Educatore/Admin) |
|---------|----------------------|---------------------------|
| **Setup richiesto** | ❌ Nessuno | ✅ Database + Pazienti |
| **Persistenza** | Browser only | Server MySQL |
| **Multi-dispositivo** | ❌ No | ✅ Sì |
| **Offline** | ✅ Sempre | ✅ Con sync |
| **Cancellabile** | ✅ Facile (localStorage) | ⚠️ Soft delete DB |
| **Ideale per** | Test, Demo, Dev | Produzione, Utenti reali |

---

## 🚨 Nota Importante

**La modalità "Anonimo" NON deve essere usata in produzione con pazienti reali!**

È pensata **solo per**:
- ✅ Testing sviluppatore
- ✅ Demo applicazione
- ✅ Sviluppo nuove feature
- ✅ Debug senza sporcare DB

Per **uso reale**:
- ✅ Crea pazienti veri nell'admin panel
- ✅ Assegna pazienti agli educatori
- ✅ Usa modalità database normale

---

## 💡 Best Practices

### Sviluppatore

```
✅ Usa "Anonimo" per test rapidi
✅ Testa con pazienti reali prima del deploy
✅ Pulisci localStorage tra test
❌ NON usare "Anonimo" per demo a clienti
```

### Educatore

```
✅ Usa sempre pazienti assegnati
✅ Verifica di vedere solo "tuoi" pazienti
✅ Segnala se vedi pazienti sbagliati
❌ NON dovresti vedere "Anonimo"
```

### Amministratore

```
✅ Vedi tutti i pazienti
✅ Assegna pazienti agli educatori
✅ Verifica associazioni corrette
❌ NON dovresti vedere "Anonimo"
```

---

## 🔧 Codice Implementazione

### Auto-Detect Ambiente Locale (Nuovo!)

```javascript
function loadCurrentUser() {
    const userData = localStorage.getItem('userData');
    if (userData) {
        appState.currentUser = JSON.parse(userData);
    }

    // 🆕 Auto-imposta sviluppatore se in localhost SENZA login
    if (!appState.currentUser &&
        (window.location.hostname === 'localhost' ||
         window.location.hostname === '127.0.0.1' ||
         window.location.hostname.includes('local'))) {

        appState.currentUser = {
            ruolo_registrazione: 'sviluppatore',
            id_registrazione: 1,
            nome_registrazione: 'Sviluppatore',
            cognome_registrazione: 'Test'
        };
    }
}
```

### Rilevamento Ruolo

```javascript
const userRole = appState.currentUser?.ruolo_registrazione;

if (userRole === 'sviluppatore') {
    // Mostra opzione "Anonimo"
    select.innerHTML = '<option value="anonimo" selected>👤 Anonimo (Test)</option>';
}
else if (userRole === 'educatore') {
    // Carica solo pazienti assegnati
    fetch(`/api/api_pazienti.php?action=list_by_educatore&id_educatore=${userId}`);
}
else if (userRole === 'amministratore') {
    // Carica tutti i pazienti
    fetch('/api/api_pazienti.php?action=list');
}
```

### Gestione Agende Anonimo

```javascript
if (appState.selectedPaziente === 'anonimo') {
    // localStorage invece di API
    const agende = JSON.parse(localStorage.getItem('agende_anonimo') || '[]');
    renderAgende(agende);
}
else {
    // API normale
    const agende = await apiClient.listAgende(idPaziente);
    renderAgende(agende);
}
```

---

## ❓ FAQ

### Q: Come faccio a sapere se sono in modalità Anonimo?
**A:** Controlla il dropdown: se vedi "👤 Anonimo (Test)", sei in modalità test.

### Q: I dati Anonimo sono salvati sul server?
**A:** No, solo nel browser (localStorage). Nessun database coinvolto.

### Q: Posso convertire agende Anonimo in reali?
**A:** No, dovrai ricrearle per un paziente reale. È voluto per evitare dati test in produzione.

### Q: Cosa succede se cancello cache browser?
**A:** Perdi tutti i dati Anonimo. Questo è normale, è modalità test!

### Q: Un educatore può vedere "Anonimo"?
**A:** No, mai. Solo sviluppatori vedono questa opzione.

### Q: 🆕 Devo fare login in localhost per testare?
**A:** No! Se apri `gestione.html` in localhost (127.0.0.1, localhost, o dominio con "local"), il sistema rileva automaticamente l'ambiente di sviluppo e imposta il ruolo sviluppatore. Test immediato senza login!

### Q: 🆕 Vedo "Effettua il login per continuare" in produzione, cosa faccio?
**A:** È normale se non hai fatto login. Clicca sul bottone "Vai al Login" che appare automaticamente, oppure vai manualmente su https://assistivetech.it/login.html

---

**Versione**: 1.1.0 (🆕 Auto-detect locale + Login Alert)
**Data**: 2025-10-28
**Implementato in**: `js/educatore-app.js` (righe 40-66, 137-148, 747-768)
