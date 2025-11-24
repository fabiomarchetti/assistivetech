<?php
/**
 * API per gestione items del Comunicatore
 * Endpoint: /training_cognitivo/strumenti/comunicatore/api/items.php
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
        // CREATE - Crea nuovo item
        // ============================================================
        case 'create':
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            // Validazione
            if (empty($input['id_pagina'])) {
                jsonResponse(false, 'ID pagina obbligatorio');
            }
            if (empty($input['posizione_griglia']) || !in_array($input['posizione_griglia'], [1, 2, 3, 4])) {
                jsonResponse(false, 'Posizione griglia non valida (1-4)');
            }
            if (empty($input['titolo'])) {
                jsonResponse(false, 'Titolo obbligatorio');
            }

            $id_pagina = (int)$input['id_pagina'];
            $posizione_griglia = (int)$input['posizione_griglia'];
            $titolo = trim($input['titolo']);
            $frase_tts = $input['frase_tts'] ?? $titolo;
            
            // Immagine
            $tipo_immagine = $input['tipo_immagine'] ?? 'nessuna';
            $id_arasaac = isset($input['id_arasaac']) ? (int)$input['id_arasaac'] : null;
            $url_immagine = $input['url_immagine'] ?? null;
            
            // Colori
            $colore_sfondo = $input['colore_sfondo'] ?? '#FFFFFF';
            $colore_testo = $input['colore_testo'] ?? '#000000';

            // Verifica che la posizione non sia già occupata
            $stmt_check = $pdo->prepare("
                SELECT id_item FROM comunicatore_items 
                WHERE id_pagina = :id_pag AND posizione_griglia = :pos AND stato = 'attivo'
            ");
            $stmt_check->execute([
                ':id_pag' => $id_pagina,
                ':pos' => $posizione_griglia
            ]);

            if ($stmt_check->fetch()) {
                jsonResponse(false, 'Posizione già occupata');
            }

            // Navigazione sottopagine
            $tipo_item = $input['tipo_item'] ?? 'normale';
            $id_pagina_riferimento = isset($input['id_pagina_riferimento']) && $input['id_pagina_riferimento'] !== '' 
                ? (int)$input['id_pagina_riferimento'] 
                : null;

            // Inserimento
            $sql = "INSERT INTO comunicatore_items
                    (id_pagina, posizione_griglia, titolo, frase_tts, 
                     tipo_immagine, id_arasaac, url_immagine, 
                     tipo_item, id_pagina_riferimento,
                     colore_sfondo, colore_testo, data_creazione, stato)
                    VALUES (:id_pag, :pos, :titolo, :frase, 
                            :tipo_img, :id_aras, :url_img,
                            :tipo_item, :id_pag_rif,
                            :col_sfondo, :col_testo, :data, 'attivo')";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':id_pag' => $id_pagina,
                ':pos' => $posizione_griglia,
                ':titolo' => $titolo,
                ':frase' => $frase_tts,
                ':tipo_img' => $tipo_immagine,
                ':id_aras' => $id_arasaac,
                ':url_img' => $url_immagine,
                ':tipo_item' => $tipo_item,
                ':id_pag_rif' => $id_pagina_riferimento,
                ':col_sfondo' => $colore_sfondo,
                ':col_testo' => $colore_testo,
                ':data' => getItalianDateTime()
            ]);

            $id_item = $pdo->lastInsertId();

            jsonResponse(true, 'Item creato con successo', [
                'id_item' => $id_item,
                'titolo' => $titolo,
                'posizione_griglia' => $posizione_griglia
            ]);
            break;

        // ============================================================
        // LIST - Lista items di una pagina
        // ============================================================
        case 'list':
            $id_pagina = $_GET['id_pagina'] ?? null;

            if (!$id_pagina) {
                jsonResponse(false, 'ID pagina obbligatorio');
            }

            $sql = "SELECT * FROM comunicatore_items 
                    WHERE id_pagina = :id_pag AND stato = 'attivo'
                    ORDER BY posizione_griglia ASC";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([':id_pag' => (int)$id_pagina]);
            $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

            jsonResponse(true, 'Items caricati', $items);
            break;

        // ============================================================
        // GET - Dettaglio singolo item
        // ============================================================
        case 'get':
            $id_item = $_GET['id_item'] ?? null;

            if (!$id_item) {
                jsonResponse(false, 'ID item obbligatorio');
            }

            $stmt = $pdo->prepare("SELECT * FROM comunicatore_items WHERE id_item = :id");
            $stmt->execute([':id' => (int)$id_item]);
            $item = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$item) {
                jsonResponse(false, 'Item non trovato');
            }

            jsonResponse(true, 'Item caricato', $item);
            break;

        // ============================================================
        // UPDATE - Modifica item
        // ============================================================
        case 'update':
            if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            if (empty($input['id_item'])) {
                jsonResponse(false, 'ID item obbligatorio');
            }

            $id_item = (int)$input['id_item'];

            // Costruisci query dinamica
            $updates = [];
            $params = [':id' => $id_item];

            if (isset($input['titolo'])) {
                $updates[] = "titolo = :titolo";
                $params[':titolo'] = trim($input['titolo']);
            }
            if (isset($input['frase_tts'])) {
                $updates[] = "frase_tts = :frase";
                $params[':frase'] = trim($input['frase_tts']);
            }
            if (isset($input['tipo_immagine'])) {
                $updates[] = "tipo_immagine = :tipo_img";
                $params[':tipo_img'] = $input['tipo_immagine'];
            }
            if (isset($input['id_arasaac'])) {
                $updates[] = "id_arasaac = :id_aras";
                $params[':id_aras'] = $input['id_arasaac'] ? (int)$input['id_arasaac'] : null;
            }
            if (isset($input['url_immagine'])) {
                $updates[] = "url_immagine = :url_img";
                $params[':url_img'] = $input['url_immagine'];
            }
            if (isset($input['colore_sfondo'])) {
                $updates[] = "colore_sfondo = :col_sfondo";
                $params[':col_sfondo'] = $input['colore_sfondo'];
            }
            if (isset($input['colore_testo'])) {
                $updates[] = "colore_testo = :col_testo";
                $params[':col_testo'] = $input['colore_testo'];
            }
            if (isset($input['posizione_griglia'])) {
                // Verifica che la nuova posizione non sia già occupata
                $new_pos = (int)$input['posizione_griglia'];
                
                // Ottieni id_pagina dell'item
                $stmt_pag = $pdo->prepare("SELECT id_pagina FROM comunicatore_items WHERE id_item = :id");
                $stmt_pag->execute([':id' => $id_item]);
                $id_pagina = $stmt_pag->fetchColumn();

                $stmt_check = $pdo->prepare("
                    SELECT id_item FROM comunicatore_items 
                    WHERE id_pagina = :id_pag AND posizione_griglia = :pos AND id_item != :id AND stato = 'attivo'
                ");
                $stmt_check->execute([
                    ':id_pag' => $id_pagina,
                    ':pos' => $new_pos,
                    ':id' => $id_item
                ]);

                if ($stmt_check->fetch()) {
                    jsonResponse(false, 'Posizione già occupata');
                }

                $updates[] = "posizione_griglia = :pos";
                $params[':pos'] = $new_pos;
            }
            if (isset($input['tipo_item'])) {
                $updates[] = "tipo_item = :tipo_item";
                $params[':tipo_item'] = $input['tipo_item'];
            }
            if (isset($input['id_pagina_riferimento'])) {
                $updates[] = "id_pagina_riferimento = :id_pag_rif";
                $params[':id_pag_rif'] = $input['id_pagina_riferimento'] !== '' ? (int)$input['id_pagina_riferimento'] : null;
            }

            if (empty($updates)) {
                jsonResponse(false, 'Nessun campo da aggiornare');
            }

            $updates[] = "data_modifica = :data_mod";
            $params[':data_mod'] = getItalianDateTime();

            $sql = "UPDATE comunicatore_items SET " . implode(', ', $updates) . " WHERE id_item = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);

            jsonResponse(true, 'Item aggiornato con successo');
            break;

        // ============================================================
        // DELETE - Elimina item
        // ============================================================
        case 'delete':
            if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_item = $_GET['id_item'] ?? null;

            if (!$id_item) {
                jsonResponse(false, 'ID item obbligatorio');
            }

            // Soft delete
            $stmt = $pdo->prepare("UPDATE comunicatore_items SET stato = 'nascosto' WHERE id_item = :id");
            $stmt->execute([':id' => (int)$id_item]);

            jsonResponse(true, 'Item eliminato con successo');
            break;

        // ============================================================
        // LOG - Registra utilizzo item (per statistiche)
        // ============================================================
        case 'log':
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            if (empty($input['id_item']) || empty($input['id_paziente'])) {
                jsonResponse(false, 'ID item e ID paziente obbligatori');
            }

            $sql = "INSERT INTO comunicatore_log 
                    (id_paziente, id_item, data_utilizzo, sessione)
                    VALUES (:id_paz, :id_item, :data, :sessione)";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':id_paz' => (int)$input['id_paziente'],
                ':id_item' => (int)$input['id_item'],
                ':data' => getItalianDateTime(),
                ':sessione' => $input['sessione'] ?? session_id()
            ]);

            jsonResponse(true, 'Log registrato');
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

