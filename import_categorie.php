<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Import Categorie Esercizi</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #673AB7; }
        .success {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #28a745;
            margin: 20px 0;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #dc3545;
            margin: 20px 0;
        }
        .info {
            background: #cce5ff;
            color: #004085;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #007bff;
            margin: 20px 0;
        }
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background: #673AB7;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            font-size: 1em;
            margin: 5px;
        }
        .btn:hover { background: #9C27B0; }
        .btn-secondary {
            background: #6c757d;
        }
        .btn-secondary:hover { background: #5a6268; }
        pre {
            background: #f4f4f4;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📥 Import Tabella categorie_esercizi</h1>

        <?php
        if (!isset($_GET['run'])) {
            // Step 1: Mostra informazioni
            echo '<div class="info">';
            echo '<strong>📋 Cosa fa questo script:</strong>';
            echo '<ol>';
            echo '<li>Elimina la tabella <code>categorie_esercizi</code> se esiste</li>';
            echo '<li>Crea la tabella con struttura corretta</li>';
            echo '<li>Importa 6 categorie dal database di origine</li>';
            echo '<li>Configura indici e AUTO_INCREMENT</li>';
            echo '</ol>';
            echo '</div>';

            echo '<div class="info">';
            echo '<strong>📦 Categorie che verranno importate:</strong>';
            echo '<ul>';
            echo '<li><strong>Categorizzazione</strong> - Scegliere l\'immagine per la categoria</li>';
            echo '<li><strong>Sequenze temporali</strong> - Mettere in ordine i componenti</li>';
            echo '<li><strong>Sequenze logiche</strong> - Ordina gli oggetti in sequenza logica</li>';
            echo '<li><strong>Causa effetto</strong> (2 varianti) - Interazioni causa-effetto</li>';
            echo '<li><strong>Scrivi con le sillabe</strong> - Composizione parole da sillabe</li>';
            echo '</ul>';
            echo '</div>';

            echo '<form method="GET">';
            echo '<input type="hidden" name="run" value="1">';
            echo '<button type="submit" class="btn">🚀 Avvia Import</button>';
            echo '<a href="test_connection.php" class="btn btn-secondary">🔍 Test Database</a>';
            echo '</form>';

        } else {
            // Step 2: Esegui import
            require_once __DIR__ . '/api/config.php';

            echo '<h2>⚙️ Esecuzione Import...</h2>';

            try {
                $pdo = getDbConnection();

                // Leggi file SQL
                $sqlFile = __DIR__ . '/import_categorie_esercizi.sql';

                if (!file_exists($sqlFile)) {
                    throw new Exception("File SQL non trovato: $sqlFile");
                }

                $sql = file_get_contents($sqlFile);

                // Rimuovi commenti e split per statement
                $statements = array_filter(
                    array_map('trim',
                        preg_split('/;[\s]*$/m', $sql, -1, PREG_SPLIT_NO_EMPTY)
                    )
                );

                $success = 0;
                $errors = 0;

                echo '<div class="info">';
                echo '<strong>📝 Esecuzione statement SQL...</strong><br><br>';

                foreach ($statements as $statement) {
                    // Salta commenti
                    if (empty($statement) ||
                        strpos($statement, '--') === 0 ||
                        strpos($statement, '/*') === 0) {
                        continue;
                    }

                    try {
                        $pdo->exec($statement);
                        $success++;

                        // Mostra tipo statement eseguito
                        if (stripos($statement, 'DROP') === 0) {
                            echo '🗑️ Tabella esistente eliminata<br>';
                        } elseif (stripos($statement, 'CREATE TABLE') === 0) {
                            echo '📋 Struttura tabella creata<br>';
                        } elseif (stripos($statement, 'INSERT') === 0) {
                            echo '📥 Dati importati (6 categorie)<br>';
                        } elseif (stripos($statement, 'ALTER TABLE') !== false && stripos($statement, 'ADD PRIMARY') !== false) {
                            echo '🔑 Chiave primaria aggiunta<br>';
                        } elseif (stripos($statement, 'MODIFY') !== false) {
                            echo '🔢 AUTO_INCREMENT configurato<br>';
                        }

                    } catch (PDOException $e) {
                        $errors++;
                        echo '<div class="error">❌ ' . htmlspecialchars($e->getMessage()) . '</div>';
                    }
                }

                echo '</div>';

                // Verifica risultato (solo se la tabella esiste)
                $count = 0;
                try {
                    $stmt = $pdo->query("SELECT COUNT(*) as count FROM categorie_esercizi");
                    $count = $stmt->fetch()['count'];
                } catch (PDOException $e) {
                    // Tabella non esiste ancora, normale
                    $count = 0;
                }

                echo '<div class="success">';
                echo '<strong>✅ Import completato con successo!</strong><br><br>';
                echo '📊 <strong>Statistiche:</strong><br>';
                echo '&nbsp;&nbsp;&nbsp;&nbsp;Statement eseguiti: ' . $success . '<br>';
                echo '&nbsp;&nbsp;&nbsp;&nbsp;Categorie importate: ' . $count . '<br>';
                if ($errors > 0) {
                    echo '&nbsp;&nbsp;&nbsp;&nbsp;⚠️ Warning: ' . $errors . '<br>';
                }
                echo '</div>';

                // Mostra categorie importate
                if ($count > 0) {
                    echo '<h3>📦 Categorie Importate</h3>';
                    echo '<table style="width: 100%; border-collapse: collapse;">';
                    echo '<tr style="background: #673AB7; color: white;">';
                    echo '<th style="padding: 10px; border: 1px solid #ddd;">ID</th>';
                    echo '<th style="padding: 10px; border: 1px solid #ddd;">Nome</th>';
                    echo '<th style="padding: 10px; border: 1px solid #ddd;">Descrizione</th>';
                    echo '</tr>';

                    try {
                        $stmt = $pdo->query("SELECT id_categoria, nome_categoria, descrizione_categoria FROM categorie_esercizi ORDER BY id_categoria");

                        while ($row = $stmt->fetch()) {
                            echo '<tr>';
                            echo '<td style="padding: 10px; border: 1px solid #ddd;">' . $row['id_categoria'] . '</td>';
                            echo '<td style="padding: 10px; border: 1px solid #ddd;"><strong>' . htmlspecialchars($row['nome_categoria']) . '</strong></td>';
                            echo '<td style="padding: 10px; border: 1px solid #ddd;">' . htmlspecialchars($row['descrizione_categoria']) . '</td>';
                            echo '</tr>';
                        }
                    } catch (PDOException $e) {
                        echo '<tr><td colspan="3" style="padding: 10px;">Errore lettura categorie</td></tr>';
                    }

                    echo '</table>';
                }

                echo '<br>';
                echo '<a href="test_connection.php" class="btn">🔍 Verifica Database</a>';
                echo '<a href="login.html" class="btn">🔐 Vai al Login</a>';
                echo '<a href="admin/" class="btn btn-secondary">⚙️ Pannello Admin</a>';

            } catch (Exception $e) {
                echo '<div class="error">';
                echo '<strong>❌ Errore durante l\'import:</strong><br>';
                echo '<pre>' . htmlspecialchars($e->getMessage()) . '</pre>';
                echo '</div>';

                echo '<a href="?" class="btn btn-secondary">🔙 Riprova</a>';
            }
        }
        ?>
    </div>
</body>
</html>
