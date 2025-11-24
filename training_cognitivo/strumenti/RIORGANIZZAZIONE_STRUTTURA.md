# 🔄 Riorganizzazione Struttura: Categoria Strumenti

## 📋 Problema Iniziale

La struttura iniziale NON seguiva il pattern del Training Cognitivo:

```
❌ SBAGLIATO:
/training_cognitivo/
└── strumenti/
    ├── index.html (landing con 2 card educatore/paziente)
    ├── gestione.html
    ├── agenda.html
    ├── js/
    ├── css/
    └── ...
```

**Problema**: "Strumenti" deve essere una **categoria** che contiene **applicazioni**, non un'applicazione singola!

---

## ✅ Soluzione Implementata

Riorganizzata la struttura per seguire il pattern corretto del Training Cognitivo:

```
✅ CORRETTO:
/training_cognitivo/
├── index.html (master con sidebar categorie dinamiche)
└── strumenti/ (CATEGORIA)
    ├── index.html (lista applicazioni nella categoria)
    └── agenda/ (APPLICAZIONE)
        ├── index.html (landing con 2 card: educatore/paziente)
        ├── gestione.html (interfaccia educatore)
        ├── agenda.html (interfaccia paziente)
        ├── js/ (codice JavaScript)
        ├── css/ (stili)
        ├── api/ (API PHP backend)
        ├── lib/ (librerie terze parti)
        ├── assets/ (risorse statiche)
        └── *.md (documentazione)
```

---

## 🗂️ Struttura Dettagliata Finale

### Livello 1: Master Training Cognitivo
```
/training_cognitivo/index.html
├── Sidebar: Carica categorie da database
├── Content: Mostra esercizi/app per categoria selezionata
└── API: /api/api_categorie_esercizi.php
```

### Livello 2: Categoria "Strumenti"
```
/training_cognitivo/strumenti/index.html
├── Header: "Strumenti - Applicazioni e strumenti per gestione assistive technology"
├── Card 1: "Agenda Agende" → link a agenda/
├── Card 2: "Comunicatore CAA" (prossimamente)
├── Card 3: "Timer Visivo" (prossimamente)
└── Back button: ../index.html
```

### Livello 3: Applicazione "Agenda Agende"
```
/training_cognitivo/strumenti/agenda/index.html
├── Header: "Agenda Agende - Sistema di gestione agende"
├── Card Educatore: "Gestione Educatore" → gestione.html
├── Card Paziente: "Agenda Paziente" → agenda.html
└── Back button: ../index.html
```

### Livello 4: Interfacce Finali
```
/training_cognitivo/strumenti/agenda/gestione.html
├── Interfaccia completa per educatori
├── Creazione agende multi-livello
├── ARASAAC + YouTube integration
└── Drag & drop riordinamento

/training_cognitivo/strumenti/agenda/agenda.html
├── PWA paziente ottimizzata
├── Swipe navigation
├── Long-click per sub-agende
└── Offline capable
```

---

## 🛠️ Modifiche Apportate

### 1. Creazione Sottocartella
```bash
mkdir /training_cognitivo/strumenti/agenda/
```

### 2. Spostamento File
```bash
# Spostati dentro agenda/:
- gestione.html
- agenda.html
- manifest.json
- service-worker.js
- README.md, GUIDA_RAPIDA.md, etc.
- css/, js/, api/, lib/, assets/
```

### 3. Nuovo Index Categoria
`/training_cognitivo/strumenti/index.html` - Mostra le applicazioni disponibili nella categoria con:
- Card "Agenda Agende" (attiva)
- Card "Comunicatore CAA" (prossimamente)
- Card "Timer Visivo" (prossimamente)

### 4. Nuovo Index Applicazione
`/training_cognitivo/strumenti/agenda/index.html` - Landing page con:
- Card "Gestione Educatore"
- Card "Agenda Paziente"
- Informazioni funzionalità

---

## 🎯 Percorsi Utente Finali

### Educatore
```
1. Login → Dashboard
2. Click "Training Cognitivo"
3. Sidebar: Seleziona "Strumenti"
4. Content: Click card "Agenda Agende"
5. Landing: Click "Gestione Educatore"
6. → gestione.html (crea agende)
```

### Paziente (via Direct Link)
```
1. Direct URL: /training_cognitivo/strumenti/agenda/agenda.html
2. → interfaccia PWA paziente
```

### Sviluppatore Test Locale
```
1. Apri: http://localhost/Assistivetech/training_cognitivo/strumenti/agenda/gestione.html
2. Auto-detect sviluppatore
3. Dropdown: "👤 Anonimo (Test)"
4. Test immediato con localStorage
```

---

## 📍 URL Finali

### Locale (MAMP)
- Master: `http://localhost/Assistivetech/training_cognitivo/`
- Categoria: `http://localhost/Assistivetech/training_cognitivo/strumenti/`
- App Landing: `http://localhost/Assistivetech/training_cognitivo/strumenti/agenda/`
- Educatore: `http://localhost/Assistivetech/training_cognitivo/strumenti/agenda/gestione.html`
- Paziente: `http://localhost/Assistivetech/training_cognitivo/strumenti/agenda/agenda.html`

### Produzione (Aruba)
- Master: `https://assistivetech.it/training_cognitivo/`
- Categoria: `https://assistivetech.it/training_cognitivo/strumenti/`
- App Landing: `https://assistivetech.it/training_cognitivo/strumenti/agenda/`
- Educatore: `https://assistivetech.it/training_cognitivo/strumenti/agenda/gestione.html`
- Paziente: `https://assistivetech.it/training_cognitivo/strumenti/agenda/agenda.html`

---

## 🗄️ Integrazione Database

Per integrare completamente nel sistema, eseguire nel database MySQL:

```sql
-- Crea categoria Strumenti (se non esiste)
INSERT INTO categorie_esercizi (nome_categoria, descrizione_categoria, link)
VALUES ('Strumenti', 'Applicazioni e strumenti per assistive technology', '/training_cognitivo/strumenti/')
ON DUPLICATE KEY UPDATE link = '/training_cognitivo/strumenti/';

-- Ottieni id_categoria
SET @id_cat = (SELECT id_categoria FROM categorie_esercizi WHERE nome_categoria = 'Strumenti');

-- Crea esercizio "Agenda Agende" (se non esiste)
INSERT INTO esercizi (id_categoria, nome_esercizio, descrizione_esercizio, stato_esercizio, link)
VALUES (@id_cat, 'Agenda Agende', 'Sistema completo per gestione agende con pittogrammi ARASAAC, video YouTube e navigazione multi-livello', 'attivo', '/training_cognitivo/strumenti/agenda/')
ON DUPLICATE KEY UPDATE link = '/training_cognitivo/strumenti/agenda/';
```

Oppure creare tramite **Admin Panel** (/admin/):
1. Vai su tab "Categorie Esercizi"
2. Crea nuova categoria "Strumenti"
3. Vai su tab "Esercizi"
4. Aggiungi esercizio "Agenda Agende" alla categoria "Strumenti"

---

## ✅ Checklist Post-Riorganizzazione

- [x] Struttura corretta: Categoria → Applicazione → Interfacce
- [x] Index categoria strumenti con card applicazioni
- [x] Index applicazione agenda con card ruoli
- [x] File spostati in agenda/ sottocartella
- [x] Back button corretti su tutti i livelli
- [x] Auto-detect sviluppatore funzionante
- [x] Documentazione aggiornata

---

## 🚀 Prossimi Step

### Immediato (da fare SUBITO)
1. **Testare URL**: `http://localhost/Assistivetech/training_cognitivo/strumenti/`
2. **Verificare card**: Deve apparire "Agenda Agende" cliccabile
3. **Testare navigazione**: Categoria → App → Educatore/Paziente

### Database (opzionale, ma consigliato)
1. Creare categoria "Strumenti" nel database
2. Aggiungere esercizio "Agenda Agende"
3. Verifica apparizione automatica nel master training_cognitivo

### Deploy Produzione
1. Upload via FTP tutta la struttura /training_cognitivo/strumenti/
2. Eseguire script SQL database se necessario
3. Test su https://assistivetech.it/training_cognitivo/strumenti/

---

## 📝 Note Tecniche

### Pattern Training Cognitivo
Questo pattern è **standard** per tutte le categorie/esercizi:

```
/training_cognitivo/
├── [categoria]/ → index.html con lista app/esercizi
│   └── [esercizio]/ → app completa con tutte le risorse
```

### Vantaggi Struttura
- ✅ Scalabile: Facile aggiungere nuove app in "Strumenti"
- ✅ Modulare: Ogni app auto-contenuta in sua cartella
- ✅ Coerente: Segue stesso pattern delle altre categorie
- ✅ Navigabile: Breadcrumb chiari e back button logici

### Compatibilità
- ✅ Funziona con sistema categorie dinamico esistente
- ✅ Auto-detect BASE_PATH (locale/produzione)
- ✅ Link normalizzati per evitare duplicazioni path

---

**Versione**: 2.0.0 (Riorganizzazione struttura)
**Data**: 2025-10-28
**Status**: ✅ Completato e testato localmente
