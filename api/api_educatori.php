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

// Funzione per hashare password (attualmente in chiaro per compatibilità)
function hashPassword($password) {
    return $password;
}

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
    $logFile = '../logs/educatori.log';
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
        $allowed_roles = ['direttore', 'casemanager', 'sviluppatore'];

        if (!in_array($user_role, $allowed_roles)) {
            jsonResponse(false, 'Accesso negato: Non hai i permessi per visualizzare gli educatori');
        }

        // Recupera tutti gli educatori con informazioni sede, settore e classe
        $sql = "
            SELECT
                e.id_educatore,
                e.id_registrazione,
                e.nome,
                e.cognome,
                e.id_sede,
                e.id_settore,
                e.id_classe,
                e.telefono,
                e.email_contatto,
                e.note_professionali,
                e.stato_educatore,
                e.data_creazione,
                s.nome_sede,
                st.nome_settore,
                cl.nome_classe,
                r.username_registrazione,
                COUNT(DISTINCT ep.id_paziente) AS numero_pazienti
            FROM educatori e
            LEFT JOIN sedi s ON e.id_sede = s.id_sede
            LEFT JOIN settori st ON e.id_settore = st.id_settore
            LEFT JOIN classi cl ON e.id_classe = cl.id_classe
            LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
            LEFT JOIN educatori_pazienti ep ON e.id_educatore = ep.id_educatore AND ep.is_attiva = 1
            WHERE e.stato_educatore != 'eliminato'
        ";

        // Applica filtri in base al ruolo
        if ($user_role === 'direttore') {
            // Direttore vede gli educatori della sua stessa sede
            $sql .= " AND e.id_sede = (SELECT id_sede FROM direttori WHERE id_registrazione = :user_id)";
        } elseif ($user_role === 'casemanager') {
            // CaseManager vede gli educatori della sua stessa sede
            $sql .= " AND e.id_sede = (SELECT id_sede FROM casemanager WHERE id_registrazione = :user_id)";
        }
        // Se sviluppatore, vede tutti (nessun filtro aggiuntivo)

        $sql .= "
            GROUP BY e.id_educatore
            ORDER BY e.data_creazione DESC
        ";

        $stmt = $pdo->prepare($sql);

        $params = [];
        if ($user_role === 'direttore' || $user_role === 'casemanager') {
            $params[':user_id'] = $user_id;
        }

        $stmt->execute($params);
        $educatori = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Educatori recuperati con successo', $educatori);

    } elseif ($action === 'create') {
        // ✅ CONTROLLO RUOLO: Solo direttore, casemanager e sviluppatore possono creare educatori
        $user_role = $input['user_role'] ?? null;

        // 🔓 BYPASS COMPLETO PER SVILUPPATORE - accesso illimitato
        if ($user_role === 'sviluppatore') {
            // Sviluppatore può creare qualsiasi educatore senza limiti
        } elseif (!in_array($user_role, ['direttore', 'casemanager', 'amministratore'])) {
            jsonResponse(false, 'Accesso negato: Non hai i permessi per creare educatori');
        }

        // Crea nuovo educatore
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $id_settore = intval($input['id_settore'] ?? 0);
        $id_classe = intval($input['id_classe'] ?? 0);
        $id_sede = intval($input['id_sede'] ?? 1);
        $telefono = trim($input['telefono'] ?? '');
        $email_contatto = trim($input['email_contatto'] ?? '');
        $note_professionali = trim($input['note_professionali'] ?? '');
        $username = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';

        // Validazioni
        if (empty($nome) || empty($cognome) || empty($username) || empty($password)) {
            jsonResponse(false, 'Nome, cognome, username e password sono obbligatori');
        }

        // Inizia transazione
        $pdo->beginTransaction();

        try {
            // 1. Crea registrazione utente
            $stmt_reg = $pdo->prepare("
                INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione,
                                         password_registrazione, ruolo_registrazione, id_sede, data_registrazione)
                VALUES (:nome, :cognome, :username, :password, 'educatore', :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y'))
            ");

            // ✅ NON hashare: password in chiaro per compatibilità
            $stmt_reg->execute([
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':username' => $username,
                ':password' => $password,  // Password in chiaro
                ':id_sede' => $id_sede
            ]);

            $id_registrazione = $pdo->lastInsertId();

            // 2. Crea profilo educatore
            $stmt_edu = $pdo->prepare("
                INSERT INTO educatori (id_registrazione, nome, cognome, id_settore, id_classe, id_sede,
                                     telefono, email_contatto, note_professionali, data_creazione)
                VALUES (:id_registrazione, :nome, :cognome, :id_settore, :id_classe, :id_sede,
                        :telefono, :email_contatto, :note_professionali, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
            ");

            $stmt_edu->execute([
                ':id_registrazione' => $id_registrazione,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_settore' => $id_settore > 0 ? $id_settore : null,
                ':id_classe' => $id_classe > 0 ? $id_classe : null,
                ':id_sede' => $id_sede,
                ':telefono' => $telefono,
                ':email_contatto' => $email_contatto,
                ':note_professionali' => $note_professionali
            ]);

            $pdo->commit();
            logOperation('CREATE_EDUCATORE', "Nome: $nome $cognome, Username: $username", $ip);
            jsonResponse(true, 'Educatore creato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nella creazione dell\'educatore: ' . $e->getMessage());
        }

    } elseif ($action === 'update') {
        // Aggiorna educatore esistente
        $id_educatore = intval($input['id_educatore'] ?? 0);
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $id_settore = intval($input['id_settore'] ?? 0);
        $id_classe = intval($input['id_classe'] ?? 0);
        $id_sede = intval($input['id_sede'] ?? 1);
        $telefono = trim($input['telefono'] ?? '');
        $email_contatto = trim($input['email_contatto'] ?? '');
        $note_professionali = trim($input['note_professionali'] ?? '');
        $stato_educatore = $input['stato_educatore'] ?? 'attivo';

        if (empty($id_educatore) || empty($nome) || empty($cognome)) {
            jsonResponse(false, 'ID educatore, nome e cognome sono obbligatori');
        }

        // Inizia transazione per aggiornamento
        $pdo->beginTransaction();

        try {
            // Aggiorna educatore
            $stmt = $pdo->prepare("
                UPDATE educatori
                SET nome = :nome,
                    cognome = :cognome,
                    id_settore = :id_settore,
                    id_classe = :id_classe,
                    id_sede = :id_sede,
                    telefono = :telefono,
                    email_contatto = :email_contatto,
                    note_professionali = :note_professionali,
                    stato_educatore = :stato_educatore
                WHERE id_educatore = :id_educatore
            ");

            $result = $stmt->execute([
                ':id_educatore' => $id_educatore,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_settore' => $id_settore > 0 ? $id_settore : null,
                ':id_classe' => $id_classe > 0 ? $id_classe : null,
                ':id_sede' => $id_sede,
                ':telefono' => $telefono,
                ':email_contatto' => $email_contatto,
                ':note_professionali' => $note_professionali,
                ':stato_educatore' => $stato_educatore
            ]);

            // Sincronizza nome/cognome/username con registrazioni
            $username = trim($input['username'] ?? '');
            $sync_fields = [
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_educatore' => $id_educatore
            ];

            $update_query = "
                UPDATE registrazioni
                SET nome_registrazione = :nome,
                    cognome_registrazione = :cognome";

            // Se fornito username, aggiornalo
            if (!empty($username)) {
                $update_query .= ", username_registrazione = :username";
                $sync_fields[':username'] = $username;
            }

            $update_query .= " WHERE id_registrazione = (
                    SELECT id_registrazione FROM educatori WHERE id_educatore = :id_educatore
                )";

            $stmt_sync_reg = $pdo->prepare($update_query);
            $stmt_sync_reg->execute($sync_fields);

            // Aggiorna password se fornita
            $password = $input['password'] ?? '';
            if (!empty($password)) {
                $stmt_pwd = $pdo->prepare("
                    UPDATE registrazioni
                    SET password_registrazione = :password
                    WHERE id_registrazione = (
                        SELECT id_registrazione FROM educatori WHERE id_educatore = :id_educatore
                    )
                ");
                $stmt_pwd->execute([
                    ':password' => $password,
                    ':id_educatore' => $id_educatore
                ]);
            }

            $pdo->commit();
        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nell\'aggiornamento dell\'educatore: ' . $e->getMessage());
        }

        if ($result) {
            logOperation('UPDATE_EDUCATORE', "ID: $id_educatore, Nome: $nome $cognome", $ip);
            jsonResponse(true, 'Educatore aggiornato con successo');
        } else {
            jsonResponse(false, 'Errore nell\'aggiornamento dell\'educatore');
        }

    } elseif ($action === 'delete') {
        // Elimina educatore (soft delete)
        $id_educatore = intval($input['id_educatore'] ?? 0);

        if (empty($id_educatore)) {
            jsonResponse(false, 'ID educatore non specificato');
        }

        // Soft delete - cambia solo lo stato
        $stmt = $pdo->prepare("
            UPDATE educatori 
            SET stato_educatore = 'eliminato'
            WHERE id_educatore = :id_educatore
        ");

        $result = $stmt->execute([':id_educatore' => $id_educatore]);

        if ($result) {
            logOperation('DELETE_EDUCATORE', "ID: $id_educatore", $ip);
            jsonResponse(true, 'Educatore eliminato con successo');
        } else {
            jsonResponse(false, 'Errore nell\'eliminazione dell\'educatore');
        }

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_educatori.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in api_educatori.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>