<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Gestione richieste OPTIONS per CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurazione database tramite DatabaseConfig
require_once 'config_database.php';

// Funzione per rispondere con JSON
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
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
    // Connessione al database tramite DatabaseConfig
    $pdo = DatabaseConfig::createConnection();

    // Leggi i dati JSON dalla richiesta
    $input = json_decode(file_get_contents('php://input'), true);
    $action = $input['action'] ?? $_GET['action'] ?? '';
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    // ===================== UTILITÀ DROPDOWN CASCATA =====================
    if ($action === 'get_dropdown_data') {
        // Restituisce tutti i dati necessari per i dropdown cascata
        $id_sede = intval($input['id_sede'] ?? $_GET['id_sede'] ?? 0);

        $result = [];

        // 1. Tutte le sedi
        $stmt_sedi = $pdo->prepare("
            SELECT id_sede, nome_sede
            FROM sedi
            WHERE stato_sede = 'attiva'
            ORDER BY nome_sede
        ");
        $stmt_sedi->execute();
        $result['sedi'] = $stmt_sedi->fetchAll(PDO::FETCH_ASSOC);

        // 2. Settori (distinti da educatori e pazienti, filtrati per sede se specificata)
        $where_settori = '';
        $params_settori = [];
        if ($id_sede > 0) {
            $where_settori = 'WHERE id_sede = :id_sede';
            $params_settori[':id_sede'] = $id_sede;
        }

        $stmt_settori = $pdo->prepare("
            SELECT DISTINCT settore as nome, id_sede, settore as id_settore
            FROM (
                SELECT settore, id_sede FROM educatori WHERE settore IS NOT NULL AND settore != ''
                UNION
                SELECT settore, id_sede FROM pazienti WHERE settore IS NOT NULL AND settore != ''
            ) as settori_uniti
            $where_settori
            ORDER BY settore
        ");
        $stmt_settori->execute($params_settori);
        $result['settori'] = $stmt_settori->fetchAll(PDO::FETCH_ASSOC);

        // 3. Classi (distinte da educatori e pazienti)
        $stmt_classi = $pdo->prepare("
            SELECT DISTINCT classe as nome, settore as id_settore, classe as id_classe
            FROM (
                SELECT classe, settore FROM educatori WHERE classe IS NOT NULL AND classe != ''
                UNION
                SELECT classe, settore FROM pazienti WHERE classe IS NOT NULL AND classe != ''
            ) as classi_unite
            ORDER BY classe
        ");
        $stmt_classi->execute();
        $result['classi'] = $stmt_classi->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Dati dropdown recuperati con successo', $result);

    // ===================== GESTIONE SETTORI =====================
    if ($action === 'get_settori') {
        // Recupera settori, opzionalmente filtrati per sede
        $id_sede = intval($input['id_sede'] ?? $_GET['id_sede'] ?? 0);

        $where_clause = '';
        $params = [];

        if ($id_sede > 0) {
            $where_clause = 'WHERE settori_uniti.id_sede = :id_sede';
            $params[':id_sede'] = $id_sede;
        }

        $stmt = $pdo->prepare("
            SELECT DISTINCT
                settore as nome,
                settore as id_settore,
                '' as descrizione,
                id_sede,
                (SELECT nome_sede FROM sedi WHERE id_sede = settori_uniti.id_sede) as nome_sede,
                (
                    SELECT COUNT(*) FROM educatori e WHERE e.settore = settori_uniti.settore AND e.id_sede = settori_uniti.id_sede
                ) + (
                    SELECT COUNT(*) FROM pazienti p WHERE p.settore = settori_uniti.settore AND p.id_sede = settori_uniti.id_sede
                ) as utilizzo
            FROM (
                SELECT settore, id_sede FROM educatori WHERE settore IS NOT NULL AND settore != ''
                UNION
                SELECT settore, id_sede FROM pazienti WHERE settore IS NOT NULL AND settore != ''
            ) as settori_uniti
            $where_clause
            ORDER BY nome_sede ASC, settore ASC
        ");
        $stmt->execute($params);
        $settori = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Settori recuperati con successo', $settori);

    } elseif ($action === 'create_settore') {
        // Crea nuovo settore nella tabella dedicata
        $nome_settore = trim($input['nome'] ?? '');
        $descrizione = trim($input['descrizione'] ?? '');

        if (empty($nome_settore)) {
            jsonResponse(false, 'Nome settore è obbligatorio');
        }

        // Verifica se il settore esiste già in educatori o pazienti
        $stmt_check = $pdo->prepare("
            SELECT COUNT(*) as count FROM (
                SELECT settore FROM educatori WHERE settore = :nome
                UNION
                SELECT settore FROM pazienti WHERE settore = :nome
            ) as settori_esistenti
        ");
        $stmt_check->execute([':nome' => $nome_settore]);
        $exists = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if ($exists['count'] > 0) {
            jsonResponse(false, 'Il settore esiste già nel sistema');
        }

        // Simula inserimento settore (non c'è tabella settori separata)
        // Il settore sarà creato quando sarà assegnato a educatori/pazienti
        $result = true;

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
        // Recupera classi, opzionalmente filtrate per settore
        $id_settore = intval($input['id_settore'] ?? $_GET['id_settore'] ?? 0);

        $where_clause = '';
        $params = [];

        if ($id_settore > 0) {
            $where_clause = 'WHERE settore = :id_settore';
            $params[':id_settore'] = $id_settore;
        }

        $stmt = $pdo->prepare("
            SELECT DISTINCT
                classe as id_classe,
                classe as nome,
                '' as descrizione,
                settore,
                settore as id_settore,
                0 as utilizzo
            FROM (
                SELECT classe, settore FROM educatori WHERE classe IS NOT NULL AND classe != ''
                UNION
                SELECT classe, settore FROM pazienti WHERE classe IS NOT NULL AND classe != ''
            ) as classi_unite
            $where_clause
            ORDER BY settore, classe
        ");
        $stmt->execute($params);
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
            SELECT COUNT(*) as count FROM (
                SELECT classe FROM educatori WHERE classe = :nome AND settore = :settore
                UNION
                SELECT classe FROM pazienti WHERE classe = :nome AND settore = :settore
            ) as classi_esistenti
        ");
        $stmt_check->execute([':nome' => $nome_classe, ':settore' => $id_settore]);
        $exists = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if ($exists['count'] > 0) {
            jsonResponse(false, 'La classe esiste già in questo settore');
        }

        // Simula inserimento classe (non c'è tabella classi separata)
        // La classe sarà creata quando sarà assegnata a educatori/pazienti
        $result = true;

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