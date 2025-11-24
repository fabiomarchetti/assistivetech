# Sequenze colori

**Categoria:** Memoria
**Descrizione:** Esercizio di memoria con sequenze di colori da ricordare

## 📦 Struttura Esercizio Autonomo

Questo esercizio è **completamente autonomo** e contiene tutto il necessario per funzionare:

- ✅ Propri file PHP (config, API)
- ✅ Propri file JavaScript
- ✅ Manifest e Service Worker PWA
- ✅ Database tables dedicate
- ✅ Nessuna dipendenza da file comuni

## 🚀 Setup Rapido

### 1. Database
Esegui lo script SQL in phpMyAdmin:
```
api/setup_database.sql
```

### 2. Test Locale
Apri in browser:
```
http://localhost/Assistivetech/training_cognitivo/memoria/sequenze_colori/
```

### 3. Deploy Aruba
Upload via FTP mantenendo la struttura:
```
/training_cognitivo/memoria/sequenze_colori/
```

## 📱 PWA - Progressive Web App

L'esercizio è installabile come app standalone:

1. Apri da Chrome mobile
2. Menu → "Aggiungi a Home"
3. Usa come app nativa

## 🎯 Interfacce

### Landing Page (index.html)
- Descrizione esercizio
- Accesso interfaccia educatore
- Accesso interfaccia paziente

### Interfaccia Educatore (gestione.html)
- Crea pagine/livelli esercizio
- Aggiungi elementi griglia
- Integrazione ARASAAC pittogrammi
- Upload immagini custom

### Interfaccia Paziente (esercizio.html)
- Modalità fullscreen
- Navigazione swipe
- TTS integrato
- Funziona offline

## 🔧 Personalizzazione

Modifica i file secondo le specifiche esigenze dell'utente:

- **Logica esercizio:** `js/esercizio-app.js`
- **Grafica utente:** `css/esercizio.css`
- **Grafica educatore:** `css/educatore.css`
- **API custom:** `api/*.php`

## 📊 Database Tables

- `memoria_sequenze_colori_pagine` - Pagine/livelli
- `memoria_sequenze_colori_items` - Elementi esercizio
- `memoria_sequenze_colori_log` - Log utilizzo

## 🆘 Supporto

Questo esercizio è stato auto-generato dal template "comunicatore".
Per problemi o personalizzazioni, consulta la documentazione principale.

---

**Generato:** {date('Y-m-d H:i:s')}
**Template:** Comunicatore v2.4.0
**Sistema:** AssistiveTech Training Cognitivo