<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Gestione richieste OPTIONS per CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurazione database MySQL Aruba
$host = '31.11.39.242';
$username = 'Sql1073852';
$password = '5k58326940';
$database = 'Sql1073852_1';

// Funzione per rispondere con JSON
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ]);
    exit();
}

try {
    // Connessione al database
    $pdo = new PDO("mysql:host=$host;dbname=$database;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Leggi parametro id_sede (opzionale)
    $id_sede = isset($_GET['id_sede']) ? intval($_GET['id_sede']) : null;

    if ($id_sede) {
        // Query per ottenere settori di una sede specifica
        $stmt = $pdo->prepare("
            SELECT
                s.id_settore,
                s.nome_settore,
                s.descrizione_settore,
                s.id_sede,
                se.nome_sede
            FROM settori s
            LEFT JOIN sedi se ON s.id_sede = se.id_sede
            WHERE s.id_sede = :id_sede
            ORDER BY s.nome_settore ASC
        ");
        $stmt->execute([':id_sede' => $id_sede]);
    } else {
        // Query per ottenere tutti i settori con le relative sedi
        $stmt = $pdo->prepare("
            SELECT
                s.id_settore,
                s.nome_settore,
                s.descrizione_settore,
                s.id_sede,
                se.nome_sede
            FROM settori s
            LEFT JOIN sedi se ON s.id_sede = se.id_sede
            ORDER BY se.nome_sede ASC, s.nome_settore ASC
        ");
        $stmt->execute();
    }

    $settori = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $message = $id_sede ? "Settori della sede recuperati con successo" : "Tutti i settori recuperati con successo";
    jsonResponse(true, $message, $settori);

} catch (PDOException $e) {
    error_log("Errore database in api_get_settori.php: " . $e->getMessage());
    jsonResponse(false, 'Errore nel caricamento dei settori');
} catch (Exception $e) {
    error_log("Errore generale in api_get_settori.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server');
}
?>