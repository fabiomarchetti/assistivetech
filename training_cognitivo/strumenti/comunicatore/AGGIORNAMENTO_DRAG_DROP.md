# 🔄 AGGIORNAMENTO DRAG & DROP - Comunicatore v2.5.0

## 📅 Data: 14/11/2025

## ✨ NUOVA FUNZIONALITÀ: RIORDINAMENTO PAGINE

È stata aggiunta la possibilità di **riordinare le pagine** tramite **drag & drop** nell'interfaccia educatore.

---

## 🆕 MODIFICHE AI FILE

### 1. **js/db-local.js**
**Modificato:** Aggiunto metodo `reorderPagine()`

**Descrizione:**
- Gestisce il riordinamento delle pagine in IndexedDB (modalità offline)
- Aggiorna il campo `numero_ordine` per ogni pagina
- Compatibile con il sistema locale PWA

**Nuovo codice:** Righe 266-310

---

### 2. **js/educatore-app.js**
**Modificato:**
- Aggiornata funzione `renderPagineList()` con supporto drag & drop
- Aggiunte funzioni di gestione eventi drag & drop

**Descrizione:**
- Ogni card pagina è ora **draggable** (trascinabile)
- Aggiunta icona **grip** (`bi-grip-vertical`) per indicare trascinabilità
- Gestione completa eventi HTML5 Drag and Drop API
- Supporto sia modalità **online** (server) che **offline** (locale)

**Nuove funzioni:**
- `handleDragStart(event)` - Inizio trascinamento
- `handleDragOver(event)` - Passaggio sopra elemento
- `handleDragEnter(event)` - Entrata in zona drop
- `handleDragLeave(event)` - Uscita da zona drop
- `handleDrop(event)` - Rilascio elemento (salva ordine)
- `handleDragEnd(event)` - Fine trascinamento

**Righe modificate/aggiunte:** 295-346, 974-1082

---

### 3. **css/educatore.css**
**Modificato:** Aggiunti stili per drag & drop

**Descrizione:**
- Stile per card draggable (cursor: move)
- Effetto visivo durante drag (opacità, scale)
- Evidenziazione zona drop (border, background)
- Animazione icona grip al hover

**Nuovi stili:** Righe 257-285

---

## 📋 FILE COINVOLTI NEL DEPLOY

### ✅ File da SOVRASCRIVERE su Aruba:

```
comunicatore/js/db-local.js          ← AGGIORNATO
comunicatore/js/educatore-app.js     ← AGGIORNATO
comunicatore/css/educatore.css       ← AGGIORNATO
```

### ✅ File già presenti (nessuna modifica):

```
comunicatore/js/api-client.js        ← OK (metodo reorderPagine già presente)
comunicatore/api/pagine.php          ← OK (endpoint reorder già presente)
```

---

## 🚀 PROCEDURA DEPLOY RAPIDO

### Opzione A: Sovrascrittura singoli file
Via FTP, carica SOLO i 3 file modificati:

```bash
/training_cognitivo/strumenti/comunicatore/js/db-local.js
/training_cognitivo/strumenti/comunicatore/js/educatore-app.js
/training_cognitivo/strumenti/comunicatore/css/educatore.css
```

### Opzione B: Sovrascrittura cartella intera
Carica l'intera cartella `comunicatore` come da procedura normale.

---

## ✅ VERIFICA POST-DEPLOY

1. **Vai a:** `https://www.assistivetech.it/training_cognitivo/strumenti/comunicatore/gestione.html`

2. **Seleziona un utente** con almeno 2 pagine create

3. **Verifica icona grip:**
   - Ogni pagina deve mostrare l'icona `⋮⋮` a sinistra
   - Al hover, l'icona diventa più opaca

4. **Testa drag & drop:**
   - Clicca e tieni premuto su una pagina
   - Trascina verso l'alto o il basso
   - Rilascia sulla posizione desiderata
   - Verifica che l'ordine venga salvato

5. **Console log:**
   ```
   🔄 Drag iniziato - Index: 0
   🔄 Drop - Da index 0 a index 2
   ✅ Riordinamento completato
   ```

6. **Verifica persistenza:**
   - Ricarica la pagina (F5)
   - L'ordine deve essere mantenuto

---

## 🎯 COMPORTAMENTO ATTESO

### Area Educatore (gestione.html)

**Prima del drag:**
```
📄 Pagina 1 - Benvenuto    #1
📄 Pagina 2 - Voglio       #2
📄 Pagina 3 - Ciao         #3
```

**Durante il drag:**
- La pagina trascinata diventa semi-trasparente (opacity: 0.5)
- La zona di drop si evidenzia (bordo viola)
- Cursor cambia in "grabbing"

**Dopo il drop:**
```
📄 Pagina 2 - Voglio       #1  ← riordinata
📄 Pagina 1 - Benvenuto    #2
📄 Pagina 3 - Ciao         #3
```

### Area Utente (comunicatore.html)

**Nessuna modifica:**
- L'utente vede le pagine nell'ordine impostato dall'educatore
- Swipe continua a funzionare normalmente
- Nessun drag & drop disponibile (solo visualizzazione)

---

## 🔧 MECCANISMO TECNICO

### 1. Frontend (JavaScript)
```javascript
// Riordina array locale
const pagine = [...appState.currentPagine];
const [removed] = pagine.splice(oldIndex, 1);
pagine.splice(newIndex, 0, removed);

// Crea array ordini aggiornato
const ordini = pagine.map((pagina, index) => ({
    id_pagina: pagina.id_pagina,
    numero_ordine: index
}));
```

### 2. Backend (API/DB)

**Modalità ONLINE (server):**
```javascript
await apiClient.reorderPagine(ordini);
```
→ POST a `/api/pagine.php?action=reorder`
→ UPDATE `comunicatore_pagine` SET `numero_ordine` = X

**Modalità OFFLINE (locale):**
```javascript
await localDB.reorderPagine(ordini);
```
→ Aggiorna IndexedDB locale
→ Sincronizzazione automatica quando torna online

---

## 🐛 TROUBLESHOOTING

### Problema: "Drag non funziona"

**Causa possibile:**
- Browser non supporta HTML5 Drag and Drop
- File CSS non caricato

**Soluzione:**
```bash
1. CTRL+SHIFT+R (ricarica hard)
2. Verifica Console → nessun errore 404 su educatore.css
3. Testa su Chrome/Firefox (Safari mobile potrebbe avere limitazioni)
```

---

### Problema: "Ordine non si salva"

**Causa possibile:**
- Errore API o database

**Soluzione:**
```bash
1. Apri Console (F12)
2. Cerca errori durante il drop
3. Verifica che l'endpoint /api/pagine.php?action=reorder risponda
4. Controlla che il database abbia la colonna 'numero_ordine'
```

---

### Problema: "Icona grip non visibile"

**Causa possibile:**
- Bootstrap Icons non caricato

**Soluzione:**
```html
<!-- Verifica in gestione.html che ci sia: -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
```

---

## 📊 COMPATIBILITÀ

| Browser | Drag & Drop | Note |
|---------|-------------|------|
| Chrome Desktop | ✅ Completo | Supporto nativo |
| Firefox Desktop | ✅ Completo | Supporto nativo |
| Edge Desktop | ✅ Completo | Supporto nativo |
| Safari Desktop | ✅ Completo | Supporto nativo |
| Chrome Mobile | ⚠️ Limitato | Touch drag potrebbe non funzionare |
| Safari Mobile | ⚠️ Limitato | Touch drag potrebbe non funzionare |

**Nota:** Il drag & drop è pensato per desktop. Su mobile si può usare comunque l'interfaccia standard (click per selezionare pagina).

---

## 🎨 ISPIRAZIONE

Questo meccanismo è **identico** a quello implementato in:
```
/agenda_timer/
```

Utilizza:
- **Flutter:** `ReorderableListView.builder`
- **Comunicatore:** HTML5 Drag and Drop API

Stesso principio, tecnologie diverse! 🚀

---

## 📦 VERSIONE

**Versione:** 2.5.0
**Data:** 14/11/2025
**Feature:** Drag & Drop Riordinamento Pagine
**Compatibilità:** Mantiene 100% compatibilità con v2.4.0

---

## ✅ CHECKLIST DEPLOY

- [x] Modificato `js/db-local.js`
- [x] Modificato `js/educatore-app.js`
- [x] Modificato `css/educatore.css`
- [x] Aggiornato `service-worker.js` versione → v2.5.0
- [ ] Caricato su Aruba via FTP (4 file: db-local.js, educatore-app.js, educatore.css, service-worker.js)
- [ ] Testato drag & drop su produzione
- [ ] Verificato persistenza ordine
- [ ] Testato modalità offline
- [ ] Comunicato agli utenti iPad di aggiornare la PWA (vedi AGGIORNAMENTO_PWA_IPAD.md)

---

**Fine documento** 🎉
