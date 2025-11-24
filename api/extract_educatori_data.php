<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Configurazione database MySQL Aruba
$host = '31.11.39.242';
$username = 'Sql1073852';
$password = '5k58326940';
$database = 'Sql1073852_1';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$database;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $result = [];

    echo "<h1>🔍 Estrazione Completa Dati Educatori</h1>";
    echo "<style>body{font-family:Arial,sans-serif;margin:20px;} table{border-collapse:collapse;width:100%;margin:20px 0;} th,td{border:1px solid #ddd;padding:8px;text-align:left;} th{background-color:#f2f2f2;} .error{color:red;background:#ffe6e6;padding:10px;} .success{color:green;background:#e6ffe6;padding:10px;}</style>";

    // 1. STRUTTURA TABELLA EDUCATORI
    echo "<h2>1. 📋 Struttura Tabella EDUCATORI</h2>";
    try {
        $stmt = $pdo->prepare("DESCRIBE educatori");
        $stmt->execute();
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "<table><tr><th>Field</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th><th>Extra</th></tr>";
        foreach ($columns as $col) {
            echo "<tr><td><strong>{$col['Field']}</strong></td><td>{$col['Type']}</td><td>{$col['Null']}</td><td>{$col['Key']}</td><td>{$col['Default']}</td><td>{$col['Extra']}</td></tr>";
        }
        echo "</table>";

        // Verifica campi critici
        $fields = array_column($columns, 'Field');
        $requiredFields = ['id_educatore', 'id_registrazione', 'nome', 'cognome', 'id_sede', 'id_settore', 'id_classe'];

        echo "<h3>✅ Verifica Campi Richiesti:</h3><ul>";
        foreach ($requiredFields as $field) {
            $exists = in_array($field, $fields);
            echo "<li style='color:" . ($exists ? 'green' : 'red') . "'>{$field}: " . ($exists ? 'PRESENTE' : 'MANCANTE') . "</li>";
        }
        echo "</ul>";

    } catch (Exception $e) {
        echo "<div class='error'>Errore struttura educatori: " . $e->getMessage() . "</div>";
    }

    // 2. TUTTI GLI EDUCATORI
    echo "<h2>2. 👥 Tutti gli Educatori nel Database</h2>";
    try {
        $stmt = $pdo->prepare("SELECT * FROM educatori ORDER BY id_educatore");
        $stmt->execute();
        $educatori = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "<p><strong>Totale Educatori:</strong> " . count($educatori) . "</p>";

        if (count($educatori) > 0) {
            echo "<table>";
            // Header
            echo "<tr>";
            foreach (array_keys($educatori[0]) as $key) {
                echo "<th>{$key}</th>";
            }
            echo "</tr>";

            // Data
            foreach ($educatori as $edu) {
                echo "<tr>";
                foreach ($edu as $value) {
                    echo "<td>" . ($value ?? 'NULL') . "</td>";
                }
                echo "</tr>";
            }
            echo "</table>";
        } else {
            echo "<div class='error'>Nessun educatore trovato nella tabella!</div>";
        }

    } catch (Exception $e) {
        echo "<div class='error'>Errore query educatori: " . $e->getMessage() . "</div>";
    }

    // 3. EDUCATORI CON JOIN (come nell'API)
    echo "<h2>3. 🔗 Educatori con JOIN (Sedi, Settori, Classi)</h2>";
    try {
        $stmt = $pdo->prepare("
            SELECT
                e.id_educatore,
                e.id_registrazione,
                e.nome,
                e.cognome,
                e.id_settore,
                e.id_classe,
                e.telefono,
                e.email_contatto,
                e.note_professionali,
                e.stato_educatore,
                e.data_creazione,
                s.nome_sede,
                st.nome_settore,
                cl.nome_classe,
                r.username_registrazione
            FROM educatori e
            LEFT JOIN sedi s ON e.id_sede = s.id_sede
            LEFT JOIN settori st ON e.id_settore = st.id_settore
            LEFT JOIN classi cl ON e.id_classe = cl.id_classe
            LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
            WHERE e.stato_educatore != 'eliminato'
            ORDER BY e.data_creazione DESC
        ");
        $stmt->execute();
        $educatori_join = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "<p><strong>Educatori con JOIN:</strong> " . count($educatori_join) . "</p>";

        if (count($educatori_join) > 0) {
            echo "<table>";
            // Header
            echo "<tr>";
            foreach (array_keys($educatori_join[0]) as $key) {
                echo "<th>{$key}</th>";
            }
            echo "</tr>";

            // Data
            foreach ($educatori_join as $edu) {
                echo "<tr>";
                foreach ($edu as $value) {
                    echo "<td>" . ($value ?? 'NULL') . "</td>";
                }
                echo "</tr>";
            }
            echo "</table>";
        } else {
            echo "<div class='error'>Nessun educatore trovato con JOIN!</div>";
        }

    } catch (Exception $e) {
        echo "<div class='error'>Errore query JOIN educatori: " . $e->getMessage() . "</div>";
    }

    // 4. VERIFICA TABELLE CORRELATE
    echo "<h2>4. 📊 Verifica Tabelle Correlate</h2>";

    $tables = ['sedi', 'settori', 'classi', 'registrazioni'];
    foreach ($tables as $table) {
        try {
            $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM {$table}");
            $stmt->execute();
            $count = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
            echo "<div class='success'>Tabella <strong>{$table}</strong>: {$count} record</div>";

            // Mostra primi 3 record per debug
            $stmt = $pdo->prepare("SELECT * FROM {$table} LIMIT 3");
            $stmt->execute();
            $sample = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($sample) > 0) {
                echo "<table><caption>Esempio record {$table}:</caption>";
                echo "<tr>";
                foreach (array_keys($sample[0]) as $key) {
                    echo "<th>{$key}</th>";
                }
                echo "</tr>";
                foreach ($sample as $row) {
                    echo "<tr>";
                    foreach ($row as $value) {
                        echo "<td>" . ($value ?? 'NULL') . "</td>";
                    }
                    echo "</tr>";
                }
                echo "</table>";
            }

        } catch (Exception $e) {
            echo "<div class='error'>Errore tabella {$table}: " . $e->getMessage() . "</div>";
        }
    }

    // 5. JSON EXPORT PER DEBUG
    echo "<h2>5. 📄 Export JSON per Debug</h2>";
    echo "<p>Copia questo JSON e passalo per l'analisi:</p>";

    $export_data = [
        'educatori_raw' => $educatori ?? [],
        'educatori_join' => $educatori_join ?? [],
        'struttura_educatori' => $columns ?? [],
        'timestamp' => date('Y-m-d H:i:s')
    ];

    echo "<textarea style='width:100%;height:200px;font-family:monospace;font-size:11px;'>";
    echo json_encode($export_data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    echo "</textarea>";

} catch (Exception $e) {
    echo "<div class='error'><h2>❌ Errore Connessione Database</h2>";
    echo "<p><strong>Errore:</strong> " . $e->getMessage() . "</p></div>";
}
?>