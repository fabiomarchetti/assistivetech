<?php
/**
 * API helper per ottenere lista pazienti
 * Usato da varie applicazioni
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/config.php';

function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $pdo = getDbConnection();

    // Query flessibile: prova prima tabella pazienti, poi registrazioni
    $possibleQueries = [
        // Tentativo 1: Tabella pazienti (struttura AssistiveTech)
        "SELECT id_paziente as id_registrazione, 
                CONCAT(nome_paziente, ' ', cognome_paziente) as username,
                nome_paziente as nome, 
                cognome_paziente as cognome 
         FROM pazienti 
         ORDER BY nome_paziente ASC",
        
        // Tentativo 2: Tabella registrazioni con username
        "SELECT id_registrazione, username, nome, cognome 
         FROM registrazioni 
         WHERE ruolo = 'paziente' 
         ORDER BY username ASC",
        
        // Tentativo 3: Tabella registrazioni con nome_utente
        "SELECT id_registrazione, nome_utente as username, nome, cognome 
         FROM registrazioni 
         WHERE ruolo = 'paziente' 
         ORDER BY nome_utente ASC",
        
        // Tentativo 4: Tabella registrazioni - costruisci username
        "SELECT id_registrazione, 
                CONCAT(COALESCE(nome, ''), ' ', COALESCE(cognome, '')) as username,
                nome, 
                cognome 
         FROM registrazioni 
         WHERE ruolo = 'paziente' 
         ORDER BY nome ASC",
        
        // Tentativo 5: Fallback - tutti i campi da registrazioni
        "SELECT * FROM registrazioni WHERE ruolo = 'paziente' ORDER BY id_registrazione ASC"
    ];

    $pazienti = null;
    $usedQuery = null;
    $tableUsed = null;

    foreach ($possibleQueries as $index => $sql) {
        try {
            $stmt = $pdo->query($sql);
            $pazienti = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $usedQuery = $index + 1;
            
            // Determina quale tabella è stata usata
            if (strpos($sql, 'FROM pazienti') !== false) {
                $tableUsed = 'pazienti';
            } else {
                $tableUsed = 'registrazioni';
            }
            
            break; // Query riuscita, esci dal loop
        } catch (PDOException $e) {
            // Query fallita, prova la prossima
            continue;
        }
    }

    if ($pazienti === null) {
        throw new Exception("Nessuna query funzionante trovata. Verifica che esista la tabella 'pazienti' o 'registrazioni'");
    }

    // Normalizza i dati: assicura che ci sia sempre un campo "username" e "id_registrazione"
    foreach ($pazienti as &$paziente) {
        // Assicura id_registrazione
        if (!isset($paziente['id_registrazione'])) {
            if (isset($paziente['id_paziente'])) {
                $paziente['id_registrazione'] = $paziente['id_paziente'];
            }
        }
        
        // Assicura username
        if (!isset($paziente['username']) || empty($paziente['username'])) {
            // Crea username da nome/cognome
            if (!empty($paziente['nome']) || !empty($paziente['cognome'])) {
                $paziente['username'] = trim(($paziente['nome'] ?? '') . ' ' . ($paziente['cognome'] ?? ''));
            } elseif (!empty($paziente['nome_paziente']) || !empty($paziente['cognome_paziente'])) {
                $paziente['username'] = trim(($paziente['nome_paziente'] ?? '') . ' ' . ($paziente['cognome_paziente'] ?? ''));
            } elseif (!empty($paziente['nome_utente'])) {
                $paziente['username'] = $paziente['nome_utente'];
            } else {
                $paziente['username'] = 'Paziente #' . $paziente['id_registrazione'];
            }
        }
    }

    jsonResponse(true, "Pazienti caricati da '$tableUsed' (query #$usedQuery)", $pazienti);

} catch (PDOException $e) {
    error_log("Database Error: " . $e->getMessage());
    jsonResponse(false, 'Errore database: ' . $e->getMessage());
} catch (Exception $e) {
    error_log("Generic Error: " . $e->getMessage());
    jsonResponse(false, 'Errore: ' . $e->getMessage());
}

