<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Setup Database Locale - AssistiveTech</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1000px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #673AB7;
        }
        .success {
            color: #28a745;
            background: #d4edda;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
            border-left: 4px solid #28a745;
        }
        .error {
            color: #dc3545;
            background: #f8d7da;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
            border-left: 4px solid #dc3545;
        }
        .warning {
            color: #856404;
            background: #fff3cd;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
            border-left: 4px solid #ffc107;
        }
        .info {
            color: #004085;
            background: #cce5ff;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
            border-left: 4px solid #007bff;
        }
        .step {
            margin: 20px 0;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 5px;
        }
        .step-title {
            font-size: 1.2em;
            font-weight: bold;
            color: #673AB7;
            margin-bottom: 10px;
        }
        pre {
            background: #2d2d2d;
            color: #f8f8f2;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-size: 0.9em;
        }
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background: #673AB7;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 10px 5px;
            border: none;
            cursor: pointer;
            font-size: 1em;
        }
        .btn:hover {
            background: #9C27B0;
        }
        .btn-secondary {
            background: #6c757d;
        }
        .btn-secondary:hover {
            background: #5a6268;
        }
        .progress {
            margin: 20px 0;
        }
        .progress-bar {
            background: #673AB7;
            height: 30px;
            border-radius: 5px;
            text-align: center;
            color: white;
            line-height: 30px;
            transition: width 0.3s;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Setup Database Locale</h1>
        <div class="info">
            <strong>📝 Questo script creerà il database locale per MAMP e importerà la struttura</strong>
        </div>

        <?php
        // Configurazione MAMP
        $host = 'localhost';
        $username = 'root';
        $password = 'root';
        $database = 'assistivetech_local';
        $port = 8889; // Porta MAMP di default

        $step = isset($_GET['step']) ? (int)$_GET['step'] : 0;

        if ($step === 0) {
            // Step 0: Mostra info e pulsante per iniziare
            echo '<div class="step">';
            echo '<div class="step-title">📋 Informazioni Setup</div>';
            echo '<p>Questo setup eseguirà le seguenti operazioni:</p>';
            echo '<ol>';
            echo '<li>✅ Test connessione a MySQL (MAMP)</li>';
            echo '<li>🗄️ Creazione database <code>assistivetech_local</code> (se non esiste)</li>';
            echo '<li>📥 Importazione struttura tabelle da <code>script_sql/database.sql</code></li>';
            echo '<li>✔️ Verifica creazione tabelle e dati</li>';
            echo '</ol>';

            echo '<div class="warning">';
            echo '<strong>⚠️ ATTENZIONE:</strong> Assicurati che MAMP sia avviato prima di procedere!';
            echo '<ul>';
            echo '<li>Apri MAMP e clicca su "Start Servers"</li>';
            echo '<li>Verifica che Apache e MySQL siano verdi (attivi)</li>';
            echo '<li>Porta MySQL dovrebbe essere 8889 (default MAMP)</li>';
            echo '</ul>';
            echo '</div>';

            echo '<form method="GET">';
            echo '<input type="hidden" name="step" value="1">';
            echo '<button type="submit" class="btn">🚀 Avvia Setup</button>';
            echo '</form>';
            echo '</div>';

        } elseif ($step === 1) {
            // Step 1: Test connessione MySQL
            echo '<div class="step">';
            echo '<div class="step-title">Step 1/4: Test Connessione MySQL</div>';

            try {
                $pdo = new PDO("mysql:host=$host;port=$port;charset=utf8mb4", $username, $password);
                $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

                echo '<div class="success">';
                echo '✅ <strong>Connessione a MySQL riuscita!</strong><br>';
                echo 'Host: ' . $host . ':' . $port . '<br>';
                echo 'Versione MySQL: ' . $pdo->query('SELECT VERSION()')->fetchColumn();
                echo '</div>';

                echo '<a href="?step=2" class="btn">➡️ Prossimo Step</a>';

            } catch (PDOException $e) {
                echo '<div class="error">';
                echo '❌ <strong>Errore di connessione a MySQL:</strong><br>';
                echo '<pre>' . htmlspecialchars($e->getMessage()) . '</pre>';
                echo '</div>';

                echo '<div class="info">';
                echo '<strong>💡 Soluzioni:</strong><br>';
                echo '<ul>';
                echo '<li>Verifica che MAMP sia avviato</li>';
                echo '<li>Controlla che la porta MySQL sia 8889 (MAMP default)</li>';
                echo '<li>Se usi porta 3306, modifica <code>api/config.php</code></li>';
                echo '</ul>';
                echo '</div>';

                echo '<a href="?step=0" class="btn btn-secondary">🔙 Indietro</a>';
            }
            echo '</div>';

        } elseif ($step === 2) {
            // Step 2: Creazione database
            echo '<div class="step">';
            echo '<div class="step-title">Step 2/4: Creazione Database</div>';

            try {
                $pdo = new PDO("mysql:host=$host;port=$port;charset=utf8mb4", $username, $password);
                $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

                // Verifica se database esiste
                $stmt = $pdo->query("SHOW DATABASES LIKE '$database'");
                $exists = $stmt->fetch();

                if ($exists) {
                    echo '<div class="warning">';
                    echo '⚠️ Il database <code>' . $database . '</code> esiste già!<br>';
                    echo 'Continuando verranno importate/aggiornate le tabelle.';
                    echo '</div>';
                } else {
                    // Crea database
                    $pdo->exec("CREATE DATABASE IF NOT EXISTS `$database` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");

                    echo '<div class="success">';
                    echo '✅ <strong>Database <code>' . $database . '</code> creato con successo!</strong>';
                    echo '</div>';
                }

                echo '<a href="?step=3" class="btn">➡️ Prossimo Step</a>';

            } catch (PDOException $e) {
                echo '<div class="error">';
                echo '❌ <strong>Errore durante la creazione del database:</strong><br>';
                echo '<pre>' . htmlspecialchars($e->getMessage()) . '</pre>';
                echo '</div>';

                echo '<a href="?step=1" class="btn btn-secondary">🔙 Indietro</a>';
            }
            echo '</div>';

        } elseif ($step === 3) {
            // Step 3: Importazione struttura
            echo '<div class="step">';
            echo '<div class="step-title">Step 3/4: Importazione Struttura Tabelle</div>';

            try {
                $pdo = new PDO("mysql:host=$host;port=$port;dbname=$database;charset=utf8mb4", $username, $password);
                $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

                // Leggi file SQL
                $sqlFile = __DIR__ . '/script_sql/database.sql';

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

                foreach ($statements as $statement) {
                    // Salta commenti e statement vuoti
                    if (empty($statement) || strpos($statement, '--') === 0 || strpos($statement, '/*') === 0) {
                        continue;
                    }

                    try {
                        $pdo->exec($statement);
                        $success++;
                    } catch (PDOException $e) {
                        // Ignora errori di tabella già esistente
                        if (strpos($e->getMessage(), 'already exists') === false &&
                            strpos($e->getMessage(), 'Duplicate') === false) {
                            $errors++;
                            echo '<div class="warning">⚠️ ' . htmlspecialchars($e->getMessage()) . '</div>';
                        }
                    }
                }

                echo '<div class="success">';
                echo '✅ <strong>Importazione completata!</strong><br>';
                echo "Statement eseguiti con successo: $success<br>";
                if ($errors > 0) {
                    echo "⚠️ Alcuni statement hanno generato warning (probabilmente tabelle già esistenti)";
                }
                echo '</div>';

                echo '<a href="?step=4" class="btn">➡️ Verifica Setup</a>';

            } catch (Exception $e) {
                echo '<div class="error">';
                echo '❌ <strong>Errore durante l\'importazione:</strong><br>';
                echo '<pre>' . htmlspecialchars($e->getMessage()) . '</pre>';
                echo '</div>';

                echo '<a href="?step=2" class="btn btn-secondary">🔙 Indietro</a>';
            }
            echo '</div>';

        } elseif ($step === 4) {
            // Step 4: Verifica finale
            echo '<div class="step">';
            echo '<div class="step-title">Step 4/4: Verifica Setup</div>';

            try {
                $pdo = new PDO("mysql:host=$host;port=$port;dbname=$database;charset=utf8mb4", $username, $password);
                $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

                // Verifica tabelle
                $stmt = $pdo->query("SHOW TABLES");
                $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);

                echo '<div class="success">';
                echo '✅ <strong>Setup completato con successo!</strong><br>';
                echo '<strong>Tabelle create:</strong> ' . count($tables) . '<br>';
                echo '</div>';

                if (count($tables) > 0) {
                    echo '<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">';
                    echo '<tr style="background: #673AB7; color: white;">';
                    echo '<th style="padding: 10px; border: 1px solid #ddd;">Tabella</th>';
                    echo '<th style="padding: 10px; border: 1px solid #ddd;">Righe</th>';
                    echo '</tr>';

                    foreach ($tables as $table) {
                        $countStmt = $pdo->query("SELECT COUNT(*) FROM `$table`");
                        $count = $countStmt->fetchColumn();

                        echo '<tr>';
                        echo '<td style="padding: 10px; border: 1px solid #ddd;"><strong>' . htmlspecialchars($table) . '</strong></td>';
                        echo '<td style="padding: 10px; border: 1px solid #ddd;">' . $count . '</td>';
                        echo '</tr>';
                    }

                    echo '</table>';
                }

                // Verifica utente sviluppatore
                if (in_array('registrazioni', $tables)) {
                    $stmt = $pdo->query("SELECT * FROM registrazioni WHERE ruolo_registrazione = 'sviluppatore' LIMIT 1");
                    $dev = $stmt->fetch();

                    if ($dev) {
                        echo '<div class="success">';
                        echo '👨‍💻 <strong>Utente sviluppatore trovato!</strong><br>';
                        echo 'Username: <code>' . htmlspecialchars($dev['username_registrazione']) . '</code><br>';
                        echo 'Password: <code>' . htmlspecialchars($dev['password_registrazione']) . '</code>';
                        echo '</div>';
                    }
                }

                echo '<div class="info">';
                echo '<strong>🎉 Il database locale è pronto!</strong><br>';
                echo 'Ora puoi utilizzare l\'applicazione in locale.<br>';
                echo '</div>';

                echo '<a href="test_connection.php" class="btn">🔍 Test Connessione</a>';
                echo '<a href="login.html" class="btn">🔐 Vai al Login</a>';
                echo '<a href="index.html" class="btn btn-secondary">🏠 Home</a>';

            } catch (Exception $e) {
                echo '<div class="error">';
                echo '❌ <strong>Errore durante la verifica:</strong><br>';
                echo '<pre>' . htmlspecialchars($e->getMessage()) . '</pre>';
                echo '</div>';
            }
            echo '</div>';
        }
        ?>

        <div style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #eee;">
            <h3>📚 Links Utili</h3>
            <ul>
                <li><a href="http://localhost:8888/phpMyAdmin/" target="_blank">phpMyAdmin MAMP</a></li>
                <li><a href="test_connection.php">Test Connessione Database</a></li>
                <li><a href="index.html">Homepage Applicazione</a></li>
            </ul>
        </div>
    </div>
</body>
</html>
