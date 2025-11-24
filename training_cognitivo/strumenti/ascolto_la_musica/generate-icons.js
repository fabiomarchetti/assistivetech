// Script per generare le icone PWA dalle immagini sorgente
// Richiede: npm install sharp

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const sourceImage = path.join(__dirname, 'assets/img/icon.png');
const outputDir = path.join(__dirname, 'assets/icons');

// Dimensioni delle icone PWA necessarie
const sizes = [
  { width: 192, height: 192, name: 'icon-192.png' },
  { width: 512, height: 512, name: 'icon-512.png' }
];

// Verifica che l'immagine sorgente esista
if (!fs.existsSync(sourceImage)) {
  console.error('❌ Errore: File sorgente non trovato:', sourceImage);
  process.exit(1);
}

// Crea la directory di output se non esiste
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
  console.log('✅ Cartella icons creata');
}

console.log('🎨 Generazione icone PWA in corso...\n');

// Genera ogni dimensione
async function generateIcons() {
  try {
    for (const size of sizes) {
      const outputPath = path.join(outputDir, size.name);
      
      await sharp(sourceImage)
        .resize(size.width, size.height, {
          fit: 'contain',
          background: { r: 0, g: 0, b: 0, alpha: 0 } // Trasparente
        })
        .png()
        .toFile(outputPath);
      
      console.log(`✅ Generata: ${size.name} (${size.width}x${size.height})`);
    }
    
    console.log('\n🎉 Tutte le icone sono state generate con successo!');
    console.log('📁 Percorso: ' + outputDir);
  } catch (error) {
    console.error('❌ Errore durante la generazione:', error.message);
    process.exit(1);
  }
}

generateIcons();

