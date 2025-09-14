#!/bin/bash

# Script per deploy su Aruba hosting
# Configurazione FTP per assistivetech.it

echo "🚀 Deploy Agenda PWA su Aruba..."

# Build dell'app
echo "📦 Building PWA..."
flutter build web --release

# Configurazione FTP
FTP_HOST="ftp.assistivetech.it"
FTP_USER="7985805@aruba.it"
FTP_PASS="Filohori33!"

# Directory di destinazione sul server
REMOTE_DIR="/public_html"

echo "📤 Uploading files to $FTP_HOST..."

# Carica tutti i file della build/web con lftp
lftp -c "
  set ftp:ssl-allow no
  open ftp://$FTP_USER:$FTP_PASS@$FTP_HOST
  cd $REMOTE_DIR
  lcd build/web
  mirror --reverse --delete --verbose .
"

echo "✅ Deploy completato!"
echo "🌐 PWA disponibile su: https://assistivetech.it"
echo "📱 Ora può essere installata come app su qualsiasi dispositivo!"