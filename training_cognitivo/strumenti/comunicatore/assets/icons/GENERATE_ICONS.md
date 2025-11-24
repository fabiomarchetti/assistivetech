# Generazione Icone PWA - Comunicatore

## 📱 Icone Necessarie

Per il corretto funzionamento della PWA, sono necessarie le seguenti icone:

- **icon-192.png** (192x192px)
- **icon-512.png** (512x512px)

## 🎨 Design Consigliato

### Concept Visivo
- **Simbolo principale**: Griglia 2x2 stilizzata con pittogrammi
- **Colori**: Viola (#673AB7) come principale, sfondo bianco o trasparente
- **Stile**: Moderno, flat design, facilmente riconoscibile

### Elementi da Includere
1. **Griglia 2x2**: 4 quadrati che rappresentano le posizioni della griglia
2. **Simbolo comunicazione**: Fumetto, bocca, o onde sonore
3. **Accessibilità**: Design inclusivo e riconoscibile

## 🛠️ Strumenti per Generare Icone

### Opzione 1: Online (Facile)
1. **Realizzr** - https://realfavicongenerator.net/
   - Carica un'immagine 512x512px
   - Genera automaticamente tutte le dimensioni

2. **PWA Icon Generator** - https://www.pwabuilder.com/imageGenerator
   - Upload immagine base
   - Download pacchetto completo

### Opzione 2: Manuale (Photoshop/GIMP)
1. Crea canvas 512x512px
2. Disegna icona con elementi descritti sopra
3. Esporta in PNG con sfondo trasparente
4. Ridimensiona a 192x192px per seconda icona

### Opzione 3: SVG to PNG (Code)
```bash
# Usa ImageMagick per convertire SVG a PNG
convert -background none -resize 512x512 icon.svg icon-512.png
convert -background none -resize 192x192 icon.svg icon-192.png
```

## 📦 Template SVG Base

Crea un file `icon-template.svg` con questo codice base:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <!-- Background -->
  <rect width="512" height="512" rx="80" fill="#673AB7"/>
  
  <!-- Grid 2x2 -->
  <g fill="#FFFFFF">
    <!-- Top-left -->
    <rect x="100" y="100" width="120" height="120" rx="20"/>
    <!-- Top-right -->
    <rect x="292" y="100" width="120" height="120" rx="20"/>
    <!-- Bottom-left -->
    <rect x="100" y="292" width="120" height="120" rx="20"/>
    <!-- Bottom-right -->
    <rect x="292" y="292" width="120" height="120" rx="20"/>
  </g>
  
  <!-- Communication symbol (speech bubble) -->
  <path d="M 380 380 L 460 460 L 460 380 Z" fill="#FFFFFF" opacity="0.8"/>
</svg>
```

Poi converti con ImageMagick o un tool online.

## ✅ Verifica Finale

Dopo aver generato le icone:

1. Verifica dimensioni corrette (192x192 e 512x512)
2. Controlla che siano PNG con sfondo trasparente
3. Posiziona in `assets/icons/`
4. Testa PWA su mobile con Chrome DevTools (Application > Manifest)

## 🚀 Quick Start (Placeholder)

Se vuoi testare subito senza icone personalizzate, puoi usare placeholder online:

```html
<!-- In manifest.json usa URL temporanei -->
"icons": [
  {
    "src": "https://via.placeholder.com/192x192/673AB7/FFFFFF?text=C",
    "sizes": "192x192",
    "type": "image/png"
  },
  {
    "src": "https://via.placeholder.com/512x512/673AB7/FFFFFF?text=COM",
    "sizes": "512x512",
    "type": "image/png"
  }
]
```

## 📚 Risorse Utili

- **Material Design Icons**: https://materialdesignicons.com/
- **Flaticon**: https://www.flaticon.com/ (cerca "communication grid")
- **Icons8**: https://icons8.com/ (stile flat, comunicazione)
- **Figma**: Design diretto con template gratuiti

---

**Nota**: Le icone sono fondamentali per l'installazione della PWA su dispositivi mobili. Assicurati di crearle prima del deploy finale!

