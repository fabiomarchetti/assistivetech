<?php
/**
 * API per gestione item nelle agende
 * Endpoint: /training_cognitivo/strumenti/api/items.php
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
        // CREATE - Crea nuovo item
        // ============================================================
        case 'create':
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            // Validazione
            if (empty($input['id_agenda'])) {
                jsonResponse(false, 'ID agenda obbligatorio');
            }
            if (empty($input['tipo_item'])) {
                jsonResponse(false, 'Tipo item obbligatorio');
            }
            if (empty($input['titolo'])) {
                jsonResponse(false, 'Titolo obbligatorio');
            }

            // Validazione tipo_item
            $tipi_validi = ['semplice', 'link_agenda', 'video_youtube'];
            if (!in_array($input['tipo_item'], $tipi_validi)) {
                jsonResponse(false, 'Tipo item non valido');
            }

            $id_agenda = (int)$input['id_agenda'];
            $tipo_item = $input['tipo_item'];
            $titolo = trim($input['titolo']);

            // Calcola posizione (ultimo + 1)
            $stmt_pos = $pdo->prepare("SELECT COALESCE(MAX(posizione), -1) + 1 as next_pos FROM agende_items WHERE id_agenda = :id_agenda");
            $stmt_pos->execute([':id_agenda' => $id_agenda]);
            $posizione = (int)$stmt_pos->fetch(PDO::FETCH_ASSOC)['next_pos'];

            // Campi opzionali
            $tipo_immagine = $input['tipo_immagine'] ?? 'nessuna';
            $id_arasaac = isset($input['id_arasaac']) ? (int)$input['id_arasaac'] : null;
            $url_immagine = $input['url_immagine'] ?? null;
            $id_agenda_collegata = isset($input['id_agenda_collegata']) ? (int)$input['id_agenda_collegata'] : null;
            $video_youtube_id = $input['video_youtube_id'] ?? null;
            $video_youtube_title = $input['video_youtube_title'] ?? null;
            $video_youtube_thumbnail = $input['video_youtube_thumbnail'] ?? null;

            // Debug log
            error_log("DEBUG CREATE ITEM - Input ricevuto: " . json_encode([
                'tipo_immagine' => $tipo_immagine,
                'id_arasaac' => $id_arasaac,
                'url_immagine' => $url_immagine
            ]));

            // Validazioni specifiche per tipo
            if ($tipo_item === 'link_agenda' && $id_agenda_collegata === null) {
                jsonResponse(false, 'ID agenda collegata obbligatorio per tipo link_agenda');
            }
            if ($tipo_item === 'video_youtube' && empty($video_youtube_id)) {
                jsonResponse(false, 'ID video YouTube obbligatorio per tipo video_youtube');
            }

            // Inserimento
            $sql = "INSERT INTO agende_items
                    (id_agenda, tipo_item, titolo, posizione, tipo_immagine, id_arasaac, url_immagine,
                     id_agenda_collegata, video_youtube_id, video_youtube_title, video_youtube_thumbnail,
                     data_creazione, stato)
                    VALUES
                    (:id_agenda, :tipo_item, :titolo, :posizione, :tipo_img, :id_arasaac, :url_img,
                     :id_agenda_coll, :yt_id, :yt_title, :yt_thumb, :data, 'attivo')";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':id_agenda' => $id_agenda,
                ':tipo_item' => $tipo_item,
                ':titolo' => $titolo,
                ':posizione' => $posizione,
                ':tipo_img' => $tipo_immagine,
                ':id_arasaac' => $id_arasaac,
                ':url_img' => $url_immagine,
                ':id_agenda_coll' => $id_agenda_collegata,
                ':yt_id' => $video_youtube_id,
                ':yt_title' => $video_youtube_title,
                ':yt_thumb' => $video_youtube_thumbnail,
                ':data' => getItalianDateTime()
            ]);

            $id_item = $pdo->lastInsertId();

            jsonResponse(true, 'Item creato con successo', [
                'id_item' => $id_item,
                'posizione' => $posizione
            ]);
            break;

        // ============================================================
        // LIST - Lista item di un'agenda
        // ============================================================
        case 'list':
            if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_agenda = isset($_GET['id_agenda']) ? (int)$_GET['id_agenda'] : null;

            if ($id_agenda === null) {
                jsonResponse(false, 'ID agenda obbligatorio');
            }

            $sql = "SELECT i.*,
                           a.nome_agenda as nome_agenda_collegata
                    FROM agende_items i
                    LEFT JOIN agende_strumenti a ON i.id_agenda_collegata = a.id_agenda
                    WHERE i.id_agenda = :id_agenda
                    AND i.stato = 'attivo'
                    ORDER BY i.posizione ASC";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([':id_agenda' => $id_agenda]);
            $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Normalizzazione dati - Converti campi numerici
            $items = array_map(function($item) {
                if (isset($item['id_item'])) $item['id_item'] = (int)$item['id_item'];
                if (isset($item['id_agenda'])) $item['id_agenda'] = (int)$item['id_agenda'];
                if (isset($item['id_arasaac']) && $item['id_arasaac']) {
                    $item['id_arasaac'] = (int)$item['id_arasaac'];
                }
                if (isset($item['posizione'])) $item['posizione'] = (int)$item['posizione'];
                if (isset($item['id_agenda_collegata']) && $item['id_agenda_collegata']) {
                    $item['id_agenda_collegata'] = (int)$item['id_agenda_collegata'];
                }
                return $item;
            }, $items);

            jsonResponse(true, 'Item recuperati con successo', $items);
            break;

        // ============================================================
        // GET - Dettagli singolo item
        // ============================================================
        case 'get':
            if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_item = isset($_GET['id_item']) ? (int)$_GET['id_item'] : null;

            if ($id_item === null) {
                jsonResponse(false, 'ID item obbligatorio');
            }

            $sql = "SELECT i.*,
                           a.nome_agenda as nome_agenda_collegata
                    FROM agende_items i
                    LEFT JOIN agende_strumenti a ON i.id_agenda_collegata = a.id_agenda
                    WHERE i.id_item = :id";

            $stmt = $pdo->prepare($sql);
            $stmt->execute([':id' => $id_item]);
            $item = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$item) {
                jsonResponse(false, 'Item non trovato');
            }

            // Normalizzazione dati - Converti campi numerici
            if (isset($item['id_item'])) $item['id_item'] = (int)$item['id_item'];
            if (isset($item['id_agenda'])) $item['id_agenda'] = (int)$item['id_agenda'];
            if (isset($item['id_arasaac']) && $item['id_arasaac']) {
                $item['id_arasaac'] = (int)$item['id_arasaac'];
            }
            if (isset($item['posizione'])) $item['posizione'] = (int)$item['posizione'];
            if (isset($item['id_agenda_collegata']) && $item['id_agenda_collegata']) {
                $item['id_agenda_collegata'] = (int)$item['id_agenda_collegata'];
            }

            jsonResponse(true, 'Item recuperato con successo', $item);
            break;

        // ============================================================
        // UPDATE - Aggiorna item
        // ============================================================
        case 'update':
            if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_item = isset($_GET['id_item']) ? (int)$_GET['id_item'] : null;
            if ($id_item === null) {
                jsonResponse(false, 'ID item obbligatorio');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            // Costruisci UPDATE dinamico solo per campi presenti
            $updates = [];
            $params = [':id' => $id_item];

            if (isset($input['titolo'])) {
                $updates[] = "titolo = :titolo";
                $params[':titolo'] = trim($input['titolo']);
            }
            if (isset($input['tipo_immagine'])) {
                $updates[] = "tipo_immagine = :tipo_img";
                $params[':tipo_img'] = $input['tipo_immagine'];
            }
            if (isset($input['id_arasaac'])) {
                $updates[] = "id_arasaac = :id_arasaac";
                $params[':id_arasaac'] = $input['id_arasaac'] ? (int)$input['id_arasaac'] : null;
            }
            if (isset($input['url_immagine'])) {
                $updates[] = "url_immagine = :url_img";
                $params[':url_img'] = $input['url_immagine'];
            }
            if (isset($input['id_agenda_collegata'])) {
                $updates[] = "id_agenda_collegata = :id_agenda_coll";
                $params[':id_agenda_coll'] = $input['id_agenda_collegata'] ? (int)$input['id_agenda_collegata'] : null;
            }
            if (isset($input['video_youtube_id'])) {
                $updates[] = "video_youtube_id = :yt_id";
                $params[':yt_id'] = $input['video_youtube_id'];
            }
            if (isset($input['video_youtube_title'])) {
                $updates[] = "video_youtube_title = :yt_title";
                $params[':yt_title'] = $input['video_youtube_title'];
            }
            if (isset($input['video_youtube_thumbnail'])) {
                $updates[] = "video_youtube_thumbnail = :yt_thumb";
                $params[':yt_thumb'] = $input['video_youtube_thumbnail'];
            }

            if (empty($updates)) {
                jsonResponse(false, 'Nessun campo da aggiornare');
            }

            $sql = "UPDATE agende_items SET " . implode(', ', $updates) . " WHERE id_item = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);

            jsonResponse(true, 'Item aggiornato con successo');
            break;

        // ============================================================
        // REORDER - Riordina items
        // ============================================================
        case 'reorder':
            if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $input = json_decode(file_get_contents('php://input'), true);

            if (empty($input['items']) || !is_array($input['items'])) {
                jsonResponse(false, 'Array items obbligatorio');
            }

            $pdo->beginTransaction();

            try {
                $stmt = $pdo->prepare("UPDATE agende_items SET posizione = :pos WHERE id_item = :id");

                foreach ($input['items'] as $item) {
                    if (!isset($item['id_item']) || !isset($item['posizione'])) {
                        throw new Exception('Formato items non valido');
                    }

                    $stmt->execute([
                        ':id' => (int)$item['id_item'],
                        ':pos' => (int)$item['posizione']
                    ]);
                }

                $pdo->commit();
                jsonResponse(true, 'Items riordinati con successo');

            } catch (Exception $e) {
                $pdo->rollBack();
                throw $e;
            }
            break;

        // ============================================================
        // DELETE - Elimina item (soft delete)
        // ============================================================
        case 'delete':
            if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
                jsonResponse(false, 'Metodo non consentito');
            }

            $id_item = isset($_GET['id_item']) ? (int)$_GET['id_item'] : null;
            if ($id_item === null) {
                jsonResponse(false, 'ID item obbligatorio');
            }

            // Soft delete
            $sql = "UPDATE agende_items SET stato = 'archiviato' WHERE id_item = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([':id' => $id_item]);

            jsonResponse(true, 'Item eliminato con successo');
            break;

        // ============================================================
        // DEFAULT - Azione non riconosciuta
        // ============================================================
        default:
            jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore Database items.php: " . $e->getMessage());
    jsonResponse(false, 'Errore database: ' . $e->getMessage());
} catch (Exception $e) {
    error_log("Errore generico items.php: " . $e->getMessage());
    jsonResponse(false, 'Errore: ' . $e->getMessage());
}
