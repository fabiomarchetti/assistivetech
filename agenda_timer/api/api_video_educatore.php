<?php
// API per gestione video educatore
// Compatibile con il database Aruba e la PWA agenda_timer

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: https://www.assistivetech.it');
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Max-Age: 86400');

// Gestione preflight CORS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurazione database Aruba
$servername = "31.11.39.242";
$username = "Sql1073852";
$password = "5k58326940";
$dbname = "Sql1073852_1";

try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Connessione al database fallita: ' . $e->getMessage()
    ]);
    exit();
}

// Ottieni parametri della richiesta
$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);
$action = $_GET['action'] ?? $_POST['action'] ?? $input['action'] ?? '';

// Log delle richieste per debug
error_log("API Video Educatore - Method: $method, Action: $action");

try {
    switch ($method) {
        case 'GET':
            handleGet($pdo, $action);
            break;
        case 'POST':
            handlePost($pdo, $action, $input);
            break;
        case 'DELETE':
            handleDelete($pdo, $action);
            break;
        default:
            throw new Exception("Metodo HTTP non supportato: $method");
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}

function handleGet($pdo, $action) {
    switch ($action) {
        case 'get_all_video':
            getAllVideo($pdo);
            break;
        case 'get_video_per_utente':
            $nomeUtente = $_GET['nome_utente'] ?? '';
            if (empty($nomeUtente)) {
                throw new Exception('Parametro nome_utente mancante');
            }
            getVideoPerUtente($pdo, $nomeUtente);
            break;
        case 'get_video_per_agenda':
            $nomeAgenda = $_GET['nome_agenda'] ?? '';
            if (empty($nomeAgenda)) {
                throw new Exception('Parametro nome_agenda mancante');
            }
            getVideoPerAgenda($pdo, $nomeAgenda);
            break;
        case 'get_categorie':
            getCategorie($pdo);
            break;
        default:
            getAllVideo($pdo);
    }
}

function handlePost($pdo, $action, $input) {
    switch ($action) {
        case 'salva_video':
            salvaVideo($pdo, $input);
            break;
        default:
            throw new Exception("Azione POST non riconosciuta: $action");
    }
}

function handleDelete($pdo, $action) {
    switch ($action) {
        case 'elimina_video':
            $idVideo = $_GET['id_video'] ?? '';
            if (empty($idVideo)) {
                throw new Exception('Parametro id_video mancante');
            }
            eliminaVideo($pdo, intval($idVideo));
            break;
        default:
            throw new Exception("Azione DELETE non riconosciuta: $action");
    }
}

function getAllVideo($pdo) {
    $stmt = $pdo->prepare("
        SELECT id_video, nome_video, categoria, link_youtube,
               nome_agenda, nome_utente, data_creazione
        FROM video_educatore
        ORDER BY data_creazione DESC
    ");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Converte id_video in numero per compatibilità Flutter
    foreach ($result as &$row) {
        $row['id_video'] = intval($row['id_video']);
    }

    echo json_encode([
        'success' => true,
        'data' => $result,
        'count' => count($result)
    ]);
}

function getVideoPerUtente($pdo, $nomeUtente) {
    $stmt = $pdo->prepare("
        SELECT id_video, nome_video, categoria, link_youtube,
               nome_agenda, nome_utente, data_creazione
        FROM video_educatore
        WHERE nome_utente = :nome_utente
        ORDER BY data_creazione DESC
    ");
    $stmt->execute(['nome_utente' => $nomeUtente]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Converte id_video in numero per compatibilità Flutter
    foreach ($result as &$row) {
        $row['id_video'] = intval($row['id_video']);
    }

    echo json_encode([
        'success' => true,
        'data' => $result,
        'count' => count($result),
        'nome_utente' => $nomeUtente
    ]);
}

function getVideoPerAgenda($pdo, $nomeAgenda) {
    $stmt = $pdo->prepare("
        SELECT id_video, nome_video, categoria, link_youtube,
               nome_agenda, nome_utente, data_creazione
        FROM video_educatore
        WHERE nome_agenda = :nome_agenda
        ORDER BY data_creazione DESC
    ");
    $stmt->execute(['nome_agenda' => $nomeAgenda]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Converte id_video in numero per compatibilità Flutter
    foreach ($result as &$row) {
        $row['id_video'] = intval($row['id_video']);
    }

    echo json_encode([
        'success' => true,
        'data' => $result,
        'count' => count($result),
        'nome_agenda' => $nomeAgenda
    ]);
}

function getCategorie($pdo) {
    $stmt = $pdo->prepare("
        SELECT categoria, COUNT(*) as count
        FROM video_educatore
        GROUP BY categoria
        ORDER BY categoria ASC
    ");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => $result,
        'count' => count($result)
    ]);
}

function salvaVideo($pdo, $input) {
    // Validazione input
    $nomeVideo = trim($input['nome_video'] ?? '');
    $categoria = trim($input['categoria'] ?? '');
    $linkYoutube = trim($input['link_youtube'] ?? '');
    $nomeAgenda = trim($input['nome_agenda'] ?? '');
    $nomeUtente = trim($input['nome_utente'] ?? '');

    if (empty($nomeVideo)) {
        throw new Exception('Il nome del video è obbligatorio');
    }
    if (empty($categoria)) {
        throw new Exception('La categoria è obbligatoria');
    }
    if (empty($linkYoutube)) {
        throw new Exception('Il link YouTube è obbligatorio');
    }
    if (empty($nomeAgenda)) {
        throw new Exception('Il nome dell\'agenda è obbligatorio');
    }
    if (empty($nomeUtente)) {
        throw new Exception('Il nome dell\'utente è obbligatorio');
    }

    // Validazione URL YouTube
    if (!isValidYouTubeUrl($linkYoutube)) {
        throw new Exception('URL YouTube non valido');
    }

    // Data italiana
    $dataCreazione = date('d/m/Y H:i:s');

    $stmt = $pdo->prepare("
        INSERT INTO video_educatore
        (nome_video, categoria, link_youtube, nome_agenda, nome_utente, data_creazione)
        VALUES (:nome_video, :categoria, :link_youtube, :nome_agenda, :nome_utente, :data_creazione)
    ");

    $result = $stmt->execute([
        'nome_video' => $nomeVideo,
        'categoria' => $categoria,
        'link_youtube' => $linkYoutube,
        'nome_agenda' => $nomeAgenda,
        'nome_utente' => $nomeUtente,
        'data_creazione' => $dataCreazione
    ]);

    if ($result) {
        $idVideo = intval($pdo->lastInsertId()); // Converte in numero
        echo json_encode([
            'success' => true,
            'message' => 'Video salvato con successo',
            'data' => [
                'id_video' => $idVideo,
                'nome_video' => $nomeVideo,
                'categoria' => $categoria,
                'link_youtube' => $linkYoutube,
                'nome_agenda' => $nomeAgenda,
                'nome_utente' => $nomeUtente,
                'data_creazione' => $dataCreazione
            ]
        ]);
    } else {
        throw new Exception('Errore nel salvataggio del video');
    }
}

function eliminaVideo($pdo, $idVideo) {
    $stmt = $pdo->prepare("DELETE FROM video_educatore WHERE id_video = :id_video");
    $result = $stmt->execute(['id_video' => $idVideo]);

    if ($result) {
        $rowsAffected = $stmt->rowCount();
        if ($rowsAffected > 0) {
            echo json_encode([
                'success' => true,
                'message' => 'Video eliminato con successo',
                'id_video' => $idVideo
            ]);
        } else {
            throw new Exception('Video non trovato');
        }
    } else {
        throw new Exception('Errore nell\'eliminazione del video');
    }
}

function isValidYouTubeUrl($url) {
    $pattern = '/^(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)[\w-]+/';
    return preg_match($pattern, $url);
}

// Funzione di log per debug
function logOperation($operation, $data = []) {
    $timestamp = date('d/m/Y H:i:s');
    $logMessage = "[$timestamp] $operation - " . json_encode($data) . PHP_EOL;
    file_put_contents('video_educatore.log', $logMessage, FILE_APPEND | LOCK_EX);
}
?>