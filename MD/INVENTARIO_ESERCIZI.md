# 📊 Inventario Esercizi Training Cognitivo

**Data mappatura**: 21 Ottobre 2025
**Path base**: `/Assistivetech/training_cognitivo/`

---

## 🎯 Riepilogo Generale

| Categoria | Totale Esercizi | JavaScript ✅ | Flutter ❌ | Da Convertire |
|-----------|-----------------|---------------|------------|---------------|
| Categorizzazione | 7 | 6 | 1 | riconosci_categoria |
| Causa Effetto | 1 | 1 | 0 | - |
| Trascina Immagini | 1 | 1 | 0 | - |
| Sequenze Logiche | 3 | 0 | 3 | ordina_lettere, ordina_numeri, ordina_azioni |
| Scrivi con Sillabe | 1 | 0 | 1 | scrivi_con_le_sillabe |
| Test Memoria | 1 | 0 | 1 | ricorda_sequenza |
| Scrivi Parole | 1 | 1? | 0? | Da verificare |
| **TOTALE** | **15** | **9-10** | **5-6** | **5-6 esercizi** |

---

## 📁 Dettaglio per Categoria

### 1️⃣ **CATEGORIZZAZIONE** (7 esercizi)

#### ✅ Già in JavaScript (6 esercizi):

| Nome Esercizio | Path | Tecnologia | Note |
|----------------|------|------------|------|
| **Cerca Animali** | `categorizzazione/animali/` | ✅ JavaScript | Bootstrap 5, TTS, ARASAAC, Timer configurabile |
| **Cerca Frutti** | `categorizzazione/frutti/` | ✅ JavaScript | Simile ad Animali |
| **Cerca Veicoli di Terra** | `categorizzazione/cerca_veicoli_di_terra/` | ✅ JavaScript | Simile ad Animali |
| **Veicoli** | `categorizzazione/veicoli/` | ✅ JavaScript | |
| **Veicoli Aria** | `categorizzazione/veicoli_aria/` | ✅ JavaScript | |
| **Veicoli Mare** | `categorizzazione/veicoli_mare/` | ✅ JavaScript | |

#### ❌ Da Convertire (1 esercizio):

| Nome Esercizio | Path | Tecnologia Attuale | Priorità |
|----------------|------|-------------------|----------|
| **Riconosci Categoria** | `categorizzazione/riconosci_categoria/` | ❌ Flutter | 🔴 ALTA |

**File presenti:**
- `pubspec.yaml` (Flutter)
- `lib/main.dart`
- `web/index.html` (build Flutter)

---

### 2️⃣ **CAUSA EFFETTO** (1 esercizio)

#### ✅ Già in JavaScript (1 esercizio):

| Nome Esercizio | Path | Tecnologia | Note |
|----------------|------|------------|------|
| **Accendi la Luce** | `causa_effetto/accendi_la_luce/` | ✅ JavaScript | Bootstrap 5, setup.html configurazione |

**Note:** Ha anche `pubspec.yaml` ma `index.html` principale è JavaScript puro

---

### 3️⃣ **TRASCINA IMMAGINI** (1 esercizio)

#### ✅ Già in JavaScript (1 esercizio):

| Nome Esercizio | Path | Tecnologia | Note |
|----------------|------|------------|------|
| **Cerca Colore** | `trascina_immagini/cerca_colore/` | ✅ JavaScript | **TEMPLATE DI RIFERIMENTO** - Drag & Drop HTML5, PWA completo, service-worker.js, ARASAAC |

**Caratteristiche:**
- ✅ PWA completo (manifest.json + service-worker.js)
- ✅ Setup wizard (setup.html)
- ✅ Drag & Drop nativo HTML5
- ✅ TTS Web Speech API
- ✅ Database logging (`api_risultati_esercizi.php`)
- ✅ Icons PWA (192x192, 512x512)

---

### 4️⃣ **SEQUENZE LOGICHE** (3 esercizi)

#### ❌ Tutti da Convertire (3 esercizi):

| Nome Esercizio | Path | Tecnologia Attuale | Priorità |
|----------------|------|-------------------|----------|
| **Ordina Lettere** | `sequenze_logiche/ordina_lettere/` | ❌ Flutter | 🔴 ALTA |
| **Ordina Numeri** | `sequenze_logiche/ordina_numeri/` | ❌ Flutter | 🔴 ALTA |
| **Ordina Azioni Quotidiane** | `sequenze_logiche/ordina_le_azioni_quotidiane/` | ❌ Flutter | 🔴 ALTA |

**File presenti (per tutti):**
- `pubspec.yaml`
- `lib/main.dart`
- `web/index.html` (build Flutter)
- `assets/`

**Logica comune:** Drag & Drop per riordinare sequenze (lettere/numeri/immagini)

---

### 5️⃣ **SCRIVI CON LE SILLABE** (1 esercizio)

#### ❌ Da Convertire (1 esercizio):

| Nome Esercizio | Path | Tecnologia Attuale | Priorità |
|----------------|------|-------------------|----------|
| **Scrivi con le Sillabe** | `scrivi_con_le_sillabe/scrivi_con_le_sillabe/` | ❌ Flutter | 🟡 MEDIA |

**File presenti:**
- `pubspec.yaml`
- `lib/main.dart`
- `web/index.html`

**Logica:** Click su sillabe per comporre parole

---

### 6️⃣ **TEST MEMORIA** (1 esercizio)

#### ❌ Da Convertire (1 esercizio):

| Nome Esercizio | Path | Tecnologia Attuale | Priorità |
|----------------|------|-------------------|----------|
| **Ricorda Sequenza** | `test_memoria/ricorda_sequenza/` | ❌ Flutter | 🟡 MEDIA |

**File presenti:**
- `pubspec.yaml`
- `lib/main.dart`
- `web/index.html`

**Logica:** Mostra sequenza → utente ripete

---

### 7️⃣ **SCRIVI PAROLE** (1 esercizio)

#### ⚠️ Da Verificare (1 esercizio):

| Nome Esercizio | Path | Tecnologia | Note |
|----------------|------|------------|------|
| **Scrivi Parole** | `scrivi/scrivi_parole/` | ⚠️ Da verificare | Ha `index.html` + `canvaskit/` (possibile Flutter web build) |

**File presenti:**
- `index.html`
- `canvaskit/` (indica possibile Flutter web)
- `icons/`

**Azione:** Verificare se è JavaScript puro o build Flutter

---

## 🎯 Piano di Conversione Prioritario

### **FASE 1 - Alta Priorità** (3 esercizi simili)

1. **Ordina Lettere** (sequenze_logiche) - Drag & Drop lettere alfabeto
2. **Ordina Numeri** (sequenze_logiche) - Drag & Drop numeri crescenti/decrescenti
3. **Ordina Azioni Quotidiane** (sequenze_logiche) - Drag & Drop immagini ARASAAC

**Tecnologie necessarie:**
- Drag & Drop HTML5 (come "Cerca Colore")
- SortableJS (libreria JS per sorting) OPPURE implementazione custom
- Bootstrap 5 per UI
- TTS Web Speech API

**Template:** Basato su "Cerca Colore" adattato per sequenze ordinabili

---

### **FASE 2 - Media Priorità** (2 esercizi)

4. **Riconosci Categoria** (categorizzazione) - Simile agli altri categorizzazione
5. **Ricorda Sequenza** (test_memoria) - Logica memory game

---

### **FASE 3 - Bassa Priorità** (1 esercizio)

6. **Scrivi con le Sillabe** - Click sillabe per comporre parole

---

## 📋 Checklist Conversione Standard

Per ogni esercizio Flutter → JavaScript:

- [ ] Leggere `lib/main.dart` per capire logica esercizio
- [ ] Creare struttura base da template "Cerca Colore":
  - [ ] `index.html` (esercizio principale)
  - [ ] `setup.html` (configurazione educatore)
  - [ ] `manifest.json` (PWA)
  - [ ] `service-worker.js` (offline support)
  - [ ] `icons/` (192x192, 512x512)
  - [ ] `README.md` (documentazione)
- [ ] Implementare logica esercizio in JavaScript vanilla
- [ ] Integrare API:
  - [ ] ARASAAC (se necessario)
  - [ ] `api_risultati_esercizi.php` (logging)
  - [ ] `api/auth_*.php` (utenti educatore/paziente)
- [ ] Test funzionale locale (`/Assistivetech/...`)
- [ ] Aggiornare database con link corretto
- [ ] Eliminare vecchia cartella Flutter (backup prima)

---

## 🔧 Template Standard JavaScript

### Struttura Cartella Tipo:
```
[esercizio_nome]/
├── index.html              # Esercizio principale (JavaScript vanilla)
├── setup.html              # Wizard configurazione educatore
├── manifest.json           # PWA config
├── service-worker.js       # Offline support
├── icons/
│   ├── icon-192.png
│   └── icon-512.png
├── assets/                 # Risorse specifiche (opzionale)
│   ├── images/
│   └── audio/
└── README.md               # Documentazione esercizio
```

### File HTML Base:
```html
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="manifest" href="manifest.json">
    <link rel="icon" href="icons/icon-192.png">
    <title>[Nome Esercizio] - AssistiveTech</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <!-- UI esercizio -->

    <script>
        const BASE_PATH = '/Assistivetech'; // Per locale MAMP

        // TTS Helper
        const tts = {
            synth: window.speechSynthesis,
            speak(text, rate = 1.0) {
                const utterance = new SpeechSynthesisUtterance(text);
                utterance.lang = 'it-IT';
                utterance.rate = rate;
                this.synth.speak(utterance);
            }
        };

        // API Helper
        async function saveRisultato(dati) {
            const response = await fetch(`${BASE_PATH}/api/api_risultati_esercizi.php`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    action: 'create_risultato',
                    ...dati
                })
            });
            return response.json();
        }

        // Logica esercizio...
    </script>
</body>
</html>
```

---

## 📊 Metriche di Conversione

| Metrica | Valore |
|---------|--------|
| Esercizi totali | 15 |
| Già JavaScript | 9-10 (60-67%) |
| Da convertire | 5-6 (33-40%) |
| Tempo stimato conversione | 2-3 giorni (1 esercizio ogni 6-8 ore) |
| Dimensione riduzione codice | ~80% (da ~500KB Flutter a ~50KB JavaScript) |
| Performance miglioramento | ~5x caricamento più veloce |

---

## ✅ Prossimi Passi

1. **Verifica "Scrivi Parole"** - Capire se è JavaScript o Flutter build
2. **Priorità 1**: Convertire **Ordina Lettere** (esercizio più semplice sequenze)
3. **Template Riutilizzabile**: Creare modulo `drag-drop-sequence.js` riutilizzabile
4. **Documentazione**: Aggiornare CLAUDE.md con nuovo workflow

---

**Documento compilato**: 21 Ottobre 2025
**Autore**: Claude Code + Team AssistiveTech
**Versione**: 1.0
