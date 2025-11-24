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

// Funzione per hashare password (attualmente in chiaro per compatibilità)
function hashPassword($password) {
    return $password;
}

function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ]);
    exit();
}

function logOperation($action, $details, $ip) {
    $logFile = '../logs/casemanager.log';
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
        // ✅ CONTROLLO RUOLO
        $user_role = $input['user_role'] ?? null;
        $user_id = intval($input['user_id'] ?? 0);

        // Ruoli autorizzati
        $allowed_roles = ['direttore', 'casemanager', 'sviluppatore'];

        if (!in_array($user_role, $allowed_roles)) {
            jsonResponse(false, 'Accesso negato: Non hai i permessi per visualizzare i case manager');
        }

        // Costruisci la query base
        $sql = "
            SELECT
                cm.id_casemanager,
                cm.id_registrazione,
                cm.id_direttore,
                cm.nome,
                cm.cognome,
                cm.id_sede,
                cm.id_settore,
                cm.id_classe,
                cm.telefono,
                cm.email_contatto,
                cm.specializzazione,
                cm.data_creazione,
                cm.stato_casemanager,
                s.nome_sede,
                st.nome_settore,
                cl.nome_classe,
                r.username_registrazione,
                CONCAT(d.nome, ' ', d.cognome) AS direttore_nome,
                COUNT(DISTINCT cp.id_paziente) AS numero_pazienti
            FROM casemanager cm
            LEFT JOIN sedi s ON cm.id_sede = s.id_sede
            LEFT JOIN settori st ON cm.id_settore = st.id_settore
            LEFT JOIN classi cl ON cm.id_classe = cl.id_classe
            LEFT JOIN registrazioni r ON cm.id_registrazione = r.id_registrazione
            LEFT JOIN direttori d ON cm.id_direttore = d.id_direttore
            LEFT JOIN casemanager_pazienti cp ON cm.id_casemanager = cp.id_casemanager AND cp.is_attiva = 1
            WHERE cm.stato_casemanager != 'inattivo'
        ";

        // Applica filtri in base al ruolo
        if ($user_role === 'direttore') {
            // Direttore vede solo i casemanager assegnati a lui
            $sql .= " AND cm.id_direttore = (SELECT id_direttore FROM direttori WHERE id_registrazione = :user_id)";
        } elseif ($user_role === 'casemanager') {
            // CaseManager vede solo sé stesso
            $sql .= " AND cm.id_registrazione = :user_id";
        }
        // Se sviluppatore, vede tutti (nessun filtro aggiuntivo)

        $sql .= "
            GROUP BY cm.id_casemanager
            ORDER BY cm.data_creazione DESC
        ";

        $stmt = $pdo->prepare($sql);

        $params = [];
        if ($user_role === 'direttore' || $user_role === 'casemanager') {
            $params[':user_id'] = $user_id;
        }

        $stmt->execute($params);
        $casemanager = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Case manager recuperati con successo', $casemanager);

    /* ===== CREATE ===== */
    } elseif ($action === 'create') {
        // ✅ CONTROLLO RUOLO: Solo direttore e sviluppatore possono creare casemanager
        $user_role = $input['user_role'] ?? null;
        $user_id = intval($input['user_id'] ?? 0);

        // 🔓 BYPASS COMPLETO PER SVILUPPATORE - accesso illimitato
        if ($user_role === 'sviluppatore') {
            // Sviluppatore può creare qualsiasi case manager senza limiti
        } elseif (!in_array($user_role, ['direttore', 'casemanager', 'amministratore'])) {
            jsonResponse(false, 'Accesso negato: Non hai i permessi per creare case manager');
        }

        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $username = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';
        $id_direttore = intval($input['id_direttore'] ?? 0);
        $id_sede = intval($input['id_sede'] ?? 1);
        $id_settore = intval($input['id_settore'] ?? 0);
        $id_classe = intval($input['id_classe'] ?? 0);
        $telefono = trim($input['telefono'] ?? '');
        $email_contatto = trim($input['email_contatto'] ?? '');
        $specializzazione = trim($input['specializzazione'] ?? '');

        if (empty($nome) || empty($cognome) || empty($username) || empty($password)) {
            jsonResponse(false, 'Nome, cognome, username e password sono obbligatori');
        }

        if (strlen($password) < 6) {
            jsonResponse(false, 'La password deve avere almeno 6 caratteri');
        }

        // Se il direttore non specifica id_direttore, lo calcola automaticamente
        if ($user_role === 'direttore' && $id_direttore <= 0) {
            $stmt_get_dir = $pdo->prepare("SELECT id_direttore FROM direttori WHERE id_registrazione = :user_id");
            $stmt_get_dir->execute([':user_id' => $user_id]);
            $result = $stmt_get_dir->fetch(PDO::FETCH_ASSOC);
            if ($result) {
                $id_direttore = $result['id_direttore'];
            } else {
                jsonResponse(false, 'Errore: Non trovato il tuo profilo di direttore');
            }
        }

        // Se id_direttore specificato, verifica che esista
        if ($id_direttore > 0) {
            $stmt_dir = $pdo->prepare("SELECT id_direttore FROM direttori WHERE id_direttore = :id AND stato_direttore = 'attivo'");
            $stmt_dir->execute([':id' => $id_direttore]);
            if (!$stmt_dir->fetch()) {
                jsonResponse(false, 'Direttore non trovato o inattivo');
            }
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
                VALUES (:nome, :cognome, :username, :password, 'casemanager', :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y'))
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

            // 2. INSERT CASEMANAGER
            $stmt_cm = $pdo->prepare("
                INSERT INTO casemanager (
                    id_registrazione, id_direttore, nome, cognome, id_sede, id_settore, id_classe,
                    telefono, email_contatto, specializzazione, data_creazione, stato_casemanager
                )
                VALUES (
                    :id_registrazione, :id_direttore, :nome, :cognome, :id_sede, :id_settore, :id_classe,
                    :telefono, :email_contatto, :specializzazione, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'), 'attivo'
                )
            ");

            $stmt_cm->execute([
                ':id_registrazione' => $id_registrazione,
                ':id_direttore' => $id_direttore > 0 ? $id_direttore : null,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_sede' => $id_sede,
                ':id_settore' => $id_settore > 0 ? $id_settore : null,
                ':id_classe' => $id_classe > 0 ? $id_classe : null,
                ':telefono' => $telefono,
                ':email_contatto' => $email_contatto,
                ':specializzazione' => $specializzazione
            ]);

            $pdo->commit();
            logOperation('CREATE_CASEMANAGER', "Nome: $nome $cognome, Username: $username", $ip);
            jsonResponse(true, 'Case manager creato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nella creazione del case manager: ' . $e->getMessage());
        }

    /* ===== UPDATE ===== */
    } elseif ($action === 'update') {
        $id_casemanager = intval($input['id_casemanager'] ?? 0);
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $username = trim($input['username'] ?? '');
        $password = $input['password'] ?? '';
        $id_direttore = intval($input['id_direttore'] ?? 0);
        $id_sede = intval($input['id_sede'] ?? 1);
        $id_settore = intval($input['id_settore'] ?? 0);
        $id_classe = intval($input['id_classe'] ?? 0);
        $telefono = trim($input['telefono'] ?? '');
        $email_contatto = trim($input['email_contatto'] ?? '');
        $specializzazione = trim($input['specializzazione'] ?? '');
        $stato_casemanager = $input['stato_casemanager'] ?? 'attivo';

        if (empty($id_casemanager) || empty($nome) || empty($cognome)) {
            jsonResponse(false, 'ID case manager, nome e cognome sono obbligatori');
        }

        if (!empty($password) && strlen($password) < 6) {
            jsonResponse(false, 'La password deve avere almeno 6 caratteri');
        }

        // Se id_direttore specificato, verifica che esista
        if ($id_direttore > 0) {
            $stmt_dir = $pdo->prepare("SELECT id_direttore FROM direttori WHERE id_direttore = :id AND stato_direttore = 'attivo'");
            $stmt_dir->execute([':id' => $id_direttore]);
            if (!$stmt_dir->fetch()) {
                jsonResponse(false, 'Direttore non trovato o inattivo');
            }
        }

        // Verifica username unico (escludendo il case manager corrente)
        if (!empty($username)) {
            $stmt = $pdo->prepare("
                SELECT id_registrazione FROM registrazioni
                WHERE username_registrazione = :username
                AND id_registrazione != (SELECT id_registrazione FROM casemanager WHERE id_casemanager = :id_casemanager)
            ");
            $stmt->execute([':username' => $username, ':id_casemanager' => $id_casemanager]);
            if ($stmt->fetch()) {
                jsonResponse(false, 'Username già utilizzato da un altro utente');
            }
        }

        $pdo->beginTransaction();

        try {
            // 1. UPDATE CASEMANAGER
            $stmt_cm = $pdo->prepare("
                UPDATE casemanager
                SET nome = :nome,
                    cognome = :cognome,
                    id_direttore = :id_direttore,
                    id_sede = :id_sede,
                    id_settore = :id_settore,
                    id_classe = :id_classe,
                    telefono = :telefono,
                    email_contatto = :email_contatto,
                    specializzazione = :specializzazione,
                    stato_casemanager = :stato_casemanager
                WHERE id_casemanager = :id_casemanager
            ");

            $stmt_cm->execute([
                ':id_casemanager' => $id_casemanager,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':id_direttore' => $id_direttore > 0 ? $id_direttore : null,
                ':id_sede' => $id_sede,
                ':id_settore' => $id_settore > 0 ? $id_settore : null,
                ':id_classe' => $id_classe > 0 ? $id_classe : null,
                ':telefono' => $telefono,
                ':email_contatto' => $email_contatto,
                ':specializzazione' => $specializzazione,
                ':stato_casemanager' => $stato_casemanager
            ]);

            // 2. Sincronizza registrazioni
            if (!empty($username) || !empty($password)) {
                $stmt_get_reg = $pdo->prepare("SELECT id_registrazione FROM casemanager WHERE id_casemanager = :id_casemanager");
                $stmt_get_reg->execute([':id_casemanager' => $id_casemanager]);
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
            logOperation('UPDATE_CASEMANAGER', "ID: $id_casemanager, Nome: $nome $cognome", $ip);
            jsonResponse(true, 'Case manager aggiornato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nell\'aggiornamento del case manager: ' . $e->getMessage());
        }

    /* ===== DELETE (SOFT DELETE) ===== */
    } elseif ($action === 'delete') {
        $id_casemanager = intval($input['id_casemanager'] ?? 0);

        if (empty($id_casemanager)) {
            jsonResponse(false, 'ID case manager non specificato');
        }

        $stmt = $pdo->prepare("SELECT id_casemanager, nome, cognome FROM casemanager WHERE id_casemanager = :id");
        $stmt->execute([':id' => $id_casemanager]);
        $casemanager = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$casemanager) {
            jsonResponse(false, 'Case manager non trovato');
        }

        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare("
                UPDATE casemanager
                SET stato_casemanager = 'inattivo'
                WHERE id_casemanager = :id_casemanager
            ");

            $stmt->execute([':id_casemanager' => $id_casemanager]);

            $pdo->commit();
            logOperation('DELETE_CASEMANAGER', "ID: $id_casemanager, Nome: {$casemanager['nome']} {$casemanager['cognome']}", $ip);
            jsonResponse(true, 'Case manager disattivato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nell\'eliminazione del case manager: ' . $e->getMessage());
        }

    /* ===== GET_MIEI_PAZIENTI ===== */
    } elseif ($action === 'get_miei_pazienti') {
        $id_casemanager = intval($input['id_casemanager'] ?? 0);

        if (empty($id_casemanager)) {
            jsonResponse(false, 'ID case manager non specificato');
        }

        $stmt = $pdo->prepare("
            SELECT
                p.id_paziente,
                p.id_registrazione,
                CONCAT(p.nome_paziente, ' ', p.cognome_paziente) AS nome_completo,
                r.username_registrazione,
                s.nome_sede,
                st.nome_settore,
                cl.nome_classe,
                cp.data_associazione,
                cp.note
            FROM casemanager_pazienti cp
            JOIN pazienti p ON cp.id_paziente = p.id_paziente
            JOIN registrazioni r ON p.id_registrazione = r.id_registrazione
            LEFT JOIN sedi s ON p.id_sede = s.id_sede
            LEFT JOIN settori st ON p.id_settore = st.id_settore
            LEFT JOIN classi cl ON p.id_classe = cl.id_classe
            WHERE cp.id_casemanager = :id_casemanager AND cp.is_attiva = 1
            ORDER BY cp.data_associazione DESC
        ");

        $stmt->execute([':id_casemanager' => $id_casemanager]);
        $pazienti = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Pazienti del case manager recuperati', $pazienti);

    /* ===== GET_PAZIENTI_DISPONIBILI ===== */
    } elseif ($action === 'get_pazienti_disponibili') {
        $id_casemanager = intval($input['id_casemanager'] ?? 0);

        if (empty($id_casemanager)) {
            jsonResponse(false, 'ID case manager non specificato');
        }

        $stmt = $pdo->prepare("
            SELECT
                p.id_paziente,
                p.id_registrazione,
                CONCAT(p.nome_paziente, ' ', p.cognome_paziente) AS nome_completo,
                r.username_registrazione,
                s.nome_sede,
                st.nome_settore,
                cl.nome_classe
            FROM pazienti p
            JOIN registrazioni r ON p.id_registrazione = r.id_registrazione
            LEFT JOIN sedi s ON p.id_sede = s.id_sede
            LEFT JOIN settori st ON p.id_settore = st.id_settore
            LEFT JOIN classi cl ON p.id_classe = cl.id_classe
            WHERE p.id_paziente NOT IN (
                SELECT id_paziente FROM casemanager_pazienti
                WHERE id_casemanager = :id_casemanager AND is_attiva = 1
            )
            ORDER BY p.nome_paziente ASC
        ");

        $stmt->execute([':id_casemanager' => $id_casemanager]);
        $pazienti = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Pazienti disponibili recuperati', $pazienti);

    /* ===== ASSIGN_PAZIENTE ===== */
    } elseif ($action === 'assign_paziente') {
        $id_casemanager = intval($input['id_casemanager'] ?? 0);
        $id_paziente = intval($input['id_paziente'] ?? 0);
        $note = trim($input['note'] ?? '');

        if (empty($id_casemanager) || empty($id_paziente)) {
            jsonResponse(false, 'ID case manager e ID paziente sono obbligatori');
        }

        // Verifica che il case manager esista
        $stmt = $pdo->prepare("SELECT id_casemanager FROM casemanager WHERE id_casemanager = :id");
        $stmt->execute([':id' => $id_casemanager]);
        if (!$stmt->fetch()) {
            jsonResponse(false, 'Case manager non trovato');
        }

        // Verifica che il paziente esista
        $stmt = $pdo->prepare("SELECT id_paziente FROM pazienti WHERE id_paziente = :id");
        $stmt->execute([':id' => $id_paziente]);
        if (!$stmt->fetch()) {
            jsonResponse(false, 'Paziente non trovato');
        }

        // Verifica se già assegnato
        $stmt = $pdo->prepare("
            SELECT id_associazione FROM casemanager_pazienti
            WHERE id_casemanager = :id_cm AND id_paziente = :id_paz AND is_attiva = 1
        ");
        $stmt->execute([':id_cm' => $id_casemanager, ':id_paz' => $id_paziente]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Paziente già assegnato a questo case manager');
        }

        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare("
                INSERT INTO casemanager_pazienti (id_casemanager, id_paziente, data_associazione, is_attiva, note)
                VALUES (:id_cm, :id_paz, DATE_FORMAT(NOW(), '%d/%m/%Y'), 1, :note)
            ");

            $stmt->execute([
                ':id_cm' => $id_casemanager,
                ':id_paz' => $id_paziente,
                ':note' => $note
            ]);

            $pdo->commit();
            logOperation('ASSIGN_PAZIENTE', "Case Manager: $id_casemanager, Paziente: $id_paziente", $ip);
            jsonResponse(true, 'Paziente assegnato con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nell\'assegnazione del paziente: ' . $e->getMessage());
        }

    /* ===== UNASSIGN_PAZIENTE ===== */
    } elseif ($action === 'unassign_paziente') {
        $id_casemanager = intval($input['id_casemanager'] ?? 0);
        $id_paziente = intval($input['id_paziente'] ?? 0);

        if (empty($id_casemanager) || empty($id_paziente)) {
            jsonResponse(false, 'ID case manager e ID paziente sono obbligatori');
        }

        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare("
                UPDATE casemanager_pazienti
                SET is_attiva = 0
                WHERE id_casemanager = :id_cm AND id_paziente = :id_paz
            ");

            $stmt->execute([
                ':id_cm' => $id_casemanager,
                ':id_paz' => $id_paziente
            ]);

            if ($stmt->rowCount() === 0) {
                jsonResponse(false, 'Associazione non trovata');
            }

            $pdo->commit();
            logOperation('UNASSIGN_PAZIENTE', "Case Manager: $id_casemanager, Paziente: $id_paziente", $ip);
            jsonResponse(true, 'Paziente rimosso con successo');

        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(false, 'Errore nella rimozione del paziente: ' . $e->getMessage());
        }

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_casemanager.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in api_casemanager.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>
