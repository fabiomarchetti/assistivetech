<?php
/**
 * API per gestione pagine del Comunicatore
 * Endpoint: /training_cognitivo/strumenti/comunicatore/api/pagine.php
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

// Path config flessibile per local e server
if (file_exists(__DIR__ . '/../../../../api/config.php')) {
    require_once __DIR__ . '/../../../../api/config.php';
} elseif (file_exists(__DIR__ . '/../../../api/config.php')) {
    require_once __DIR__ . '/../../../api/config.php';
} elseif (file_exists($_SERVER['DOCUMENT_ROOT'] . '/api/config.php')) {
    require_once $_SERVER['DOCUMENT_ROOT'] . '/api/config.php';
} else {
    die(json_encode(['success' => false, 'error' => 'Config file not found']));
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
        // CREATE - Crea nuova pagina
        // ============================================================
        case 'create':
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            // Validazione
            if (empty($input['nome_pagina'])) {
                jsonResponse(false, 'Nome pagina obbligatorio');
            }
            if (empty($input['id_paziente'])) {
                jsonResponse(false, 'ID paziente obbligatorio');
            }
            if (empty($input['id_educatore'])) {
                jsonResponse(false, 'ID educatore obbligatorio');
            }

            $nome_pagina = trim($input['nome_pagina']);
            $id_paziente = (int)$input['id_paziente'];
            $id_educatore = (int)$input['id_educatore'];
            $descrizione = $input['descrizione'] ?? '';

            // Calcola prossimo numero ordine
            $stmt_ord = $pdo->prepare("SELECT COALESCE(MAX(numero_ordine), -1) + 1 as next_ord FROM comunicatore_pagine WHERE id_paziente = :id_paz");
            $stmt_ord->execute([':id_paz' => $id_paziente]);
            $numero_ordine = (int)$stmt_ord->fetch(PDO::FETCH_ASSOC)['next_ord'];

            // Inserimento
            $sql = "INSERT INTO comunicatore_pagine
                    (nome_pagina, descrizione, id_paziente, id_educatore, numero_ordine, data_creazione, stato)
                    VALUES (:nome, :desc, :id_paz, :id_edu, :ordine, :data, 'attiva')";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':nome' => $nome_pagina,
                ':desc' => $descrizione,
                ':id_paz' => $id_paziente,
                ':id_edu' => $id_educatore,
                ':ordine' => $numero_ordine,
                ':data' => getItalianDateTime()
            ]);

            $id_pagina = $pdo->lastInsertId();

            jsonResponse(true, 'Pagina creata con successo', [
                'id_pagina' => $id_pagina,
                'nome_pagina' => $nome_pagina,
                'numero_ordine' => $numero_ordine
            ]);
            break;

        // ============================================================
        // LIST - Lista pagine di un paziente
        // ============================================================
        case 'list':
            $id_paziente = $_GET['id_paziente'] ?? null;

            if (!$id_paziente) {
                jsonResponse(false, 'ID paziente obbligatorio');
            }

            $sql = "SELECT 
                        p.*,
                        COUNT(i.id_item) as num_items
                    FROM comunicatore_pagine p
                    LEFT JOIN comunicatore_items i ON p.id_pagina = i.id_pagina AND i.stato = 'attivo'
                    WHERE p.id_paziente = :id_paz AND p.stato = 'attiva'
                    GROUP BY p.id_pagina
                    ORDER BY p.numero_ordine ASC";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([':id_paz' => (int)$id_paziente]);
            $pagine = $stmt->fetchAll(PDO::FETCH_ASSOC);

            jsonResponse(true, 'Pagine caricate', $pagine);
            break;

        // ============================================================
        // GET - Dettaglio singola pagina con items
        // ============================================================
        case 'get':
            $id_pagina = $_GET['id_pagina'] ?? null;

            if (!$id_pagina) {
                jsonResponse(false, 'ID pagina obbligatorio');
            }

            // Dati pagina
            $stmt_pag = $pdo->prepare("SELECT * FROM comunicatore_pagine WHERE id_pagina = :id");
            $stmt_pag->execute([':id' => (int)$id_pagina]);
            $pagina = $stmt_pag->fetch(PDO::FETCH_ASSOC);

            if (!$pagina) {
                jsonResponse(false, 'Pagina non trovata');
            }

            // Items della pagina (ordinati per posizione)
            $stmt_items = $pdo->prepare("
                SELECT * FROM comunicatore_items 
                WHERE id_pagina = :id_pag AND stato = 'attivo'
                ORDER BY posizione_griglia ASC
            ");
            $stmt_items->execute([':id_pag' => (int)$id_pagina]);
            $items = $stmt_items->fetchAll(PDO::FETCH_ASSOC);

            $pagina['items'] = $items;

            jsonResponse(true, 'Pagina caricata', $pagina);
            break;

        // ============================================================
        // UPDATE - Modifica pagina
        // ============================================================
        case 'update':
            if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            if (empty($input['id_pagina'])) {
                jsonResponse(false, 'ID pagina obbligatorio');
            }

            $id_pagina = (int)$input['id_pagina'];
            $nome_pagina = isset($input['nome_pagina']) ? trim($input['nome_pagina']) : null;
            $descrizione = isset($input['descrizione']) ? trim($input['descrizione']) : null;
            $numero_ordine = isset($input['numero_ordine']) ? (int)$input['numero_ordine'] : null;

            // Costruisci query dinamica
            $updates = [];
            $params = [':id' => $id_pagina];

            if ($nome_pagina !== null) {
                $updates[] = "nome_pagina = :nome";
                $params[':nome'] = $nome_pagina;
            }
            if ($descrizione !== null) {
                $updates[] = "descrizione = :desc";
                $params[':desc'] = $descrizione;
            }
            if ($numero_ordine !== null) {
                $updates[] = "numero_ordine = :ordine";
                $params[':ordine'] = $numero_ordine;
            }

            if (empty($updates)) {
                jsonResponse(false, 'Nessun campo da aggiornare');
            }

            $updates[] = "data_modifica = :data_mod";
            $params[':data_mod'] = getItalianDateTime();

            $sql = "UPDATE comunicatore_pagine SET " . implode(', ', $updates) . " WHERE id_pagina = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);

            jsonResponse(true, 'Pagina aggiornata con successo');
            break;

        // ============================================================
        // DELETE - Elimina pagina (e tutti gli items)
        // ============================================================
        case 'delete':
            if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_pagina = $_GET['id_pagina'] ?? null;

            if (!$id_pagina) {
                jsonResponse(false, 'ID pagina obbligatorio');
            }

            // Soft delete
            $stmt = $pdo->prepare("UPDATE comunicatore_pagine SET stato = 'archiviata' WHERE id_pagina = :id");
            $stmt->execute([':id' => (int)$id_pagina]);

            jsonResponse(true, 'Pagina eliminata con successo');
            break;

        // ============================================================
        // REORDER - Riordina pagine
        // ============================================================
        case 'reorder':
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            if (empty($input['ordini']) || !is_array($input['ordini'])) {
                jsonResponse(false, 'Array ordini obbligatorio');
            }

            // Aggiorna ogni pagina con il nuovo ordine
            $stmt = $pdo->prepare("UPDATE comunicatore_pagine SET numero_ordine = :ordine WHERE id_pagina = :id");

            foreach ($input['ordini'] as $item) {
                $stmt->execute([
                    ':id' => (int)$item['id_pagina'],
                    ':ordine' => (int)$item['numero_ordine']
                ]);
            }

            jsonResponse(true, 'Ordine aggiornato con successo');
            break;

        default:
            jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Database Error: " . $e->getMessage());
    jsonResponse(false, 'Errore database: ' . $e->getMessage());
} catch (Exception $e) {
    error_log("Generic Error: " . $e->getMessage());
    jsonResponse(false, 'Errore: ' . $e->getMessage());
}

