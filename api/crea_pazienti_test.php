<?php
/**
 * Script per creare pazienti di test
 * Apri: http://localhost:8888/Assistivetech/api/crea_pazienti_test.php
 */

header('Content-Type: text/html; charset=utf-8');
require_once __DIR__ . '/config.php';

?>
<!DOCTYPE html>
<html>
<head>
    <title>Crea Pazienti Test</title>
    <style>
        body { font-family: sans-serif; padding: 20px; background: #f5f5f5; }
        .box { background: white; padding: 20px; margin: 10px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .success { border-left: 4px solid #4CAF50; }
        .error { border-left: 4px solid #F44336; }
        .warning { border-left: 4px solid #FF9800; }
        button { background: #673AB7; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-size: 16px; margin: 5px; }
        button:hover { background: #512DA8; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #673AB7; color: white; }
    </style>
</head>
<body>
    <h1>👥 Gestione Pazienti Test</h1>

<?php

try {
    $pdo = getDbConnection();
    
    // Se è stato inviato il form
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $action = $_POST['action'] ?? '';
        
        if ($action === 'create') {
            // Crea pazienti di test
            $pazienti = [
                ['nome' => 'Mario', 'cognome' => 'Rossi'],
                ['nome' => 'Luca', 'cognome' => 'Verdi'],
                ['nome' => 'Anna', 'cognome' => 'Bianchi'],
                ['nome' => 'Paolo', 'cognome' => 'Neri']
            ];
            
            $inserted = 0;
            foreach ($pazienti as $p) {
                // Verifica se esiste già
                $stmt = $pdo->prepare("SELECT id_registrazione FROM registrazioni WHERE nome = :nome AND cognome = :cognome");
                $stmt->execute([':nome' => $p['nome'], ':cognome' => $p['cognome']]);
                
                if (!$stmt->fetch()) {
                    // Non esiste, inserisci
                    $stmt = $pdo->prepare("INSERT INTO registrazioni (nome, cognome, ruolo) VALUES (:nome, :cognome, 'paziente')");
                    $stmt->execute([':nome' => $p['nome'], ':cognome' => $p['cognome']]);
                    $inserted++;
                }
            }
            
            echo '<div class="box success">';
            echo "<p>✅ Inseriti <strong>$inserted</strong> nuovi pazienti!</p>";
            echo '</div>';
        }
        
        if ($action === 'update_role') {
            // Aggiorna ruolo di tutti gli utenti esistenti
            $stmt = $pdo->query("UPDATE registrazioni SET ruolo = 'paziente' WHERE ruolo IS NULL OR ruolo = ''");
            $updated = $stmt->rowCount();
            
            echo '<div class="box success">';
            echo "<p>✅ Aggiornati <strong>$updated</strong> utenti con ruolo 'paziente'!</p>";
            echo '</div>';
        }
    }
    
    // Mostra utenti attuali
    echo '<div class="box">';
    echo '<h2>📊 Utenti Attuali</h2>';
    
    $stmt = $pdo->query("SELECT id_registrazione, nome, cognome, ruolo FROM registrazioni ORDER BY id_registrazione ASC");
    $utenti = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (count($utenti) > 0) {
        // Conta per ruolo
        $pazienti_count = 0;
        $altri_count = 0;
        foreach ($utenti as $u) {
            if ($u['ruolo'] === 'paziente') {
                $pazienti_count++;
            } else {
                $altri_count++;
            }
        }
        
        echo "<p><strong>Totale:</strong> " . count($utenti) . " utenti</p>";
        echo "<p><strong>Pazienti:</strong> $pazienti_count</p>";
        echo "<p><strong>Altri ruoli:</strong> $altri_count</p>";
        
        echo '<table>';
        echo '<tr><th>ID</th><th>Nome</th><th>Cognome</th><th>Ruolo</th></tr>';
        foreach ($utenti as $u) {
            $ruolo_class = $u['ruolo'] === 'paziente' ? 'style="background: #E8F5E9;"' : '';
            echo "<tr $ruolo_class>";
            echo "<td>{$u['id_registrazione']}</td>";
            echo "<td>" . ($u['nome'] ?? '-') . "</td>";
            echo "<td>" . ($u['cognome'] ?? '-') . "</td>";
            echo "<td><strong>" . ($u['ruolo'] ?? 'NON IMPOSTATO') . "</strong></td>";
            echo "</tr>";
        }
        echo '</table>';
        
        if ($pazienti_count === 0) {
            echo '<div class="box warning">';
            echo '<p>⚠️ <strong>Nessun utente con ruolo "paziente"!</strong></p>';
            echo '<p>Questo è il motivo per cui il dropdown è vuoto.</p>';
            echo '</div>';
        }
        
    } else {
        echo '<div class="box warning">';
        echo '<p>⚠️ Nessun utente nella tabella!</p>';
        echo '</div>';
    }
    
    echo '</div>';
    
    // Form azioni
    echo '<div class="box">';
    echo '<h2>🔧 Azioni</h2>';
    
    echo '<form method="POST" style="display: inline;">';
    echo '<input type="hidden" name="action" value="create">';
    echo '<button type="submit">➕ Crea 4 Pazienti di Test</button>';
    echo '</form>';
    
    if ($altri_count > 0) {
        echo '<form method="POST" style="display: inline;" onsubmit="return confirm(\'Impostare TUTTI gli utenti come pazienti?\');">';
        echo '<input type="hidden" name="action" value="update_role">';
        echo "<button type=\"submit\">🔄 Imposta tutti come 'paziente' ($altri_count utenti)</button>";
        echo '</form>';
    }
    
    echo '</div>';
    
    // Query SQL manuale
    echo '<div class="box">';
    echo '<h2>📝 Query SQL Manuale</h2>';
    echo '<p>Oppure esegui queste query in phpMyAdmin:</p>';
    echo '<pre style="background: #263238; color: #aed581; padding: 15px; border-radius: 4px; overflow-x: auto;">';
    echo "-- Inserisci pazienti specifici\n";
    echo "INSERT INTO registrazioni (nome, cognome, ruolo) VALUES\n";
    echo "  ('Mario', 'Rossi', 'paziente'),\n";
    echo "  ('Luca', 'Verdi', 'paziente'),\n";
    echo "  ('Anna', 'Bianchi', 'paziente');\n\n";
    echo "-- Oppure aggiorna utenti esistenti\n";
    echo "UPDATE registrazioni SET ruolo = 'paziente' WHERE id_registrazione IN (1,2,3);";
    echo '</pre>';
    echo '</div>';
    
} catch (Exception $e) {
    echo '<div class="box error">';
    echo '<p>❌ Errore: ' . htmlspecialchars($e->getMessage()) . '</p>';
    echo '</div>';
}

?>

<div class="box">
    <h2>🔄 Prossimi Passi</h2>
    <ol>
        <li>Clicca "Crea 4 Pazienti di Test" per inserire utenti automaticamente</li>
        <li>Oppure esegui le query SQL in phpMyAdmin</li>
        <li>Poi ricarica: <a href="../training_cognitivo/strumenti/comunicatore/gestione.html">gestione.html</a></li>
        <li>Vedrai gli utenti nel dropdown! 🎉</li>
    </ol>
</div>

<div class="box">
    <p><a href="get_pazienti.php" target="_blank">📡 Test API get_pazienti.php</a></p>
    <p><a href="debug_registrazioni.php" target="_blank">🔍 Debug struttura tabella</a></p>
</div>

</body>
</html>

