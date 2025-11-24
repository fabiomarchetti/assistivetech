<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // Permetto tutti gli origin per localhost
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Max-Age: 86400');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Rilevo ambiente locale vs produzione
$isLocalhost = in_array($_SERVER['HTTP_HOST'] ?? '', ['localhost', '127.0.0.1', 'localhost:8888']);

if ($isLocalhost) {
    // Configurazione locale MAMP
    $config = [
        'host' => 'localhost',
        'user' => 'root',
        'pass' => 'root',
        'db'   => 'assistivetech_local',
    ];
} else {
    // Configurazione produzione Aruba
    $config = [
        'host' => '31.11.39.242',
        'user' => 'Sql1073852',
        'pass' => '5k58326940',
        'db'   => 'Sql1073852_1',
    ];
}

try {
    $pdo = new PDO(
        sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $config['host'], $config['db']),
        $config['user'],
        $config['pass'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Connessione al database fallita: ' . $e->getMessage(),
    ]);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true) ?? [];
$action = $_GET['action'] ?? $_POST['action'] ?? $input['action'] ?? '';

try {
    if ($method === 'POST') {
        gestisciPost($pdo, $action, $input);
    } elseif ($method === 'GET') {
        gestisciGet($pdo, $action);
    } else {
        rispostaErrore('Metodo non supportato: ' . $method, 405);
    }
} catch (Exception $e) {
    rispostaErrore($e->getMessage(), 500);
}

function gestisciPost(PDO $pdo, string $action, array $input): void
{
    switch ($action) {
        case 'save':
            salvaVideo($pdo, $input);
            break;
        case 'delete':
            eliminaVideo($pdo, $input);
            break;
        default:
            rispostaErrore('Azione POST non riconosciuta: ' . $action, 400);
    }
}

function gestisciGet(PDO $pdo, string $action): void
{
    switch ($action) {
        case 'list':
            $nomeUtente = trim($_GET['nome_utente'] ?? '');
            listaVideo($pdo, $nomeUtente);
            break;
        case 'get_pazienti':
            getPazienti($pdo);
            break;
        default:
            rispostaErrore('Azione GET non riconosciuta: ' . $action, 400);
    }
}

function salvaVideo(PDO $pdo, array $input): void
{
    $nomeVideo = trim($input['nome_video'] ?? '');
    $categoria = trim($input['categoria'] ?? '');
    $link = trim($input['link_youtube'] ?? '');
    $nomeUtente = trim($input['nome_utente'] ?? '');
    
    // Campi opzionali per "ascolto e rispondo"
    $inizioBrano = isset($input['inizio_brano']) ? (int)$input['inizio_brano'] : 0;
    $fineBrano = isset($input['fine_brano']) ? (int)$input['fine_brano'] : 0;
    $domanda = trim($input['domanda'] ?? '');

    if ($nomeVideo === '') {
        throw new InvalidArgumentException('Il nome del video è obbligatorio.');
    }
    if ($categoria === '') {
        throw new InvalidArgumentException('La categoria è obbligatoria.');
    }
    if ($link === '') {
        throw new InvalidArgumentException('Il link YouTube è obbligatorio.');
    }
    if ($nomeUtente === '') {
        throw new InvalidArgumentException('Il nome utente è obbligatorio.');
    }

    if (!isValidYouTubeUrl($link)) {
        throw new InvalidArgumentException('Il link fornito non sembra un URL YouTube valido.');
    }

    $stmt = $pdo->prepare('
        INSERT INTO video_yt (nome_video, categoria, link_youtube, nome_utente, inizio_brano, fine_brano, domanda, data_creazione)
        VALUES (:nome_video, :categoria, :link_youtube, :nome_utente, :inizio_brano, :fine_brano, :domanda, :data_creazione)
    ');

    $dataCreazione = date('d/m/Y H:i:s');

    $stmt->execute([
        'nome_video' => $nomeVideo,
        'categoria' => $categoria,
        'link_youtube' => $link,
        'nome_utente' => $nomeUtente,
        'inizio_brano' => $inizioBrano,
        'fine_brano' => $fineBrano,
        'domanda' => $domanda,
        'data_creazione' => $dataCreazione,
    ]);

    $id = (int) $pdo->lastInsertId();

    rispostaOk([
        'data' => [
            'id_video' => $id,
            'nome_video' => $nomeVideo,
            'categoria' => $categoria,
            'link_youtube' => $link,
            'nome_utente' => $nomeUtente,
            'inizio_brano' => $inizioBrano,
            'fine_brano' => $fineBrano,
            'domanda' => $domanda,
            'data_creazione' => $dataCreazione,
        ],
        'message' => 'Video salvato con successo'
    ]);
}

function eliminaVideo(PDO $pdo, array $input): void
{
    $id = $input['id'] ?? null;
    $linkYoutube = trim($input['link_youtube'] ?? '');

    // Devo avere almeno uno dei due parametri
    if (!$id && $linkYoutube === '') {
        throw new InvalidArgumentException('Specificare id o link_youtube per eliminare il video.');
    }

    // Preparo la query in base a quale parametro è disponibile
    if ($id) {
        $stmt = $pdo->prepare('DELETE FROM video_yt WHERE id_video = :id');
        $stmt->execute(['id' => $id]);
    } else {
        $stmt = $pdo->prepare('DELETE FROM video_yt WHERE link_youtube = :link_youtube');
        $stmt->execute(['link_youtube' => $linkYoutube]);
    }

    $rowCount = $stmt->rowCount();

    if ($rowCount === 0) {
        rispostaErrore('Nessun video trovato con i parametri specificati.', 404);
    }

    rispostaOk([
        'message' => 'Video eliminato con successo',
        'deleted_count' => $rowCount
    ]);
}

function listaVideo(PDO $pdo, string $nomeUtente): void
{
    if ($nomeUtente === '') {
        throw new InvalidArgumentException('Specificare il parametro nome_utente.');
    }

    $stmt = $pdo->prepare('
        SELECT 
            id_video, 
            nome_video, 
            categoria, 
            link_youtube, 
            nome_utente, 
            inizio_brano, 
            fine_brano, 
            domanda, 
            data_creazione
        FROM video_yt
        WHERE nome_utente = :nome_utente
        ORDER BY data_creazione DESC
    ');
    $stmt->execute(['nome_utente' => $nomeUtente]);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    rispostaOk(['data' => $data]);
}

// Recupera lista pazienti per dropdown
function getPazienti(PDO $pdo): void
{
    $stmt = $pdo->prepare('
        SELECT 
            id_paziente, 
            nome_paziente, 
            cognome_paziente
        FROM pazienti
        ORDER BY cognome_paziente ASC, nome_paziente ASC
    ');
    $stmt->execute();
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    rispostaOk(['data' => $data]);
}

function isValidYouTubeUrl(string $url): bool
{
    $pattern = '/^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\//i';
    return (bool) preg_match($pattern, $url);
}

function rispostaOk(array $payload): void
{
    echo json_encode(['success' => true] + $payload);
    exit();
}

function rispostaErrore(string $messaggio, int $status = 400): void
{
    http_response_code($status);
    echo json_encode([
        'success' => false,
        'error' => $messaggio,
    ]);
    exit();
}

