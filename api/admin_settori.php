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

// Funzione per validare i dati settore
function validateSettore($nome_settore, $id_settore = null) {
    if (empty(trim($nome_settore))) {
        return 'Nome settore è obbligatorio';
    }

    if (strlen(trim($nome_settore)) < 2) {
        return 'Nome settore deve avere almeno 2 caratteri';
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
            // Lista tutti i settori
            $stmt = $pdo->prepare("
                SELECT s.*,
                       (SELECT COUNT(*) FROM classi c WHERE c.id_settore = s.id_settore AND c.stato_classe = 'attiva') as numero_classi,
                       (SELECT COUNT(*) FROM educatori e WHERE e.id_settore = s.id_settore) as numero_educatori,
                       (SELECT COUNT(*) FROM pazienti p WHERE p.id_settore = s.id_settore) as numero_pazienti
                FROM settori s
                ORDER BY s.ordine_visualizzazione, s.nome_settore
            ");
            $stmt->execute();
            $settori = $stmt->fetchAll(PDO::FETCH_ASSOC);

            jsonResponse(true, 'Settori recuperati con successo', $settori);

        } elseif ($action === 'get' && isset($_GET['id'])) {
            // Dettagli singolo settore
            $id = intval($_GET['id']);
            $stmt = $pdo->prepare("
                SELECT s.*,
                       (SELECT COUNT(*) FROM classi c WHERE c.id_settore = s.id_settore) as numero_classi
                FROM settori s
                WHERE s.id_settore = :id
            ");
            $stmt->execute([':id' => $id]);
            $settore = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($settore) {
                jsonResponse(true, 'Settore trovato', $settore);
            } else {
                jsonResponse(false, 'Settore non trovato');
            }

        } else {
            jsonResponse(false, 'Azione non riconosciuta');
        }

    } elseif ($method === 'POST') {
        // Crea nuovo settore
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input) {
            jsonResponse(false, 'Dati non validi');
        }

        $nome_settore = trim($input['nome_settore'] ?? '');
        $descrizione = trim($input['descrizione'] ?? '');
        $ordine_visualizzazione = intval($input['ordine_visualizzazione'] ?? 0);
        $stato_settore = $input['stato_settore'] ?? 'attivo';

        // Validazione
        $validation = validateSettore($nome_settore);
        if ($validation !== true) {
            jsonResponse(false, $validation);
        }

        // Verifica unicità nome
        $stmt = $pdo->prepare("SELECT id_settore FROM settori WHERE nome_settore = :nome");
        $stmt->execute([':nome' => $nome_settore]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Un settore con questo nome esiste già');
        }

        // Se ordine non specificato, metti alla fine
        if ($ordine_visualizzazione === 0) {
            $stmt = $pdo->prepare("SELECT MAX(ordine_visualizzazione) as max_ordine FROM settori");
            $stmt->execute();
            $max_ordine = $stmt->fetchColumn();
            $ordine_visualizzazione = $max_ordine + 1;
        }

        // Inserimento
        $stmt = $pdo->prepare("
            INSERT INTO settori (nome_settore, descrizione, ordine_visualizzazione, stato_settore, data_creazione)
            VALUES (:nome, :descrizione, :ordine, :stato, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
        ");

        $result = $stmt->execute([
            ':nome' => $nome_settore,
            ':descrizione' => $descrizione,
            ':ordine' => $ordine_visualizzazione,
            ':stato' => $stato_settore
        ]);

        if ($result) {
            $id_nuovo = $pdo->lastInsertId();
            jsonResponse(true, 'Settore creato con successo', ['id_settore' => $id_nuovo]);
        } else {
            jsonResponse(false, 'Errore nella creazione del settore');
        }

    } elseif ($method === 'PUT') {
        // Aggiorna settore esistente
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input || !isset($input['id_settore'])) {
            jsonResponse(false, 'ID settore mancante');
        }

        $id_settore = intval($input['id_settore']);
        $nome_settore = trim($input['nome_settore'] ?? '');
        $descrizione = trim($input['descrizione'] ?? '');
        $ordine_visualizzazione = intval($input['ordine_visualizzazione'] ?? 0);
        $stato_settore = $input['stato_settore'] ?? 'attivo';

        // Validazione
        $validation = validateSettore($nome_settore, $id_settore);
        if ($validation !== true) {
            jsonResponse(false, $validation);
        }

        // Verifica che il settore esista
        $stmt = $pdo->prepare("SELECT id_settore FROM settori WHERE id_settore = :id");
        $stmt->execute([':id' => $id_settore]);
        if (!$stmt->fetch()) {
            jsonResponse(false, 'Settore non trovato');
        }

        // Verifica unicità nome (escluso il settore corrente)
        $stmt = $pdo->prepare("SELECT id_settore FROM settori WHERE nome_settore = :nome AND id_settore != :id");
        $stmt->execute([':nome' => $nome_settore, ':id' => $id_settore]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Un altro settore con questo nome esiste già');
        }

        // Aggiornamento
        $stmt = $pdo->prepare("
            UPDATE settori
            SET nome_settore = :nome,
                descrizione = :descrizione,
                ordine_visualizzazione = :ordine,
                stato_settore = :stato
            WHERE id_settore = :id
        ");

        $result = $stmt->execute([
            ':id' => $id_settore,
            ':nome' => $nome_settore,
            ':descrizione' => $descrizione,
            ':ordine' => $ordine_visualizzazione,
            ':stato' => $stato_settore
        ]);

        if ($result) {
            jsonResponse(true, 'Settore aggiornato con successo');
        } else {
            jsonResponse(false, 'Errore nell\'aggiornamento del settore');
        }

    } elseif ($method === 'DELETE') {
        // Elimina settore
        $id_settore = intval($_GET['id'] ?? 0);

        if ($id_settore === 0) {
            jsonResponse(false, 'ID settore mancante');
        }

        // Verifica che il settore esista
        $stmt = $pdo->prepare("SELECT nome_settore FROM settori WHERE id_settore = :id");
        $stmt->execute([':id' => $id_settore]);
        $settore = $stmt->fetch();
        if (!$settore) {
            jsonResponse(false, 'Settore non trovato');
        }

        // Verifica se ci sono classi associate
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM classi WHERE id_settore = :id");
        $stmt->execute([':id' => $id_settore]);
        $classi_count = $stmt->fetchColumn();

        if ($classi_count > 0) {
            jsonResponse(false, "Impossibile eliminare: il settore '{$settore['nome_settore']}' ha $classi_count classi associate");
        }

        // Verifica se ci sono utenti associati
        $stmt = $pdo->prepare("
            SELECT
                (SELECT COUNT(*) FROM educatori WHERE id_settore = :id) +
                (SELECT COUNT(*) FROM pazienti WHERE id_settore = :id) as utenti_totali
        ");
        $stmt->execute([':id' => $id_settore]);
        $utenti_count = $stmt->fetchColumn();

        if ($utenti_count > 0) {
            jsonResponse(false, "Impossibile eliminare: il settore '{$settore['nome_settore']}' ha $utenti_count utenti associati");
        }

        // Eliminazione
        $stmt = $pdo->prepare("DELETE FROM settori WHERE id_settore = :id");
        $result = $stmt->execute([':id' => $id_settore]);

        if ($result) {
            jsonResponse(true, 'Settore eliminato con successo');
        } else {
            jsonResponse(false, 'Errore nell\'eliminazione del settore');
        }

    } else {
        jsonResponse(false, 'Metodo HTTP non supportato');
    }

} catch (PDOException $e) {
    error_log("Errore database in admin_settori.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio');
} catch (Exception $e) {
    error_log("Errore generale in admin_settori.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server');
}
?>