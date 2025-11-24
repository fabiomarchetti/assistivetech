# 🎨 Cerca Colore - Esercizio Drag & Drop

## 📋 Descrizione

**Cerca Colore** è un esercizio cognitivo di categorizzazione e accoppiamento colori basato sulla tecnica del drag and drop. L'utente deve trascinare il colore corretto (pittogramma ARASAAC) sulla card target centrale.

## ✨ Caratteristiche Principali

### 🎯 Funzionalità Esercizio
- **Drag & Drop Intuitivo**: Trascinamento fluido con feedback visivo
- **Pittogrammi ARASAAC**: Immagini colori da API ARASAAC (300x300px)
- **TTS Integrato**: Istruzioni vocali e feedback personalizzabile
- **Timer Latenza**: Misurazione precisa tempo di risposta
- **Prove Gratuite**: Prime 3 prove non registrate (training)
- **Celebrazione Successo**: Animazione fuochi d'artificio + GIF + TTS
- **Feedback Errori**: "Riprova!" con possibilità ripetizione prova

### 📊 Configurazione Setup
- **Selezione Educatore/Paziente**: Dropdown utenti
- **Numero Prove**: Da 3 a 10 prove configurabili
- **Colore Target**: Selezione da 12 colori disponibili
- **Colori Distrattori**: Da 2 a 12 colori (deve includere target)
- **Messaggio Rinforzo**: TTS personalizzabile ("Molto bene!", "Bravo!", ecc.)

### 🎨 Colori Disponibili
Rosso, Blu, Giallo, Verde, Arancione, Viola, Rosa, Marrone, Nero, Bianco, Grigio, Azzurro

## 🏗️ Architettura

### File Principali
```
cerca_colore/
├── setup.html          # Configurazione educatore
├── index.html          # Esercizio drag & drop
└── README.md           # Questa documentazione
```

### Flusso Operativo
```
1. Setup → 2. Configurazione → 3. Esercizio → 4. Salvataggio DB → 5. Fine
```

## 💾 Database - Tabella `risultati_esercizi`

### Campi Registrati
```sql
nome_educatore, nome_paziente, categoria_esercizio, nome_esercizio,
tempo_latenza, items_totali_utilizzati, item_corretto, item_errato,
nome_item_corretto, nome_item_errato, data_esecuzione,
ora_inizio_esercizio, ora_fine_esercizio, ip_address, user_agent
```

## 🔧 Tecnologie

- **HTML5/CSS3/JavaScript ES6+**
- **Bootstrap 5**
- **Drag & Drop API** (HTML5)
- **Web Speech API** (TTS)
- **ARASAAC API** (pittogrammi)
- **MySQL** (persistenza)

## 🎮 Utilizzo

### Setup
```
URL: setup.html
1. Carica 12 colori ARASAAC
2. Seleziona paziente
3. Scegli target + distrattori
4. Configura prove
5. Avvia esercizio
```

### Esercizio
```
1. TTS: "Cerca il colore [NOME]"
2. Timer start
3. Drag & Drop
4. Validazione + feedback
5. Registrazione DB (se > prova 3)
6. Prossima prova
```

## 🌐 Deployment

### Locale
```
BASE_PATH = '/Assistivetech'
URL: http://localhost:8888/Assistivetech/training_cognitivo/trascina_immagini/cerca_colore/setup.html
```

### Produzione
```
BASE_PATH = ''
URL: https://assistivetech.it/training_cognitivo/trascina_immagini/cerca_colore/setup.html
NOTA: Modificare BASE_PATH in setup.html:95 e index.html:349
```

## 📝 Licenza ARASAAC

Pittogrammi sotto **Creative Commons BY-NC-SA** - Uso educativo consentito.

---

**Versione**: 1.0 | **Data**: Ottobre 2025 | **Piattaforma**: assistivetech.it