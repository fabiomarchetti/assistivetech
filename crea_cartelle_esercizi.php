<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Crea Struttura Esercizi</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 900px;
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
        .success { background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .info { background: #cce5ff; color: #004085; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .warning { background: #fff3cd; color: #856404; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .btn {
            padding: 12px 24px;
            background: #673AB7;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
        }
        .btn:hover { background: #9C27B0; }
        ul { line-height: 1.8; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📁 Crea Struttura Cartelle Esercizi</h1>

        <?php
        if (!isset($_GET['run'])) {
            echo '<div class="warning">';
            echo '<strong>⚠️ ATTENZIONE:</strong><br>';
            echo 'Questo script creerà cartelle TEMPORANEE con pagine segnaposto per tutti gli esercizi.<br>';
            echo 'Le cartelle saranno vuote - dovrai poi copiare i contenuti reali dall\'altro PC.';
            echo '</div>';

            echo '<div class="info">';
            echo '<strong>📋 Cosa farà questo script:</strong>';
            echo '<ol>';
            echo '<li>Legge tutti gli esercizi dal database</li>';
            echo '<li>Crea le cartelle mancanti in <code>/training_cognitivo/</code></li>';
            echo '<li>Mette un file <code>index.html</code> segnaposto in ogni cartella</li>';
            echo '<li>Così i link non daranno più 404</li>';
            echo '</ol>';
            echo '</div>';

            echo '<form method="GET">';
            echo '<input type="hidden" name="run" value="1">';
            echo '<button type="submit" class="btn">🚀 Crea Cartelle</button>';
            echo '</form>';

        } else {
            require_once __DIR__ . '/api/config.php';

            echo '<h2>⚙️ Creazione in corso...</h2>';

            try {
                $pdo = getDbConnection();

                // Leggi tutti gli esercizi
                $stmt = $pdo->query("SELECT id_esercizio, nome_esercizio, link FROM esercizi WHERE link IS NOT NULL AND link != ''");
                $esercizi = $stmt->fetchAll();

                $created = [];
                $errors = [];
                $existing = [];

                foreach ($esercizi as $es) {
                    $link = $es['link'];

                    // Rimuovi /Assistivetech/ se presente
                    $link = str_replace('/Assistivetech/', '/', $link);

                    // Costruisci path assoluto
                    $fullPath = __DIR__ . $link;

                    // Crea directory se non esiste
                    if (!is_dir($fullPath)) {
                        if (mkdir($fullPath, 0755, true)) {
                            // Crea index.html segnaposto
                            $html = <<<HTML
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$es['nome_esercizio']}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: center;
        }
        .box {
            background: white;
            color: #333;
            padding: 50px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; margin: 0 0 20px 0; }
        .icon { font-size: 4em; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="box">
        <div class="icon">🚧</div>
        <h1>{$es['nome_esercizio']}</h1>
        <p><strong>Esercizio in Costruzione</strong></p>
        <p>Questa è una pagina segnaposto.</p>
        <p>Copia i file reali dall'altro computer.</p>
        <hr style="margin: 30px 0; border: none; border-top: 1px solid #ddd;">
        <p style="font-size: 0.9em; color: #999;">ID Esercizio: {$es['id_esercizio']}</p>
    </div>
</body>
</html>
HTML;
                            file_put_contents($fullPath . '/index.html', $html);
                            $created[] = $link;
                        } else {
                            $errors[] = "Impossibile creare: $link";
                        }
                    } else {
                        $existing[] = $link;
                    }
                }

                echo '<div class="success">';
                echo '<strong>✅ Operazione completata!</strong><br><br>';
                echo '<strong>📊 Statistiche:</strong><br>';
                echo '&nbsp;&nbsp;&nbsp;&nbsp;Cartelle create: ' . count($created) . '<br>';
                echo '&nbsp;&nbsp;&nbsp;&nbsp;Cartelle già esistenti: ' . count($existing) . '<br>';
                echo '&nbsp;&nbsp;&nbsp;&nbsp;Errori: ' . count($errors) . '<br>';
                echo '</div>';

                if (count($created) > 0) {
                    echo '<div class="info">';
                    echo '<strong>📁 Cartelle create:</strong><ul>';
                    foreach ($created as $path) {
                        echo '<li><code>' . htmlspecialchars($path) . '</code></li>';
                    }
                    echo '</ul></div>';
                }

                if (count($existing) > 0) {
                    echo '<div class="info">';
                    echo '<strong>✅ Cartelle già esistenti:</strong><ul>';
                    foreach ($existing as $path) {
                        echo '<li><code>' . htmlspecialchars($path) . '</code></li>';
                    }
                    echo '</ul></div>';
                }

                echo '<div class="warning">';
                echo '<strong>🔄 Prossimi Step:</strong><br>';
                echo '<ol>';
                echo '<li>Le cartelle sono state create con pagine segnaposto</li>';
                echo '<li>Ora copia i file REALI dall\'altro computer</li>';
                echo '<li>Sostituisci i file <code>index.html</code> segnaposto con quelli veri</li>';
                echo '</ol>';
                echo '</div>';

                echo '<a href="test_api_esercizi.html" class="btn">🧪 Testa API Esercizi</a>';
                echo '<a href="admin/" class="btn" style="background: #6c757d; margin-left: 10px;">⚙️ Pannello Admin</a>';

            } catch (Exception $e) {
                echo '<div class="error">';
                echo '<strong>❌ Errore:</strong><br>';
                echo '<pre>' . htmlspecialchars($e->getMessage()) . '</pre>';
                echo '</div>';
            }
        }
        ?>
    </div>
</body>
</html>
