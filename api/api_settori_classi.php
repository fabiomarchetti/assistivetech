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

// Configurazione database auto (locale/produzione)
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

// Funzione per log delle operazioni
function logOperation($action, $details, $ip) {
    $logFile = '../logs/settori_classi.log';
    $logDir = dirname($logFile);

    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $action - $details - IP: $ip\n";

    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

try {
    // Connessione al database
    $pdo = getDbConnection();

    // Leggi i dati JSON dalla richiesta
    $rawBody = file_get_contents('php://input');
    $input = json_decode($rawBody ?: '[]', true);
    $action = $input['action'] ?? $_GET['action'] ?? '';
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    // ===================== GESTIONE SETTORI =====================
    if ($action === 'get_settori') {
        // Recupera tutti i settori dalla tabella dedicata con conteggio utilizzi
        $stmt = $pdo->prepare("
            SELECT
                s.id_settore,
                s.nome_settore as nome,
                s.descrizione,
                (
                    SELECT COUNT(*) FROM educatori e WHERE e.id_settore = s.id_settore
                ) + (
                    SELECT COUNT(*) FROM pazienti p WHERE p.id_settore = s.id_settore
                ) as utilizzo
            FROM settori s
            ORDER BY s.nome_settore
        ");
        $stmt->execute();
        $settori = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Settori recuperati con successo', $settori);

    } elseif ($action === 'create_settore') {
        // Crea nuovo settore nella tabella dedicata
        $nome_settore = trim($input['nome'] ?? '');
        $descrizione = trim($input['descrizione'] ?? '');

        if (empty($nome_settore)) {
            jsonResponse(false, 'Nome settore è obbligatorio');
        }

        // Verifica se il settore esiste già
        $stmt_check = $pdo->prepare("SELECT COUNT(*) as count FROM settori WHERE nome_settore = :nome");
        $stmt_check->execute([':nome' => $nome_settore]);
        $exists = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if ($exists['count'] > 0) {
            jsonResponse(false, 'Il settore esiste già nel sistema');
        }

        // Inserisci nuovo settore
        $stmt = $pdo->prepare("
            INSERT INTO settori (nome_settore, descrizione, data_creazione)
            VALUES (:nome, :descrizione, NOW())
        ");
        $result = $stmt->execute([
            ':nome' => $nome_settore,
            ':descrizione' => $descrizione
        ]);

        if ($result) {
            logOperation('CREATE_SETTORE', "Nome: $nome_settore", $ip);
            jsonResponse(true, 'Settore creato con successo', ['nome' => $nome_settore]);
        } else {
            jsonResponse(false, 'Errore nella creazione del settore');
        }

    } elseif ($action === 'delete_settore') {
        // "Elimina" settore (verifica che non sia in uso)
        $nome_settore = trim($input['nome'] ?? '');

        if (empty($nome_settore)) {
            jsonResponse(false, 'Nome settore è obbligatorio');
        }

        // Verifica se il settore è in uso
        $stmt_check = $pdo->prepare("
            SELECT COUNT(*) as count FROM (
                SELECT settore FROM educatori WHERE settore = :settore
                UNION ALL
                SELECT settore FROM pazienti WHERE settore = :settore
            ) as check_utilizzo
        ");
        $stmt_check->execute([':settore' => $nome_settore]);
        $in_uso = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if ($in_uso['count'] > 0) {
            jsonResponse(false, 'Impossibile eliminare: il settore è attualmente in uso');
        }

        logOperation('DELETE_SETTORE', "Nome: $nome_settore", $ip);
        jsonResponse(true, 'Settore rimosso dal sistema');

    // ===================== GESTIONE CLASSI =====================
    } elseif ($action === 'get_classi') {
        // Recupera tutte le classi dalla tabella dedicata con settore e conteggio utilizzi
        $stmt = $pdo->prepare("
            SELECT
                c.id_classe,
                c.nome_classe as nome,
                c.descrizione,
                s.nome_settore as settore,
                c.id_settore,
                (
                    SELECT COUNT(*) FROM educatori e WHERE e.id_classe = c.id_classe
                ) + (
                    SELECT COUNT(*) FROM pazienti p WHERE p.id_classe = c.id_classe
                ) as utilizzo
            FROM classi c
            LEFT JOIN settori s ON c.id_settore = s.id_settore
            ORDER BY s.nome_settore, c.nome_classe
        ");
        $stmt->execute();
        $classi = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Classi recuperate con successo', $classi);

    } elseif ($action === 'create_classe') {
        // Crea nuova classe nella tabella dedicata
        $nome_classe = trim($input['nome'] ?? '');
        $descrizione = trim($input['descrizione'] ?? '');
        $id_settore = intval($input['id_settore'] ?? 0);

        if (empty($nome_classe)) {
            jsonResponse(false, 'Nome classe è obbligatorio');
        }

        if (empty($id_settore)) {
            jsonResponse(false, 'Settore è obbligatorio per la classe');
        }

        // Verifica se la classe esiste già nello stesso settore
        $stmt_check = $pdo->prepare("
            SELECT COUNT(*) as count FROM classi
            WHERE nome_classe = :nome AND id_settore = :id_settore
        ");
        $stmt_check->execute([':nome' => $nome_classe, ':id_settore' => $id_settore]);
        $exists = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if ($exists['count'] > 0) {
            jsonResponse(false, 'La classe esiste già in questo settore');
        }

        // Inserisci nuova classe
        $stmt = $pdo->prepare("
            INSERT INTO classi (nome_classe, descrizione, id_settore, data_creazione)
            VALUES (:nome, :descrizione, :id_settore, NOW())
        ");
        $result = $stmt->execute([
            ':nome' => $nome_classe,
            ':descrizione' => $descrizione,
            ':id_settore' => $id_settore
        ]);

        if ($result) {
            logOperation('CREATE_CLASSE', "Nome: $nome_classe, Settore: $id_settore", $ip);
            jsonResponse(true, 'Classe creata con successo', ['nome' => $nome_classe]);
        } else {
            jsonResponse(false, 'Errore nella creazione della classe');
        }

    } elseif ($action === 'delete_classe') {
        // "Elimina" classe (verifica che non sia in uso)
        $nome_classe = trim($input['nome'] ?? '');

        if (empty($nome_classe)) {
            jsonResponse(false, 'Nome classe è obbligatorio');
        }

        // Verifica se la classe è in uso
        $stmt_check = $pdo->prepare("
            SELECT COUNT(*) as count FROM (
                SELECT classe FROM educatori WHERE classe = :classe
                UNION ALL
                SELECT classe FROM pazienti WHERE classe = :classe
            ) as check_utilizzo
        ");
        $stmt_check->execute([':classe' => $nome_classe]);
        $in_uso = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if ($in_uso['count'] > 0) {
            jsonResponse(false, 'Impossibile eliminare: la classe è attualmente in uso');
        }

        logOperation('DELETE_CLASSE', "Nome: $nome_classe", $ip);
        jsonResponse(true, 'Classe rimossa dal sistema');

    // ===================== STATISTICHE =====================
    } elseif ($action === 'get_statistics') {
        // Recupera statistiche su settori e classi
        $stmt_settori = $pdo->prepare("
            SELECT 
                COUNT(DISTINCT settore) as totale_settori,
                COUNT(*) as totale_utilizzi_settori
            FROM (
                SELECT settore FROM educatori WHERE settore IS NOT NULL AND settore != ''
                UNION ALL
                SELECT settore FROM pazienti WHERE settore IS NOT NULL AND settore != ''
            ) as settori_stats
        ");
        $stmt_settori->execute();
        $stats_settori = $stmt_settori->fetch(PDO::FETCH_ASSOC);

        $stmt_classi = $pdo->prepare("
            SELECT 
                COUNT(DISTINCT classe) as totale_classi,
                COUNT(*) as totale_utilizzi_classi
            FROM (
                SELECT classe FROM educatori WHERE classe IS NOT NULL AND classe != ''
                UNION ALL
                SELECT classe FROM pazienti WHERE classe IS NOT NULL AND classe != ''
            ) as classi_stats
        ");
        $stmt_classi->execute();
        $stats_classi = $stmt_classi->fetch(PDO::FETCH_ASSOC);

        $statistiche = [
            'settori' => $stats_settori,
            'classi' => $stats_classi
        ];

        jsonResponse(true, 'Statistiche recuperate con successo', $statistiche);

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_settori_classi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in api_settori_classi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>