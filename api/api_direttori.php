<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

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
    ]);
    exit();
}

function logOperation($action, $details, $ip) {
    $logFile = '../logs/direttori.log';
    $logDir = dirname($logFile);

    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $action - $details - IP: $ip\n";

    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

try {
    $pdo = getDbConnection();

    $rawBody = file_get_contents('php://input');
    $input = json_decode($rawBody ?: '[]', true);
    $action = $input['action'] ?? $_GET['action'] ?? '';
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    /* ===== GET_ALL ===== */
    if ($action === 'get_all') {
        // ✅ CONTROLLO RUOLO: Solo sviluppatore può accedere a questa sezione
        $user_role = $input['user_role'] ?? null;

        if ($user_role !== 'sviluppatore') {
            jsonResponse(false, 'Accesso negato: Solo gli sviluppatori possono visualizzare i direttori');
        }

        $stmt = $pdo->prepare("
            SELECT
                d.id_direttore,
                d.id_registrazione,
                d.nome,
                d.cognome,
                d.id_sede,
                d.id_settore,
                d.id_classe,
                d.telefono,
                d.email_contatto,
                d.note_direttive,
                d.data_creazione,
                d.stato_direttore,
                s.nome_sede,
                st.nome_settore,
                cl.nome_classe,
                r.username_registrazione,
                COUNT(DISTINCT cm.id_casemanager) AS numero_casemanager
            FROM direttori d
            LEFT JOIN sedi s ON d.id_sede = s.id_sede
            LEFT JOIN settori st ON d.id_settore = st.id_settore
            LEFT JOIN classi cl ON d.id_classe = cl.id_classe
            LEFT JOIN registrazioni r ON d.id_registrazione = r.id_registrazione
            LEFT JOIN casemanager cm ON d.id_direttore = cm.id_direttore AND cm.stato_casemanager = 'attivo'
            WHERE d.stato_direttore != 'inattivo'
            GROUP BY d.id_direttore
            ORDER BY d.data_creazione DESC
        ");
        $stmt->execute();
        $direttori = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Direttori recuperati con successo', $direttori);

    /* ===== CREATE ===== */
    } elseif ($action === 'create') {
        // ✅ CONTROLLO RUOLO: Solo sviluppatore e amministratore possono creare direttori
        $user_role = $input['user_role'] ?? null;

        // 🔓 BYPASS COMPLETO PER SVILUPPATORE - accesso illimitato
        if ($user_role === 'sviluppatore') {
            // Sviluppatore può creare qualsiasi direttore senza limiti
        } elseif ($user_role !== 'amministratore') {
            jsonResponse(false, 'Accesso negato: Solo sviluppatori e amministratori possono creare direttori');
        }

        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $username = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';
        $id_sede = intval($input['id_sede'] ?? 1);
        $id_settore = intval($input['id_settore'] ?? 0);
        $id_classe = intval($input['id_classe'] ?? 0);
        $telefono = trim($input['telefono'] ?? '');
        $email_contatto = trim($input['email_contatto'] ?? '');
        $note_direttive = trim($input['note_direttive'] ?? '');

        if (empty($nome) || empty($cognome) || empty($username) || empty($password)) {
            jsonResponse(false, 'Nome, cognome, username e password sono obbligatori');
        }

        if (strlen($password) < 6) {
            jsonResponse(false, 'La password deve avere almeno 6 caratteri');
        }

        // Verifica username unico
        $stmt = $pdo->prepare("SELECT id_registrazione FROM registrazioni WHERE username_registrazione = :username");
        $stmt->execute([':username' => $username]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Username già esistente');
        }

        $pdo->beginTransaction();

        try {
            // 1. INSERT REGISTRAZIONI
            $stmt_reg = $pdo->prepare("
                INSERT INTO registrazioni (
                    nome_registrazione, cognome_registrazione, username_registrazione,
                    password_registrazione, ruolo_registrazione, id_sede, data_registrazione
                )
                VALUES (:nome, :cognome, :username, :password, 'direttore', :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y'))
            ");

            $stmt_reg->execute([
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':username' => $username,
                ':password' => $password,
                ':id_sede' => $id_sede
            ]);

            $id_registrazione = $pdo->lastInsertId();

            // 2. INSERT DIRETTORI
            $stmt_dir = $pdo->prepare("
                INSERT INTO direttori (
                    id_registrazione, nome, cognome, id_sede, id_settore, id_classe,
                    telefono, email_contatto, note_direttive, data_creazione, stato_direttore
                )
                VALUES (
                    :id_registrazione, :nome, :cognome, :id_sede, :id_settore, :id_classe,
                    :telefono, :email_contatto, :note_direttive, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'), 'attivo'
                )
            ");

            $stmt_dir->execute([
                ':id_registrazione' => $id_registrazione,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_sede' => $id_sede,
                ':id_settore' => $id_settore > 0 ? $id_settore : null,
                ':id_classe' => $id_classe > 0 ? $id_classe : null,
                ':telefono' => $telefono,
                ':email_contatto' => $email_contatto,
                ':note_direttive' => $note_direttive
            ]);

            $pdo->commit();
            logOperation('CREATE_DIRETTORE', "Nome: $nome $cognome, Username: $username", $ip);
            jsonResponse(true, 'Direttore creato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nella creazione del direttore: ' . $e->getMessage());
        }

    /* ===== UPDATE ===== */
    } elseif ($action === 'update') {
        $id_direttore = intval($input['id_direttore'] ?? 0);
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $username = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';
        $id_sede = intval($input['id_sede'] ?? 1);
        $id_settore = intval($input['id_settore'] ?? 0);
        $id_classe = intval($input['id_classe'] ?? 0);
        $telefono = trim($input['telefono'] ?? '');
        $email_contatto = trim($input['email_contatto'] ?? '');
        $note_direttive = trim($input['note_direttive'] ?? '');
        $stato_direttore = $input['stato_direttore'] ?? 'attivo';

        if (empty($id_direttore) || empty($nome) || empty($cognome)) {
            jsonResponse(false, 'ID direttore, nome e cognome sono obbligatori');
        }

        if (!empty($password) && strlen($password) < 6) {
            jsonResponse(false, 'La password deve avere almeno 6 caratteri');
        }

        // Verifica username unico (escludendo il direttore corrente)
        if (!empty($username)) {
            $stmt = $pdo->prepare("
                SELECT id_registrazione FROM registrazioni
                WHERE username_registrazione = :username
                AND id_registrazione != (SELECT id_registrazione FROM direttori WHERE id_direttore = :id_direttore)
            ");
            $stmt->execute([':username' => $username, ':id_direttore' => $id_direttore]);
            if ($stmt->fetch()) {
                jsonResponse(false, 'Username già utilizzato da un altro utente');
            }
        }

        $pdo->beginTransaction();

        try {
            // 1. UPDATE DIRETTORI
            $stmt_dir = $pdo->prepare("
                UPDATE direttori
                SET nome = :nome,
                    cognome = :cognome,
                    id_sede = :id_sede,
                    id_settore = :id_settore,
                    id_classe = :id_classe,
                    telefono = :telefono,
                    email_contatto = :email_contatto,
                    note_direttive = :note_direttive,
                    stato_direttore = :stato_direttore
                WHERE id_direttore = :id_direttore
            ");

            $stmt_dir->execute([
                ':id_direttore' => $id_direttore,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_sede' => $id_sede,
                ':id_settore' => $id_settore > 0 ? $id_settore : null,
                ':id_classe' => $id_classe > 0 ? $id_classe : null,
                ':telefono' => $telefono,
                ':email_contatto' => $email_contatto,
                ':note_direttive' => $note_direttive,
                ':stato_direttore' => $stato_direttore
            ]);

            // 2. Sincronizza registrazioni se username/password/nome/cognome cambiano
            if (!empty($username) || !empty($password)) {
                // Ottieni id_registrazione
                $stmt_get_reg = $pdo->prepare("SELECT id_registrazione FROM direttori WHERE id_direttore = :id_direttore");
                $stmt_get_reg->execute([':id_direttore' => $id_direttore]);
                $result = $stmt_get_reg->fetch(PDO::FETCH_ASSOC);
                $id_registrazione = $result['id_registrazione'] ?? null;

                if ($id_registrazione) {
                    $stmt_reg = $pdo->prepare("
                        UPDATE registrazioni
                        SET nome_registrazione = :nome,
                            cognome_registrazione = :cognome,
                            username_registrazione = COALESCE(:username, username_registrazione),
                            password_registrazione = COALESCE(:password, password_registrazione)
                        WHERE id_registrazione = :id_registrazione
                    ");

                    $stmt_reg->execute([
                        ':id_registrazione' => $id_registrazione,
                        ':nome' => $nome,
                        ':cognome' => $cognome,
                        ':username' => !empty($username) ? $username : null,
                        ':password' => !empty($password) ? $password : null
                    ]);
                }
            }

            $pdo->commit();
            logOperation('UPDATE_DIRETTORE', "ID: $id_direttore, Nome: $nome $cognome", $ip);
            jsonResponse(true, 'Direttore aggiornato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nell\'aggiornamento del direttore: ' . $e->getMessage());
        }

    /* ===== DELETE ===== */
    } elseif ($action === 'delete') {
        $id_direttore = intval($input['id_direttore'] ?? 0);

        if (empty($id_direttore)) {
            jsonResponse(false, 'ID direttore non specificato');
        }

        // Verifica che il direttore esista
        $stmt = $pdo->prepare("SELECT id_direttore, nome, cognome FROM direttori WHERE id_direttore = :id");
        $stmt->execute([':id' => $id_direttore]);
        $direttore = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$direttore) {
            jsonResponse(false, 'Direttore non trovato');
        }

        $pdo->beginTransaction();

        try {
            // Soft delete: cambia stato invece di eliminare
            $stmt = $pdo->prepare("
                UPDATE direttori
                SET stato_direttore = 'inattivo'
                WHERE id_direttore = :id_direttore
            ");

            $stmt->execute([':id_direttore' => $id_direttore]);

            $pdo->commit();
            logOperation('DELETE_DIRETTORE', "ID: $id_direttore, Nome: {$direttore['nome']} {$direttore['cognome']}", $ip);
            jsonResponse(true, 'Direttore disattivato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nell\'eliminazione del direttore: ' . $e->getMessage());
        }

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_direttori.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in api_direttori.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>
