<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Configurazione database centralizzata (auto locale/produzione)
require_once __DIR__ . '/config.php';

try {
    $pdo = getDbConnection();

    $result = [];

    // Controlla struttura tabella educatori
    try {
        $stmt = $pdo->prepare("DESCRIBE educatori");
        $stmt->execute();
        $result['educatori_columns'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        $result['educatori_error'] = $e->getMessage();
    }

    // Controlla struttura tabella pazienti
    try {
        $stmt = $pdo->prepare("DESCRIBE pazienti");
        $stmt->execute();
        $result['pazienti_columns'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        $result['pazienti_error'] = $e->getMessage();
    }

    // Controlla tutte le tabelle nel database
    try {
        $stmt = $pdo->prepare("SHOW TABLES");
        $stmt->execute();
        $result['all_tables'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        $result['tables_error'] = $e->getMessage();
    }

    echo json_encode([
        'success' => true,
        'message' => 'Schema controllato con successo',
        'data' => $result
    ], JSON_PRETTY_PRINT);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Errore: ' . $e->getMessage(),
        'data' => null
    ]);
}
?>