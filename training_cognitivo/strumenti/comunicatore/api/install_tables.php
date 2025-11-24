<?php
/**
 * Installazione automatica tabelle Comunicatore
 * Apri: http://localhost:8888/Assistivetech/training_cognitivo/strumenti/comunicatore/api/install_tables.php
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: text/html; charset=utf-8');

require_once __DIR__ . '/../../../../api/config.php';

?>
<!DOCTYPE html>
<html>
<head>
    <title>Installazione Tabelle Comunicatore</title>
    <style>
        body { font-family: sans-serif; padding: 20px; background: #f5f5f5; }
        .box { background: white; padding: 20px; margin: 10px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .success { border-left: 4px solid #4CAF50; }
        .error { border-left: 4px solid #F44336; }
        .warning { border-left: 4px solid #FF9800; }
        pre { background: #263238; color: #aed581; padding: 15px; border-radius: 4px; overflow-x: auto; white-space: pre-wrap; }
        button { background: #673AB7; color: white; border: none; padding: 12px 24px; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #512DA8; }
        .log { background: #f9f9f9; padding: 10px; margin: 5px 0; border-left: 3px solid #2196F3; }
    </style>
</head>
<body>
    <h1>🛠️ Installazione Tabelle Comunicatore</h1>

<?php

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['install'])) {
    
    echo '<div class="box">';
    echo '<h2>📦 Installazione in corso...</h2>';
    
    try {
        $pdo = getDbConnection();
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        // Leggi file SQL
        $sqlFile = __DIR__ . '/setup_database.sql';
        
        if (!file_exists($sqlFile)) {
            throw new Exception("File setup_database.sql non trovato: $sqlFile");
        }
        
        $sql = file_get_contents($sqlFile);
        
        // Rimuovi commenti e dividi le query
        $sql = preg_replace('/--.*$/m', '', $sql);
        $sql = preg_replace('/\/\*.*?\*\//s', '', $sql);
        
        // Esegui le query una alla volta
        $queries = explode(';', $sql);
        $executed = 0;
        $errors = 0;
        
        foreach ($queries as $query) {
            $query = trim($query);
            if (empty($query)) continue;
            
            try {
                $pdo->exec($query);
                $executed++;
                
                // Identifica quale tabella è stata creata
                if (preg_match('/CREATE TABLE.*?`(\w+)`/i', $query, $matches)) {
                    echo "<div class='log'>✅ Tabella <strong>{$matches[1]}</strong> creata</div>";
                }
                
            } catch (PDOException $e) {
                // Ignora errori "table already exists"
                if (strpos($e->getMessage(), 'already exists') === false) {
                    echo "<div class='log error'>❌ Errore: " . htmlspecialchars($e->getMessage()) . "</div>";
                    $errors++;
                } else {
                    echo "<div class='log warning'>⚠️ Tabella già esistente (ok)</div>";
                }
            }
        }
        
        echo '</div>';
        
        if ($errors === 0) {
            echo '<div class="box success">';
            echo '<h2>🎉 Installazione Completata!</h2>';
            echo "<p>✅ Eseguite <strong>$executed</strong> query con successo</p>";
            echo '<p>Le tabelle sono pronte:</p>';
            echo '<ul>';
            echo '<li><code>comunicatore_pagine</code></li>';
            echo '<li><code>comunicatore_items</code></li>';
            echo '<li><code>comunicatore_log</code></li>';
            echo '</ul>';
            echo '</div>';
            
            echo '<div class="box">';
            echo '<h2>🚀 Prossimi Passi</h2>';
            echo '<ol>';
            echo '<li>Torna a <a href="../gestione.html">gestione.html</a></li>';
            echo '<li>Seleziona un paziente</li>';
            echo '<li>Ora funzionerà! 🎉</li>';
            echo '</ol>';
            echo '</div>';
        } else {
            echo '<div class="box error">';
            echo '<h2>⚠️ Installazione con errori</h2>';
            echo "<p>Ci sono stati <strong>$errors</strong> errori</p>";
            echo '</div>';
        }
        
        // Verifica tabelle create
        echo '<div class="box">';
        echo '<h2>🔍 Verifica Tabelle</h2>';
        
        $tables = ['comunicatore_pagine', 'comunicatore_items', 'comunicatore_log'];
        foreach ($tables as $table) {
            $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
            if ($stmt->rowCount() > 0) {
                echo "<p>✅ <code>$table</code> esiste</p>";
            } else {
                echo "<p>❌ <code>$table</code> NON esiste</p>";
            }
        }
        echo '</div>';
        
    } catch (Exception $e) {
        echo '<div class="box error">';
        echo '<h2>❌ Errore Fatale</h2>';
        echo '<p>' . htmlspecialchars($e->getMessage()) . '</p>';
        echo '</div>';
    }
    
} else {
    // Form iniziale
    
    echo '<div class="box warning">';
    echo '<h2>⚠️ Attenzione</h2>';
    echo '<p>Questo script creerà le tabelle necessarie per il Comunicatore:</p>';
    echo '<ul>';
    echo '<li><code>comunicatore_pagine</code></li>';
    echo '<li><code>comunicatore_items</code></li>';
    echo '<li><code>comunicatore_log</code></li>';
    echo '</ul>';
    echo '<p><strong>Nota:</strong> Se le tabelle esistono già, verranno saltate (nessun dato perso).</p>';
    echo '</div>';
    
    // Verifica stato attuale
    echo '<div class="box">';
    echo '<h2>📊 Stato Attuale</h2>';
    
    try {
        $pdo = getDbConnection();
        
        $tables = ['comunicatore_pagine', 'comunicatore_items', 'comunicatore_log'];
        $missing = [];
        
        foreach ($tables as $table) {
            $stmt = $pdo->query("SHOW TABLES LIKE '$table'");
            if ($stmt->rowCount() > 0) {
                echo "<p>✅ <code>$table</code> già esiste</p>";
            } else {
                echo "<p>❌ <code>$table</code> mancante</p>";
                $missing[] = $table;
            }
        }
        
        if (count($missing) > 0) {
            echo '<p><strong>Mancano ' . count($missing) . ' tabelle</strong></p>';
        } else {
            echo '<p class="success">✅ Tutte le tabelle già esistono!</p>';
        }
        
    } catch (Exception $e) {
        echo '<p class="error">Errore: ' . htmlspecialchars($e->getMessage()) . '</p>';
    }
    
    echo '</div>';
    
    echo '<div class="box">';
    echo '<h2>🚀 Installazione</h2>';
    echo '<form method="POST">';
    echo '<button type="submit" name="install" value="1">▶️ Installa Tabelle</button>';
    echo '</form>';
    echo '</div>';
    
    echo '<div class="box">';
    echo '<h2>📝 Contenuto SQL</h2>';
    $sqlFile = __DIR__ . '/setup_database.sql';
    if (file_exists($sqlFile)) {
        echo '<pre>' . htmlspecialchars(file_get_contents($sqlFile)) . '</pre>';
    }
    echo '</div>';
}

?>

</body>
</html>

