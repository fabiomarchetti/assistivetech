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
$database = 'Sql1073852_1';

// Funzione per rispondere con JSON
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'registrazioni' => $data
    ]);
    exit();
}

// Funzione per validare email
function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

// Funzione per hash password (per versioni future)
function hashPassword($password) {
    // Per ora manteniamo password in chiaro per compatibilità
    // In futuro: return password_hash($password, PASSWORD_DEFAULT);
    return $password;
}

// Funzione per log delle operazioni
function logOperation($action, $username, $ip) {
    $logFile = '../logs/registrations.log';
    $logDir = dirname($logFile);

    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $action - User: $username - IP: $ip\n";

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
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    if ($action === 'get_all') {
        // Recupera tutte le registrazioni (solo per amministratori)
        $stmt = $pdo->prepare("
            SELECT id_registrazione, nome_registrazione, cognome_registrazione,
                   username_registrazione, ruolo_registrazione, data_registrazione,
                   ultimo_accesso
            FROM registrazioni
            ORDER BY data_registrazione DESC
        ");
        $stmt->execute();
        $registrazioni = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Registrazioni recuperate con successo', $registrazioni);

    } elseif ($action === 'create') {
        // Crea nuova registrazione
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $user_username = trim($input['username'] ?? '');
        $user_password = $input['password'] ?? '';
        $ruolo = $input['ruolo'] ?? '';
        $settore = trim($input['settore'] ?? '');
        $classe = trim($input['classe'] ?? '');
        $id_sede = intval($input['id_sede'] ?? 1); // Default alla sede principale

        // Validazioni
        if (empty($nome) || empty($cognome) || empty($user_username) || empty($user_password) || empty($ruolo)) {
            jsonResponse(false, 'Tutti i campi sono obbligatori');
        }

        if (strlen($nome) < 2 || strlen($cognome) < 2) {
            jsonResponse(false, 'Nome e cognome devono avere almeno 2 caratteri');
        }

        if (strlen($user_password) < 6) {
            jsonResponse(false, 'La password deve avere almeno 6 caratteri');
        }

        if (strpos($user_username, '@') !== false && !validateEmail($user_username)) {
            jsonResponse(false, 'Formato email non valido');
        }

        // Verifica che il ruolo sia valido
        $ruoli_validi = ['amministratore', 'educatore', 'paziente'];
        if (!in_array($ruolo, $ruoli_validi)) {
            jsonResponse(false, 'Ruolo non valido');
        }

        // Verifica che l'username non esista già
        $stmt = $pdo->prepare("SELECT id_registrazione FROM registrazioni WHERE username_registrazione = :username");
        $stmt->execute([':username' => $user_username]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Username già esistente. Scegli un altro username o email.');
        }

        // Hash password
        $hashedPassword = hashPassword($user_password);

        // Inizia transazione
        $pdo->beginTransaction();

        try {
            // Inserisci nuova registrazione
            $stmt = $pdo->prepare("
                INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione,
                                         password_registrazione, ruolo_registrazione, data_registrazione)
                VALUES (:nome, :cognome, :username, :password, :ruolo, DATE_FORMAT(NOW(), '%d/%m/%Y'))
            ");

            $result = $stmt->execute([
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':username' => $user_username,
                ':password' => $hashedPassword,
                ':ruolo' => $ruolo
            ]);

            if (!$result) {
                throw new Exception('Errore inserimento registrazione');
            }

            // Se il ruolo è educatore o paziente, inserisci anche nella tabella specifica
            $id_registrazione = $pdo->lastInsertId();

            if ($ruolo === 'educatore') {
                $stmt_educatore = $pdo->prepare("
                    INSERT INTO educatori (id_registrazione, nome, cognome, settore, classe, id_sede, data_creazione)
                    VALUES (:id_registrazione, :nome, :cognome, :settore, :classe, :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
                ");

                $result_educatore = $stmt_educatore->execute([
                    ':id_registrazione' => $id_registrazione,
                    ':nome' => $nome,
                    ':cognome' => $cognome,
                    ':settore' => $settore,
                    ':classe' => $classe,
                    ':id_sede' => $id_sede
                ]);

                if (!$result_educatore) {
                    throw new Exception('Errore creazione profilo educatore');
                }

            } elseif ($ruolo === 'paziente') {
                $stmt_paziente = $pdo->prepare("
                    INSERT INTO pazienti (id_registrazione, nome, cognome, settore, classe, id_sede, data_creazione)
                    VALUES (:id_registrazione, :nome, :cognome, :settore, :classe, :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
                ");

                $result_paziente = $stmt_paziente->execute([
                    ':id_registrazione' => $id_registrazione,
                    ':nome' => $nome,
                    ':cognome' => $cognome,
                    ':settore' => $settore,
                    ':classe' => $classe,
                    ':id_sede' => $id_sede
                ]);

                if (!$result_paziente) {
                    throw new Exception('Errore creazione profilo paziente');
                }
            }

            // Commit transazione
            $pdo->commit();

            logOperation('CREATE_USER', $user_username, $ip);
            jsonResponse(true, 'Registrazione creata con successo');

        } catch (Exception $e) {
            // Rollback in caso di errore
            $pdo->rollBack();
            jsonResponse(false, $e->getMessage());
        }

    } elseif ($action === 'update') {
        // Aggiorna registrazione esistente
        $id = $input['id'] ?? '';
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $user_username = trim($input['username'] ?? '');
        $user_password = $input['password'] ?? '';
        $ruolo = $input['ruolo'] ?? '';

        if (empty($id) || empty($nome) || empty($cognome) || empty($user_username) || empty($user_password) || empty($ruolo)) {
            jsonResponse(false, 'Tutti i campi sono obbligatori');
        }

        // Validazioni
        if (strlen($nome) < 2 || strlen($cognome) < 2) {
            jsonResponse(false, 'Nome e cognome devono avere almeno 2 caratteri');
        }

        if (strlen($user_password) < 6) {
            jsonResponse(false, 'La password deve avere almeno 6 caratteri');
        }

        // Verifica che il ruolo sia valido
        $ruoli_validi = ['amministratore', 'educatore', 'paziente'];
        if (!in_array($ruolo, $ruoli_validi)) {
            jsonResponse(false, 'Ruolo non valido');
        }

        // Verifica che l'username non sia già utilizzato da un altro utente
        $stmt = $pdo->prepare("SELECT id_registrazione FROM registrazioni WHERE username_registrazione = :username AND id_registrazione != :id");
        $stmt->execute([':username' => $user_username, ':id' => $id]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Username già utilizzato da un altro utente');
        }

        // Hash password
        $hashedPassword = hashPassword($user_password);

        // Aggiorna la registrazione
        $stmt = $pdo->prepare("
            UPDATE registrazioni
            SET nome_registrazione = :nome,
                cognome_registrazione = :cognome,
                username_registrazione = :username,
                password_registrazione = :password,
                ruolo_registrazione = :ruolo
            WHERE id_registrazione = :id
        ");

        $result = $stmt->execute([
            ':id' => $id,
            ':nome' => $nome,
            ':cognome' => $cognome,
            ':username' => $user_username,
            ':password' => $hashedPassword,
            ':ruolo' => $ruolo
        ]);

        if ($result) {
            logOperation('UPDATE_USER', $user_username, $ip);
            jsonResponse(true, 'Registrazione aggiornata con successo');
        } else {
            jsonResponse(false, 'Errore nell\'aggiornamento della registrazione');
        }

    } elseif ($action === 'delete') {
        // Elimina registrazione
        $id = $input['id'] ?? '';

        if (empty($id)) {
            jsonResponse(false, 'ID registrazione non specificato');
        }

        // Ottieni username per log prima di eliminare
        $stmt = $pdo->prepare("SELECT username_registrazione FROM registrazioni WHERE id_registrazione = :id");
        $stmt->execute([':id' => $id]);
        $user_data = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user_data) {
            jsonResponse(false, 'Registrazione non trovata');
        }

        $stmt = $pdo->prepare("DELETE FROM registrazioni WHERE id_registrazione = :id");
        $result = $stmt->execute([':id' => $id]);

        if ($result) {
            logOperation('DELETE_USER', $user_data['username_registrazione'], $ip);
            jsonResponse(true, 'Registrazione eliminata con successo');
        } else {
            jsonResponse(false, 'Errore nell\'eliminazione della registrazione');
        }

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in auth_registrazioni.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in auth_registrazioni.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>