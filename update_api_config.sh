#!/bin/bash

##
# Script per aggiornare tutti i file API per usare config.php centralizzato
# Sostituisce le credenziali hardcoded con require_once 'config.php'
##

echo "🔧 Aggiornamento file API per usare config.php centralizzato..."
echo ""

# Pattern da cercare (credenziali Aruba)
PATTERN_OLD="// Configurazione database MySQL Aruba
\$host = '31.11.39.242';
\$username = 'Sql1073852';
\$password = '5k58326940';
\$database = 'Sql1073852_1';"

# Nuovo codice
PATTERN_NEW="// Configurazione database automatica (locale/produzione)
require_once __DIR__ . '/config.php';"

# File API da aggiornare
API_FILES=(
    "api/auth_login.php"
    "api/auth_registrazioni.php"
    "api/api_sedi.php"
    "api/api_settori_classi.php"
    "api/api_educatori.php"
    "api/api_pazienti.php"
    "api/api_esercizi.php"
    "api/api_risultati_esercizi.php"
    "api/api_associazioni.php"
    "api/educatori_pazienti.php"
)

UPDATED_COUNT=0
SKIPPED_COUNT=0

for file in "${API_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Controlla se il file contiene già require_once config.php
        if grep -q "require_once.*config.php" "$file"; then
            echo "⏭️  $file - già aggiornato, skip"
            ((SKIPPED_COUNT++))
        else
            # Backup file originale
            cp "$file" "${file}.bak"

            # Sostituisci credenziali con require config.php
            # Usa sed per sostituire il blocco multi-linea
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS sed
                sed -i '' "s|// Configurazione database MySQL Aruba.*\$database = 'Sql1073852_1';|// Configurazione database automatica (locale/produzione)\nrequire_once __DIR__ . '/config.php';|" "$file"
            else
                # Linux sed
                sed -i "s|// Configurazione database MySQL Aruba.*\$database = 'Sql1073852_1';|// Configurazione database automatica (locale/produzione)\nrequire_once __DIR__ . '/config.php';|" "$file"
            fi

            echo "✅ $file - aggiornato (backup: ${file}.bak)"
            ((UPDATED_COUNT++))
        fi
    else
        echo "⚠️  $file - file non trovato"
    fi
done

echo ""
echo "═══════════════════════════════════════"
echo "✅ Aggiornamento completato!"
echo "═══════════════════════════════════════"
echo "File aggiornati: $UPDATED_COUNT"
echo "File skipped: $SKIPPED_COUNT"
echo ""
echo "📝 Nota: I file originali sono stati salvati con estensione .bak"
echo "   Se qualcosa non funziona, puoi ripristinare con:"
echo "   cp api/nome_file.php.bak api/nome_file.php"
echo ""
echo "🚀 Ora puoi:"
echo "   1. Copiare il progetto in /Applications/MAMP/htdocs/assistivetech/"
echo "   2. Tutto funzionerà automaticamente in locale E su Aruba!"
