# 🎨 Generazione Icone PWA - ascolto e rispondo

## 📝 Istruzioni

Per generare le icone necessarie per l'app PWA "ascolto e rispondo" a partire dall'immagine sorgente `ascolto.png`:

### Metodo 1: Utilizzare il Generatore HTML (Raccomandato) ✅

1. Apri il file `crea_icone.html` nel browser:
   ```
   http://localhost/Assistivetech/training_cognitivo/strumenti/ascolto_e_rispondo/assets/crea_icone.html
   ```

2. Clicca sul pulsante **"🚀 Genera Icone"**

3. Attendi il caricamento e la generazione delle icone

4. Clicca sui pulsanti di download per scaricare:
   - `icon-192.png` (192x192 pixel)
   - `icon-512.png` (512x512 pixel)

5. Salva entrambe le icone nella cartella:
   ```
   assets/icons/
   ```

6. Ricarica l'applicazione per vedere le nuove icone!

---

### Metodo 2: Utilizzo di Software Esterno

Se preferisci utilizzare un software di grafica:

1. Apri `assets/images/ascolto.png` con un editor di immagini (Photoshop, GIMP, Paint.NET, ecc.)

2. Ridimensiona l'immagine a **192x192 pixel**:
   - Mantieni le proporzioni
   - Usa interpolazione di alta qualità (bicubica/lanczos)
   - Salva come `icon-192.png` nella cartella `assets/icons/`

3. Ridimensiona l'immagine a **512x512 pixel**:
   - Mantieni le proporzioni
   - Usa interpolazione di alta qualità
   - Salva come `icon-512.png` nella cartella `assets/icons/`

---

### Metodo 3: Servizi Online

Utilizza un servizio online come:
- [Favicon Generator](https://www.favicon-generator.org/)
- [RealFaviconGenerator](https://realfavicongenerator.net/)
- [IconGenerator](https://cthedot.de/icongen/)

Carica `ascolto.png` e scarica le icone generate.

---

## 📁 Struttura File Finale

```
ascolto_e_rispondo/
├── assets/
│   ├── icons/
│   │   ├── icon-192.png   ← Da generare
│   │   └── icon-512.png   ← Da generare
│   └── images/
│       └── ascolto.png    ← Immagine sorgente (già presente)
```

---

## ✅ Verifica

Dopo aver generato le icone, verifica che:
1. Entrambi i file esistano nella cartella `assets/icons/`
2. Le dimensioni siano corrette (192x192 e 512x512 pixel)
3. Le icone siano in formato PNG
4. Le icone siano visibili nel manifest.json dell'app

---

## 🎯 Note Importanti

- Le icone sono necessarie per l'installazione dell'app come PWA
- Assicurati che l'immagine sorgente abbia una risoluzione sufficiente
- Usa sempre immagini PNG con sfondo trasparente (se possibile)
- Mantieni il design semplice e riconoscibile anche a dimensioni ridotte

---

**📅 Data creazione:** $(date +'%d/%m/%Y')
**✏️ Autore:** AssistiveTech.it

