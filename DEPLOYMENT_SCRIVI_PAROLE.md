# 🚀 Deployment App "Scrivi con le Sillabe" - AssistiveTech.it

## 📋 Panoramica Integrazione

L'app **"Scrivi con le Sillabe"** è stata integrata con successo nel **Sistema Training Cognitivo** di AssistiveTech.it come PWA installabile.

### ✅ Stato Completamento

| Task | Stato | Dettagli |
|------|-------|----------|
| Build Flutter Web | ✅ Completato | Build con `--base-href="/training_cognitivo/scrivi/scrivi_parole/"` |
| Struttura Directory | ✅ Creata | `training_cognitivo/scrivi/scrivi_parole/` |
| Manifest PWA | ✅ Aggiornato | Nome, descrizione, scope, start_url configurati |
| Index Categoria | ✅ Creato | `training_cognitivo/scrivi/index.html` |
| Script SQL | ✅ Pronto | `api/insert_scrivi_categoria_esercizio.sql` |
| Documentazione | ✅ Completa | Questo file |

---

## 📁 Struttura File Creata

```
training_cognitivo/
└── scrivi/
    ├── index.html                    # Pagina categoria "Scrivi"
    └── scrivi_parole/                # App Flutter PWA
        ├── index.html                # Entry point app
        ├── main.dart.js              # Codice Flutter compilato (2.4 MB)
        ├── flutter.js
        ├── flutter_bootstrap.js
        ├── flutter_service_worker.js # Service worker PWA
        ├── manifest.json             # Configurazione PWA installabile
        ├── favicon.png
        ├── version.json
        ├── assets/                   # Assets Flutter
        ├── canvaskit/                # CanvasKit renderer
        └── icons/                    # Icone PWA (192px, 512px, maskable)
```

---

## 🗄️ Database: Categoria e Esercizio

### Script SQL da Eseguire

**File**: `api/insert_scrivi_categoria_esercizio.sql`

**Dove eseguire**: http://mysql.aruba.it (Database: Sql1073852_1)

**Contenuto**:
- ✅ Inserisce categoria "Scrivi" con link `/training_cognitivo/scrivi/`
- ✅ Inserisce esercizio "Scrivi con le Sillabe" con link `/training_cognitivo/scrivi/scrivi_parole/`
- ✅ Controlli anti-duplicazione integrati
- ✅ Query di verifica risultati

---

## 📱 Caratteristiche App

### Funzionalità Principali
- ✅ **Modalità 2/3 sillabe**: Interruttore per parole con 2 o 3 sillabe
- ✅ **Integrazione ARASAAC**: Ricerca automatica pittogrammi API
- ✅ **Text-to-Speech**: Pronuncia sillabe e parole (italiano, velocità 0.5)
- ✅ **Modalità Maestra**: Area gialla per inserire 6 sillabe
- ✅ **Feedback Visivo**: Immagini ARASAAC quando parola trovata
- ✅ **Feedback Audio**: Messaggi personalizzabili successo/errore
- ✅ **Responsive**: Funziona su desktop, tablet, smartphone

### Tecnologie
- **Framework**: Flutter Web
- **Dipendenze**:
  - `http: ^1.1.0` - Chiamate API ARASAAC
  - `flutter_tts: ^4.0.2` - Sintesi vocale
  - `cupertino_icons: ^1.0.8` - Icone iOS
- **PWA**: Manifest completo, service worker, icone maskable

---

## 🌐 Procedura Deployment su Aruba

### Step 1: Eseguire Script SQL

1. Accedi a **http://mysql.aruba.it**
2. Seleziona database **Sql1073852_1**
3. Vai su tab **SQL**
4. Copia e incolla il contenuto di `api/insert_scrivi_categoria_esercizio.sql`
5. Clicca **Esegui**
6. Verifica risultati queries:
   ```
   ✓ CATEGORIA INSERITA
   ✓ ESERCIZIO INSERITO
   ```

### Step 2: Upload File via FTP

**Credenziali FTP Aruba**:
- Host: `ftp.assistivetech.it`
- User: `7985805@aruba.it`
- Pass: `67XV57wk4R`
- Porta: 21

**File da caricare**:
```bash
# Upload intera directory scrivi
training_cognitivo/scrivi/          → /training_cognitivo/scrivi/

# Contenuto:
# - index.html (categoria)
# - scrivi_parole/ (intera cartella app Flutter)
```

**Comando FTP esempio** (da root progetto):
```bash
# Se usi lftp o FileZilla:
# 1. Connettiti a ftp.assistivetech.it
# 2. Naviga nella directory /training_cognitivo/
# 3. Upload ricorsivo di: scrivi/
```

### Step 3: Verifica Deployment

**URL da testare**:

1. **Pagina master Training Cognitivo**:
   ```
   https://assistivetech.it/training_cognitivo/
   ```
   - ✅ Deve apparire categoria "Scrivi" nella sidebar
   - ✅ Clic su "Scrivi" → mostra esercizio "Scrivi con le Sillabe"

2. **Pagina categoria Scrivi**:
   ```
   https://assistivetech.it/training_cognitivo/scrivi/
   ```
   - ✅ Mostra card esercizio con descrizione
   - ✅ Bottone "Avvia Esercizio" funzionante

3. **App Flutter PWA**:
   ```
   https://assistivetech.it/training_cognitivo/scrivi/scrivi_parole/
   ```
   - ✅ App carica correttamente
   - ✅ Interfaccia responsive visibile
   - ✅ Toggle 2/3 sillabe funzionante
   - ✅ Inserimento sillabe area maestra (gialla) funzionante
   - ✅ Sillabe cliccabili area alunno (azzurra) responsive
   - ✅ Ricerca ARASAAC funzionante (prova: "ca", "sa", "ca" → "casaca")
   - ✅ TTS pronuncia sillabe e parole
   - ✅ Modal licenza ARASAAC (icona info in alto a destra)

4. **PWA Installabile**:
   - ✅ Chrome/Edge: Icona "Installa" in barra indirizzo
   - ✅ Mobile: Prompt "Aggiungi a schermata Home"
   - ✅ App installata apre in modalità standalone (senza browser chrome)

---

## 🧪 Test Funzionali Completi

### Test 1: Modalità 3 Sillabe (Default)
1. Apri app
2. Area maestra: inserisci "CA", "SA", "CA" nelle prime 3 celle
3. Area alunno: clicca "CA" → "SA" → "CA"
4. Verifica:
   - ✅ Immagine casaca appare
   - ✅ TTS dice "Molto bravo!!!"
   - ✅ Dopo 2 secondi TTS legge "CASACA"

### Test 2: Modalità 2 Sillabe
1. Clicca icona "3" in alto a sinistra → passa a "2"
2. Area maestra: inserisci "CA", "NE" nelle prime 2 celle
3. Area alunno: clicca "CA" → "NE"
4. Verifica:
   - ✅ Immagine cane appare
   - ✅ TTS dice "Molto bravo!!!"
   - ✅ Dopo 2 secondi TTS legge "CANE"

### Test 3: Parola Non Trovata
1. Area maestra: inserisci sillabe casuali ("XY", "ZW", "QQ")
2. Clicca le 3 sillabe in ordine
3. Verifica:
   - ✅ Nessuna immagine appare
   - ✅ TTS dice "Fai attenzione!!!" (messaggio alert)

### Test 4: Bottoni Funzionali
- ✅ "Cancella Sillabe Scelte" (bottone rosa) → resetta solo area verde senza perdere sillabe maestra
- ✅ "Cancella tutto" (bottone rosa grande) → resetta tutto
- ✅ "Leggi Parola" (bottone verde) → TTS legge parola composta (anche senza immagine)

### Test 5: PWA Offline (dopo installazione)
1. Installa app come PWA
2. Disabilita Wi-Fi/dati mobili
3. Apri app installata
4. Verifica:
   - ✅ App carica (service worker attivo)
   - ✅ Inserimento sillabe funziona
   - ❌ Ricerca ARASAAC non funziona (richiede internet)
   - ✅ TTS funziona offline

---

## 📊 Manifest PWA Configurato

**File**: `training_cognitivo/scrivi/scrivi_parole/manifest.json`

```json
{
    "name": "Scrivi con le Sillabe - AssistiveTech",
    "short_name": "Scrivi Parole",
    "start_url": "/training_cognitivo/scrivi/scrivi_parole/",
    "scope": "/training_cognitivo/scrivi/scrivi_parole/",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2",
    "description": "Esercizio interattivo per comporre parole con sillabe utilizzando pittogrammi ARASAAC. Modalità 2 e 3 sillabe con sintesi vocale.",
    "orientation": "any",
    "categories": ["education", "accessibility"],
    "icons": [
        { "src": "icons/Icon-192.png", "sizes": "192x192" },
        { "src": "icons/Icon-512.png", "sizes": "512x512" },
        { "src": "icons/Icon-maskable-192.png", "sizes": "192x192", "purpose": "maskable" },
        { "src": "icons/Icon-maskable-512.png", "sizes": "512x512", "purpose": "maskable" }
    ]
}
```

---

## 🔧 Troubleshooting

### Problema: App non carica
**Soluzione**: Verifica `base-href` in `index.html` sia `/training_cognitivo/scrivi/scrivi_parole/`

### Problema: Immagini ARASAAC non appaiono
**Soluzione**: Verifica connessione internet, API ARASAAC potrebbe essere temporaneamente offline

### Problema: TTS non funziona
**Soluzione**: Verifica permessi browser per sintesi vocale, alcuni browser richiedono interazione utente prima

### Problema: PWA non installabile
**Soluzione**: Verifica HTTPS attivo, manifest.json accessibile, service worker registrato

### Problema: Categoria non appare in training_cognitivo
**Soluzione**: Verifica script SQL eseguito correttamente su database Aruba

---

## 📝 Licenze e Crediti

### Pittogrammi ARASAAC
- **Proprietà**: Governo di Aragona
- **Autore**: Sergio Palao
- **Licenza**: Creative Commons BY-NC-SA
- **URL**: https://arasaac.org
- **Email**: arasaac@educa.aragon.es

L'app include un modal informativo (icona info in AppBar) con termini d'uso completi.

### App Flutter
- **Sviluppatore**: AssistiveTech.it
- **Framework**: Flutter (Google)
- **Uso**: Esclusivamente educativo

---

## 📞 Supporto Tecnico

Per problemi o domande:
- **Developer**: Fabio Marchetti
- **Email**: marchettisoft@gmail.com
- **Sistema**: AssistiveTech.it

---

## ✅ Checklist Pre-Deployment

- [ ] Script SQL `insert_scrivi_categoria_esercizio.sql` eseguito su http://mysql.aruba.it
- [ ] Verifica categoria "Scrivi" presente in database
- [ ] Verifica esercizio "Scrivi con le Sillabe" presente in database
- [ ] Upload FTP directory `training_cognitivo/scrivi/` completa
- [ ] Test URL categoria: https://assistivetech.it/training_cognitivo/scrivi/
- [ ] Test URL app: https://assistivetech.it/training_cognitivo/scrivi/scrivi_parole/
- [ ] Test navigazione da https://assistivetech.it/training_cognitivo/
- [ ] Test PWA installazione (Chrome Desktop + Mobile)
- [ ] Test funzionalità complete (modalità 2/3 sillabe, ARASAAC, TTS)
- [ ] Test modal licenza ARASAAC

---

## 🎉 Deployment Completato!

L'app **"Scrivi con le Sillabe"** è pronta per essere deployata su produzione e utilizzata da educatori e pazienti del sistema AssistiveTech.it.

**URL Finali**:
- 🏠 Training Cognitivo: https://assistivetech.it/training_cognitivo/
- 📂 Categoria Scrivi: https://assistivetech.it/training_cognitivo/scrivi/
- 🎮 App PWA: https://assistivetech.it/training_cognitivo/scrivi/scrivi_parole/

---

*Documentazione generata: 09/10/2025*
*Sistema: AssistiveTech.it - Training Cognitivo v2.0*
