<?php
/**
 * API per gestione agende
 * Endpoint: /training_cognitivo/strumenti/api/agende.php
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Prova path relativi flessibili per config.php
if (file_exists(__DIR__ . '/../../../../api/config.php')) {
    require_once __DIR__ . '/../../../../api/config.php';
} elseif (file_exists(__DIR__ . '/../../../api/config.php')) {
    require_once __DIR__ . '/../../../api/config.php';
} elseif (file_exists($_SERVER['DOCUMENT_ROOT'] . '/api/config.php')) {
    require_once $_SERVER['DOCUMENT_ROOT'] . '/api/config.php';
} else {
    die(json_encode(['success' => false, 'message' => 'Config file non trovato']));
}

/**
 * Risposta JSON standardizzata
 */
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

/**
 * Ottieni data/ora italiana formattata
 */
function getItalianDateTime() {
    return date('d/m/Y H:i:s');
}

try {
    $pdo = getDbConnection();
    $action = $_GET['action'] ?? '';

    switch ($action) {

        // ============================================================
        // CREATE - Crea nuova agenda
        // ============================================================
        case 'create':
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            // Validazione
            if (empty($input['nome_agenda'])) {
                jsonResponse(false, 'Nome agenda obbligatorio');
            }
            if (empty($input['id_paziente'])) {
                jsonResponse(false, 'ID paziente obbligatorio');
            }
            if (empty($input['id_educatore'])) {
                jsonResponse(false, 'ID educatore obbligatorio');
            }

            $nome_agenda = trim($input['nome_agenda']);
            $id_paziente = (int)$input['id_paziente'];
            $id_educatore = (int)$input['id_educatore'];
            $id_agenda_parent = isset($input['id_agenda_parent']) && $input['id_agenda_parent'] !== null
                ? (int)$input['id_agenda_parent']
                : null;
            $tipo_agenda = $id_agenda_parent === null ? 'principale' : 'sottomenu';

            // Inserimento
            $sql = "INSERT INTO agende_strumenti
                    (nome_agenda, id_paziente, id_educatore, id_agenda_parent, tipo_agenda, data_creazione, stato)
                    VALUES (:nome, :id_paz, :id_edu, :id_parent, :tipo, :data, 'attiva')";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':nome' => $nome_agenda,
                ':id_paz' => $id_paziente,
                ':id_edu' => $id_educatore,
                ':id_parent' => $id_agenda_parent,
                ':tipo' => $tipo_agenda,
                ':data' => getItalianDateTime()
            ]);

            $id_agenda = $pdo->lastInsertId();

            jsonResponse(true, 'Agenda creata con successo', [
                'id_agenda' => $id_agenda,
                'nome_agenda' => $nome_agenda,
                'tipo_agenda' => $tipo_agenda
            ]);
            break;

        // ============================================================
        // LIST - Lista agende di un paziente
        // ============================================================
        case 'list':
            if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_paziente = isset($_GET['id_paziente']) ? (int)$_GET['id_paziente'] : null;
            $id_agenda_parent = isset($_GET['id_agenda_parent']) ? (int)$_GET['id_agenda_parent'] : null;
            $solo_principali = isset($_GET['solo_principali']) && $_GET['solo_principali'] === 'true';

            if ($id_paziente === null) {
                jsonResponse(false, 'ID paziente obbligatorio');
            }

            // Query base
            $sql = "SELECT a.*,
                           p.nome_paziente, p.cognome_paziente,
                           e.nome as nome_educatore, e.cognome as cognome_educatore
                    FROM agende_strumenti a
                    LEFT JOIN pazienti p ON a.id_paziente = p.id_paziente
                    LEFT JOIN educatori e ON a.id_educatore = e.id_educatore
                    WHERE a.id_paziente = :id_paziente
                    AND a.stato = 'attiva'";

            if ($solo_principali) {
                $sql .= " AND a.id_agenda_parent IS NULL";
            } elseif ($id_agenda_parent !== null) {
                $sql .= " AND a.id_agenda_parent = :id_parent";
            }

            $sql .= " ORDER BY a.tipo_agenda DESC, a.data_creazione DESC";

            $stmt = $pdo->prepare($sql);
            $params = [':id_paziente' => $id_paziente];
            if (!$solo_principali && $id_agenda_parent !== null) {
                $params[':id_parent'] = $id_agenda_parent;
            }
            $stmt->execute($params);

            $agende = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Conta item per ogni agenda
            foreach ($agende as &$agenda) {
                $stmt_count = $pdo->prepare("SELECT COUNT(*) as count FROM agende_items WHERE id_agenda = :id AND stato = 'attivo'");
                $stmt_count->execute([':id' => $agenda['id_agenda']]);
                $agenda['num_items'] = (int)$stmt_count->fetch(PDO::FETCH_ASSOC)['count'];
            }

            jsonResponse(true, 'Agende recuperate con successo', $agende);
            break;

        // ============================================================
        // GET - Dettagli singola agenda
        // ============================================================
        case 'get':
            if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_agenda = isset($_GET['id_agenda']) ? (int)$_GET['id_agenda'] : null;

            if ($id_agenda === null) {
                jsonResponse(false, 'ID agenda obbligatorio');
            }

            $sql = "SELECT a.*,
                           p.nome_paziente, p.cognome_paziente,
                           e.nome as nome_educatore, e.cognome as cognome_educatore
                    FROM agende_strumenti a
                    LEFT JOIN pazienti p ON a.id_paziente = p.id_paziente
                    LEFT JOIN educatori e ON a.id_educatore = e.id_educatore
                    WHERE a.id_agenda = :id";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([':id' => $id_agenda]);
            $agenda = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$agenda) {
                jsonResponse(false, 'Agenda non trovata');
            }

            // Conta item
            $stmt_count = $pdo->prepare("SELECT COUNT(*) as count FROM agende_items WHERE id_agenda = :id AND stato = 'attivo'");
            $stmt_count->execute([':id' => $id_agenda]);
            $agenda['num_items'] = (int)$stmt_count->fetch(PDO::FETCH_ASSOC)['count'];

            jsonResponse(true, 'Agenda recuperata con successo', $agenda);
            break;

        // ============================================================
        // UPDATE - Aggiorna agenda
        // ============================================================
        case 'update':
            if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_agenda = isset($_GET['id_agenda']) ? (int)$_GET['id_agenda'] : null;
            if ($id_agenda === null) {
                jsonResponse(false, 'ID agenda obbligatorio');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            if (empty($input['nome_agenda'])) {
                jsonResponse(false, 'Nome agenda obbligatorio');
            }

            $sql = "UPDATE agende_strumenti SET nome_agenda = :nome WHERE id_agenda = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':nome' => trim($input['nome_agenda']),
                ':id' => $id_agenda
            ]);

            jsonResponse(true, 'Agenda aggiornata con successo');
            break;

        // ============================================================
        // DELETE - Elimina agenda (soft delete)
        // ============================================================
        case 'delete':
            if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_agenda = isset($_GET['id_agenda']) ? (int)$_GET['id_agenda'] : null;
            if ($id_agenda === null) {
                jsonResponse(false, 'ID agenda obbligatorio');
            }

            // Soft delete (cambia stato)
            $sql = "UPDATE agende_strumenti SET stato = 'archiviata' WHERE id_agenda = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([':id' => $id_agenda]);

            // Archivia anche tutti gli item
            $sql_items = "UPDATE agende_items SET stato = 'archiviato' WHERE id_agenda = :id";
            $stmt_items = $pdo->prepare($sql_items);
            $stmt_items->execute([':id' => $id_agenda]);

            jsonResponse(true, 'Agenda eliminata con successo');
            break;

        // ============================================================
        // DEFAULT - Azione non riconosciuta
        // ============================================================
        default:
            jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore Database agende.php: " . $e->getMessage());
    jsonResponse(false, 'Errore database: ' . $e->getMessage());
} catch (Exception $e) {
    error_log("Errore generico agende.php: " . $e->getMessage());
    jsonResponse(false, 'Errore: ' . $e->getMessage());
}
