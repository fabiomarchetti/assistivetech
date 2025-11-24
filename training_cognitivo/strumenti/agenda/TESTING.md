# GUIDA TESTING - Agenda Strumenti PWA

## Ambiente di Test
- **URL Paziente:** `http://localhost/Assistivetech/training_cognitivo/strumenti/agenda/agenda.html`
- **URL Educatore:** `http://localhost/Assistivetech/training_cognitivo/strumenti/agenda/gestione.html`
- **Browser consigliati:** Chrome, Edge, Firefox (con supporto PWA e Web Speech API)
- **Modalità test:** Apri DevTools (F12) per vedere i log della console

---

## 1. TEST INIZIALI - PWA e Service Worker

### 1.1 Verifica Manifest
```
Passaggi:
1. Apri agenda.html in Chrome/Edge
2. DevTools (F12) → Application tab → Manifest
3. Verifica che manifest.json sia caricato correttamente
4. Controlla che icone 192x192 e 512x512 siano presenti
```

**Risultato atteso:** ✅ Manifest valido con icone caricate

---

### 1.2 Installazione PWA
```
Passaggi:
1. Apri agenda.html in Chrome/Edge
2. Clicca sul pulsante "Installa" nella barra (Chrome) o menu (Edge)
3. Segui i passaggi di installazione
4. L'app dovrebbe essere disponibile nel menu start / homescreen
```

**Risultato atteso:** ✅ PWA installabile e apribile come app standalone

---

### 1.3 Service Worker Caching
```
Passaggi:
1. DevTools → Application → Service Workers
2. Verifica che "service-worker.js" sia "activated and running"
3. Vai alla tab "Cache Storage"
4. Verifica che cache "agenda-strumenti-v1" contenga i file statici
```

**Risultato atteso:** ✅ Service Worker attivo, cache con almeno 10+ file

---

## 2. TEST PAZIENTE - Navigazione e TTS

### 2.1 Caricamento Pagina
```
Passaggi:
1. Apri agenda.html
2. Attendi caricamento
3. Verifica schermata "Seleziona Utente" con dropdown
4. In localhost, dovrebbe essere disponibile "Utente Test"
```

**Risultato atteso:** ✅ Dropdown con opzione test visibile

---

### 2.2 TTS Automatico - Riproduzione Automatica
```
Prerequisiti:
- Browser deve avere Web Speech API (Chrome, Edge, Safari)
- Dispositivo deve avere speaker/audio funzionante
- Deve essere stata creata un'agenda con item dotati di fraseVocale

Passaggi:
1. Seleziona "Utente Test" e conferma
2. Seleziona un'agenda
3. Seleziona un item dalla lista
4. Attendi il caricamento della schermata
5. Entro 300ms, l'item dovrebbe pronunciare la frase automaticamente
6. Apri DevTools (F12) → Console
7. Cerca log "TTS Auto: Pronuncia frase"
```

**Risultato atteso:** ✅
- La frase viene pronunciata automaticamente all'arrivo dell'item
- Log console mostra "TTS Auto: Pronuncia frase dell'item: [frase]"
- Pulsante "Ascolta" appare se la frase è disponibile

---

### 2.3 TTS Manuale - Bottone "Ascolta"
```
Passaggi:
1. Con un item caricato (che ha pronunciato automaticamente)
2. Clicca il bottone "Ascolta" (icon + testo)
3. La frase dovrebbe essere pronunciata di nuovo
4. Verifica log console "TTS: Pronuncia avviata: [frase]"
```

**Risultato atteso:** ✅ Bottone "Ascolta" pronuncia la frase

---

### 2.4 Slider Velocità
```
Passaggi:
1. Guarda il controllo TTS in basso a sinistra
2. Vedi slider "Velocità" con valori da 0.5x a 2.0x
3. Il valore predefinito dovrebbe essere 0.9x
4. Muovi lo slider (es. a 1.5x)
5. Clicca "Ascolta" per pronunciare con velocità nuova
6. Verifica che il testo mostri il nuovo valore (es. "1.5x")
```

**Risultato atteso:** ✅ Slider aggiorna velocità in tempo reale

---

### 2.5 Slider Volume
```
Passaggi:
1. Guarda slider "Volume" (0.3 - 1.0)
2. Valore predefinito: 100% (1.0)
3. Muovi a volume più basso (es. 0.5 = 50%)
4. Clicca "Ascolta" per sentire il volume ridotto
5. Verifica che la percentuale aggiorni correttamente
```

**Risultato atteso:** ✅ Slider volume modifica il volume pronuncia

---

### 2.6 Persistenza Impostazioni TTS
```
Passaggi:
1. Imposta Velocità a 1.5x e Volume a 60%
2. Ricarica la pagina (F5)
3. Verifica che Velocità sia ancora 1.5x e Volume 60%
4. DevTools → Application → localStorage
5. Cerca chiavi "tts_velocity" e "tts_volume"
```

**Risultato atteso:** ✅
- Impostazioni persistono tra sessioni
- localStorage contiene "tts_velocity" e "tts_volume"

---

### 2.7 Navigazione Item - Swipe
```
Passaggi (su desktop - simulate swipe):
1. Carica un'agenda con più item
2. Premi tasto freccia destra (o clicca bottone freccia)
3. Item dovrebbe cambiare e pronunciare nuova frase
4. Premi tasto freccia sinistra per tornare indietro
5. Verifica che il numero di progressione aggiorni (es. "2 / 5")
```

**Risultato atteso:** ✅ Navigazione fluida tra item con TTS automatico

---

### 2.8 Navigazione Item - Long-Click (Sub-Agende)
```
Passaggi:
1. Se un item è collegato ad una sub-agenda (tipo "link_agenda")
2. Mantieni premuto il mouse per 1+ secondo sull'item
3. La pagina dovrebbe caricare la sub-agenda
4. Breadcrumb dovrebbe aggiornare il percorso
5. Pulsante "Home" dovrebbe apparire in alto a sinistra
```

**Risultato atteso:** ✅ Long-click apre la sub-agenda, navigazione breadcrumb funziona

---

## 3. TEST EDUCATORE - Gestione Agende

### 3.1 Caricamento Pazienti
```
Passaggi:
1. Apri gestione.html
2. Verifica dropdown "Seleziona Paziente"
3. Dovrebbe contenere almeno "Anonimo (Test - Dev)" se in localhost
4. Se API disponibile, dovrebbe caricare pazienti dal server
5. Se errore API, dovrebbe mostrare almeno il test paziente
```

**Risultato atteso:** ✅ Dropdown pazienti caricato senza errori

---

### 3.2 Creazione Agenda (Test Anonimo)
```
Passaggi:
1. Seleziona "Anonimo" dal dropdown pazienti
2. Clicca il pulsante "+" accanto a "Agende"
3. Finestra modale "Crea Nuova Agenda"
4. Inserisci nome (es. "Test Agenda")
5. Seleziona "Agenda Principale"
6. Clicca "Crea Agenda"
7. DevTools → Application → localStorage
8. Verifica chiave "agende_anonimo" contenga la nuova agenda
```

**Risultato atteso:** ✅
- Agenda appare in lista sinistra
- Agenda salvata in localStorage con ID temporaneo (es. 1698765432123)

---

### 3.3 Aggiunta Item con TTS
```
Passaggi:
1. Seleziona un'agenda dalla lista
2. Clicca "Aggiungi Item"
3. Compila form:
   - Titolo: "Voglio mangiare"
   - Frase TTS: "Voglio mangiare un gelato" (OBBLIGATORIO!)
   - Tipo Item: "Item Semplice"
   - Immagine: ARASAAC (cerca "pizza")
4. Clicca "Aggiungi Item"
5. DevTools → localStorage
6. Verifica chiave "items_anonimo_[agendaId]" contenga item
```

**Risultato atteso:** ✅
- Item appare nella card dell'agenda
- fraseVocale salvato in localStorage
- Immagine ARASAAC visualizzata nella card

---

### 3.4 Ridimensionamento Immagine Item
```
Passaggi:
1. Crea item con pittogramma ARASAAC (300x300px piccolo)
2. Verifica che l'immagine nella card sia contenuta (non tagliata)
3. L'immagine dovrebbe avere padding intorno
4. Confronta con educatore-app.js CSS: object-fit: contain
```

**Risultato atteso:** ✅ Piccoli pittogrammi ARASAAC non sono tagliati, hanno padding

---

### 3.5 Creazione Sub-Agenda
```
Passaggi:
1. Crea prima agenda "agenda_fabio"
2. Crea seconda agenda "mangiare_fabio"
3. Nella creazione della seconda, seleziona "Sub-Agenda"
4. Seleziona "agenda_fabio" come padre
5. LocalStorage dovrebbe contenere "id_agenda_parent"
```

**Risultato atteso:** ✅ Sub-agenda creata e collegata al padre

---

### 3.6 Item con Link ad Altra Agenda
```
Passaggi:
1. Seleziona agenda principale
2. Aggiungi Item con tipo "Link ad Altra Agenda"
3. Seleziona sub-agenda da collegare
4. Salva e controlla che item sia creato
5. Vai su agenda.html e verifica long-click apre sub-agenda
```

**Risultato atteso:** ✅ Long-click su item apre sub-agenda collegata

---

### 3.7 Drag & Drop Riordino Item
```
Passaggi:
1. Crea più item in un'agenda
2. Trascina un item card sopra un altro
3. L'ordine dovrebbe cambiare
4. LocalStorage dovrebbe aggiornare le posizioni
5. Ricarica pagina: ordine dovrebbe persistere
```

**Risultato atteso:** ✅ Drag & drop funziona, posizioni salvate in localStorage

---

## 4. TEST OFFLINE

### 4.1 Offline Mode - Agenda Caricata
```
Passaggi:
1. Carica un'agenda in agenda.html
2. DevTools → Network
3. Imposta modalità "Offline"
4. Prova a navigare tra item
5. Prova a fare swipe
6. Dovrebbe continuare a funzionare da cache locale
```

**Risultato atteso:** ✅ Navigazione offline funziona completamente

---

### 4.2 Offline Mode - Nuovo Item
```
Passaggi:
1. Disconnetti rete
2. Apri gestione.html (dovrebbe caricare da cache)
3. Prova ad aggiungere item
4. Se anonimo, dovrebbe funzionare (localStorage)
5. Se API, dovrebbe mostrare errore o usare queue
```

**Risultato atteso:** ✅ Anonimo può creare item offline, veri pazienti vedono errore/queue

---

## 5. TEST RESPONSIVE

### 5.1 Mobile (375px width)
```
Passaggi:
1. DevTools → Toggle Device Toolbar
2. Imposta iPhone 12 (375px)
3. Verifica che agenda.html sia leggibile
4. Pulsanti navigazione siano accessibili
5. Slider TTS siano usabili (non troppo piccoli)
```

**Risultato atteso:** ✅ Layout responsive, tutto accessibile su mobile

---

### 5.2 Tablet (768px width)
```
Passaggi:
1. DevTools → iPad (768px)
2. Verifica layout educatore sia usabile
3. Modal sia leggibile
4. Drag & drop funzioni su tablet
```

**Risultato attesto:** ✅ Layout fluido, usabile su tablet

---

## 6. TEST BROWSER COMPATIBILITY

### 6.1 Chrome/Edge
```
Dovrebbe supportare:
- Service Worker ✅
- Web Speech API ✅
- PWA Installation ✅
- localStorage ✅
- Fetch API ✅
```

### 6.2 Firefox
```
Dovrebbe supportare:
- Service Worker ✅
- Web Speech API ⚠️ (supporto limitato)
- localStorage ✅
- Fetch API ✅

Nota: TTS potrebbe non funzionare in Firefox
```

### 6.3 Safari (macOS/iOS)
```
Dovrebbe supportare:
- Service Worker (iOS 11.3+) ⚠️
- Web Speech API (macOS solo) ⚠️
- PWA Installation (iOS) ✅
- localStorage ✅
```

---

## 7. TEST ERROR HANDLING

### 7.1 Browser senza Web Speech API
```
Passaggi:
1. Usa browser senza Web Speech API
2. Clicca "Ascolta"
3. Dovrebbe mostrare alert: "La pronuncia non è supportata nel tuo browser"
```

**Risultato atteso:** ✅ Messaggio di errore chiaro

---

### 7.2 API Offline - Fallback localStorage
```
Passaggi:
1. Spegni server API (o localhost offline)
2. Apri gestione.html
3. Dovrebbe caricare pazienti da localStorage (cache)
4. Dovrebbe mostrare avviso se niente in cache
5. Anonimo dovrebbe funzionare completamente
```

**Risultato atteso:** ✅ Fallback a localStorage, app funziona in modalità offline

---

## 8. TEST CONSOLE LOGS

### 8.1 TTS Logs Attesi
```
Aprire console (F12) e cercare:
- "TTS Auto: Pronuncia frase dell'item: [frase]"
- "TTS: Pronuncia avviata: [frase]"
- "TTS: Fine pronuncia"
- "TTS Velocità: [valore]"
- "TTS Volume: [valore]"
```

**Risultato atteso:** ✅ Logs di debug visibili per tracking TTS

---

### 8.2 Service Worker Logs
```
Console dovrebbe mostrare:
- "[SW] Installazione..."
- "[SW] Caching assets"
- "[SW] Service Worker attivo"
```

**Risultato atteso:** ✅ Service Worker logging funziona

---

## 9. CHECKLIST FINALE

- [ ] PWA installabile su mobile
- [ ] Service Worker attivo e caching funziona
- [ ] TTS pronuncia automaticamente all'arrivo item
- [ ] Bottone "Ascolta" funziona
- [ ] Slider velocità modifica la velocità
- [ ] Slider volume modifica il volume
- [ ] Impostazioni slider persistono tra sessioni
- [ ] Navigazione swipe/frecce funziona
- [ ] Long-click apre sub-agende
- [ ] Educatore può creare agende/item
- [ ] Immagini ARASAAC non sono tagliate
- [ ] Drag & drop riordina item
- [ ] localStorage persiste dati anonimo
- [ ] Layout responsive su mobile/tablet
- [ ] App funziona offline (cache)
- [ ] Messaggi di errore chiari
- [ ] Icons PWA visibili in installazione

---

## 10. NOTE TECNICHE

### Log Console Importanti
```javascript
// Verificare TTS supporto:
TTSService.isSupported() // Dovrebbe essere true

// Verificare settings TTS:
console.log(getTTSSettings()) // Mostra {velocity: 0.9, volume: 1}

// Verificare state agenda:
console.log(agendaState) // Mostra dati corrente item
```

### URL Test Offline
```
Apri in incognito per evitare cache globale:
http://localhost/Assistivetech/training_cognitivo/strumenti/agenda/agenda.html
```

### Debug Service Worker
```
1. DevTools → Application → Service Workers
2. Clicca checkbox "Update on reload" per refresh service worker
3. Clicca "Clear site data" per cancellare cache completamente
```

---

## REPORT RISULTATI

Quando completi i test, documenta:
1. **Browser/Versione:** (es. Chrome 119)
2. **Device:** (es. Desktop, iPhone 12, iPad)
3. **Risultati:** (Passato/Fallito)
4. **Bug/Problemi:** (se presenti)
5. **Console Errors:** (se presenti)
6. **Timestamp:** (data/ora test)

Esempio:
```
✅ Test TTS Automatico - PASSATO
   Browser: Chrome 119, Desktop
   Nota: Pronuncia automatica entro 300ms
   Console: "TTS Auto: Pronuncia frase dell'item: test"

❌ Offline Mode - PARZIALE
   Browser: Firefox 121, Mobile
   Problema: TTS non supportato in Firefox
   Soluzione: Mostrare fallback message
```

