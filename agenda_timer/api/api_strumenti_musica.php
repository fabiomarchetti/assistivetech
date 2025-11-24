<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: https://www.assistivetech.it');
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Max-Age: 86400');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$config = [
    'host' => '31.11.39.242',
    'user' => 'Sql1073852',
    'pass' => '5k58326940',
    'db'   => 'Sql1073852_1',
];

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
    switch ($method) {
        case 'GET':
            gestisciGet($pdo, $action);
            break;
        case 'POST':
            gestisciPost($pdo, $action, $input);
            break;
        case 'DELETE':
            gestisciDelete($pdo, $action);
            break;
        default:
            rispostaErrore('Metodo non supportato: ' . $method, 405);
    }
} catch (Exception $e) {
    rispostaErrore($e->getMessage(), 500);
}

function gestisciGet(PDO $pdo, string $action): void
{
    switch ($action) {
        case 'resolve_credentials':
            $utente = trim($_GET['utente'] ?? '');
            $educatore = trim($_GET['educatore'] ?? '');
            if ($utente === '' || $educatore === '') {
                throw new InvalidArgumentException('Parametri utente o educatore mancanti.');
            }
            $ids = risolviCredenziali($pdo, $utente, $educatore);
            rispostaOk(['data' => $ids]);
            break;
        case 'list':
            $utente = trim($_GET['utente'] ?? '');
            $educatore = trim($_GET['educatore'] ?? '');
            if ($utente === '' || $educatore === '') {
                throw new InvalidArgumentException('Parametri utente o educatore mancanti.');
            }
            $ids = risolviCredenziali($pdo, $utente, $educatore);
            $lista = recuperaBrani($pdo, $ids['id_utente'], $ids['id_educatore']);
            rispostaOk(['data' => $lista]);
            break;
        case 'random':
            $utente = trim($_GET['utente'] ?? '');
            $educatore = trim($_GET['educatore'] ?? '');
            if ($utente === '' || $educatore === '') {
                throw new InvalidArgumentException('Parametri utente o educatore mancanti.');
            }
            $ids = risolviCredenziali($pdo, $utente, $educatore);
            $brano = recuperaBranoCasuale($pdo, $ids['id_utente'], $ids['id_educatore']);
            rispostaOk(['data' => $brano]);
            break;
        default:
            rispostaErrore('Azione GET non riconosciuta: ' . $action, 400);
    }
}

function gestisciPost(PDO $pdo, string $action, array $input): void
{
    switch ($action) {
        case 'create':
            $dati = validaDatiCreazione($pdo, $input);
            $nuovo = inserisciBrano($pdo, $dati);
            rispostaOk(['data' => $nuovo, 'message' => 'Brano creato con successo']);
            break;
        default:
            rispostaErrore('Azione POST non riconosciuta: ' . $action, 400);
    }
}

function gestisciDelete(PDO $pdo, string $action): void
{
    switch ($action) {
        case 'delete':
            $id = intval($_GET['id'] ?? 0);
            if ($id <= 0) {
                throw new InvalidArgumentException('ID brano non valido.');
            }
            eliminaBrano($pdo, $id);
            rispostaOk(['message' => 'Brano eliminato']);
            break;
        default:
            rispostaErrore('Azione DELETE non riconosciuta: ' . $action, 400);
    }
}

function risolviCredenziali(PDO $pdo, string $utente, string $educatore): array
{
    $sql = 'SELECT id_registrazione, username_registrazione FROM registrazioni WHERE username_registrazione = :username LIMIT 1';

    $stmtUtente = $pdo->prepare($sql);
    $stmtUtente->execute(['username' => $utente]);
    $rowUtente = $stmtUtente->fetch(PDO::FETCH_ASSOC);
    if (!$rowUtente) {
        throw new RuntimeException("Utente '{$utente}' non trovato nelle registrazioni.");
    }

    $stmtEducatore = $pdo->prepare($sql);
    $stmtEducatore->execute(['username' => $educatore]);
    $rowEducatore = $stmtEducatore->fetch(PDO::FETCH_ASSOC);
    if (!$rowEducatore) {
        throw new RuntimeException("Educatore '{$educatore}' non trovato nelle registrazioni.");
    }

    return [
        'id_utente' => intval($rowUtente['id_registrazione']),
        'id_educatore' => intval($rowEducatore['id_registrazione']),
    ];
}

function recuperaBrani(PDO $pdo, int $idUtente, int $idEducatore): array
{
    $stmt = $pdo->prepare('
        SELECT id, id_utente, id_educatore, nome_brano, link_brano, categoria_brano,
               durata_preferita_sec, created_at, updated_at
        FROM strumenti_youtube
        WHERE id_utente = :id_utente AND id_educatore = :id_educatore AND is_deleted = 0
        ORDER BY created_at DESC
    ');
    $stmt->execute([
        'id_utente' => $idUtente,
        'id_educatore' => $idEducatore,
    ]);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
    return array_map(static function ($row) {
        $row['id'] = intval($row['id']);
        $row['id_utente'] = intval($row['id_utente']);
        $row['id_educatore'] = intval($row['id_educatore']);
        $row['durata_preferita_sec'] = intval($row['durata_preferita_sec']);
        return $row;
    }, $records);
}

function recuperaBranoCasuale(PDO $pdo, int $idUtente, int $idEducatore): ?array
{
    $stmt = $pdo->prepare('
        SELECT id, id_utente, id_educatore, nome_brano, link_brano, categoria_brano,
               durata_preferita_sec, created_at, updated_at
        FROM strumenti_youtube
        WHERE id_utente = :id_utente AND id_educatore = :id_educatore AND is_deleted = 0
        ORDER BY RAND()
        LIMIT 1
    ');
    $stmt->execute([
        'id_utente' => $idUtente,
        'id_educatore' => $idEducatore,
    ]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        return null;
    }
    $row['id'] = intval($row['id']);
    $row['id_utente'] = intval($row['id_utente']);
    $row['id_educatore'] = intval($row['id_educatore']);
    $row['durata_preferita_sec'] = intval($row['durata_preferita_sec']);
    return $row;
}

function validaDatiCreazione(PDO $pdo, array $input): array
{
    $nome = trim($input['nome_brano'] ?? '');
    $categoria = trim($input['categoria_brano'] ?? '');
    $link = trim($input['link_brano'] ?? '');
    $durata = intval($input['durata_preferita_sec'] ?? 0);
    $idUtente = intval($input['id_utente'] ?? 0);
    $idEducatore = intval($input['id_educatore'] ?? 0);

    if ($nome === '') {
        throw new InvalidArgumentException('Il nome del brano è obbligatorio.');
    }
    if ($categoria === '') {
        throw new InvalidArgumentException('La categoria del brano è obbligatoria.');
    }
    if ($link === '') {
        throw new InvalidArgumentException('Il link del brano è obbligatorio.');
    }
    if ($idUtente <= 0 || $idEducatore <= 0) {
        throw new InvalidArgumentException('Identificativi utente o educatore non validi.');
    }

    $pattern = '/^(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)[^\s]+$/i';
    if (!preg_match($pattern, $link)) {
        throw new InvalidArgumentException('Il link fornito non sembra un URL YouTube valido.');
    }

    // Verifica esistenza utente/educatore
    verificaRegistrazione($pdo, $idUtente);
    verificaRegistrazione($pdo, $idEducatore);

    return [
        'nome_brano' => $nome,
        'categoria_brano' => $categoria,
        'link_brano' => $link,
        'durata_preferita_sec' => max(0, $durata),
        'id_utente' => $idUtente,
        'id_educatore' => $idEducatore,
    ];
}

function verificaRegistrazione(PDO $pdo, int $id): void
{
    $stmt = $pdo->prepare('SELECT id_registrazione FROM registrazioni WHERE id_registrazione = :id LIMIT 1');
    $stmt->execute(['id' => $id]);
    if (!$stmt->fetch()) {
        throw new RuntimeException('Registrazione non trovata per ID: ' . $id);
    }
}

function inserisciBrano(PDO $pdo, array $dati): array
{
    $stmt = $pdo->prepare('
        INSERT INTO strumenti_youtube
            (id_utente, id_educatore, nome_brano, link_brano, categoria_brano, durata_preferita_sec, created_at, updated_at)
        VALUES
            (:id_utente, :id_educatore, :nome_brano, :link_brano, :categoria_brano, :durata_preferita_sec, :created_at, :updated_at)
    ');

    $timestamp = date('Y-m-d H:i:s');
    $stmt->execute([
        'id_utente' => $dati['id_utente'],
        'id_educatore' => $dati['id_educatore'],
        'nome_brano' => $dati['nome_brano'],
        'link_brano' => $dati['link_brano'],
        'categoria_brano' => $dati['categoria_brano'],
        'durata_preferita_sec' => $dati['durata_preferita_sec'],
        'created_at' => $timestamp,
        'updated_at' => $timestamp,
    ]);

    $id = intval($pdo->lastInsertId());
    return [
        'id' => $id,
        'id_utente' => $dati['id_utente'],
        'id_educatore' => $dati['id_educatore'],
        'nome_brano' => $dati['nome_brano'],
        'link_brano' => $dati['link_brano'],
        'categoria_brano' => $dati['categoria_brano'],
        'durata_preferita_sec' => $dati['durata_preferita_sec'],
        'created_at' => $timestamp,
        'updated_at' => $timestamp,
    ];
}

function eliminaBrano(PDO $pdo, int $id): void
{
    $stmt = $pdo->prepare('UPDATE strumenti_youtube SET is_deleted = 1, updated_at = :updated_at WHERE id = :id');
    $stmt->execute([
        'id' => $id,
        'updated_at' => date('Y-m-d H:i:s'),
    ]);
    if ($stmt->rowCount() === 0) {
        throw new RuntimeException('Brano non trovato o già eliminato.');
    }
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



