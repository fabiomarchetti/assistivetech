<?php
/**
 * Script per aggiornare tutti i file API per usare config.php centralizzato
 * Esegui questo script UNA VOLTA dal browser: http://localhost:8888/assistivetech/api/update_all_api_files.php
 *
 * IMPORTANTE: Elimina questo file dopo l'uso per sicurezza!
 */

// Solo per sicurezza - rimuovi questo blocco se necessario
$allowed_hosts = ['localhost', '127.0.0.1', '::1'];
if (!in_array($_SERVER['REMOTE_ADDR'], $allowed_hosts)) {
    die('❌ Accesso negato. Script eseguibile solo da localhost.');
}

?>
<!DOCTYPE html>
<html>
<head>
    <title>Update API Files - AssistiveTech</title>
    <style>
        body { font-family: monospace; padding: 20px; background: #f5f5f5; }
        .success { color: #27ae60; }
        .error { color: #e74c3c; }
        .warning { color: #f39c12; }
        .info { color: #3498db; }
        pre { background: white; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
<h2>🔧 Aggiornamento File API - AssistiveTech.it</h2>

<?php

$output = [];
$output[] = "Inizio aggiornamento file API...";
$output[] = "";

// File API da aggiornare
$api_files = [
    'auth_login.php',
    'auth_registrazioni.php',
    'api_sedi.php',
    'api_settori_classi.php',
    'api_educatori.php',
    'api_pazienti.php',
    'api_esercizi.php',
    'api_risultati_esercizi.php',
    'api_associazioni.php',
    'educatori_pazienti.php'
];

// Pattern da sostituire (regex multilinea)
$pattern_old = "/\/\/ Configurazione database MySQL Aruba\s*\n\s*\\\$host = '31\.11\.39\.242';\s*\n\s*\\\$username = 'Sql1073852';\s*\n\s*\\\$password = '5k58326940';\s*\n\s*\\\$database = 'Sql1073852_1';/";

// Nuovo codice
$pattern_new = "// Configurazione database automatica (locale/produzione)\nrequire_once __DIR__ . '/config.php';";

$updated_count = 0;
$skipped_count = 0;
$errors = [];

foreach ($api_files as $filename) {
    $filepath = __DIR__ . '/' . $filename;

    if (!file_exists($filepath)) {
        $output[] = "⚠️  $filename - file non trovato";
        continue;
    }

    $content = file_get_contents($filepath);

    // Controlla se già aggiornato
    if (strpos($content, "require_once __DIR__ . '/config.php'") !== false) {
        $output[] = "<span class='warning'>⏭️  $filename - già aggiornato, skip</span>";
        $skipped_count++;
        continue;
    }

    // Backup file originale
    $backup_path = $filepath . '.bak.' . date('YmdHis');
    if (!copy($filepath, $backup_path)) {
        $errors[] = "❌ Errore backup di $filename";
        continue;
    }

    // Sostituisci il pattern
    $new_content = preg_replace($pattern_old, $pattern_new, $content);

    if ($new_content === null || $new_content === $content) {
        $output[] = "<span class='error'>❌ $filename - pattern non trovato o errore regex</span>";
        $errors[] = "$filename - pattern non trovato";
        continue;
    }

    // Salva file aggiornato
    if (file_put_contents($filepath, $new_content) !== false) {
        $output[] = "<span class='success'>✅ $filename - aggiornato con successo</span>";
        $output[] = "   Backup salvato: " . basename($backup_path);
        $updated_count++;
    } else {
        $output[] = "<span class='error'>❌ $filename - errore scrittura file</span>";
        $errors[] = "$filename - errore scrittura";
    }
}

$output[] = "";
$output[] = "═══════════════════════════════════════════════";
$output[] = "<span class='success'>✅ Aggiornamento completato!</span>";
$output[] = "═══════════════════════════════════════════════";
$output[] = "File aggiornati: <strong>$updated_count</strong>";
$output[] = "File skipped: $skipped_count";

if (count($errors) > 0) {
    $output[] = "";
    $output[] = "<span class='error'>Errori riscontrati:</span>";
    foreach ($errors as $error) {
        $output[] = "  - $error";
    }
}

$output[] = "";
$output[] = "<span class='info'>📝 I file originali sono stati salvati con estensione .bak.timestamp</span>";
$output[] = "<span class='info'>   In caso di problemi, puoi ripristinare manualmente</span>";
$output[] = "";
$output[] = "<span class='success'>🚀 Sistema pronto per uso multi-ambiente!</span>";
$output[] = "";
$output[] = "<strong>Prossimi step:</strong>";
$output[] = "1. ✅ Copia progetto in /Applications/MAMP/htdocs/assistivetech/";
$output[] = "2. ✅ Configura database locale (vedi istruzioni sotto)";
$output[] = "3. ✅ ELIMINA questo file per sicurezza!";
$output[] = "";
$output[] = "<strong>URLs Test Locale:</strong>";
$output[] = "• Homepage: <a href='http://localhost:8888/assistivetech/' target='_blank'>http://localhost:8888/assistivetech/</a>";
$output[] = "• Training: <a href='http://localhost:8888/assistivetech/training_cognitivo/' target='_blank'>http://localhost:8888/assistivetech/training_cognitivo/</a>";
$output[] = "• App Scrivi: <a href='http://localhost:8888/assistivetech/training_cognitivo/scrivi/scrivi_parole/' target='_blank'>http://localhost:8888/assistivetech/training_cognitivo/scrivi/scrivi_parole/</a>";

// Output risultati
echo "<pre>";
foreach ($output as $line) {
    echo $line . "\n";
}
echo "</pre>";

?>

<h3>📊 Database Locale - Setup</h3>
<ol>
    <li>Accedi a <a href="http://localhost:8888/phpMyAdmin" target="_blank">phpMyAdmin (localhost:8888/phpMyAdmin)</a></li>
    <li>Login con: <code>root</code> / <code>root</code></li>
    <li>Crea database: <code>assistivetech_local</code></li>
    <li>Esegui in ordine:
        <ul>
            <li><code>api/create_database.sql</code> (schema base)</li>
            <li><code>api/create_table_sedi.sql</code></li>
            <li><code>api/update_table_educatori.sql</code></li>
            <li><code>api/create_table_pazienti.sql</code></li>
            <li><code>api/insert_scrivi_categoria_esercizio.sql</code></li>
        </ul>
    </li>
</ol>

<h3>⚠️ IMPORTANTE</h3>
<p style="color: #e74c3c; font-weight: bold;">
    Elimina questo file (update_all_api_files.php) dopo l'uso per sicurezza!
</p>

</body>
</html>
