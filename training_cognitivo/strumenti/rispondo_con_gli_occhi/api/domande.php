<?php
/**
 * API per gestione domande Eye Tracking
 * Endpoints: GET, POST, PUT, DELETE
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Gestione preflight OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Includi configurazione database
// Prova prima il percorso relativo (locale), poi quello assoluto (Aruba)
if (file_exists(__DIR__ . '/../../../../api/db_config.php')) {
    require_once __DIR__ . '/../../../../api/db_config.php';
} elseif (file_exists($_SERVER['DOCUMENT_ROOT'] . '/api/db_config.php')) {
    require_once $_SERVER['DOCUMENT_ROOT'] . '/api/db_config.php';
} else {
    die(json_encode(['success' => false, 'error' => 'File di configurazione database non trovato']));
}

// Funzione per gestire gli errori
function sendError($message, $code = 400) {
    http_response_code($code);
    echo json_encode(['success' => false, 'error' => $message]);
    exit();
}

// Funzione per gestire le risposte di successo
function sendSuccess($data = null, $message = 'Operazione completata') {
    echo json_encode(['success' => true, 'message' => $message, 'data' => $data]);
    exit();
}

// Ottieni il metodo HTTP
$method = $_SERVER['REQUEST_METHOD'];

try {
    // Connessione database
    $conn = getDbConnectionMySQLi();
    
    switch ($method) {
        case 'GET':
            // GET /api/domande.php - Ottieni tutte le domande
            // GET /api/domande.php?id=X - Ottieni domanda specifica
            // GET /api/domande.php?id_educatore=X - Ottieni domande di un educatore
            
            if (isset($_GET['id'])) {
                // Ottieni domanda specifica
                $id = intval($_GET['id']);
                $stmt = $conn->prepare("
                    SELECT d.* 
                    FROM domande_eye_tracking d
                    WHERE d.id_domanda = ?
                ");
                $stmt->bind_param("i", $id);
                $stmt->execute();
                $result = $stmt->get_result();
                $domanda = $result->fetch_assoc();
                
                if ($domanda) {
                    sendSuccess($domanda);
                } else {
                    sendError('Domanda non trovata', 404);
                }
                
            } elseif (isset($_GET['id_educatore'])) {
                // Ottieni domande di un educatore
                $id_educatore = intval($_GET['id_educatore']);
                $stmt = $conn->prepare("
                    SELECT d.* 
                    FROM domande_eye_tracking d
                    WHERE d.id_educatore = ? AND d.stato = 'attiva'
                    ORDER BY d.data_creazione DESC
                ");
                $stmt->bind_param("i", $id_educatore);
                $stmt->execute();
                $result = $stmt->get_result();
                $domande = $result->fetch_all(MYSQLI_ASSOC);
                
                sendSuccess($domande);
                
            } else {
                // Ottieni tutte le domande attive
                $result = $conn->query("
                    SELECT d.* 
                    FROM domande_eye_tracking d
                    WHERE d.stato = 'attiva'
                    ORDER BY d.data_creazione DESC
                ");
                $domande = $result->fetch_all(MYSQLI_ASSOC);
                
                sendSuccess($domande);
            }
            break;
            
        case 'POST':
            // POST /api/domande.php - Crea nuova domanda
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Validazione campi obbligatori
            if (!isset($data['id_educatore']) || !isset($data['testo_domanda'])) {
                sendError('Campi obbligatori mancanti: id_educatore, testo_domanda');
            }
            
            $id_educatore = intval($data['id_educatore']);
            $testo_domanda = trim($data['testo_domanda']);
            $immagine_sinistra_url = $data['immagine_sinistra_url'] ?? null;
            $immagine_sinistra_id = isset($data['immagine_sinistra_id']) ? intval($data['immagine_sinistra_id']) : null;
            $etichetta_sinistra = $data['etichetta_sinistra'] ?? 'NO';
            $immagine_destra_url = $data['immagine_destra_url'] ?? null;
            $immagine_destra_id = isset($data['immagine_destra_id']) ? intval($data['immagine_destra_id']) : null;
            $etichetta_destra = $data['etichetta_destra'] ?? 'SI';
            $tipo_domanda = $data['tipo_domanda'] ?? 'si_no';
            
            $stmt = $conn->prepare("
                INSERT INTO domande_eye_tracking 
                (id_educatore, testo_domanda, immagine_sinistra_url, immagine_sinistra_id, 
                 etichetta_sinistra, immagine_destra_url, immagine_destra_id, 
                 etichetta_destra, tipo_domanda)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ");
            
            $stmt->bind_param(
                "isssissss",
                $id_educatore,
                $testo_domanda,
                $immagine_sinistra_url,
                $immagine_sinistra_id,
                $etichetta_sinistra,
                $immagine_destra_url,
                $immagine_destra_id,
                $etichetta_destra,
                $tipo_domanda
            );
            
            if ($stmt->execute()) {
                $id_inserito = $conn->insert_id;
                sendSuccess(['id_domanda' => $id_inserito], 'Domanda creata con successo');
            } else {
                sendError('Errore durante la creazione della domanda');
            }
            break;
            
        case 'PUT':
            // PUT /api/domande.php?id=X - Aggiorna domanda esistente
            // Oppure PUT /api/domande.php con id_domanda nel body
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Accetta ID da query string o da body
            if (isset($_GET['id'])) {
                $id = intval($_GET['id']);
            } elseif (isset($data['id_domanda'])) {
                $id = intval($data['id_domanda']);
            } else {
                sendError('ID domanda mancante');
            }
            
            // Costruisci query dinamica per aggiornare solo i campi forniti
            $updates = [];
            $types = '';
            $values = [];
            
            $campi_permessi = [
                'testo_domanda' => 's',
                'immagine_sinistra_url' => 's',
                'immagine_sinistra_id' => 'i',
                'etichetta_sinistra' => 's',
                'immagine_destra_url' => 's',
                'immagine_destra_id' => 'i',
                'etichetta_destra' => 's',
                'tipo_domanda' => 's',
                'stato' => 's'
            ];
            
            foreach ($campi_permessi as $campo => $tipo) {
                if (isset($data[$campo])) {
                    $updates[] = "$campo = ?";
                    $types .= $tipo;
                    $values[] = $tipo === 'i' ? intval($data[$campo]) : $data[$campo];
                }
            }
            
            if (empty($updates)) {
                sendError('Nessun campo da aggiornare');
            }
            
            $types .= 'i';
            $values[] = $id;
            
            $sql = "UPDATE domande_eye_tracking SET " . implode(', ', $updates) . " WHERE id_domanda = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param($types, ...$values);
            
            if ($stmt->execute()) {
                sendSuccess(null, 'Domanda aggiornata con successo');
            } else {
                sendError('Errore durante l\'aggiornamento della domanda');
            }
            break;
            
        case 'DELETE':
            // DELETE /api/domande.php?id=X - Elimina domanda (eliminazione fisica)
            if (!isset($_GET['id'])) {
                sendError('ID domanda mancante');
            }
            
            $id = intval($_GET['id']);
            
            // DELETE fisica dal database
            // Nota: Le risposte associate verranno eliminate automaticamente per CASCADE
            $stmt = $conn->prepare("DELETE FROM domande_eye_tracking WHERE id_domanda = ?");
            $stmt->bind_param("i", $id);
            
            if ($stmt->execute()) {
                if ($stmt->affected_rows > 0) {
                    sendSuccess(null, 'Domanda eliminata con successo');
                } else {
                    sendError('Domanda non trovata o già eliminata', 404);
                }
            } else {
                sendError('Errore durante l\'eliminazione della domanda');
            }
            break;
            
        default:
            sendError('Metodo HTTP non supportato', 405);
    }
    
} catch (Exception $e) {
    sendError('Errore del server: ' . $e->getMessage(), 500);
} finally {
    if (isset($conn)) {
        $conn->close();
    }
}
?>

