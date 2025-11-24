<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Test PHP - MAMP</title>
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
        .success {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #28a745;
            margin: 20px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        table th, table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        table th {
            background-color: #673AB7;
            color: white;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background: #673AB7;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 5px;
        }
        .btn:hover { background: #9C27B0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐘 Test PHP Funzionante!</h1>

        <div class="success">
            ✅ <strong>PHP sta funzionando correttamente!</strong>
        </div>

        <h2>📋 Informazioni PHP</h2>
        <table>
            <tr>
                <th>Parametro</th>
                <th>Valore</th>
            </tr>
            <tr>
                <td><strong>Versione PHP</strong></td>
                <td><?php echo phpversion(); ?></td>
            </tr>
            <tr>
                <td><strong>Server Software</strong></td>
                <td><?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'N/A'; ?></td>
            </tr>
            <tr>
                <td><strong>Document Root</strong></td>
                <td><?php echo $_SERVER['DOCUMENT_ROOT']; ?></td>
            </tr>
            <tr>
                <td><strong>Script Path</strong></td>
                <td><?php echo __FILE__; ?></td>
            </tr>
            <tr>
                <td><strong>HTTP Host</strong></td>
                <td><?php echo $_SERVER['HTTP_HOST'] ?? 'N/A'; ?></td>
            </tr>
            <tr>
                <td><strong>Server Port</strong></td>
                <td><?php echo $_SERVER['SERVER_PORT'] ?? 'N/A'; ?></td>
            </tr>
        </table>

        <h2>🔧 Estensioni PHP Critiche</h2>
        <table>
            <tr>
                <th>Estensione</th>
                <th>Status</th>
            </tr>
            <tr>
                <td><strong>PDO</strong></td>
                <td><?php echo extension_loaded('pdo') ? '✅ Installato' : '❌ Non installato'; ?></td>
            </tr>
            <tr>
                <td><strong>PDO MySQL</strong></td>
                <td><?php echo extension_loaded('pdo_mysql') ? '✅ Installato' : '❌ Non installato'; ?></td>
            </tr>
            <tr>
                <td><strong>MySQLi</strong></td>
                <td><?php echo extension_loaded('mysqli') ? '✅ Installato' : '❌ Non installato'; ?></td>
            </tr>
            <tr>
                <td><strong>JSON</strong></td>
                <td><?php echo extension_loaded('json') ? '✅ Installato' : '❌ Non installato'; ?></td>
            </tr>
            <tr>
                <td><strong>mbstring</strong></td>
                <td><?php echo extension_loaded('mbstring') ? '✅ Installato' : '❌ Non installato'; ?></td>
            </tr>
        </table>

        <h2>📂 Directory Applicazione</h2>
        <table>
            <tr>
                <th>Directory</th>
                <th>Esiste?</th>
            </tr>
            <?php
            $dirs = ['api', 'admin', 'agenda', 'script_sql'];
            foreach ($dirs as $dir) {
                $exists = is_dir(__DIR__ . '/' . $dir);
                echo "<tr>";
                echo "<td><strong>/$dir/</strong></td>";
                echo "<td>" . ($exists ? '✅ Sì' : '❌ No') . "</td>";
                echo "</tr>";
            }
            ?>
        </table>

        <h2>🔗 Prossimi Step</h2>
        <a href="test_connection.php" class="btn">Test Connessione Database</a>
        <a href="login.html" class="btn">Vai al Login</a>
        <a href="index.html" class="btn">Homepage</a>

        <hr style="margin: 30px 0;">

        <details>
            <summary style="cursor: pointer; color: #673AB7; font-weight: bold;">🔍 Mostra phpinfo() completo</summary>
            <div style="margin-top: 20px;">
                <?php phpinfo(); ?>
            </div>
        </details>
    </div>
</body>
</html>
