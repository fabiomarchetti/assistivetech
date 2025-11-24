# Generare le Icone PWA

Questo documento spiega come generare le icone per la PWA nelle dimensioni necessarie (192x192 e 512x512).

## Metodo 1: Script Automatico Node.js (Consigliato)

### Prerequisiti
- Node.js installato sul sistema

### Passaggi

1. **Apri il terminale** nella cartella del progetto:
```bash
cd training_cognitivo/strumenti/ascolto_la_musica
```

2. **Installa le dipendenze**:
```bash
npm install
```

3. **Genera le icone**:
```bash
npm run generate-icons
```

Le icone verranno create automaticamente in `assets/icons/`:
- `icon-192.png` (192x192px)
- `icon-512.png` (512x512px)

---

## Metodo 2: Tool Online (Alternativa)

Se non hai Node.js o preferisci un metodo più veloce:

### 1. PWA Asset Generator
🔗 https://www.pwabuilder.com/imageGenerator

1. Carica `assets/img/icon.png`
2. Scarica le icone generate
3. Copia `icon-192.png` e `icon-512.png` in `assets/icons/`

### 2. RealFaviconGenerator
🔗 https://realfavicongenerator.net/

1. Carica l'immagine sorgente
2. Configura le opzioni PWA
3. Scarica il pacchetto
4. Copia le icone necessarie

---

## Metodo 3: Photoshop / GIMP (Manuale)

1. Apri `assets/img/icon.png` in Photoshop o GIMP
2. Ridimensiona a 192x192px
   - Salva come: `assets/icons/icon-192.png`
3. Ridimensiona a 512x512px
   - Salva come: `assets/icons/icon-512.png`

**Importante**: Mantieni la proporzione e usa interpolazione bicubica per qualità ottimale.

---

## Verifica

Dopo aver generato le icone, verifica che esistano:
- ✅ `assets/icons/icon-192.png`
- ✅ `assets/icons/icon-512.png`

Il file `manifest.json` è già configurato per utilizzare queste icone.

---

## Note

- **Dimensione minima immagine sorgente**: 512x512px o superiore
- **Formato**: PNG con trasparenza
- **Colore di sfondo**: Viola (#673AB7) se necessario
- Le icone saranno visibili quando l'app viene installata come PWA

