<?php
/**
 * AUTH LOGIN con AUTO-RICONOSCIMENTO AMBIENTE
 * Versione aggiornata che usa config_database.php per rilevamento automatico
 */

require_once 'config_database.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Gestione richieste OPTIONS per CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Funzione per rispondere con JSON
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'user' => $data
    ]);
    exit();
}

// Funzione per log degli accessi
function logAccess($username, $success, $ip) {
    $logFile = '../logs/access.log';
    $logDir = dirname($logFile);

    // Crea directory log se non esiste
    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $status = $success ? 'SUCCESS' : 'FAILED';
    $logEntry = "[$timestamp] LOGIN $status - User: $username - IP: $ip\n";

    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

try {
    // *** NUOVA CONFIGURAZIONE AUTO-RICONOSCIMENTO ***
    $pdo = DatabaseConfig::createConnection();
    $envInfo = DatabaseConfig::getDebugInfo();

    // Log dell'ambiente rilevato per debug
    error_log("AUTH_LOGIN - Ambiente rilevato: " . $envInfo['environment'] . " - " . $envInfo['description']);

    // Verifica metodo richiesta
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        jsonResponse(false, 'Metodo non supportato. Utilizzare POST.');
    }

    // Ottieni dati POST
    $username = trim($_POST['username'] ?? '');
    $password = trim($_POST['password'] ?? '');
    $clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    // Validazione input
    if (empty($username) || empty($password)) {
        logAccess($username, false, $clientIP);
        jsonResponse(false, 'Username e password sono obbligatori.');
    }

    // Query per verifica credenziali
    $sql = "SELECT id_registrazione, nome_registrazione, cognome_registrazione,
                   username_registrazione, password_registrazione, ruolo_registrazione,
                   stato_account
            FROM registrazioni
            WHERE username_registrazione = :username
            AND stato_account = 'attivo'";

    $stmt = $pdo->prepare($sql);
    $stmt->bindParam(':username', $username);
    $stmt->execute();

    $user = $stmt->fetch();

    if (!$user) {
        logAccess($username, false, $clientIP);
        jsonResponse(false, 'Credenziali non valide o account non attivo.');
    }

    // Verifica password (attualmente in chiaro - da migliorare con hash)
    if ($password !== $user['password_registrazione']) {
        logAccess($username, false, $clientIP);
        jsonResponse(false, 'Credenziali non valide.');
    }

    // Aggiorna ultimo accesso
    $updateSql = "UPDATE registrazioni
                  SET ultimo_accesso = :timestamp
                  WHERE id_registrazione = :id";

    $updateStmt = $pdo->prepare($updateSql);
    $updateStmt->bindParam(':timestamp', date('d/m/Y H:i:s'));
    $updateStmt->bindParam(':id', $user['id_registrazione']);
    $updateStmt->execute();

    // Log accesso riuscito
    logAccess($username, true, $clientIP);

    // Prepara risposta con informazioni ambiente per debug
    $userResponse = [
        'id' => $user['id_registrazione'],
        'nome' => $user['nome_registrazione'],
        'cognome' => $user['cognome_registrazione'],
        'username' => $user['username_registrazione'],
        'ruolo' => $user['ruolo_registrazione'],
        'stato' => $user['stato_account'],
        // Aggiungi info ambiente solo in sviluppo
        'environment_info' => $envInfo['environment'] === 'local' ? $envInfo : null
    ];

    jsonResponse(true, 'Login effettuato con successo.', $userResponse);

} catch (Exception $e) {
    error_log("AUTH_LOGIN ERROR: " . $e->getMessage());
    jsonResponse(false, 'Errore interno del server: ' . $e->getMessage());
}
?>