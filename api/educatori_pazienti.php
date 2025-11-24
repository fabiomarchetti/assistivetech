<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
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

try {
    // Connessione al database
    $pdo = getDbConnection();

    // Determina l'azione
    $method = $_SERVER['REQUEST_METHOD'];
    $action = $_GET['action'] ?? '';
    $id_educatore = intval($_GET['id_educatore'] ?? 0);

    if ($method === 'GET') {

        if ($action === 'miei_pazienti' && $id_educatore > 0) {
            // Lista pazienti associati all'educatore
            $stmt = $pdo->prepare("
                SELECT
                    p.id_paziente,
                    r.id_registrazione,
                    r.nome_registrazione,
                    r.cognome_registrazione,
                    r.username_registrazione,
                    s.nome_sede,
                    set.nome_settore,
                    c.nome_classe,
                    ep.data_associazione,
                    ep.note,
                    ep.is_attiva
                FROM educatori_pazienti ep
                JOIN registrazioni r ON ep.id_paziente = r.id_registrazione
                JOIN pazienti p ON p.id_registrazione = r.id_registrazione
                LEFT JOIN sedi s ON p.id_sede = s.id_sede
                LEFT JOIN settori set ON p.id_settore = set.id_settore
                LEFT JOIN classi c ON p.id_classe = c.id_classe
                WHERE ep.id_educatore = :id_educatore AND ep.is_attiva = 1
                ORDER BY r.nome_registrazione, r.cognome_registrazione
            ");

            $stmt->execute([':id_educatore' => $id_educatore]);
            $pazienti = $stmt->fetchAll(PDO::FETCH_ASSOC);

            jsonResponse(true, 'Pazienti associati recuperati', $pazienti);

        } elseif ($action === 'pazienti_disponibili' && $id_educatore > 0) {
            // Lista pazienti NON ancora associati all'educatore
            $stmt = $pdo->prepare("
                SELECT
                    p.id_paziente,
                    r.id_registrazione,
                    r.nome_registrazione,
                    r.cognome_registrazione,
                    r.username_registrazione,
                    s.nome_sede,
                    set.nome_settore,
                    set.id_settore,
                    c.nome_classe,
                    c.id_classe,
                    r.data_registrazione
                FROM registrazioni r
                JOIN pazienti p ON p.id_registrazione = r.id_registrazione
                LEFT JOIN sedi s ON p.id_sede = s.id_sede
                LEFT JOIN settori set ON p.id_settore = set.id_settore
                LEFT JOIN classi c ON p.id_classe = c.id_classe
                WHERE r.ruolo_registrazione = 'paziente'
                  AND r.stato_account = 'attivo'
                  AND r.id_registrazione NOT IN (
                      SELECT ep.id_paziente
                      FROM educatori_pazienti ep
                      WHERE ep.id_educatore = :id_educatore AND ep.is_attiva = 1
                  )
                ORDER BY r.nome_registrazione, r.cognome_registrazione
            ");

            $stmt->execute([':id_educatore' => $id_educatore]);
            $pazienti = $stmt->fetchAll(PDO::FETCH_ASSOC);

            jsonResponse(true, 'Pazienti disponibili recuperati', $pazienti);

        } elseif ($action === 'dettagli_paziente') {
            $id_paziente = intval($_GET['id_paziente'] ?? 0);

            if ($id_paziente === 0) {
                jsonResponse(false, 'ID paziente mancante');
            }

            // Dettagli completi paziente
            $stmt = $pdo->prepare("
                SELECT
                    p.id_paziente,
                    r.id_registrazione,
                    r.nome_registrazione,
                    r.cognome_registrazione,
                    r.username_registrazione,
                    r.data_registrazione,
                    r.ultimo_accesso,
                    s.nome_sede,
                    set.nome_settore,
                    c.nome_classe,
                    ep.data_associazione,
                    ep.note
                FROM registrazioni r
                JOIN pazienti p ON p.id_registrazione = r.id_registrazione
                LEFT JOIN sedi s ON p.id_sede = s.id_sede
                LEFT JOIN settori set ON p.id_settore = set.id_settore
                LEFT JOIN classi c ON p.id_classe = c.id_classe
                LEFT JOIN educatori_pazienti ep ON (ep.id_paziente = r.id_registrazione AND ep.id_educatore = :id_educatore AND ep.is_attiva = 1)
                WHERE r.id_registrazione = :id_paziente
            ");

            $stmt->execute([
                ':id_paziente' => $id_paziente,
                ':id_educatore' => $id_educatore
            ]);
            $paziente = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($paziente) {
                jsonResponse(true, 'Dettagli paziente recuperati', $paziente);
            } else {
                jsonResponse(false, 'Paziente non trovato');
            }

        } else {
            jsonResponse(false, 'Azione non riconosciuta o parametri mancanti');
        }

    } elseif ($method === 'POST') {
        // Associa pazienti all'educatore
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input || !isset($input['id_educatore']) || !isset($input['pazienti_ids'])) {
            jsonResponse(false, 'Dati non validi o mancanti');
        }

        $id_educatore = intval($input['id_educatore']);
        $pazienti_ids = $input['pazienti_ids'];
        $note = trim($input['note'] ?? '');

        if (empty($pazienti_ids) || !is_array($pazienti_ids)) {
            jsonResponse(false, 'Nessun paziente selezionato');
        }

        // Verifica che l'educatore esista
        $stmt = $pdo->prepare("SELECT id_educatore FROM educatori WHERE id_registrazione = :id");
        $stmt->execute([':id' => $id_educatore]);
        if (!$stmt->fetch()) {
            jsonResponse(false, 'Educatore non trovato');
        }

        $pdo->beginTransaction();

        try {
            $associazioni_create = 0;
            $errori = [];

            foreach ($pazienti_ids as $id_paziente) {
                $id_paziente = intval($id_paziente);

                // Verifica che il paziente esista e non sia già associato
                $stmt = $pdo->prepare("
                    SELECT r.nome_registrazione, r.cognome_registrazione
                    FROM registrazioni r
                    WHERE r.id_registrazione = :id_paziente
                      AND r.ruolo_registrazione = 'paziente'
                      AND r.id_registrazione NOT IN (
                          SELECT ep.id_paziente
                          FROM educatori_pazienti ep
                          WHERE ep.id_educatore = :id_educatore AND ep.is_attiva = 1
                      )
                ");
                $stmt->execute([':id_paziente' => $id_paziente, ':id_educatore' => $id_educatore]);
                $paziente = $stmt->fetch();

                if (!$paziente) {
                    $errori[] = "Paziente ID $id_paziente non valido o già associato";
                    continue;
                }

                // Crea associazione
                $stmt = $pdo->prepare("
                    INSERT INTO educatori_pazienti (id_educatore, id_paziente, data_associazione, is_attiva, note)
                    VALUES (:id_educatore, :id_paziente, DATE_FORMAT(NOW(), '%d/%m/%Y'), 1, :note)
                ");

                $result = $stmt->execute([
                    ':id_educatore' => $id_educatore,
                    ':id_paziente' => $id_paziente,
                    ':note' => $note
                ]);

                if ($result) {
                    $associazioni_create++;
                } else {
                    $errori[] = "Errore associazione paziente {$paziente['nome_registrazione']} {$paziente['cognome_registrazione']}";
                }
            }

            $pdo->commit();

            if ($associazioni_create > 0) {
                $messaggio = "$associazioni_create pazienti associati con successo";
                if (!empty($errori)) {
                    $messaggio .= ". Errori: " . implode(', ', $errori);
                }
                jsonResponse(true, $messaggio, ['associazioni_create' => $associazioni_create]);
            } else {
                jsonResponse(false, 'Nessuna associazione creata. Errori: ' . implode(', ', $errori));
            }

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore durante le associazioni: ' . $e->getMessage());
        }

    } elseif ($method === 'DELETE') {
        // Dissocia paziente dall'educatore
        $id_educatore = intval($_GET['id_educatore'] ?? 0);
        $id_paziente = intval($_GET['id_paziente'] ?? 0);

        if ($id_educatore === 0 || $id_paziente === 0) {
            jsonResponse(false, 'Parametri mancanti');
        }

        // Verifica che l'associazione esista
        $stmt = $pdo->prepare("
            SELECT ep.id_associazione, r.nome_registrazione, r.cognome_registrazione
            FROM educatori_pazienti ep
            JOIN registrazioni r ON ep.id_paziente = r.id_registrazione
            WHERE ep.id_educatore = :id_educatore
              AND ep.id_paziente = :id_paziente
              AND ep.is_attiva = 1
        ");
        $stmt->execute([':id_educatore' => $id_educatore, ':id_paziente' => $id_paziente]);
        $associazione = $stmt->fetch();

        if (!$associazione) {
            jsonResponse(false, 'Associazione non trovata o già disattivata');
        }

        // Disattiva l'associazione invece di eliminarla (per mantenere storico)
        $stmt = $pdo->prepare("
            UPDATE educatori_pazienti
            SET is_attiva = 0
            WHERE id_associazione = :id_associazione
        ");

        $result = $stmt->execute([':id_associazione' => $associazione['id_associazione']]);

        if ($result) {
            jsonResponse(true, "Paziente {$associazione['nome_registrazione']} {$associazione['cognome_registrazione']} dissociato con successo");
        } else {
            jsonResponse(false, 'Errore nella dissociazione');
        }

    } else {
        jsonResponse(false, 'Metodo HTTP non supportato');
    }

} catch (PDOException $e) {
    error_log("Errore database in educatori_pazienti.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio');
} catch (Exception $e) {
    error_log("Errore generale in educatori_pazienti.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server');
}
?>