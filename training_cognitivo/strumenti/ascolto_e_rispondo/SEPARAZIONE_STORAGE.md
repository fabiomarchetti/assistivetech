# 🔐 Separazione Storage - ascolto e rispondo

## 📋 Problema Risolto

**Problema originale:**  
Le applicazioni "ascolto la musica" e "ascolto e rispondo" condividevano le stesse chiavi nel localStorage, causando:
- Sovrapposizione dei dati tra le due app
- Perdita delle caratteristiche specifiche di "ascolto e rispondo" (domande, tempi)
- Confusione tra i brani delle due applicazioni

**Soluzione implementata:**  
Aggiunto un prefisso unico `ascolto_rispondo_` a tutte le chiavi del localStorage di "ascolto e rispondo".

---

## 🔑 Chiavi localStorage

### PRIMA (condivise tra le due app):
```
localUser                    → Nome utente corrente
localBrani_NomeUtente        → Brani salvati per NomeUtente
```

### DOPO (separate):

**"ascolto la musica":**
```
localUser                    → Nome utente corrente
localBrani_NomeUtente        → Brani musicali (senza domande/tempi)
```

**"ascolto e rispondo":**
```
ascolto_rispondo_localUser              → Nome utente corrente
ascolto_rispondo_localBrani_NomeUtente  → Esercizi (con domande/tempi)
```

---

## 🚀 Migrazione Dati Esistenti

Se hai già dati salvati nella vecchia versione, devi migrarli:

### **Opzione 1: Tool HTML Automatico** (Raccomandato)

1. Apri nel browser:
   ```
   http://localhost/Assistivetech/.../ascolto_e_rispondo/assets/migrazione_storage.html
   ```

2. Clicca **"🚀 Avvia Migrazione"**

3. Controlla il log per verificare il successo

4. (Opzionale) Dopo aver verificato che tutto funziona, clicca **"🗑️ Elimina Vecchie Chiavi"**

---

### **Opzione 2: Console Browser (Manuale)**

Apri la console del browser (`F12` → Console) e incolla:

```javascript
// Migrazione manuale localStorage
const STORAGE_PREFIX = 'ascolto_rispondo_';

function migraStorage() {
    let count = 0;
    
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        
        if (key && !key.startsWith(STORAGE_PREFIX)) {
            if (key.startsWith('localBrani_') || key === 'localUser') {
                const value = localStorage.getItem(key);
                const newKey = STORAGE_PREFIX + key;
                
                if (!localStorage.getItem(newKey)) {
                    localStorage.setItem(newKey, value);
                    console.log(`✅ Migrata: ${key} → ${newKey}`);
                    count++;
                }
            }
        }
    }
    
    console.log(`📊 Totale chiavi migrate: ${count}`);
}

migraStorage();
```

---

## ✅ Verifica Migrazione

Per verificare che i dati siano stati migrati correttamente:

1. Apri DevTools (`F12`)
2. Vai su **"Application" → "Local Storage"**
3. Seleziona il dominio (`localhost`)
4. Cerca le chiavi che iniziano con `ascolto_rispondo_`

Dovresti vedere:
- `ascolto_rispondo_localUser`
- `ascolto_rispondo_localBrani_NomeUtente1`
- `ascolto_rispondo_localBrani_NomeUtente2`
- ecc.

---

## 🗑️ Pulizia Vecchie Chiavi (Opzionale)

**⚠️ SOLO DOPO** aver verificato che la migrazione funzioni:

1. Usa il tool di migrazione e clicca "Elimina Vecchie Chiavi"

**OPPURE** console browser:

```javascript
// Elimina vecchie chiavi (ATTENZIONE: irreversibile!)
function pulisciVecchieChiavi() {
    const keysToDelete = [];
    
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && !key.startsWith('ascolto_rispondo_')) {
            if (key.startsWith('localBrani_') || key === 'localUser') {
                keysToDelete.push(key);
            }
        }
    }
    
    keysToDelete.forEach(key => {
        localStorage.removeItem(key);
        console.log(`🗑️ Eliminata: ${key}`);
    });
    
    console.log(`📊 Totale chiavi eliminate: ${keysToDelete.length}`);
}

pulisciVecchieChiavi();
```

---

## 🔧 Modifiche Tecniche al Codice

Nel file `js/app.js` sono state applicate le seguenti modifiche:

### 1. Aggiunta Costante
```javascript
const STORAGE_PREFIX = 'ascolto_rispondo_';
```

### 2. Funzioni Modificate
- `getLocalUsers()` - Cerca utenti con prefisso
- `selectLocalUser()` - Usa chiave con prefisso
- `addNewLocalUser()` - Crea chiavi con prefisso
- `saveLocalUserAndStart()` - Salva con prefisso
- `loadUserBraniLocal()` - Legge da chiave con prefisso
- `deleteBranoLocal()` - Elimina da chiave con prefisso
- `changeLocalUser()` - Rimuove chiave con prefisso
- `saveToLocalStorageIfExists()` - Sincronizza con prefisso
- `loadLocalUsers()` - Carica utenti educatore con prefisso
- `handleFormSubmit()` - Salva offline con prefisso

---

## 📊 Impatto

### Vantaggi:
✅ Le due app sono completamente indipendenti  
✅ Nessuna interferenza tra i dati  
✅ Ogni app mantiene le sue caratteristiche specifiche  
✅ Possibilità di usare entrambe le app sullo stesso dispositivo  
✅ Nessuna perdita di dati durante il caricamento  

### Cosa NON cambia:
- Il funzionamento online (database) rimane identico
- L'interfaccia utente è invariata
- Le funzionalità rimangono le stesse
- La compatibilità PWA è mantenuta

---

## 🆘 Troubleshooting

### Problema: Vedo ancora i dati vecchi

**Soluzione:**
1. Chiudi completamente il browser
2. Riapri e vai all'app
3. Esegui la migrazione storage
4. Ricarica con `Ctrl + Shift + R`

### Problema: I dati sono spariti

**Soluzione:**
1. Apri DevTools → Application → Local Storage
2. Verifica se esistono le chiavi vecchie (`localBrani_...`)
3. Esegui lo script di migrazione
4. I dati verranno copiati nelle nuove chiavi

### Problema: Ho eliminato per errore le vecchie chiavi

**Soluzione:**
- Se hai eliminato le vecchie chiavi ma la migrazione era già stata fatta, i dati sono al sicuro nelle nuove chiavi
- Se hai eliminato PRIMA di migrare, i dati sono persi (usa backup se disponibile)

---

## 📝 Note per Sviluppatori

- Il prefisso `ascolto_rispondo_` è hardcoded nella costante `STORAGE_PREFIX`
- Cambiare il prefisso richiede una nuova migrazione
- Le chiavi database (online) NON usano il prefisso (condividono la tabella `video_yt`)
- Il sistema è retrocompatibile: se non ci sono vecchie chiavi, funziona comunque

---

**📅 Data implementazione:** 2024-11-11  
**✏️ Versione app:** 1.0.0 → 2.0.0  
**🔧 File modificati:**
- `js/app.js` (10 funzioni aggiornate)
- `assets/migrazione_storage.html` (nuovo tool)
- `SEPARAZIONE_STORAGE.md` (questa documentazione)

