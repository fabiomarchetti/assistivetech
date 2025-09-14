<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
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
        'sedi' => $data
    ]);
    exit();
}

try {
    // Connessione al database
    $pdo = new PDO("mysql:host=$host;dbname=$database;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Leggi i dati JSON dalla richiesta
    $input = json_decode(file_get_contents('php://input'), true);

    // Se è una richiesta GET, restituisci tutte le sedi
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $stmt = $pdo->prepare("
            SELECT id_sede, nome_sede, indirizzo, citta, provincia, cap,
                   telefono, email, stato_sede, data_creazione
            FROM sedi
            WHERE stato_sede IN ('attiva', 'sospesa')
            ORDER BY nome_sede
        ");
        $stmt->execute();
        $sedi = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Sedi recuperate con successo', $sedi);
    }

    // Se è una richiesta POST per creare/aggiornare sede
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $input) {
        $action = $input['action'] ?? 'create';

        if ($action === 'create') {
            $nome_sede = trim($input['nome_sede'] ?? '');
            $indirizzo = trim($input['indirizzo'] ?? '');
            $citta = trim($input['citta'] ?? '');
            $provincia = strtoupper(trim($input['provincia'] ?? ''));
            $cap = trim($input['cap'] ?? '');
            $telefono = trim($input['telefono'] ?? '');
            $email = trim($input['email'] ?? '');

            if (empty($nome_sede)) {
                jsonResponse(false, 'Il nome della sede è obbligatorio');
            }

            // Verifica che il nome sede non esista già
            $stmt = $pdo->prepare("SELECT id_sede FROM sedi WHERE nome_sede = :nome_sede");
            $stmt->execute([':nome_sede' => $nome_sede]);
            if ($stmt->fetch()) {
                jsonResponse(false, 'Esiste già una sede con questo nome');
            }

            // Inserisci nuova sede
            $stmt = $pdo->prepare("
                INSERT INTO sedi (nome_sede, indirizzo, citta, provincia, cap, telefono, email, data_creazione)
                VALUES (:nome_sede, :indirizzo, :citta, :provincia, :cap, :telefono, :email, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
            ");

            $result = $stmt->execute([
                ':nome_sede' => $nome_sede,
                ':indirizzo' => $indirizzo,
                ':citta' => $citta,
                ':provincia' => $provincia,
                ':cap' => $cap,
                ':telefono' => $telefono,
                ':email' => $email
            ]);

            if ($result) {
                jsonResponse(true, 'Sede creata con successo');
            } else {
                jsonResponse(false, 'Errore nella creazione della sede');
            }

        } elseif ($action === 'update') {
            $id_sede = intval($input['id_sede'] ?? 0);
            $nome_sede = trim($input['nome_sede'] ?? '');
            $indirizzo = trim($input['indirizzo'] ?? '');
            $citta = trim($input['citta'] ?? '');
            $provincia = strtoupper(trim($input['provincia'] ?? ''));
            $cap = trim($input['cap'] ?? '');
            $telefono = trim($input['telefono'] ?? '');
            $email = trim($input['email'] ?? '');

            if (empty($id_sede) || empty($nome_sede)) {
                jsonResponse(false, 'ID sede e nome sono obbligatori');
            }

            // Verifica che la sede esista
            $stmt = $pdo->prepare("SELECT id_sede FROM sedi WHERE id_sede = :id_sede");
            $stmt->execute([':id_sede' => $id_sede]);
            if (!$stmt->fetch()) {
                jsonResponse(false, 'Sede non trovata');
            }

            // Verifica che il nome sede non sia già utilizzato da un'altra sede
            $stmt = $pdo->prepare("SELECT id_sede FROM sedi WHERE nome_sede = :nome_sede AND id_sede != :id_sede");
            $stmt->execute([':nome_sede' => $nome_sede, ':id_sede' => $id_sede]);
            if ($stmt->fetch()) {
                jsonResponse(false, 'Esiste già una sede con questo nome');
            }

            // Aggiorna la sede
            $stmt = $pdo->prepare("
                UPDATE sedi SET
                    nome_sede = :nome_sede,
                    indirizzo = :indirizzo,
                    citta = :citta,
                    provincia = :provincia,
                    cap = :cap,
                    telefono = :telefono,
                    email = :email
                WHERE id_sede = :id_sede
            ");

            $result = $stmt->execute([
                ':id_sede' => $id_sede,
                ':nome_sede' => $nome_sede,
                ':indirizzo' => $indirizzo,
                ':citta' => $citta,
                ':provincia' => $provincia,
                ':cap' => $cap,
                ':telefono' => $telefono,
                ':email' => $email
            ]);

            if ($result) {
                jsonResponse(true, 'Sede aggiornata con successo');
            } else {
                jsonResponse(false, 'Errore nell\'aggiornamento della sede');
            }
        }
    }

} catch (PDOException $e) {
    error_log("Errore database in api_sedi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in api_sedi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>