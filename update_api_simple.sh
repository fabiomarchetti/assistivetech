#!/bin/bash
# Script aggiornamento semplificato file API

cd /Applications/MAMP/htdocs/assistivetech/api

# Backup
mkdir -p backups
cp *.php backups/ 2>/dev/null

# Sostituisci credenziali con require config.php
for file in auth_login.php auth_registrazioni.php api_sedi.php api_settori_classi.php api_educatori.php api_pazienti.php api_esercizi.php; do
  if [ -f "$file" ]; then
    sed -i '' "s|^\$host = '31\.11\.39\.242';|\$host = ''; // Obsoleto - usa config.php|g" "$file"
    sed -i '' "s|^// Configurazione database MySQL Aruba|// Configurazione database automatica\nrequire_once __DIR__ . '/config.php';\n\n// Configurazione database MySQL Aruba (OBSOLETO)|g" "$file"
    echo "✓ $file aggiornato"
  fi
done

echo ""
echo "✅ Aggiornamento completato!"
