<?php
require_once 'api/config.php';

echo "<h1>Fix Tabella categorie_esercizi</h1><hr>";

try {
    $pdo = getDbConnection();

    // Verifica struttura attuale
    echo "<h2>Struttura Attuale:</h2>";
    $stmt = $pdo->query("DESCRIBE categorie_esercizi");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "<pre>";
    print_r($columns);
    echo "</pre>";

    // Fix: Aggiungi AUTO_INCREMENT se mancante
    echo "<h2>Applicazione Fix...</h2>";

    $pdo->exec("ALTER TABLE categorie_esercizi MODIFY id_categoria INT AUTO_INCREMENT PRIMARY KEY");

    echo "✅ Fix applicato con successo!<br>";
    echo "Campo id_categoria ora ha AUTO_INCREMENT<br><br>";

    // Verifica fix
    echo "<h2>Struttura Dopo Fix:</h2>";
    $stmt = $pdo->query("DESCRIBE categorie_esercizi");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "<pre>";
    print_r($columns);
    echo "</pre>";

} catch (Exception $e) {
    echo "<p style='color:red'>❌ Errore: " . $e->getMessage() . "</p>";
}

echo "<hr>";
echo "<a href='admin/index.html'>← Torna all'admin</a>";
?>
