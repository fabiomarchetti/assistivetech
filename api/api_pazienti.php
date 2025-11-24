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

// Configurazione database automatica (locale/produzione)
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
    $logFile = '../logs/pazienti.log';
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

    if ($action === 'get_all') {
        // ✅ CONTROLLO RUOLO
        $user_role = $input['user_role'] ?? null;
        $user_id = intval($input['user_id'] ?? 0);

        // Ruoli autorizzati
        $allowed_roles = ['educatore', 'direttore', 'casemanager', 'sviluppatore'];

        if (!in_array($user_role, $allowed_roles)) {
            jsonResponse(false, 'Accesso negato: Non hai i permessi per visualizzare i pazienti');
        }

        // Recupera tutti i pazienti con informazioni sede e educatore assegnato
        $sql = "
            SELECT
                p.id_paziente,
                p.id_registrazione,
                p.nome_paziente as nome,
                p.cognome_paziente as cognome,
                p.id_sede,
                p.id_settore,
                p.id_classe,
                s.nome_sede,
                st.nome_settore as settore,
                c.nome_classe as classe,
                r.username_registrazione,
                COALESCE(
                    CONCAT(e.nome, ' ', e.cognome),
                    'Nessun educatore assegnato'
                ) as educatore_assegnato,
                ep.is_attiva
            FROM pazienti p
            LEFT JOIN sedi s ON p.id_sede = s.id_sede
            LEFT JOIN settori st ON p.id_settore = st.id_settore
            LEFT JOIN classi c ON p.id_classe = c.id_classe
            LEFT JOIN registrazioni r ON p.id_registrazione = r.id_registrazione
            LEFT JOIN educatori_pazienti ep ON p.id_paziente = ep.id_paziente AND ep.is_attiva = 1
            LEFT JOIN educatori e ON ep.id_educatore = e.id_educatore
            WHERE 1=1
        ";

        // Applica filtri in base al ruolo
        if ($user_role === 'educatore') {
            // Educatore vede solo i pazienti assegnati a lui
            $sql .= " AND ep.id_educatore = (SELECT id_educatore FROM educatori WHERE id_registrazione = :user_id)";
        } elseif ($user_role === 'direttore') {
            // Direttore vede i pazienti della sua sede
            $sql .= " AND p.id_sede = (SELECT id_sede FROM direttori WHERE id_registrazione = :user_id)";
        } elseif ($user_role === 'casemanager') {
            // CaseManager vede i pazienti della sua sede
            $sql .= " AND p.id_sede = (SELECT id_sede FROM casemanager WHERE id_registrazione = :user_id)";
        }
        // Se sviluppatore, vede tutti (nessun filtro aggiuntivo)

        $sql .= " ORDER BY p.nome_paziente, p.cognome_paziente";

        $stmt = $pdo->prepare($sql);

        $params = [];
        if ($user_role !== 'sviluppatore') {
            $params[':user_id'] = $user_id;
        }

        $stmt->execute($params);
        $pazienti = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Pazienti recuperati con successo', $pazienti);

    } elseif ($action === 'create') {
        // ✅ CONTROLLO RUOLO: Solo educatore, direttore, casemanager e sviluppatore possono creare pazienti
        $user_role = $input['user_role'] ?? null;

        // 🔓 BYPASS COMPLETO PER SVILUPPATORE - accesso illimitato
        if ($user_role === 'sviluppatore') {
            // Sviluppatore può creare qualsiasi paziente senza limiti
        } elseif (!in_array($user_role, ['educatore', 'direttore', 'casemanager', 'amministratore'])) {
            jsonResponse(false, 'Accesso negato: Non hai i permessi per creare pazienti/utenti');
        }

        // Crea nuovo paziente
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $id_settore = intval($input['id_settore'] ?? 0);
        $id_classe = intval($input['id_classe'] ?? 0);
        $id_sede = intval($input['id_sede'] ?? 1);
        $username = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';
        $id_educatore = intval($input['id_educatore'] ?? 0); // Educatore da associare

        // Validazioni
        if (empty($nome) || empty($cognome) || empty($username) || empty($password)) {
            jsonResponse(false, 'Nome, cognome, username e password sono obbligatori');
        }

        if (strlen($password) < 6) {
            jsonResponse(false, 'La password deve avere almeno 6 caratteri');
        }

        // Inizia transazione
        $pdo->beginTransaction();

        try {
            // 1. Crea registrazione utente
            $stmt_reg = $pdo->prepare("
                INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione,
                                         password_registrazione, ruolo_registrazione, id_sede, data_registrazione)
                VALUES (:nome, :cognome, :username, :password, 'paziente', :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y'))
            ");
            
            $stmt_reg->execute([
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':username' => $username,
                ':password' => $password,
                ':id_sede' => $id_sede
            ]);

            $id_registrazione = $pdo->lastInsertId();

            // 2. Crea profilo paziente
            $stmt_paz = $pdo->prepare("
                INSERT INTO pazienti (id_registrazione, nome_paziente, cognome_paziente, id_settore, id_classe, id_sede)
                VALUES (:id_registrazione, :nome, :cognome, :id_settore, :id_classe, :id_sede)
            ");

            $stmt_paz->execute([
                ':id_registrazione' => $id_registrazione,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_settore' => $id_settore ?: null,
                ':id_classe' => $id_classe ?: null,
                ':id_sede' => $id_sede
            ]);

            $id_paziente = $pdo->lastInsertId();

            // 3. Associa a educatore se specificato
            if ($id_educatore > 0) {
                $stmt_assoc = $pdo->prepare("
                    INSERT INTO educatori_pazienti (id_educatore, id_paziente, data_associazione, is_attiva)
                    VALUES (:id_educatore, :id_paziente, DATE_FORMAT(NOW(), '%d/%m/%Y'), 1)
                ");

                $stmt_assoc->execute([
                    ':id_educatore' => $id_educatore,
                    ':id_paziente' => $id_paziente
                ]);
            }

            $pdo->commit();
            logOperation('CREATE_PAZIENTE', "Nome: $nome $cognome, Username: $username", $ip);
            jsonResponse(true, 'Paziente creato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nella creazione del paziente: ' . $e->getMessage());
        }

    } elseif ($action === 'update') {
        // Aggiorna paziente esistente
        $id_paziente = intval($input['id_paziente'] ?? 0);
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $id_settore = intval($input['id_settore'] ?? 0);
        $id_classe = intval($input['id_classe'] ?? 0);
        $id_sede = intval($input['id_sede'] ?? 1);
        $id_educatore = intval($input['id_educatore'] ?? 0);

        if (empty($id_paziente) || empty($nome) || empty($cognome)) {
            jsonResponse(false, 'ID paziente, nome e cognome sono obbligatori');
        }

        // Inizia transazione
        $pdo->beginTransaction();

        try {
            // 1. Aggiorna dati paziente
            $stmt_paz = $pdo->prepare("
                UPDATE pazienti
                SET nome_paziente = :nome,
                    cognome_paziente = :cognome,
                    id_settore = :id_settore,
                    id_classe = :id_classe,
                    id_sede = :id_sede
                WHERE id_paziente = :id_paziente
            ");

            $stmt_paz->execute([
                ':id_paziente' => $id_paziente,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_settore' => $id_settore ?: null,
                ':id_classe' => $id_classe ?: null,
                ':id_sede' => $id_sede
            ]);

            // 2. Sincronizza nome/cognome con registrazioni
            $stmt_sync_reg = $pdo->prepare("
                UPDATE registrazioni
                SET nome_registrazione = :nome,
                    cognome_registrazione = :cognome
                WHERE id_registrazione = (
                    SELECT id_registrazione FROM pazienti WHERE id_paziente = :id_paziente
                )
            ");
            $stmt_sync_reg->execute([
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_paziente' => $id_paziente
            ]);

            // 3. Gestisci associazione educatore
            // Prima disattiva tutte le associazioni esistenti
            $stmt_disattiva = $pdo->prepare("
                UPDATE educatori_pazienti
                SET is_attiva = 0
                WHERE id_paziente = :id_paziente
            ");
            $stmt_disattiva->execute([':id_paziente' => $id_paziente]);

            // Poi crea nuova associazione se specificato
            if ($id_educatore > 0) {
                $stmt_assoc = $pdo->prepare("
                    INSERT INTO educatori_pazienti (id_educatore, id_paziente, data_associazione, is_attiva)
                    VALUES (:id_educatore, :id_paziente, DATE_FORMAT(NOW(), '%d/%m/%Y'), 1)
                    ON DUPLICATE KEY UPDATE is_attiva = 1, data_associazione = DATE_FORMAT(NOW(), '%d/%m/%Y')
                ");

                $stmt_assoc->execute([
                    ':id_educatore' => $id_educatore,
                    ':id_paziente' => $id_paziente
                ]);
            }

            $pdo->commit();
            logOperation('UPDATE_PAZIENTE', "ID: $id_paziente, Nome: $nome $cognome", $ip);
            jsonResponse(true, 'Paziente aggiornato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nell\'aggiornamento del paziente: ' . $e->getMessage());
        }

    } elseif ($action === 'delete') {
        // Elimina paziente
        $id_paziente = intval($input['id_paziente'] ?? 0);

        if (empty($id_paziente)) {
            jsonResponse(false, 'ID paziente non specificato');
        }

        // Inizia transazione
        $pdo->beginTransaction();

        try {
            // 1. Disattiva associazioni educatori
            $stmt_disattiva = $pdo->prepare("
                UPDATE educatori_pazienti 
                SET is_attiva = 0
                WHERE id_paziente = :id_paziente
            ");
            $stmt_disattiva->execute([':id_paziente' => $id_paziente]);

            // 2. Ottieni ID registrazione prima di eliminare
            $stmt_get_reg = $pdo->prepare("SELECT id_registrazione FROM pazienti WHERE id_paziente = :id_paziente");
            $stmt_get_reg->execute([':id_paziente' => $id_paziente]);
            $reg_data = $stmt_get_reg->fetch(PDO::FETCH_ASSOC);

            // 3. Elimina paziente
            $stmt_del_paz = $pdo->prepare("DELETE FROM pazienti WHERE id_paziente = :id_paziente");
            $stmt_del_paz->execute([':id_paziente' => $id_paziente]);

            // 4. Elimina registrazione associata
            if ($reg_data) {
                $stmt_del_reg = $pdo->prepare("DELETE FROM registrazioni WHERE id_registrazione = :id_registrazione");
                $stmt_del_reg->execute([':id_registrazione' => $reg_data['id_registrazione']]);
            }

            $pdo->commit();
            logOperation('DELETE_PAZIENTE', "ID: $id_paziente", $ip);
            jsonResponse(true, 'Paziente eliminato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nell\'eliminazione del paziente: ' . $e->getMessage());
        }

    } elseif ($action === 'get_educatori') {
        // Recupera lista educatori per dropdown
        $stmt = $pdo->prepare("
            SELECT id_educatore, CONCAT(nome, ' ', cognome) as nome_completo
            FROM educatori
            WHERE stato_educatore = 'attivo'
            ORDER BY nome, cognome
        ");
        $stmt->execute();
        $educatori = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Educatori recuperati con successo', $educatori);

    } elseif ($action === 'list_by_educatore') {
        // Recupera pazienti assegnati a un educatore specifico
        $id_educatore = intval($_GET['id_educatore'] ?? 0);

        if ($id_educatore === 0) {
            jsonResponse(false, 'ID educatore obbligatorio');
        }

        $stmt = $pdo->prepare("
            SELECT
                p.id_paziente,
                p.id_registrazione,
                p.nome_paziente as nome,
                p.cognome_paziente as cognome,
                p.id_sede,
                p.id_settore,
                p.id_classe,
                s.nome_sede,
                st.nome_settore as settore,
                c.nome_classe as classe,
                r.username_registrazione
            FROM pazienti p
            INNER JOIN educatori_pazienti ep ON p.id_paziente = ep.id_paziente
            LEFT JOIN sedi s ON p.id_sede = s.id_sede
            LEFT JOIN settori st ON p.id_settore = st.id_settore
            LEFT JOIN classi c ON p.id_classe = c.id_classe
            LEFT JOIN registrazioni r ON p.id_registrazione = r.id_registrazione
            WHERE ep.id_educatore = :id_educatore
            AND ep.is_attiva = 1
            ORDER BY p.nome_paziente, p.cognome_paziente
        ");

        $stmt->execute([':id_educatore' => $id_educatore]);
        $pazienti = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Pazienti assegnati recuperati con successo', $pazienti);

    } elseif ($action === 'list') {
        // Alias per get_all (compatibilità)
        $stmt = $pdo->prepare("
            SELECT
                p.id_paziente,
                p.id_registrazione,
                p.nome_paziente as nome,
                p.cognome_paziente as cognome,
                p.id_sede,
                p.id_settore,
                p.id_classe,
                s.nome_sede,
                st.nome_settore as settore,
                c.nome_classe as classe,
                r.username_registrazione
            FROM pazienti p
            LEFT JOIN sedi s ON p.id_sede = s.id_sede
            LEFT JOIN settori st ON p.id_settore = st.id_settore
            LEFT JOIN classi c ON p.id_classe = c.id_classe
            LEFT JOIN registrazioni r ON p.id_registrazione = r.id_registrazione
            ORDER BY p.nome_paziente, p.cognome_paziente
        ");
        $stmt->execute();
        $pazienti = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Pazienti recuperati con successo', $pazienti);

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_pazienti.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in api_pazienti.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>