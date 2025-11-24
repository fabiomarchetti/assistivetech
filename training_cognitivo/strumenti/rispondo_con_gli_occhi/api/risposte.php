
<?php
/**
 * API per gestione risposte Eye Tracking
 * Endpoints: GET, POST
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
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
            // GET /api/risposte.php?id_utente=X - Ottieni risposte di un utente
            // GET /api/risposte.php?id_domanda=X - Ottieni risposte a una domanda
            // GET /api/risposte.php?id_utente=X&id_domanda=Y - Filtra per entrambi
            
            $where_clauses = ['1=1'];
            $params = [];
            $types = '';
            
            if (isset($_GET['id_utente'])) {
                $where_clauses[] = 'r.id_utente = ?';
                $types .= 'i';
                $params[] = intval($_GET['id_utente']);
            }
            
            if (isset($_GET['id_domanda'])) {
                $where_clauses[] = 'r.id_domanda = ?';
                $types .= 'i';
                $params[] = intval($_GET['id_domanda']);
            }
            
            $sql = "
                SELECT r.*, 
                       d.testo_domanda
                FROM risposte_eye_tracking r
                LEFT JOIN domande_eye_tracking d ON r.id_domanda = d.id_domanda
                WHERE " . implode(' AND ', $where_clauses) . "
                ORDER BY r.data_risposta DESC
            ";
            
            if (!empty($params)) {
                $stmt = $conn->prepare($sql);
                $stmt->bind_param($types, ...$params);
                $stmt->execute();
                $result = $stmt->get_result();
            } else {
                $result = $conn->query($sql);
            }
            
            $risposte = $result->fetch_all(MYSQLI_ASSOC);
            sendSuccess($risposte);
            break;
            
        case 'POST':
            // POST /api/risposte.php - Salva nuova risposta
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Validazione campi obbligatori
            $required = ['id_utente', 'id_domanda', 'domanda_fatta', 'risposta_data', 'etichetta_risposta'];
            foreach ($required as $field) {
                if (!isset($data[$field])) {
                    sendError("Campo obbligatorio mancante: $field");
                }
            }
            
            $id_utente = intval($data['id_utente']);
            $id_domanda = intval($data['id_domanda']);
            $domanda_fatta = trim($data['domanda_fatta']);
            $risposta_data = $data['risposta_data']; // 'sinistra' o 'destra'
            $etichetta_risposta = trim($data['etichetta_risposta']);
            $tempo_risposta_ms = isset($data['tempo_risposta_ms']) ? intval($data['tempo_risposta_ms']) : null;
            $confidenza = isset($data['confidenza']) ? floatval($data['confidenza']) : null;
            $metodo_rilevamento = $data['metodo_rilevamento'] ?? 'combinato';
            
            // Validazione risposta_data
            if (!in_array($risposta_data, ['sinistra', 'destra'])) {
                sendError('Valore risposta_data non valido (deve essere sinistra o destra)');
            }
            
            // Validazione metodo_rilevamento
            if (!in_array($metodo_rilevamento, ['iris', 'head_pose', 'combinato'])) {
                sendError('Valore metodo_rilevamento non valido');
            }
            
            $stmt = $conn->prepare("
                INSERT INTO risposte_eye_tracking 
                (id_utente, id_domanda, domanda_fatta, risposta_data, etichetta_risposta, 
                 tempo_risposta_ms, confidenza, metodo_rilevamento)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ");
            
            $stmt->bind_param(
                "iissssds",
                $id_utente,
                $id_domanda,
                $domanda_fatta,
                $risposta_data,
                $etichetta_risposta,
                $tempo_risposta_ms,
                $confidenza,
                $metodo_rilevamento
            );
            
            if ($stmt->execute()) {
                $id_inserito = $conn->insert_id;
                sendSuccess(['id_risposta' => $id_inserito], 'Risposta salvata con successo');
            } else {
                sendError('Errore durante il salvataggio della risposta');
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

