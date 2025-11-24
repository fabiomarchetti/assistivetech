# 📱 AGGIORNAMENTO PWA SU iPAD/iPhone

## 🎯 Come aggiornare la PWA già installata

Quando aggiorni il codice del Comunicatore su Aruba, gli utenti che hanno già installato la PWA sul loro iPad/iPhone devono aggiornare l'app per vedere le nuove funzionalità.

---

## ⚙️ PREPARAZIONE PRE-DEPLOY

### 1. **Aggiorna versione Service Worker** ✅ (GIÀ FATTO)

Il file `service-worker.js` è stato aggiornato da `v2.4.0` → `v2.5.0`

Questo forza Safari a scaricare i nuovi file quando l'utente apre l'app.

---

## 🔄 METODI DI AGGIORNAMENTO (Per l'Utente)

### **METODO 1: Ricarica Forzata** (Più Semplice)

#### Per l'utente con iPad/iPhone:

1. **Apri la PWA** dall'icona sulla Home Screen
2. **Chiudi completamente l'app:**
   - Swipe up dalla barra inferiore (iPad)
   - O doppio click sul bottone Home
   - Trova l'app "Comunicatore" nelle app aperte
   - Swipe up per chiuderla completamente
3. **Riapri l'app** dall'icona sulla Home Screen
4. **Aspetta 5-10 secondi** (Service Worker si aggiorna in background)
5. **Chiudi di nuovo l'app** completamente
6. **Riapri** → Ora hai la versione aggiornata!

#### Verifica aggiornamento:
- Le pagine devono essere riordinabili (drag & drop)
- Console dovrebbe mostrare: `[SW] Service Worker activated - comunicatore-v2.5.0`

---

### **METODO 2: Cancella Cache Safari** (Se Metodo 1 non funziona)

#### Per l'utente:

1. **Chiudi completamente la PWA** (vedi sopra)
2. Vai in **Impostazioni** → **Safari**
3. Scorri fino a **"Avanzate"**
4. Tocca **"Dati dei siti web"**
5. Cerca **"assistivetech.it"**
6. Swipe left → **Elimina**
7. Oppure tocca **"Rimuovi tutti i dati dei siti web"** (più drastico)
8. **Riapri la PWA** dall'icona
9. Attendi il download dei nuovi file (primo caricamento sarà più lento)

---

### **METODO 3: Reinstalla PWA** (Metodo Definitivo)

Se gli altri metodi non funzionano:

#### Per l'utente:

1. **Elimina l'app dalla Home Screen:**
   - Tieni premuto sull'icona del Comunicatore
   - Tocca **"Rimuovi App"** → **"Elimina"**

2. **Reinstalla da Safari:**
   - Apri Safari
   - Vai su: `https://www.assistivetech.it/training_cognitivo/strumenti/comunicatore/`
   - Tocca il pulsante **Condividi** (quadrato con freccia)
   - Scorri e tocca **"Aggiungi a Home"**
   - Tocca **"Aggiungi"**

3. **Nuova icona** apparirà sulla Home Screen con la versione aggiornata

---

## 🤖 AGGIORNAMENTO AUTOMATICO (Background)

### Come funziona:

Quando cambi il `CACHE_NAME` nel service worker (es. da `v2.4.0` → `v2.5.0`), Safari:

1. **Rileva la modifica** al prossimo caricamento
2. **Scarica il nuovo Service Worker** in background
3. **Aspetta** che l'utente chiuda l'app
4. **Attiva** la nuova versione alla prossima apertura

**Nota:** Su Safari/iOS, questo processo può richiedere **2-3 riaperture** dell'app.

---

## 📊 CONFRONTO METODI

| Metodo | Tempo | Facilità | Affidabilità | Dati Persi |
|--------|-------|----------|--------------|------------|
| **1. Ricarica Forzata** | 30 sec | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ❌ No |
| **2. Cancella Cache** | 2 min | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ❌ No* |
| **3. Reinstalla** | 5 min | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⚠️ Sì** |

*I dati in IndexedDB (utenti locali) rimangono
**Solo se l'utente aveva creato utenti locali (offline mode)

---

## 🔧 PER L'AMMINISTRATORE (Tu)

### Dopo il deploy su Aruba:

#### 1. **Verifica Service Worker attivo**

Vai su: `https://www.assistivetech.it/training_cognitivo/strumenti/comunicatore/`

Apri **DevTools** (F12):
```
Console → Applicazione → Service Workers
```

Verifica:
- ✅ Service Worker registrato
- ✅ Stato: "activated and is running"
- ✅ Versione cache: `comunicatore-v2.5.0`

#### 2. **Forza aggiornamento immediato** (Opzionale)

Se vuoi forzare l'aggiornamento per TUTTI gli utenti istantaneamente:

Aggiungi questo codice in `gestione.html` e `comunicatore.html` (temporaneo):

```javascript
// AGGIUNGERE DOPO LA REGISTRAZIONE DEL SERVICE WORKER
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
        for(let registration of registrations) {
            registration.update(); // Forza controllo aggiornamenti
        }
    });
}
```

**Dove inserire:**
Cerca nel file la sezione con `navigator.serviceWorker.register` e aggiungi subito dopo.

**IMPORTANTE:** Questo codice è temporaneo. Rimuovilo dopo 1-2 settimane.

---

## 📱 GUIDA PER UTENTI (Da inviare via email/WhatsApp)

```
📱 COMUNICATORE - AGGIORNAMENTO DISPONIBILE

Ciao! È disponibile un aggiornamento del Comunicatore con nuove funzionalità.

Per aggiornare la tua app:

1. Apri il Comunicatore dal tuo iPad
2. Chiudi completamente l'app (swipe up dalle app recenti)
3. Riapri l'app
4. Aspetta 10 secondi
5. Chiudi di nuovo completamente
6. Riapri → Aggiornamento completato!

Se l'app non si aggiorna:
- Vai in Impostazioni → Safari → Avanzate
- Tocca "Dati dei siti web"
- Cerca "assistivetech.it" ed elimina
- Riapri l'app

Novità v2.5.0:
✨ Riordinamento pagine con drag & drop (area educatore)
✨ Miglioramenti prestazioni
✨ Correzioni bug

Per supporto: [tuo contatto]
```

---

## 🐛 PROBLEMI COMUNI

### Problema: "L'app non si aggiorna mai"

**Causa:** Safari su iOS è conservativo con gli aggiornamenti PWA

**Soluzione:**
1. Aspetta 24 ore (Safari aggiorna in background)
2. Oppure usa Metodo 2 (Cancella Cache)
3. Oppure usa Metodo 3 (Reinstalla)

---

### Problema: "Dopo l'aggiornamento mancano dati"

**Causa:** IndexedDB cancellato per errore

**Soluzione:**
- Se era in modalità online (server) → Dati sono sul database, basta ricaricare
- Se era in modalità offline (locale) → Dati persi, avvisare di fare backup regolari

---

### Problema: "Service Worker non si registra"

**Causa:** HTTPS non attivo o errori in service-worker.js

**Soluzione:**
```bash
1. Verifica HTTPS attivo su assistivetech.it
2. Controlla console per errori JavaScript
3. Verifica che service-worker.js sia caricabile:
   https://www.assistivetech.it/training_cognitivo/strumenti/comunicatore/service-worker.js
```

---

## ✅ CHECKLIST DEPLOY CON AGGIORNAMENTO PWA

Prima del deploy:
- [x] Aggiornato `CACHE_NAME` in `service-worker.js` → `v2.5.0`
- [x] Verificato che tutti i file in `CACHE_URLS` esistano
- [ ] Caricato `service-worker.js` su Aruba

Dopo il deploy:
- [ ] Testato aggiornamento su Safari desktop
- [ ] Testato aggiornamento su iPad/iPhone di test
- [ ] Verificato cache attiva in DevTools
- [ ] Inviata comunicazione agli utenti

---

## 📚 RISORSE

### Per debug Service Worker:

**Safari Desktop:**
- Sviluppo → Mostra Service Workers
- Console → Filtra per "[SW]"

**Safari iOS:**
- Collega iPad a Mac via USB
- Safari Desktop → Sviluppo → [Nome iPad] → [Comunicatore]
- Console

**Chrome (per test):**
- F12 → Application → Service Workers
- Cache Storage → Vedi cache attive

---

## 🎯 STRATEGIA CONSIGLIATA

### Per utenti tecnici (educatori):
→ Usa **Metodo 1** (Ricarica Forzata)

### Per utenti non tecnici (pazienti):
→ Chiedi all'educatore di:
1. Chiudere completamente l'app dal loro iPad
2. Riaprirla 2-3 volte
3. Se non funziona → Usa Metodo 2

### Per deploy importanti:
→ Invia email/notifica a tutti gli utenti con istruzioni Metodo 1

---

## 📝 NOTE TECNICHE

### Differenze iOS vs Android:

| Aspetto | iOS/Safari | Android/Chrome |
|---------|-----------|----------------|
| Aggiornamento SW | Lento (24-48h) | Veloce (1-2h) |
| Cache persistente | Sì | Sì |
| Background sync | Limitato | Completo |
| Notifiche push | ❌ Non supportato | ✅ Supportato |

**Conclusione:** Su iOS è normale che l'aggiornamento richieda più tempo.

---

## ✨ VERSIONI

| Versione | Data | Modifiche Service Worker |
|----------|------|--------------------------|
| v2.4.0 | 12/11/2025 | Click semplificato, swipe loop |
| **v2.5.0** | **14/11/2025** | **Drag & drop riordinamento pagine** |

---

**IMPORTANTE:** Ogni volta che modifichi file JavaScript o CSS, **DEVI** aggiornare il `CACHE_NAME` in `service-worker.js` altrimenti gli utenti vedranno la versione vecchia in cache!

---

**Fine documento** 🎉
