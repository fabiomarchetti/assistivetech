#!/bin/bash
# Script per preparare build Agenda Timer per Aruba
# Esegui: bash build_per_aruba.sh

echo "========================================"
echo "PREPARAZIONE BUILD PER ARUBA"
echo "========================================"
echo ""

echo "[1/4] Pulizia build precedente..."
rm -rf build/web

echo "[2/4] Modifica temporanea web/index.html..."
sed -i.bak 's/\$FLUTTER_BASE_HREF/\/agenda_timer\//g' web/index.html

echo "[3/4] Build Flutter per produzione..."
flutter build web --release
if [ $? -ne 0 ]; then
    echo "ERRORE: Build Flutter fallito!"
    mv web/index.html.bak web/index.html
    exit 1
fi

echo "[4/4] Copia file nella root..."
cp -r build/web/* .

echo ""
echo "[RIPRISTINO] Ripristino web/index.html originale..."
mv web/index.html.bak web/index.html

echo ""
echo "========================================"
echo "BUILD COMPLETATO CON SUCCESSO!"
echo "========================================"
echo ""
echo "File pronti per upload FTP su Aruba:"
echo "- Host: ftp.assistivetech.it"
echo "- User: 7985805@aruba.it"
echo "- Cartella destinazione: /agenda_timer/"
echo ""
echo "IMPORTANTE: Carica tutti i file mantenendo la struttura:"
echo "  - index.html"
echo "  - manifest.json"
echo "  - .htaccess"
echo "  - flutter*.js"
echo "  - main.dart.js"
echo "  - assets/"
echo "  - canvaskit/"
echo "  - icons/"
echo "  - api/"
echo ""
