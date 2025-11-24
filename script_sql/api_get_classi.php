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

    // Leggi parametri per filtraggio
    $id_sede = isset($_GET['id_sede']) ? intval($_GET['id_sede']) : null;
    $id_settore = isset($_GET['id_settore']) ? intval($_GET['id_settore']) : null;

    // Costruisci query dinamicamente in base ai filtri
    if ($id_settore) {
        // Classi di un settore specifico
        $stmt = $pdo->prepare("
            SELECT
                c.id_classe,
                c.nome_classe,
                c.id_settore,
                s.nome_settore,
                s.id_sede,
                se.nome_sede
            FROM classi c
            LEFT JOIN settori s ON c.id_settore = s.id_settore
            LEFT JOIN sedi se ON s.id_sede = se.id_sede
            WHERE c.id_settore = :id_settore
            ORDER BY c.nome_classe ASC
        ");
        $stmt->execute([':id_settore' => $id_settore]);
        $message = 'Classi del settore recuperate con successo';
    } elseif ($id_sede) {
        // Classi di tutti i settori di una sede specifica
        $stmt = $pdo->prepare("
            SELECT
                c.id_classe,
                c.nome_classe,
                c.id_settore,
                s.nome_settore,
                s.id_sede,
                se.nome_sede
            FROM classi c
            LEFT JOIN settori s ON c.id_settore = s.id_settore
            LEFT JOIN sedi se ON s.id_sede = se.id_sede
            WHERE s.id_sede = :id_sede
            ORDER BY s.nome_settore ASC, c.nome_classe ASC
        ");
        $stmt->execute([':id_sede' => $id_sede]);
        $message = 'Classi della sede recuperate con successo';
    } else {
        // Tutte le classi con gerarchia completa
        $stmt = $pdo->prepare("
            SELECT
                c.id_classe,
                c.nome_classe,
                c.id_settore,
                s.nome_settore,
                s.id_sede,
                se.nome_sede
            FROM classi c
            LEFT JOIN settori s ON c.id_settore = s.id_settore
            LEFT JOIN sedi se ON s.id_sede = se.id_sede
            ORDER BY se.nome_sede ASC, s.nome_settore ASC, c.nome_classe ASC
        ");
        $stmt->execute();
        $message = 'Tutte le classi recuperate con successo';
    }

    $classi = $stmt->fetchAll(PDO::FETCH_ASSOC);

    jsonResponse(true, $message, $classi);

} catch (PDOException $e) {
    error_log("Errore database in api_get_classi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore nel caricamento delle classi');
} catch (Exception $e) {
    error_log("Errore generale in api_get_classi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server');
}
?>