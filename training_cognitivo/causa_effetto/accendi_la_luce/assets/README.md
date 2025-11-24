# Esercizio "Causa-Effetto" - Sistema ARASAAC

## 🎯 Panoramica Sistema (Aggiornato Settembre 2024)

**Esercizio causa-effetto completamente dinamico** con integrazione ARASAAC per oggetti personalizzabili e sistema di 10 sessioni automatiche.

### 🔄 Flusso Completo
1. **Setup Pre-Esercizio**: Wizard 3-step per educatore, paziente e selezione pittogramma ARASAAC
2. **10 Sessioni Automatiche**: Ciclo mostra oggetto → nascondi → timer latenza → click → feedback
3. **Risultati Finali**: Statistiche complete con opzione ripeti o nuovo setup

## 📁 Struttura File

### 🖼️ Immagini Dinamiche ARASAAC
- **Directory**: `images/` (auto-populate da setup)
- **Dimensioni**: 300x300px (auto-resize da Canvas)
- **Formato**: JPG/PNG/WebP supportati
- **Naming**: `[nome]_arasaac_[id]_[timestamp].ext`
- **Fallback**: `luce.png` (originale lampadina se setup non completato)

### 🔊 Audio Feedback
- **File**: `audio/applauso.mp3`
- **Durata**: 2-3 secondi
- **Formato**: MP3
- **Utilizzo**: Feedback automatico tra le sessioni

## 🚀 Caratteristiche Avanzate

### 🔍 Integrazione ARASAAC
- **API Search**: Ricerca real-time pittogrammi da database ARASAAC
- **Auto-Download**: Scaricamento e resize automatico immagini
- **Cache Locale**: Storage browser per performance ottimizzate
- **Terms Compliance**: Modal Creative Commons per uso corretto

### 📊 Sistema 10 Sessioni
- **Progress Tracking**: Barra progresso visuale (1/10, 2/10, etc.)
- **Auto-Flow**: Transizione automatica tra sessioni
- **Database Storage**: Ogni sessione salvata individualmente nel DB
- **Final Statistics**: Tempo medio, migliore, completamento

### 🎨 UI/UX Migliorata v2.0
- **Sfondo Pastello**: Gradient blu (#f8f9ff → #e8f4fd) per contrasto ottimale
- **Oggetti Grandi**: 300x300px per migliore visibilità
- **Bottone Causa-Effetto**: Pulsante grande "FAI APPARIRE [OGGETTO]" con animazione pulse
- **Card Risultati**: Spostata nel pannello educatore (non più al centro)
- **Input Multipli**: Mouse click, tastiera (Invio/Spazio), touch
- **Messaggio Chiarificato**: "Clicca per far apparire [oggetto]" invece di "quando vedi"
- **Animazioni Fluide**: Transizioni smooth per mostra/nascondi
- **Responsive Design**: Ottimizzato desktop, tablet, mobile

## 📐 Specifiche Tecniche

### CSS Oggetto Dinamico
```css
.exercise-object {
    width: 300px;
    height: 300px;
    object-fit: contain;
    transition: all 0.5s ease;
    filter: drop-shadow(0 10px 20px rgba(0,0,0,0.3));
}

.exercise-object.hidden {
    opacity: 0;
    transform: scale(0.8);
}

.exercise-object.active {
    filter: drop-shadow(0 15px 30px rgba(255, 215, 0, 0.8));
    transform: scale(1.1);
}
```

### JavaScript Flusso Sessioni
```javascript
// Ciclo automatico 10 sessioni
nextSession() {
    this.currentSession++;
    if (this.currentSession > this.totalSessions) {
        this.showFinalResults();
        return;
    }
    this.updateProgressDisplay();
    this.showObjectForSession();
}

// Timing: 3sec mostra → nascondi → timer latenza
showObjectForSession() {
    this.exerciseObject.classList.add('active');
    setTimeout(() => this.startLatencyTimer(), 3000);
}
```

## 💾 Database Integration v2.0

### Tabella `risultati_esercizi` (Aggiornata Settembre 2024)
```sql
CREATE TABLE risultati_esercizi (
    id_risultato INT PRIMARY KEY AUTO_INCREMENT,
    nome_educatore VARCHAR(100) NOT NULL,
    nome_paziente VARCHAR(100) NOT NULL,
    categoria_esercizio VARCHAR(100) NOT NULL,
    nome_esercizio VARCHAR(150) NOT NULL,
    sessione_numero INT NOT NULL DEFAULT 1,        -- NUOVO: Traccia sessioni 1-10
    tempo_latenza DECIMAL(10,3) NOT NULL,          -- Precisione millisecondi
    tempo_visualizzazione DECIMAL(6,2) DEFAULT 30.0,
    feedback_tipo ENUM('nessuno', 'applauso', 'tts') DEFAULT 'nessuno',
    feedback_testo TEXT,
    data_esercizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_esecuzione VARCHAR(19),                    -- Formato italiano
    timestamp_inizio BIGINT,                        -- Performance.now()
    timestamp_click BIGINT,                         -- Performance.now()
    ip_address VARCHAR(45),
    user_agent TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Indici ottimizzati per performance
CREATE INDEX idx_educatore_paziente ON risultati_esercizi(nome_educatore, nome_paziente);
CREATE INDEX idx_sessione_numero ON risultati_esercizi(sessione_numero);
CREATE INDEX idx_esercizio_completo ON risultati_esercizi(nome_educatore, nome_paziente, categoria_esercizio, nome_esercizio, sessione_numero);
```

### API Endpoints
- `../../api/api_risultati_esercizi.php` - Salvataggio risultati
- `../../api/upload_pictogram.php` - Upload immagini ARASAAC

## 🔧 Setup e Configurazione

### 1. Prerequisiti
- ✅ Database MySQL con tabella `risultati_esercizi`
- ✅ Directory `assets/images/` scrivibile per upload
- ✅ API ARASAAC accessibile (https://api.arasaac.org)

### 2. Configurazione Wizard
- **URL Setup**: `/setup.html` (obbligatorio prima dell'esercizio)
- **LocalStorage**: Configurazione salvata temporaneamente
- **Redirect**: Auto-redirect al main exercise dopo setup

### 3. File Structure
```
accendi_la_luce/
├── index.html (esercizio principale - 10 sessioni)
├── setup.html (wizard pre-esercizio)
└── assets/
    ├── README.md (questa documentazione)
    ├── images/ (pittogrammi ARASAAC auto-scaricati)
    └── audio/ (file audio feedback)
```

## 🧪 Testing e QA

### Flusso Test Completo
1. **Setup Wizard**: Educatore + Paziente + Selezione ARASAAC
2. **10 Sessioni**: Ogni sessione con timing corretto (3sec → nascondi → click)
3. **Database**: Verifica salvataggio ogni sessione
4. **Final Screen**: Statistiche e opzioni finali
5. **Responsive**: Test su desktop, tablet, mobile

## 📋 Deployment Checklist

### Files da Caricare
- ✅ `index.html` (aggiornato con nuovo sistema 10 sessioni)
- ✅ `setup.html` (wizard ARASAAC già caricato)
- ✅ `assets/README.md` (questa documentazione aggiornata)
- ✅ Audio `applauso.mp3` in `assets/audio/`
- ✅ Database table `risultati_esercizi` già creata
- ✅ API upload pittogrammi già funzionante

### URLs di Test
- **Setup**: https://assistivetech.it/training_cognitivo/causa_effetto/accendi_la_luce/setup.html
- **Esercizio**: Auto-redirect dopo setup completato

### Performance Checklist
- [ ] Test caricamento pittogrammi ARASAAC
- [ ] Verifica resize automatico immagini 300x300px
- [ ] Test flusso 10 sessioni complete
- [ ] Verifica salvataggio database ogni sessione
- [ ] Test feedback audio/TTS
- [ ] Check responsive design mobile
- [ ] Test statistiche finali accurate

## 🆕 Changelog

### v2.1 - Settembre 2024 (Ultima Versione)
- ✅ **Database v2.0**: Tabella completamente riprogettata con indici ottimizzati
- ✅ **Bottone Causa-Effetto**: Grande pulsante "FAI APPARIRE [OGGETTO]" con pulse animation
- ✅ **Card Risultati Spostata**: Dal centro al pannello educatore (UX migliorata)
- ✅ **Input Multipli**: Mouse + tastiera (Invio/Spazio) + touch
- ✅ **Messaggi Chiarificati**: "Clicca per far apparire" vs "quando vedi"
- ✅ **Debug Logging**: Console logging per troubleshooting database
- ✅ **Tabella Condivisa**: Tutti educatori/pazienti nella stessa tabella
- ✅ **Sessioni Illimitate**: Educatori possono ripetere 10 sessioni infinite volte

### v2.0 - Settembre 2024
- ✅ **Sistema 10 Sessioni**: Flusso automatico sessioni multiple
- ✅ **Integrazione ARASAAC**: Pittogrammi dinamici da API
- ✅ **Setup Wizard**: Configurazione pre-esercizio completa
- ✅ **UI/UX Migliorata**: Sfondo pastello, oggetti 300px, animazioni
- ✅ **Database Multi-Sessioni**: Tracking individuale ogni sessione
- ✅ **Statistiche Finali**: Tempo medio, migliore, opzioni ripeti

### v1.0 - Iniziale
- Esercizio singolo lampadina fissa
- Timing manuale educatore
- Salvataggio singola sessione