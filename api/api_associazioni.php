<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
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
    ]);
    exit();
}

// Funzione per log delle operazioni
function logOperation($action, $details, $ip) {
    $logFile = '../logs/associazioni.log';
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

    if ($action === 'get_associazioni') {
        // Recupera tutte le associazioni educatori-pazienti attive
        $calling_user_role = $input['calling_user_role'] ?? '';
        $calling_user_sede = intval($input['calling_user_sede'] ?? 0);

        $where_clause = '';
        $params = [];

        // Filtro per sede se non è sviluppatore
        if ($calling_user_role !== 'sviluppatore') {
            $where_clause = 'AND e.id_sede = :sede AND p.id_sede = :sede';
            $params[':sede'] = $calling_user_sede;
        }

        $stmt = $pdo->prepare("
            SELECT
                ep.id_associazione,
                ep.id_educatore,
                ep.id_paziente,
                ep.data_associazione,
                ep.is_attiva,
                ep.note,
                e.nome as educatore_nome,
                e.cognome as educatore_cognome,
                reg_edu.username_registrazione as educatore_username,
                reg_paz.nome_registrazione as paziente_nome,
                reg_paz.cognome_registrazione as paziente_cognome,
                reg_paz.username_registrazione as paziente_username,
                s.nome_sede,
                st.nome_settore,
                c.nome_classe
            FROM educatori_pazienti ep
            JOIN educatori e ON ep.id_educatore = e.id_educatore
            JOIN pazienti p ON ep.id_paziente = p.id_paziente
            JOIN registrazioni reg_edu ON e.id_registrazione = reg_edu.id_registrazione
            JOIN registrazioni reg_paz ON p.id_registrazione = reg_paz.id_registrazione
            LEFT JOIN sedi s ON e.id_sede = s.id_sede
            LEFT JOIN settori st ON e.id_settore = st.id_settore
            LEFT JOIN classi c ON e.id_classe = c.id_classe
            WHERE ep.is_attiva = 1 $where_clause
            ORDER BY e.cognome, e.nome, reg_paz.cognome_registrazione
        ");

        $stmt->execute($params);
        $associazioni = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Associazioni recuperate con successo', $associazioni);

    } elseif ($action === 'create_associazione') {
        // Crea nuova associazione educatore-paziente
        $id_educatore = intval($input['id_educatore'] ?? 0);
        $id_paziente = intval($input['id_paziente'] ?? 0);
        $note = trim($input['note'] ?? '');
        $calling_user_role = $input['calling_user_role'] ?? '';
        $calling_user_sede = intval($input['calling_user_sede'] ?? 0);

        // Validazioni
        if ($id_educatore <= 0 || $id_paziente <= 0) {
            jsonResponse(false, 'ID educatore e paziente sono obbligatori');
        }

        // Controllo permessi: solo sviluppatore e amministratori
        if (!in_array($calling_user_role, ['sviluppatore', 'amministratore'])) {
            jsonResponse(false, 'Solo sviluppatori e amministratori possono creare associazioni');
        }

        // Verifica che educatore e paziente esistano nella stessa sede (se admin)
        if ($calling_user_role === 'amministratore') {
            $stmt_check = $pdo->prepare("
                SELECT e.id_sede as educatore_sede, p.id_sede as paziente_sede
                FROM educatori e, pazienti p
                WHERE e.id_educatore = :id_educatore AND p.id_paziente = :id_paziente
            ");
            $stmt_check->execute([
                ':id_educatore' => $id_educatore,
                ':id_paziente' => $id_paziente
            ]);
            $sede_check = $stmt_check->fetch(PDO::FETCH_ASSOC);

            if (!$sede_check) {
                jsonResponse(false, 'Educatore o paziente non trovato');
            }

            if ($sede_check['educatore_sede'] !== $calling_user_sede ||
                $sede_check['paziente_sede'] !== $calling_user_sede) {
                jsonResponse(false, 'Puoi associare solo educatori e pazienti della tua sede');
            }
        }

        // Verifica se esiste già un'associazione attiva
        $stmt_existing = $pdo->prepare("
            SELECT id_associazione
            FROM educatori_pazienti
            WHERE id_educatore = :id_educatore AND id_paziente = :id_paziente AND is_attiva = 1
        ");
        $stmt_existing->execute([
            ':id_educatore' => $id_educatore,
            ':id_paziente' => $id_paziente
        ]);

        if ($stmt_existing->fetch()) {
            jsonResponse(false, 'Associazione già esistente tra questo educatore e paziente');
        }

        // Crea l'associazione
        $stmt = $pdo->prepare("
            INSERT INTO educatori_pazienti (id_educatore, id_paziente, data_associazione, note)
            VALUES (:id_educatore, :id_paziente, DATE_FORMAT(NOW(), '%d/%m/%Y'), :note)
        ");

        $result = $stmt->execute([
            ':id_educatore' => $id_educatore,
            ':id_paziente' => $id_paziente,
            ':note' => $note
        ]);

        if ($result) {
            logOperation('CREATE_ASSOCIATION', "Educatore: $id_educatore, Paziente: $id_paziente", $ip);
            jsonResponse(true, 'Associazione creata con successo');
        } else {
            jsonResponse(false, 'Errore nella creazione dell\'associazione');
        }

    } elseif ($action === 'delete_associazione') {
        // Elimina associazione (disattiva)
        $id_associazione = intval($input['id_associazione'] ?? 0);
        $calling_user_role = $input['calling_user_role'] ?? '';

        if ($id_associazione <= 0) {
            jsonResponse(false, 'ID associazione obbligatorio');
        }

        // Controllo permessi: solo sviluppatore e amministratori
        if (!in_array($calling_user_role, ['sviluppatore', 'amministratore'])) {
            jsonResponse(false, 'Solo sviluppatori e amministratori possono eliminare associazioni');
        }

        // Disattiva l'associazione invece di eliminarla
        $stmt = $pdo->prepare("
            UPDATE educatori_pazienti
            SET is_attiva = 0
            WHERE id_associazione = :id_associazione
        ");

        $result = $stmt->execute([':id_associazione' => $id_associazione]);

        if ($result) {
            logOperation('DELETE_ASSOCIATION', "ID: $id_associazione", $ip);
            jsonResponse(true, 'Associazione eliminata con successo');
        } else {
            jsonResponse(false, 'Errore nell\'eliminazione dell\'associazione');
        }

    } elseif ($action === 'get_educatori_disponibili') {
        // Recupera educatori disponibili per associazioni
        $calling_user_sede = intval($input['calling_user_sede'] ?? 0);
        $calling_user_role = $input['calling_user_role'] ?? '';

        $where_clause = '';
        $params = [];

        if ($calling_user_role !== 'sviluppatore') {
            $where_clause = 'WHERE e.id_sede = :sede';
            $params[':sede'] = $calling_user_sede;
        }

        $stmt = $pdo->prepare("
            SELECT
                e.id_educatore,
                e.nome,
                e.cognome,
                r.username_registrazione,
                s.nome_sede,
                st.nome_settore,
                c.nome_classe
            FROM educatori e
            JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
            LEFT JOIN sedi s ON e.id_sede = s.id_sede
            LEFT JOIN settori st ON e.id_settore = st.id_settore
            LEFT JOIN classi c ON e.id_classe = c.id_classe
            $where_clause
            ORDER BY e.cognome, e.nome
        ");

        $stmt->execute($params);
        $educatori = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Educatori recuperati con successo', $educatori);

    } elseif ($action === 'get_pazienti_disponibili') {
        // Recupera pazienti disponibili per associazioni
        $calling_user_sede = intval($input['calling_user_sede'] ?? 0);
        $calling_user_role = $input['calling_user_role'] ?? '';

        $where_clause = '';
        $params = [];

        if ($calling_user_role !== 'sviluppatore') {
            $where_clause = 'WHERE p.id_sede = :sede';
            $params[':sede'] = $calling_user_sede;
        }

        $stmt = $pdo->prepare("
            SELECT
                p.id_paziente,
                r.nome_registrazione as nome,
                r.cognome_registrazione as cognome,
                r.username_registrazione,
                s.nome_sede,
                st.nome_settore,
                c.nome_classe
            FROM pazienti p
            JOIN registrazioni r ON p.id_registrazione = r.id_registrazione
            LEFT JOIN sedi s ON p.id_sede = s.id_sede
            LEFT JOIN settori st ON p.id_settore = st.id_settore
            LEFT JOIN classi c ON p.id_classe = c.id_classe
            $where_clause
            ORDER BY r.cognome_registrazione, r.nome_registrazione
        ");

        $stmt->execute($params);
        $pazienti = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Pazienti recuperati con successo', $pazienti);

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_associazioni.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in api_associazioni.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}