<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Gestione richieste OPTIONS per CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurazione database centralizzata (auto locale/produzione)
require_once __DIR__ . '/config.php';

// Funzione per rispondere con JSON
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ]);
    exit();
}

// Funzione per validare i dati classe
function validateClasse($nome_classe, $id_settore) {
    if (empty(trim($nome_classe))) {
        return 'Nome classe è obbligatorio';
    }

    if (strlen(trim($nome_classe)) < 1) {
        return 'Nome classe deve avere almeno 1 carattere';
    }

    if (intval($id_settore) === 0) {
        return 'Settore di appartenenza è obbligatorio';
    }

    return true;
}

try {
    // Connessione al database
    $pdo = getDbConnection();

    // Determina l'azione
    $method = $_SERVER['REQUEST_METHOD'];
    $action = $_GET['action'] ?? '';

    if ($method === 'GET') {
        if ($action === 'list' || empty($action)) {
            // Lista tutte le classi con settore
            $id_settore = intval($_GET['id_settore'] ?? 0);

            $where_clause = '';
            $params = [];

            if ($id_settore > 0) {
                $where_clause = 'WHERE c.id_settore = :id_settore';
                $params[':id_settore'] = $id_settore;
            }

            $stmt = $pdo->prepare("
                SELECT c.*,
                       s.nome_settore,
                       (SELECT COUNT(*) FROM educatori e WHERE e.id_classe = c.id_classe) as numero_educatori,
                       (SELECT COUNT(*) FROM pazienti p WHERE p.id_classe = c.id_classe) as numero_pazienti
                FROM classi c
                JOIN settori s ON c.id_settore = s.id_settore
                $where_clause
                ORDER BY s.ordine_visualizzazione, c.ordine_visualizzazione, c.nome_classe
            ");
            $stmt->execute($params);
            $classi = $stmt->fetchAll(PDO::FETCH_ASSOC);

            jsonResponse(true, 'Classi recuperate con successo', $classi);

        } elseif ($action === 'get' && isset($_GET['id'])) {
            // Dettagli singola classe
            $id = intval($_GET['id']);
            $stmt = $pdo->prepare("
                SELECT c.*, s.nome_settore
                FROM classi c
                JOIN settori s ON c.id_settore = s.id_settore
                WHERE c.id_classe = :id
            ");
            $stmt->execute([':id' => $id]);
            $classe = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($classe) {
                jsonResponse(true, 'Classe trovata', $classe);
            } else {
                jsonResponse(false, 'Classe non trovata');
            }

        } else {
            jsonResponse(false, 'Azione non riconosciuta');
        }

    } elseif ($method === 'POST') {
        // Crea nuova classe
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input) {
            jsonResponse(false, 'Dati non validi');
        }

        $id_settore = intval($input['id_settore'] ?? 0);
        $nome_classe = trim($input['nome_classe'] ?? '');
        $descrizione = trim($input['descrizione'] ?? '');
        $ordine_visualizzazione = intval($input['ordine_visualizzazione'] ?? 0);
        $stato_classe = $input['stato_classe'] ?? 'attiva';

        // Validazione
        $validation = validateClasse($nome_classe, $id_settore);
        if ($validation !== true) {
            jsonResponse(false, $validation);
        }

        // Verifica che il settore esista
        $stmt = $pdo->prepare("SELECT nome_settore FROM settori WHERE id_settore = :id AND stato_settore = 'attivo'");
        $stmt->execute([':id' => $id_settore]);
        if (!$stmt->fetch()) {
            jsonResponse(false, 'Settore non trovato o non attivo');
        }

        // Verifica unicità nome classe nel settore
        $stmt = $pdo->prepare("SELECT id_classe FROM classi WHERE nome_classe = :nome AND id_settore = :settore");
        $stmt->execute([':nome' => $nome_classe, ':settore' => $id_settore]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Una classe con questo nome esiste già nel settore selezionato');
        }

        // Se ordine non specificato, metti alla fine nel settore
        if ($ordine_visualizzazione === 0) {
            $stmt = $pdo->prepare("SELECT MAX(ordine_visualizzazione) as max_ordine FROM classi WHERE id_settore = :settore");
            $stmt->execute([':settore' => $id_settore]);
            $max_ordine = $stmt->fetchColumn();
            $ordine_visualizzazione = ($max_ordine ?: 0) + 1;
        }

        // Inserimento
        $stmt = $pdo->prepare("
            INSERT INTO classi (id_settore, nome_classe, descrizione, ordine_visualizzazione, stato_classe, data_creazione)
            VALUES (:settore, :nome, :descrizione, :ordine, :stato, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
        ");

        $result = $stmt->execute([
            ':settore' => $id_settore,
            ':nome' => $nome_classe,
            ':descrizione' => $descrizione,
            ':ordine' => $ordine_visualizzazione,
            ':stato' => $stato_classe
        ]);

        if ($result) {
            $id_nuovo = $pdo->lastInsertId();
            jsonResponse(true, 'Classe creata con successo', ['id_classe' => $id_nuovo]);
        } else {
            jsonResponse(false, 'Errore nella creazione della classe');
        }

    } elseif ($method === 'PUT') {
        // Aggiorna classe esistente
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input || !isset($input['id_classe'])) {
            jsonResponse(false, 'ID classe mancante');
        }

        $id_classe = intval($input['id_classe']);
        $id_settore = intval($input['id_settore'] ?? 0);
        $nome_classe = trim($input['nome_classe'] ?? '');
        $descrizione = trim($input['descrizione'] ?? '');
        $ordine_visualizzazione = intval($input['ordine_visualizzazione'] ?? 0);
        $stato_classe = $input['stato_classe'] ?? 'attiva';

        // Validazione
        $validation = validateClasse($nome_classe, $id_settore);
        if ($validation !== true) {
            jsonResponse(false, $validation);
        }

        // Verifica che la classe esista
        $stmt = $pdo->prepare("SELECT id_classe FROM classi WHERE id_classe = :id");
        $stmt->execute([':id' => $id_classe]);
        if (!$stmt->fetch()) {
            jsonResponse(false, 'Classe non trovata');
        }

        // Verifica che il settore esista
        $stmt = $pdo->prepare("SELECT nome_settore FROM settori WHERE id_settore = :id");
        $stmt->execute([':id' => $id_settore]);
        if (!$stmt->fetch()) {
            jsonResponse(false, 'Settore non trovato');
        }

        // Verifica unicità nome classe nel settore (escluso la classe corrente)
        $stmt = $pdo->prepare("SELECT id_classe FROM classi WHERE nome_classe = :nome AND id_settore = :settore AND id_classe != :id");
        $stmt->execute([':nome' => $nome_classe, ':settore' => $id_settore, ':id' => $id_classe]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Un\'altra classe con questo nome esiste già nel settore selezionato');
        }

        // Aggiornamento
        $stmt = $pdo->prepare("
            UPDATE classi
            SET id_settore = :settore,
                nome_classe = :nome,
                descrizione = :descrizione,
                ordine_visualizzazione = :ordine,
                stato_classe = :stato
            WHERE id_classe = :id
        ");

        $result = $stmt->execute([
            ':id' => $id_classe,
            ':settore' => $id_settore,
            ':nome' => $nome_classe,
            ':descrizione' => $descrizione,
            ':ordine' => $ordine_visualizzazione,
            ':stato' => $stato_classe
        ]);

        if ($result) {
            jsonResponse(true, 'Classe aggiornata con successo');
        } else {
            jsonResponse(false, 'Errore nell\'aggiornamento della classe');
        }

    } elseif ($method === 'DELETE') {
        // Elimina classe
        $id_classe = intval($_GET['id'] ?? 0);

        if ($id_classe === 0) {
            jsonResponse(false, 'ID classe mancante');
        }

        // Verifica che la classe esista
        $stmt = $pdo->prepare("
            SELECT c.nome_classe, s.nome_settore
            FROM classi c
            JOIN settori s ON c.id_settore = s.id_settore
            WHERE c.id_classe = :id
        ");
        $stmt->execute([':id' => $id_classe]);
        $classe = $stmt->fetch();
        if (!$classe) {
            jsonResponse(false, 'Classe non trovata');
        }

        // Verifica se ci sono utenti associati
        $stmt = $pdo->prepare("
            SELECT
                (SELECT COUNT(*) FROM educatori WHERE id_classe = :id) +
                (SELECT COUNT(*) FROM pazienti WHERE id_classe = :id) as utenti_totali
        ");
        $stmt->execute([':id' => $id_classe]);
        $utenti_count = $stmt->fetchColumn();

        if ($utenti_count > 0) {
            jsonResponse(false, "Impossibile eliminare: la classe '{$classe['nome_classe']}' ha $utenti_count utenti associati");
        }

        // Eliminazione
        $stmt = $pdo->prepare("DELETE FROM classi WHERE id_classe = :id");
        $result = $stmt->execute([':id' => $id_classe]);

        if ($result) {
            jsonResponse(true, 'Classe eliminata con successo');
        } else {
            jsonResponse(false, 'Errore nell\'eliminazione della classe');
        }

    } else {
        jsonResponse(false, 'Metodo HTTP non supportato');
    }

} catch (PDOException $e) {
    error_log("Errore database in admin_classi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio');
} catch (Exception $e) {
    error_log("Errore generale in admin_classi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server');
}
?>