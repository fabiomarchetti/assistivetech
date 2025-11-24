# Generazione Icone PWA

Per completare la PWA, è necessario creare le icone nei seguenti formati:

## Icone Richieste

1. **icon-192.png** (192x192 px)
2. **icon-512.png** (512x512 px)

## Strumenti Online Gratuiti

### 1. Favicon Generator
- URL: https://favicon.io/favicon-converter/
- Carica un'immagine quadrata (minimo 512x512)
- Scarica il pacchetto con tutte le dimensioni

### 2. PWA Asset Generator
- URL: https://www.pwabuilder.com/imageGenerator
- Carica immagine sorgente
- Genera automaticamente tutte le icone PWA

### 3. Canva (Gratuito)
- URL: https://www.canva.com
- Crea design 512x512px
- Esporta come PNG
- Ridimensiona per 192x192

## Design Suggerito

**Colori tema:**
- Primario: #673AB7 (viola)
- Secondario: #9C27B0 (viola scuro)
- Background: #FAFAFA (grigio chiaro)

**Icona suggerita:**
- Simbolo: Icona "journal" o "calendar" di Bootstrap Icons
- Sfondo: Cerchio viola (#673AB7)
- Simbolo: Bianco (#FFFFFF)
- Bordo arrotondato: 10-15%

## Esempio con GIMP/Photoshop

```
1. Nuovo progetto 512x512px
2. Cerchio viola (#673AB7) come sfondo
3. Aggiungi icona calendario/journal bianca al centro
4. Esporta come PNG
5. Ridimensiona a 192x192 per la versione piccola
```

## Placeholder Temporaneo

Se non hai tempo di creare le icone subito, puoi usare un generatore di lettere:

```html
<!-- Usa questo servizio: -->
https://ui-avatars.com/api/?name=Agenda&size=512&background=673AB7&color=fff&font-size=0.4

<!-- Scarica e rinomina in icon-512.png -->
<!-- Poi ridimensiona a 192x192 per icon-192.png -->
```

## Posizionamento File

Salva le icone in:
```
/training_cognitivo/strumenti/assets/icons/
├── icon-192.png
└── icon-512.png
```

## Verifica

Dopo aver creato le icone, verifica che siano referenziate correttamente in `manifest.json`:

```json
"icons": [
    {
        "src": "assets/icons/icon-192.png",
        "sizes": "192x192",
        "type": "image/png"
    },
    {
        "src": "assets/icons/icon-512.png",
        "sizes": "512x512",
        "type": "image/png"
    }
]
```

## Test PWA

1. Apri `agenda.html` in Chrome/Edge
2. Apri DevTools (F12)
3. Tab "Application" → "Manifest"
4. Verifica che le icone siano caricate correttamente

---

**Nota**: Le icone sono essenziali per l'installazione PWA su dispositivi mobili!
