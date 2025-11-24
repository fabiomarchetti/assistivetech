<?php
/**
 * Installazione automatica tabelle Agenda Strumenti
 * Accedi a: http://localhost:8888/Assistivetech/training_cognitivo/strumenti/agenda/api/install_tables.php
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Prova path relativi flessibili per config.php
if (file_exists(__DIR__ . '/../../../../api/config.php')) {
    require_once __DIR__ . '/../../../../api/config.php';
} elseif (file_exists(__DIR__ . '/../../../api/config.php')) {
    require_once __DIR__ . '/../../../api/config.php';
} elseif (file_exists($_SERVER['DOCUMENT_ROOT'] . '/api/config.php')) {
    require_once $_SERVER['DOCUMENT_ROOT'] . '/api/config.php';
} else {
    die("❌ Config file non trovato!");
}

?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Installazione Tabelle Agenda</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 900px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        .success { color: #28a745; font-weight: bold; }
        .error { color: #dc3545; font-weight: bold; }
        .info { color: #17a2b8; }
        pre { background: #f5f5f5; padding: 15px; border-radius: 5px; overflow-x: auto; }
        .box { border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 5px; }
        button { background: #007bff; color: white; border: none; padding: 10px 20px; 
                 border-radius: 5px; cursor: pointer; font-size: 16px; margin: 10px 5px 0 0; }
        button:hover { background: #0056b3; }
        button.danger { background: #dc3545; }
        button.danger:hover { background: #c82333; }
    </style>
</head>
<body>
    <h1>🛠️ Installazione Tabelle Agenda Strumenti</h1>

    <?php
    $pdo = null;
    try {
        $pdo = getDbConnection();
        echo "<p class='success'>✅ Connessione database OK</p>";
    } catch (Exception $e) {
        echo "<p class='error'>❌ Errore connessione: " . $e->getMessage() . "</p>";
        exit;
    }

    // Leggi file SQL
    $sql_file = __DIR__ . '/setup_database.sql';
    if (!file_exists($sql_file)) {
        echo "<p class='error'>❌ File setup_database.sql non trovato!</p>";
        exit;
    }

    $sql_content = file_get_contents($sql_file);

    // Verifica se le tabelle esistono già
    $tables = ['agende_strumenti', 'agende_items', 'agende_log'];
    $existing_tables = [];

    foreach ($tables as $table) {
        $check = $pdo->query("SHOW TABLES LIKE '{$table}'");
        if ($check->rowCount() > 0) {
            $existing_tables[] = $table;
        }
    }

    if (!empty($existing_tables)) {
        echo "<div class='box'>";
        echo "<h2>⚠️ Attenzione</h2>";
        echo "<p>Le seguenti tabelle esistono già:</p>";
        echo "<ul>";
        foreach ($existing_tables as $table) {
            echo "<li><strong>{$table}</strong></li>";
        }
        echo "</ul>";
        echo "<p class='info'>Se procedi, le tabelle verranno <strong>sovrascritte</strong> (DROP + CREATE)</p>";
        echo "<form method='post'>";
        echo "<button type='submit' name='action' value='install'>✅ Installa Comunque</button>";
        echo "<button type='submit' name='action' value='drop' class='danger'>🗑️ Elimina Vecchie Tabelle</button>";
        echo "</form>";
        echo "</div>";
    } else {
        echo "<div class='box'>";
        echo "<p class='info'>✨ Nessuna tabella esistente. Pronto per l'installazione.</p>";
        echo "<form method='post'>";
        echo "<button type='submit' name='action' value='install'>✅ Installa Tabelle</button>";
        echo "</form>";
        echo "</div>";
    }

    // Gestione azioni
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $action = $_POST['action'] ?? '';

        if ($action === 'drop') {
            echo "<div class='box'>";
            echo "<h2>🗑️ Eliminazione Tabelle...</h2>";
            try {
                foreach (array_reverse($tables) as $table) {
                    $pdo->exec("DROP TABLE IF EXISTS `{$table}`");
                    echo "<p class='success'>✅ Tabella <strong>{$table}</strong> eliminata</p>";
                }
                echo "<p class='info'>🔄 Ricarica la pagina per reinstallare</p>";
            } catch (Exception $e) {
                echo "<p class='error'>❌ Errore: " . $e->getMessage() . "</p>";
            }
            echo "</div>";
        }

        if ($action === 'install') {
            echo "<div class='box'>";
            echo "<h2>⚙️ Installazione in corso...</h2>";

            try {
                // Rimuovi commenti SQL
                $sql_lines = explode("\n", $sql_content);
                $sql_queries = [];
                $current_query = '';

                foreach ($sql_lines as $line) {
                    $line = trim($line);
                    
                    // Salta commenti e righe vuote
                    if (empty($line) || strpos($line, '--') === 0) {
                        continue;
                    }

                    $current_query .= ' ' . $line;

                    // Fine statement
                    if (substr($line, -1) === ';') {
                        $sql_queries[] = trim($current_query);
                        $current_query = '';
                    }
                }

                // Esegui query
                $success_count = 0;
                $error_count = 0;

                foreach ($sql_queries as $query) {
                    if (empty(trim($query))) continue;

                    try {
                        $pdo->exec($query);
                        
                        // Identifica tipo query
                        if (stripos($query, 'CREATE TABLE') !== false) {
                            preg_match('/CREATE TABLE.*?`(\w+)`/i', $query, $matches);
                            $table_name = $matches[1] ?? 'sconosciuta';
                            echo "<p class='success'>✅ Tabella <strong>{$table_name}</strong> creata</p>";
                        } elseif (stripos($query, 'INSERT INTO') !== false) {
                            echo "<p class='success'>✅ Dati di test inseriti</p>";
                        }
                        
                        $success_count++;
                    } catch (Exception $e) {
                        echo "<p class='error'>❌ Errore: " . $e->getMessage() . "</p>";
                        echo "<details><summary>Query fallita</summary><pre>" . htmlspecialchars($query) . "</pre></details>";
                        $error_count++;
                    }
                }

                echo "<hr>";
                echo "<p><strong>Riepilogo:</strong></p>";
                echo "<p class='success'>✅ Query eseguite: {$success_count}</p>";
                if ($error_count > 0) {
                    echo "<p class='error'>❌ Errori: {$error_count}</p>";
                } else {
                    echo "<p class='success'>🎉 <strong>Installazione completata con successo!</strong></p>";
                    echo "<p><a href='../gestione.html'>➡️ Vai all'applicazione Agenda</a></p>";
                }

            } catch (Exception $e) {
                echo "<p class='error'>❌ Errore generale: " . $e->getMessage() . "</p>";
            }

            echo "</div>";
        }
    }

    // Mostra struttura SQL
    echo "<div class='box'>";
    echo "<h2>📄 Contenuto setup_database.sql</h2>";
    echo "<details><summary>Visualizza SQL</summary>";
    echo "<pre>" . htmlspecialchars($sql_content) . "</pre>";
    echo "</details>";
    echo "</div>";
    ?>

</body>
</html>

