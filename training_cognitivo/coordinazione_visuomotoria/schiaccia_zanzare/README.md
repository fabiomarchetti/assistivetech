# 🦟 Schiaccia le Zanzare - PWA

Esercizio di **coordinazione visuomotoria** con tracking webcam tramite MediaPipe Hands.

## 📱 Progressive Web App (PWA)

Questa applicazione è una **PWA completa** installabile su:
- 💻 **Desktop**: Windows, macOS, Linux (Chrome, Edge, Firefox)
- 📱 **Mobile**: Android, iOS, iPad
- 🌐 **Web**: Funziona anche da browser senza installazione

### ✨ Caratteristiche PWA

- ✅ **Installabile** come app nativa
- ✅ **Funzionamento offline** (dopo primo caricamento)
- ✅ **Icona personalizzata** su home screen/desktop
- ✅ **Modalità standalone** (schermo intero senza barra browser)
- ✅ **Responsive** - Si adatta a tutti i dispositivi
- ✅ **Accessibile** - Dimensioni regolabili per ipovisione

## 🎮 Come Usare

### 1. Area Educatore
Configura parametri esercizio:
- **Numero Zanzare** (0-10): Insetti da colpire
- **Numero Farfalle** (0-10): Insetti da evitare
- **Dimensione Insetti** (4 livelli): Per utenti con ipovisione
  - Piccola (70%)
  - Media (100% - default)
  - Grande (150%)
  - Extra Large (200%)
- **Velocità Movimento** (Lenta/Media/Veloce)

### 2. Area Utente
Inizia esercizio:
- Permetti accesso webcam
- Usa la **mano** per schiacciare le zanzare 🦟
- **Evita** di toccare le farfalle 🦋
- Controlla punteggio in tempo reale

## 🔧 Installazione PWA

### Desktop (Chrome/Edge)
1. Apri l'app nel browser
2. Click sull'icona **Installa** (⊕) nella barra URL
3. Conferma installazione
4. L'app apparirà come programma nativo

### Android
1. Apri in Chrome
2. Menu (⋮) → **Aggiungi a schermata Home**
3. Conferma
4. Icona apparirà sulla home screen

### iOS/iPad (Safari)
1. Apri in Safari
2. Tap **Condividi** (□↑)
3. **Aggiungi a Home**
4. Conferma nome e icona

## 🌐 Funzionamento Offline

Dopo il **primo caricamento**, l'app funziona offline grazie al Service Worker che memorizza:
- Tutte le pagine HTML
- Fogli di stile Bootstrap
- Icone e risorse

**Nota**: MediaPipe (tracking webcam) richiede connessione internet al primo avvio.

## 📂 Struttura File

```
schiaccia_zanzare/
├── index.html          # Landing page con 2 cards
├── setup.html          # Configurazione educatore
├── gioca.html          # Gioco con webcam tracking
├── manifest.json       # Configurazione PWA
├── sw.js               # Service Worker per offline
├── icons/              # Icone PWA (8 risoluzioni)
│   ├── icon-72x72.png
│   ├── icon-96x96.png
│   ├── icon-128x128.png
│   ├── icon-144x144.png
│   ├── icon-152x152.png
│   ├── icon-192x192.png
│   ├── icon-384x384.png
│   └── icon-512x512.png
└── README.md           # Questa documentazione
```

## 🎯 Accessibilità (Ipovisione)

L'esercizio supporta utenti con **ipovisione media/grave**:

| Livello | Dimensione Zanzara | Dimensione Farfalla | Uso Consigliato |
|---------|-------------------|---------------------|-----------------|
| Piccola | 28px | 35px | Normovedenti |
| Media | 40px | 50px | Standard |
| Grande | 60px | 75px | Ipovisione Media |
| Extra Large | 80px | 100px | Ipovisione Grave |

## 🔐 Permessi Richiesti

- **📷 Webcam**: Necessaria per tracking mano (MediaPipe Hands)
- **💾 Storage**: Per salvare configurazione (localStorage)

## 🌍 Compatibilità Browser

| Browser | Desktop | Mobile | PWA Install |
|---------|---------|--------|-------------|
| Chrome | ✅ | ✅ | ✅ |
| Edge | ✅ | ✅ | ✅ |
| Firefox | ✅ | ✅ | ⚠️ Limitata |
| Safari | ✅ | ✅ | ✅ (iOS 11.3+) |

## 🚀 Portabilità

L'intera cartella `schiaccia_zanzare` è **completamente portabile** tra:
- ✅ Mac ↔ Windows
- ✅ Locale ↔ Server remoto
- ✅ MAMP ↔ XAMPP ↔ Apache

**Nessuna dipendenza database o configurazione server richiesta!**

## 📊 Tecnologie Utilizzate

- **HTML5 Canvas** - Rendering grafico
- **MediaPipe Hands** - Tracking mano via webcam (Google AI)
- **localStorage** - Persistenza configurazione
- **Service Worker** - Funzionamento offline
- **Web App Manifest** - Installazione PWA
- **Bootstrap 5** - UI responsive

---

**Versione**: 1.0.0  
**Data Creazione**: 16 Novembre 2025  
**Autore**: AssistiveTech.it  
**Licenza**: Uso interno AssistiveTech
