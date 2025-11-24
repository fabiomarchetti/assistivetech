# Guida Modalità Offline - ascolto la musica v2.6.0

## 📱 PWA Completamente Autonoma

Questa versione dell'app è stata progettata per funzionare **completamente offline** una volta installata come PWA, senza alcuna dipendenza da connessioni internet o database esterni.

---

## 🔄 Modalità Operative

### 🌐 Modalità Online

**Quando si attiva**: L'app riesce a connettersi all'API del database (server Aruba disponibile)

**Caratteristiche**:
- ✅ **Area Educatore**: Dropdown con lista pazienti dal database
- ✅ **Area Utente**: Dropdown con lista utenti dal database
- ✅ **Salvataggio**: Brani salvati nel database remoto
- ✅ **Sincronizzazione**: Brani copiati anche in localStorage per uso futuro offline
- ✅ **Link esterni**: Bottone "Torna indietro" visibile (se non in PWA standalone)

### 📱 Modalità Offline

**Quando si attiva**: L'app NON riesce a connettersi all'API (timeout 3 secondi)

**Caratteristiche**:
- ✅ **Area Educatore**: Campo di testo con autocompletamento utenti locali
- ✅ **Area Utente**: Login con campo di testo libero
- ✅ **Salvataggio**: Brani salvati in localStorage del browser
- ✅ **Multi-utente**: Ogni utente ha il proprio archivio locale
- ✅ **Indicatori visivi**: Badge "OFFLINE" nell'header
- ✅ **Nessun link esterno**: In PWA standalone, tutti i link esterni sono nascosti

---

## 🧪 Come Testare

### Test 1: Modalità Online
```bash
# Avvia MAMP o il tuo server locale
# Apri: http://localhost:8888/Assistivetech/training_cognitivo/strumenti/ascolto_la_musica/

# Dovresti vedere:
# - Area Educatore: dropdown "Paziente"
# - Area Utente: dropdown con lista utenti
```

### Test 2: Modalità Offline (Simulata)
```javascript
// Apri DevTools (F12) → Console
// Modifica temporaneamente l'endpoint per forzare errore:
// Nel file app.js, riga 8, cambia API_ENDPOINT in un URL inesistente
// Oppure disabilita il server MAMP

// Ricarica la pagina

// Dovresti vedere:
// - Area Educatore: campo di testo "Nome Utente" con badge "OFFLINE"
// - Area Utente: schermata "Come ti chiami?"
```

### Test 3: PWA Standalone
```bash
# 1. Apri l'app in Chrome/Edge
# 2. Clicca l'icona "Installa app" nella barra degli indirizzi
# 3. Installa l'app

# Apri l'app installata (icona sul desktop/menu)

# Dovresti vedere:
# - Nessun bottone "Torna indietro" nell'header
# - Nessuna voce "Torna alla home" nel menu laterale
# - L'app è completamente self-contained
```

---

## 💾 Struttura Dati localStorage

### Utente Corrente (Area Utente)
```javascript
localStorage.getItem('localUser') 
// Ritorna: "Mario"
```

### Brani per Utente
```javascript
localStorage.getItem('localBrani_Mario')
// Ritorna: '[{"nome_video":"Ninna nanna","categoria":"sonno","link_youtube":"..."}]'

localStorage.getItem('localBrani_Giulia')
// Ritorna: '[{"nome_video":"Canzone ABC","categoria":"didattica","link_youtube":"..."}]'
```

### Come Ispezionare localStorage
1. Apri DevTools (F12)
2. Vai su **Application** → **Storage** → **Local Storage**
3. Seleziona il dominio dell'app
4. Vedi tutte le chiavi e valori salvati

---

## 🔧 Gestione Utenti Offline

### Come Aggiungere Brani per un Utente

**Area Educatore Offline**:
1. Clicca "Area Educatore"
2. Vedi badge "OFFLINE" nell'header
3. Campo "Nome Utente" è un campo di testo libero
4. Inizia a digitare → appare autocompletamento con utenti esistenti
5. Compila categoria, link YouTube e nome brano
6. Clicca "Salva brano"
7. Brano salvato in `localStorage.localBrani_[NomeUtente]`

**Area Utente Offline**:
1. Clicca "Area Utente"
2. Se primo accesso → inserisci nome nella schermata "Come ti chiami?"
3. Se già loggato → vai direttamente alla lista brani
4. Pulsante "Cambia Utente" disponibile nel menu laterale

---

## 🚀 Deployment e Installazione

### Su Dispositivo Portatile

1. **Installa la PWA** dal browser:
   - Chrome/Edge: clicca l'icona "Installa app"
   - Safari iOS: "Aggiungi a Home"
   
2. **Primo utilizzo**:
   - Area Educatore: aggiungi brani per gli utenti che useranno il dispositivo
   - I brani vengono salvati localmente
   
3. **Uso offline**:
   - L'app funziona completamente senza connessione
   - Ogni utente ha il proprio archivio
   - Nessun link esterno per evitare di uscire dall'app

### Sincronizzazione con Database

**Importante**: I brani salvati in modalità offline rimangono **solo sul dispositivo locale**. Non vengono sincronizzati automaticamente con il database remoto.

**Per sincronizzare**:
- Se in futuro hai connessione internet, usa l'Area Educatore online per ri-aggiungere i brani al database
- Oppure esporta manualmente localStorage e importa nel DB (operazione manuale)

---

## ❓ FAQ

### D: Come faccio a sapere se sono online o offline?
**R**: Nell'Area Educatore, se vedi il badge "OFFLINE" nell'header, sei in modalità locale. Se vedi un dropdown "Paziente", sei online.

### D: I brani offline sono visibili anche online?
**R**: No. I brani salvati in localStorage sono separati dal database remoto. Sono due archivi distinti.

### D: Posso usare l'app su più dispositivi?
**R**: Sì, ma ogni dispositivo avrà il proprio archivio locale. I dati localStorage non si sincronizzano tra dispositivi diversi.

### D: Come elimino tutti i dati locali?
**R**: DevTools (F12) → Application → Local Storage → Seleziona dominio → Tasto destro → "Clear". Oppure svuota la cache del browser.

### D: La modalità offline funziona anche per Area Educatore?
**R**: Sì! Dalla v2.6.0 l'Area Educatore funziona completamente offline, salvando i brani direttamente in localStorage.

### D: Come aggiungo più utenti sullo stesso dispositivo?
**R**: In Area Educatore offline, semplicemente digita nomi diversi nel campo "Nome Utente". Ogni nome crea automaticamente un nuovo archivio locale.

---

## 🆘 Troubleshooting

### Problema: L'app dice "Errore caricamento pazienti"
**Soluzione**: Sei in modalità online ma il server non risponde. Verifica:
- MAMP è avviato?
- L'URL API è corretto?
- Il database è configurato?

### Problema: Non vedo il pulsante "Cambia Utente"
**Soluzione**: Il pulsante appare solo in modalità offline. Verifica di essere in Area Utente senza connessione al database.

### Problema: L'autocompletamento utenti non funziona
**Soluzione**: L'autocompletamento mostra solo utenti che hanno già brani salvati in localStorage. Se è il primo utente, non apparirà nulla.

### Problema: I link "Torna indietro" sono ancora visibili in PWA
**Soluzione**: Assicurati di aver installato l'app come PWA (non solo aperta in browser). Chiudi e riapri l'app installata.

---

## 📚 Risorse Aggiuntive

- **README.md**: Documentazione completa funzionalità
- **GENERATE_ICONS.md**: Come generare icone PWA
- **CACHE_CLEAR.md**: Come pulire la cache del browser

---

**Versione**: 2.6.0  
**Data**: Novembre 2025  
**Autore**: AssistiveTech.it

