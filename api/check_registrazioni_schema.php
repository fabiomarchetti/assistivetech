<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Configurazione database centralizzata (auto locale/produzione)
require_once __DIR__ . '/config.php';

try {
    $pdo = getDbConnection();

    $result = [];

    // Controlla struttura tabella registrazioni
    try {
        $stmt = $pdo->prepare("DESCRIBE registrazioni");
        $stmt->execute();
        $result['registrazioni_columns'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        $result['registrazioni_error'] = $e->getMessage();
    }

    echo json_encode([
        'success' => true,
        'message' => 'Schema registrazioni controllato',
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