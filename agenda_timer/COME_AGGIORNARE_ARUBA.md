# 🔄 Come Aggiornare Agenda Timer su Aruba

## ⚡ Metodo Rapido (Automatico)

### Windows
```bash
# Doppio click su:
build_per_aruba.bat

# Oppure da terminale:
.\build_per_aruba.bat
```

### Linux/Mac
```bash
bash build_per_aruba.sh
```

Lo script farà automaticamente:
1. ✅ Pulizia build precedente
2. ✅ Build Flutter con base-href corretto (`/agenda_timer/`)
3. ✅ Copia file nella root
4. ✅ Ripristino file sorgenti

## 📤 Upload su Aruba (dopo il build)

### Opzione 1: FTP Client (FileZilla, ecc.)
- **Host**: ftp.assistivetech.it
- **Username**: 7985805@aruba.it
- **Password**: 67XV57wk4R
- **Porta**: 21

**Carica questi file/cartelle** dalla root di `agenda_timer/`:
- ✅ `index.html`
- ✅ `manifest.json`
- ✅ `.htaccess` (IMPORTANTE!)
- ✅ `flutter.js`
- ✅ `flutter_bootstrap.js`
- ✅ `flutter_service_worker.js`
- ✅ `main.dart.js`
- ✅ `favicon.png`
- ✅ `version.json`
- ✅ Cartella `assets/` (completa)
- ✅ Cartella `canvaskit/` (completa)
- ✅ Cartella `icons/` (completa)
- ✅ Cartella `api/` (completa)

### Opzione 2: Script FTP (se hai lftp installato)
```bash
lftp -u 7985805@aruba.it,67XV57wk4R ftp.assistivetech.it << EOF
mirror -R --delete --verbose . /agenda_timer/
bye
EOF
```

## 🔍 Verifica Deployment

1. **Test Base**: Apri https://assistivetech.it/agenda_timer/
2. **Test PWA**:
   - Chrome → Icona "Installa" nella barra indirizzi
   - Mobile → Menu → "Aggiungi a schermata Home"
3. **Test Console**: F12 → Tab "Application"
   - Manifest caricato ✅
   - Service Worker registrato ✅

## 🛠️ Metodo Manuale (se gli script non funzionano)

```bash
# 1. Modifica temporanea web/index.html
# Cambia: <base href="$FLUTTER_BASE_HREF">
# In:     <base href="/agenda_timer/">

# 2. Build
flutter build web --release

# 3. Copia file
cp -r build/web/* .
# (Windows: xcopy /E /Y build\web\* .)

# 4. Ripristina web/index.html
# Rimetti: <base href="$FLUTTER_BASE_HREF">

# 5. Upload via FTP
```

## ⚙️ Sviluppo Locale

Per testare in locale dopo modifiche:

```bash
# 1. Build con base-href locale
flutter build web --base-href="/Assistivetech/agenda_timer/"

# 2. Copia file
cp -r build/web/* .

# 3. Apri browser
http://localhost:8888/Assistivetech/agenda_timer/
```

## 📋 Checklist Pre-Upload

Prima di uploadare su Aruba, verifica:

- [ ] Build completato senza errori
- [ ] File `.htaccess` presente nella root
- [ ] Cartella `icons/` contiene 4 file PNG
- [ ] Cartella `assets/` completa
- [ ] File `manifest.json` presente
- [ ] `index.html` ha base href `/agenda_timer/`

## 🐛 Troubleshooting

### "404 Not Found" dopo upload
- ✅ Verifica che `.htaccess` sia stato uploadato
- ✅ Controlla permessi file su server (644 per file, 755 per cartelle)

### Service Worker non si registra
- ✅ Verifica HTTPS attivo
- ✅ Controlla console browser (F12)
- ✅ Pulisci cache browser (Ctrl+Shift+Delete)

### Manifest.json non caricato
- ✅ Verifica path relativo in `index.html`: `<link rel="manifest" href="manifest.json">`
- ✅ Controlla che file sia nella root di `agenda_timer/`

## 📞 Note Importanti

- **NON** modificare il `web/index.html` manualmente per produzione - usa lo script!
- **SEMPRE** caricare il file `.htaccess` - è essenziale per PWA
- Dopo l'upload, aspetta 2-3 minuti per propagazione cache Aruba
- Testa sempre su dispositivo mobile reale (non solo emulatore)

---

**Ultimo aggiornamento**: Ottobre 2025
**URL Produzione**: https://assistivetech.it/agenda_timer/
