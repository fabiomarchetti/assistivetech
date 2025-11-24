<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Gestione richieste OPTIONS per CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurazione database tramite DatabaseConfig
require_once 'config_database.php';

// Funzione per rispondere con JSON
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Funzione per log delle operazioni
function logOperation($action, $details, $ip) {
    $logFile = '../logs/settori_classi.log';
    $logDir = dirname($logFile);

    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $action - $details - IP: $ip\n";

    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

try {
    // Connessione al database tramite DatabaseConfig
    $pdo = DatabaseConfig::createConnection();

    // Leggi i dati JSON dalla richiesta
    $input = json_decode(file_get_contents('php://input'), true);
    $action = $input['action'] ?? $_GET['action'] ?? '';
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    // ===================== GESTIONE SETTORI =====================
    if ($action === 'get_settori') {
        // Recupera settori, opzionalmente filtrati per sede
        $id_sede = intval($input['id_sede'] ?? $_GET['id_sede'] ?? 0);

        $where_clause = '';
        $params = [];

        if ($id_sede > 0) {
            $where_clause = 'WHERE s.id_sede = :id_sede';
            $params[':id_sede'] = $id_sede;
        }

        $stmt = $pdo->prepare("
            SELECT
                s.id_settore,
                s.nome_settore as nome,
                s.descrizione,
                s.id_sede,
                se.nome_sede,
                (
                    SELECT COUNT(*) FROM educatori e WHERE e.id_settore = s.id_settore
                ) + (
                    SELECT COUNT(*) FROM pazienti p WHERE p.id_settore = s.id_settore
                ) as utilizzo
            FROM settori s
            LEFT JOIN sedi se ON s.id_sede = se.id_sede
            $where_clause
            ORDER BY se.nome_sede ASC, s.nome_settore ASC
        ");
        $stmt->execute($params);
        $settori = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Settori recuperati con successo', $settori);

    // ===================== GESTIONE CLASSI =====================
    } elseif ($action === 'get_classi') {
        // Recupera classi, opzionalmente filtrate per settore
        $id_settore = intval($input['id_settore'] ?? $_GET['id_settore'] ?? 0);

        $where_clause = '';
        $params = [];

        if ($id_settore > 0) {
            $where_clause = 'WHERE c.id_settore = :id_settore';
            $params[':id_settore'] = $id_settore;
        }

        // Query semplificata senza subquery COUNT che potrebbero causare errori
        $stmt = $pdo->prepare("
            SELECT
                c.id_classe,
                c.nome_classe as nome,
                c.descrizione,
                s.nome_settore as settore,
                c.id_settore,
                0 as utilizzo
            FROM classi c
            LEFT JOIN settori s ON c.id_settore = s.id_settore
            $where_clause
            ORDER BY s.nome_settore, c.nome_classe
        ");
        $stmt->execute($params);
        $classi = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Classi recuperate con successo', $classi);

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_settori_classi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in api_settori_classi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>