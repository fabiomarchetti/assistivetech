# 👁️ Rispondo con gli Occhi

Sistema di comunicazione alternativa basato su **Eye Tracking** e **Head Pose Estimation** utilizzando **MediaPipe** e **OpenCV**.

Permette a utenti con deficit motori e del linguaggio di rispondere a domande utilizzando solo lo sguardo verso destra o sinistra.

---

## 🎯 Caratteristiche Principali

### ✨ Funzionalità
- **Eye Tracking avanzato**: Combina iris tracking e head pose estimation
- **Interfaccia Educatore**: Creazione domande personalizzate con immagini ARASAAC
- **Interfaccia Utente**: Esperienza semplificata per utenti con disabilità
- **Text-to-Speech**: Verbalizzazione automatica delle domande
- **Feedback visivo**: Barre di progresso e indicatori in tempo reale
- **Database completo**: Registrazione di tutte le risposte per analisi

### 🔬 Tecnologie Utilizzate
- **MediaPipe Face Mesh**: Rilevamento landmark facciali (478 punti)
- **Iris Tracking**: Tracciamento preciso della posizione degli occhi
- **Head Pose Estimation**: Calcolo rotazione testa (yaw, pitch, roll)
- **Web Speech API**: Text-to-Speech per verbalizzazione
- **ARASAAC API**: Libreria pittogrammi per comunicazione aumentativa
- **Bootstrap 5**: UI responsive e moderna
- **Vanilla JavaScript**: Nessuna dipendenza framework pesanti

---

## 📁 Struttura del Progetto

```
rispondo_con_gli_occhi/
├── index.html              # Landing page con scelta ruolo
├── gestione.html           # Interfaccia educatore
├── rispondo.html           # Interfaccia paziente
│
├── css/
│   ├── educatore.css       # Stili interfaccia educatore
│   └── paziente.css        # Stili interfaccia paziente
│
├── js/
│   ├── arasaac-service.js  # Servizio ricerca pittogrammi ARASAAC
│   ├── educatore-app.js    # Logica interfaccia educatore
│   ├── eye-tracking.js     # Engine eye tracking (MediaPipe)
│   └── paziente-app.js     # Logica interfaccia paziente
│
├── api/
│   ├── setup_database.sql  # Script creazione tabelle
│   ├── domande.php         # API CRUD domande
│   └── risposte.php        # API salvataggio risposte
│
├── assets/
│   └── (icone, immagini)
│
└── README.md               # Questa documentazione
```

---

## 🚀 Installazione

### 1. Prerequisiti
- Server web (Apache/MAMP)
- PHP 7.4+
- MySQL 5.7+
- Browser moderno (Chrome/Edge consigliati)
- Webcam funzionante

### 2. Setup Database

Esegui lo script SQL per creare le tabelle:

```bash
mysql -u root -p assistivetech_local < api/setup_database.sql
```

Oppure importa manualmente da phpMyAdmin.

**Tabelle create:**
- `domande_eye_tracking`: Domande create dagli educatori
- `risposte_eye_tracking`: Risposte degli utenti

### 3. Configurazione

Verifica che il file `db_config.php` nella directory `api/` del progetto principale sia configurato correttamente:

```php
<?php
function getDbConnection() {
    $host = 'localhost';
    $dbname = 'assistivetech_local';
    $username = 'root';
    $password = 'root'; // Modifica se necessario
    
    $conn = new mysqli($host, $username, $password, $dbname);
    
    if ($conn->connect_error) {
        die("Connessione fallita: " . $conn->connect_error);
    }
    
    $conn->set_charset("utf8mb4");
    return $conn;
}
?>
```

### 4. Integrazione nel Sistema

Inserisci l'applicazione nella categoria "Strumenti" del database:

```sql
-- Verifica l'id_categoria per "strumenti"
SELECT id_categoria FROM categorie_esercizi WHERE nome_categoria LIKE '%strumenti%';

-- Inserisci l'esercizio
INSERT INTO esercizi (id_categoria, nome_esercizio, descrizione_esercizio, stato_esercizio, link)
VALUES 
  ([ID_CATEGORIA_STRUMENTI], 
   'Rispondo con gli Occhi',
   'Sistema di comunicazione alternativa basato su eye tracking',
   'attivo',
   '/Assistivetech/training_cognitivo/strumenti/rispondo_con_gli_occhi/');
```

---

## 📖 Guida all'Uso

### Per l'Educatore

1. **Accedi all'interfaccia educatore** (`gestione.html`)
2. **Crea una nuova domanda**:
   - Clicca su "Nuova Domanda"
   - Inserisci il testo della domanda
   - Scegli il tipo (SI/NO, Immagini, Colori)
   - Cerca pittogrammi ARASAAC per le opzioni
   - Imposta etichette personalizzate
   - Salva

3. **Gestisci domande esistenti**:
   - Visualizza lista domande
   - Modifica o elimina domande
   - Visualizza statistiche risposte

### Per l'Utente

1. **Avvia l'esercizio** (`rispondo.html`)
2. **Seleziona l'utente** dal menu a tendina
3. **Clicca "Avvia Esercizio"**
4. **Autorizza l'accesso alla webcam** quando richiesto
5. **Posizionati davanti alla camera**:
   - Volto centrato e ben illuminato
   - Distanza 40-60 cm dallo schermo
   
6. **Rispondi alle domande**:
   - Ascolta la domanda (si riproduce automaticamente)
   - Guarda l'opzione che vuoi scegliere (sinistra o destra)
   - Mantieni lo sguardo per 2 secondi
   - La barra di progresso si riempie
   - La risposta viene registrata automaticamente

7. **Visualizza il video di controllo** nella parte bassa dello schermo

---

## ⚙️ Configurazione Eye Tracking

### Parametri Calibrabili

Nel file `js/eye-tracking.js`:

```javascript
// Soglie per rilevamento direzione
this.calibration = {
    leftThreshold: -0.15,    // Soglia per "sinistra"
    rightThreshold: 0.15,    // Soglia per "destra"
    centerZone: 0.1         // Zona morta centrale
};
```

Nel file `js/paziente-app.js`:

```javascript
// Tempo di permanenza sguardo per confermare risposta
dwellTime: 2000, // millisecondi (2 secondi)
```

### Ottimizzazione Performance

- **FPS target**: 20-30 FPS
- **Smoothing**: Media mobile su 5 frame per ridurre jitter
- **Peso combinato**: 70% iris tracking, 30% head pose

---

## 🔍 Debug e Troubleshooting

### Panel di Debug

L'interfaccia paziente include un pannello di debug (visibile desktop) con:
- FPS correnti
- Coordinate sguardo (X, Y)
- Rotazione testa (gradi)
- Direzione rilevata

### Problemi Comuni

#### ❌ Webcam non si avvia
- Controlla permessi browser
- Verifica che nessun'altra app stia usando la webcam
- Usa Chrome/Edge (miglior supporto MediaPipe)

#### ❌ Volto non rilevato
- Migliora illuminazione
- Avvicinati/allontanati dalla camera
- Rimuovi ostacoli (capelli, cappelli)

#### ❌ Rilevamento impreciso
- Calibra le soglie in `eye-tracking.js`
- Aumenta il dwell time se troppo sensibile
- Controlla la posizione degli occhiali (possono interferire)

#### ❌ TTS non funziona
- Verifica che il browser supporti Web Speech API
- Controlla volume sistema
- Alcune lingue potrebbero non essere disponibili

---

## 📊 Database Schema

### Tabella `domande_eye_tracking`

| Campo | Tipo | Descrizione |
|-------|------|-------------|
| `id_domanda` | INT | ID univoco domanda (PK) |
| `id_educatore` | INT | ID educatore creatore (FK) |
| `testo_domanda` | TEXT | Testo domanda da verbalizzare |
| `immagine_sinistra_url` | VARCHAR | URL pittogramma sinistra |
| `immagine_sinistra_id` | INT | ID ARASAAC sinistra |
| `etichetta_sinistra` | VARCHAR | Etichetta opzione sinistra |
| `immagine_destra_url` | VARCHAR | URL pittogramma destra |
| `immagine_destra_id` | INT | ID ARASAAC destra |
| `etichetta_destra` | VARCHAR | Etichetta opzione destra |
| `tipo_domanda` | ENUM | si_no, scelta_immagini, colori |
| `stato` | ENUM | attiva, archiviata |

### Tabella `risposte_eye_tracking`

| Campo | Tipo | Descrizione |
|-------|------|-------------|
| `id_risposta` | INT | ID univoco risposta (PK) |
| `id_utente` | INT | ID paziente (FK) |
| `id_domanda` | INT | ID domanda (FK) |
| `domanda_fatta` | TEXT | Snapshot testo domanda |
| `risposta_data` | ENUM | sinistra, destra |
| `etichetta_risposta` | VARCHAR | Etichetta scelta |
| `tempo_risposta_ms` | INT | Tempo impiegato (ms) |
| `confidenza` | DECIMAL | Livello confidenza (0-100) |
| `metodo_rilevamento` | ENUM | iris, head_pose, combinato |
| `data_risposta` | TIMESTAMP | Data/ora risposta |

---

## 🎨 API ARASAAC

L'applicazione utilizza l'API pubblica ARASAAC per i pittogrammi:

**Endpoint**: `https://api.arasaac.org/api/pictograms/it/search/{keyword}`

**Esempio**:
```javascript
const results = await arasaacService.searchPictograms('acqua', 24);
// Restituisce array di pittogrammi con URL e metadati
```

**Documentazione**: https://arasaac.org/developers/api

---

## 📈 Metriche e Analisi

Le risposte salvate nel database includono:
- ✅ Tempo di risposta (millisecondi)
- ✅ Confidenza del rilevamento (0-100)
- ✅ Metodo utilizzato (iris/head_pose/combinato)
- ✅ Timestamp preciso

Puoi creare report e grafici interrogando la tabella `risposte_eye_tracking`.

---

## 🔐 Privacy e Sicurezza

- ❗ **Nessun video viene registrato**: solo landmark facciali in tempo reale
- ❗ **Dati anonimi**: le coordinate gaze non sono memorizzate
- ❗ **Accesso webcam locale**: stream non inviato a server esterni
- ❗ **GDPR compliant**: salva solo risposte e metadati essenziali

---

## 🛠️ Sviluppi Futuri

### Possibili Miglioramenti
- [ ] **Calibrazione personalizzata** per ogni utente
- [ ] **Modalità allenamento** per familiarizzare con il sistema
- [ ] **Domande a scelta multipla** (3-4 opzioni)
- [ ] **Statistiche avanzate** con grafici e trend
- [ ] **Esportazione dati** in CSV/Excel
- [ ] **Modalità offline** con service worker avanzato
- [ ] **Integrazione switch esterni** per utenti con movimento residuo
- [ ] **Suoni di feedback** per conferme/errori
- [ ] **Temi personalizzabili** (alto contrasto, ipovisione)

---

## 📞 Supporto

Per problemi o domande:
1. Controlla la sezione **Troubleshooting**
2. Verifica i log della console browser (F12)
3. Consulta la documentazione MediaPipe
4. Contatta il team di sviluppo

---

## 📄 Licenza

Questo progetto è parte del sistema **AssistiveTech.it**

© 2025 - Tutti i diritti riservati

---

## 🙏 Ringraziamenti

- **MediaPipe** (Google) per la libreria Face Mesh
- **ARASAAC** per la libreria pittogrammi
- **Bootstrap** per il framework UI

---

**Versione**: 1.0.0  
**Data**: Novembre 2025  
**Autore**: Sviluppato per AssistiveTech.it
