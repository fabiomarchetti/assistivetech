<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
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
$database = 'Sql1073852_1'; // Utilizzando il primo database disponibile

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
    // Connessione al database
    $pdo = new PDO("mysql:host=$host;dbname=$database;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Leggi i dati JSON dalla richiesta
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['action'])) {
        jsonResponse(false, 'Azione non specificata');
    }

    $action = $input['action'];

    if ($action === 'login') {
        $user_username = $input['username'] ?? '';
        $user_password = $input['password'] ?? '';

        if (empty($user_username) || empty($user_password)) {
            jsonResponse(false, 'Username e password sono obbligatori');
        }

        // Ottieni indirizzo IP per log
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

        // Cerca l'utente nel database
        $stmt = $pdo->prepare("
            SELECT id_registrazione, nome_registrazione, cognome_registrazione,
                   username_registrazione, password_registrazione, ruolo_registrazione,
                   data_registrazione
            FROM registrazioni
            WHERE username_registrazione = :username AND password_registrazione = :password
        ");

        $stmt->execute([
            ':username' => $user_username,
            ':password' => $user_password
        ]);

        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user) {
            // Login riuscito
            logAccess($user_username, true, $ip);

            // Aggiorna timestamp ultimo accesso in formato italiano
            $updateStmt = $pdo->prepare("
                UPDATE registrazioni
                SET ultimo_accesso = DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')
                WHERE id_registrazione = :id
            ");
            $updateStmt->execute([':id' => $user['id_registrazione']]);

            jsonResponse(true, 'Login effettuato con successo', $user);
        } else {
            // Credenziali non valide
            logAccess($user_username, false, $ip);
            jsonResponse(false, 'Username o password non corretti');
        }
    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    // Log errore database
    error_log("Errore database in auth_login.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    // Log errore generico
    error_log("Errore generale in auth_login.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>