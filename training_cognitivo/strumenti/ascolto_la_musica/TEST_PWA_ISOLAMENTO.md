# 🔒 Test Isolamento PWA - ascolto la musica

## Obiettivo
Verificare che la PWA installata sia **completamente isolata** e non contenga link verso il portale AssistiveTech principale.

---

## 🧪 Test da Eseguire

### Test 1: Verifica Visibilità Pulsanti

#### Browser Normale (http://localhost:8888/...)
1. Apri l'app nel browser
2. **VERIFICA Console**:
   ```
   🌐 Modalità BROWSER: Link al portale visibili
   ```
3. **VERIFICA Header**:
   - ✅ Pulsante "← Torna indietro" **VISIBILE** (in alto a sinistra)
4. **VERIFICA Menu Laterale**:
   - Apri menu (☰)
   - ✅ Voce "🏠 Torna alla home" **VISIBILE**
5. **Test Funzionalità**:
   - Click su "← Torna indietro" → Chiede conferma
   - Conferma → Torna al portale `../../`

---

#### PWA Installata
1. Disinstalla PWA se già presente
2. Reinstalla da browser: http://localhost:8888/.../ascolto_la_musica/
3. Apri PWA installata
4. Apri Console (F12)
5. **VERIFICA Console**:
   ```
   🔒 PWA INSTALLATA: Nascondo tutti i link esterni al portale
     ✓ Pulsante header "Torna indietro" nascosto
     ✓ Voce menu "Torna alla home" nascosta
   🎉 PWA completamente isolata - Nessun link esterno visibile
   ```
6. **VERIFICA Header**:
   - ❌ Pulsante "← Torna indietro" **NON VISIBILE**
7. **VERIFICA Menu Laterale**:
   - Apri menu (☰)
   - ❌ Voce "🏠 Torna alla home" **NON VISIBILE**
   - ✅ Altre voci presenti: "Come funziona", "Ricomincia", "Informazioni", "Impostazioni"

---

### Test 2: Tentativo di Uscire dalla PWA

#### Browser Normale
1. Click su "← Torna indietro"
2. **Atteso**: Popup "Vuoi davvero tornare alla home del portale AssistiveTech?"
3. Annulla → Rimani nell'app
4. Conferma → Torni a `../../`

---

#### PWA Installata
1. Se per errore il pulsante fosse visibile o richiamabile
2. **Atteso**: Alert bloccante:
   ```
   🔒 Sei nell'app installata "ascolto la musica".
   
   Questa app è completamente autonoma e non ha link esterni.
   
   Usa il menu per:
   • "Ricomincia" → Torna alla schermata iniziale
   • Chiudi l'app dalla barra applicazioni se vuoi uscire
   ```
3. OK → Rimani nell'app
4. **Verifica Console**:
   ```
   ⚠️ Tentativo di uscire dalla PWA bloccato
   ```

---

### Test 3: Controllo Link HTML

#### Browser Normale + DevTools
1. Apri l'app nel browser
2. Apri DevTools (F12) → Tab "Elements"
3. Cerca tutti i `<button>` e `<a>`:
   ```javascript
   document.querySelectorAll('button[onclick*="goBack"], a[href*="../"]')
   ```
4. **Atteso**: 2 elementi trovati
   - `<button class="btn-back" id="btnBackToPortal">`
   - `<li id="menuBackToPortal"><button onclick="goBack()">`
5. **Verifica stile**:
   - Entrambi con `display: block` o visibili

---

#### PWA Installata + DevTools
1. Apri PWA installata
2. Apri DevTools (F12) → Tab "Elements"
3. Cerca tutti i `<button>` e `<a>`:
   ```javascript
   document.querySelectorAll('button[onclick*="goBack"], a[href*="../"]')
   ```
4. **Atteso**: 2 elementi trovati (ma nascosti)
   - `<button class="btn-back" id="btnBackToPortal" style="display: none;">`
   - `<li id="menuBackToPortal" style="display: none;">`
5. **Verifica stile**:
   - Entrambi con `display: none`

---

### Test 4: Test Funzionale Completo PWA

#### Flusso Completo
1. Installa PWA
2. Apri PWA da desktop/dock
3. **Non vedi** pulsante "Torna indietro" nell'header ✅
4. Click menu (☰)
5. **Non vedi** "Torna alla home" ✅
6. Click "Area Educatore"
7. Cerca un brano su YouTube (popup si apre se c'è internet) ✅
8. Salva brano
9. Click "Area Utente"
10. Ascolta brano ✅
11. Apri menu → Click "Ricomincia"
12. **Torni alla schermata iniziale (Educatore/Utente)** ✅
13. **Non esci mai dalla PWA** ✅

---

## ✅ Risultati Attesi

| Test | Browser | PWA Installata |
|------|---------|----------------|
| Pulsante header "←" | ✅ Visibile | ❌ Nascosto |
| Menu "🏠 Torna alla home" | ✅ Visibile | ❌ Nascosto |
| Console log isolamento | 🌐 Browser | 🔒 PWA isolata |
| Click goBack() | ⚠️ Conferma uscita | 🚫 Alert blocco |
| Link `../` in HTML | ✅ Funzionanti | ❌ Nascosti |
| Esperienza utente | Multi-app | App singola |

---

## 🐛 Cosa Fare se il Test Fallisce

### Problema: Pulsante "Torna indietro" ancora visibile in PWA
**Soluzione**:
1. Disinstalla completamente la PWA
2. Chiudi tutti i browser
3. Riapri browser
4. Vai a: http://localhost:8888/.../ascolto_la_musica/
5. Reinstalla PWA
6. Verifica console all'avvio

### Problema: Console non mostra "🔒 PWA INSTALLATA"
**Diagnosi**:
1. Verifica che la PWA sia davvero in modalità standalone:
   ```javascript
   window.matchMedia('(display-mode: standalone)').matches
   ```
2. Se `false` → Non è installata come PWA (è una tab del browser)
3. Reinstalla seguendo i passaggi corretti

### Problema: goBack() non mostra alert in PWA
**Diagnosi**:
1. Controlla `appState.isPWA`:
   ```javascript
   console.log(appState.isPWA)
   ```
2. Se `false` → `detectPWAMode()` non è stata chiamata
3. Verifica che `detectPWAMode()` sia chiamata in `DOMContentLoaded`

---

## 📋 Checklist Finale

Prima di considerare il test superato:

- [ ] Browser: Pulsante "Torna indietro" visibile
- [ ] Browser: Menu "Torna alla home" visibile
- [ ] Browser: goBack() funziona e torna a `../../`
- [ ] PWA: Console mostra "🔒 PWA INSTALLATA"
- [ ] PWA: Pulsante "Torna indietro" nascosto
- [ ] PWA: Menu "Torna alla home" nascosto
- [ ] PWA: goBack() mostra alert blocco
- [ ] PWA: Nessun modo di uscire verso il portale
- [ ] PWA: "Ricomincia" riporta alla schermata iniziale
- [ ] PWA: App completamente autonoma e isolata

---

## 🎯 Conclusione

Se tutti i test passano:
- ✅ La PWA è **completamente isolata**
- ✅ Non ci sono link esterni visibili
- ✅ L'utente non può uscire accidentalmente
- ✅ L'esperienza è nativa e professionale

Se qualche test fallisce:
- ⚠️ Controlla i log della console
- ⚠️ Verifica che `detectPWAMode()` sia chiamata
- ⚠️ Disinstalla e reinstalla la PWA
- ⚠️ Svuota cache del browser (Ctrl+Shift+Del)

