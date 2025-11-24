<?php
require_once __DIR__ . '/api/config.php';

try {
    $pdo = getDbConnection();

    // Cerca esercizio veicoli mare
    $stmt = $pdo->query("
        SELECT id_esercizio, nome_esercizio, link, id_categoria
        FROM esercizi
        WHERE nome_esercizio LIKE '%veicoli%mare%' OR nome_esercizio LIKE '%mare%'
    ");
    $esercizi = $stmt->fetchAll();

    echo "<h2>Esercizi Mare trovati:</h2>";
    echo "<pre>";
    print_r($esercizi);
    echo "</pre>";

} catch (Exception $e) {
    echo "Errore: " . $e->getMessage();
}
?>
