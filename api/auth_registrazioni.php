<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
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
        'registrazioni' => $data
    ]);
    exit();
}

// Funzione per validare email
function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

// Funzione per hash password (per versioni future)
function hashPassword($password) {
    // Per ora manteniamo password in chiaro per compatibilità
    // In futuro: return password_hash($password, PASSWORD_DEFAULT);
    return $password;
}

// Funzione per log delle operazioni
function logOperation($action, $username, $ip) {
    $logFile = '../logs/registrations.log';
    $logDir = dirname($logFile);

    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $action - User: $username - IP: $ip\n";

    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

try {
    // Connessione al database usando helper function
    $pdo = getDbConnection();

    // Leggi i dati JSON dalla richiesta
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['action'])) {
        jsonResponse(false, 'Azione non specificata');
    }

    $action = $input['action'];
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    if ($action === 'get_all') {
        // Recupera tutte le registrazioni (solo per amministratori)
        // ESCLUDI gli sviluppatori dalla lista - non devono essere visibili o modificabili
        $stmt = $pdo->prepare("
            SELECT id_registrazione, nome_registrazione, cognome_registrazione,
                   username_registrazione, ruolo_registrazione, data_registrazione,
                   ultimo_accesso
            FROM registrazioni
            WHERE ruolo_registrazione != 'sviluppatore'
            ORDER BY data_registrazione DESC
        ");
        $stmt->execute();
        $registrazioni = $stmt->fetchAll(PDO::FETCH_ASSOC);

        jsonResponse(true, 'Registrazioni recuperate con successo', $registrazioni);

    } elseif ($action === 'get_direttori_dettagli') {
        // Recupera direttori con tutti i dettagli (JOIN registrazioni + direttori + settori)
        // Verifica se la tabella direttori esiste
        try {
            $stmt = $pdo->prepare("
                SELECT r.id_registrazione, r.nome_registrazione, r.cognome_registrazione,
                       r.username_registrazione, r.ruolo_registrazione, r.data_registrazione,
                       r.ultimo_accesso, r.id_sede, r.stato_account,
                       d.id_direttore, d.id_settore, d.id_classe, d.telefono, d.email_contatto,
                       d.data_creazione, d.stato_direttore,
                       s.nome_settore as settore
                FROM registrazioni r
                LEFT JOIN direttori d ON r.id_registrazione = d.id_registrazione
                LEFT JOIN settori s ON d.id_settore = s.id_settore
                WHERE r.ruolo_registrazione = :ruolo
                ORDER BY r.data_registrazione DESC
            ");
            $stmt->execute([':ruolo' => 'direttore']);
            $direttori = $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            // Se il JOIN fallisce (tabella direttori non esiste), carica solo da registrazioni
            error_log("JOIN fallito in get_direttori_dettagli: " . $e->getMessage());
            $stmt = $pdo->prepare("
                SELECT id_registrazione, nome_registrazione, cognome_registrazione,
                       username_registrazione, ruolo_registrazione, data_registrazione,
                       ultimo_accesso, id_sede, id_settore, stato_account,
                       NULL as id_direttore, NULL as settore, NULL as classe,
                       NULL as telefono, NULL as email_contatto,
                       NULL as ruolo_specifico, NULL as data_creazione, NULL as stato_direttore
                FROM registrazioni
                WHERE ruolo_registrazione = :ruolo
                ORDER BY data_registrazione DESC
            ");
            $stmt->execute([':ruolo' => 'direttore']);
            $direttori = $stmt->fetchAll(PDO::FETCH_ASSOC);
        }

        jsonResponse(true, 'Direttori recuperati con successo', $direttori);

    } elseif ($action === 'get_casemanager_dettagli') {
        // Recupera casemanager con tutti i dettagli (JOIN registrazioni + casemanager + settori)
        // Verifica se la tabella casemanager esiste
        try {
            $stmt = $pdo->prepare("
                SELECT r.id_registrazione, r.nome_registrazione, r.cognome_registrazione,
                       r.username_registrazione, r.ruolo_registrazione, r.data_registrazione,
                       r.ultimo_accesso, r.id_sede, r.stato_account,
                       c.id_casemanager, c.id_direttore, c.id_settore, c.id_classe,
                       c.telefono, c.email_contatto, c.specializzazione,
                       c.data_creazione, c.stato_casemanager,
                       s.nome_settore as settore
                FROM registrazioni r
                LEFT JOIN casemanager c ON r.id_registrazione = c.id_registrazione
                LEFT JOIN settori s ON c.id_settore = s.id_settore
                WHERE r.ruolo_registrazione = :ruolo
                ORDER BY r.data_registrazione DESC
            ");
            $stmt->execute([':ruolo' => 'casemanager']);
            $casemanager = $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            // Se il JOIN fallisce (tabella direttori non esiste), carica solo da registrazioni
            error_log("JOIN fallito in get_casemanager_dettagli: " . $e->getMessage());
            $stmt = $pdo->prepare("
                SELECT id_registrazione, nome_registrazione, cognome_registrazione,
                       username_registrazione, ruolo_registrazione, data_registrazione,
                       ultimo_accesso, id_sede, id_settore, stato_account,
                       NULL as id_direttore, NULL as settore, NULL as classe,
                       NULL as telefono, NULL as email_contatto,
                       NULL as ruolo_specifico, NULL as data_creazione, NULL as stato_direttore
                FROM registrazioni
                WHERE ruolo_registrazione = :ruolo
                ORDER BY data_registrazione DESC
            ");
            $stmt->execute([':ruolo' => 'casemanager']);
            $casemanager = $stmt->fetchAll(PDO::FETCH_ASSOC);
        }

        jsonResponse(true, 'CaseManager recuperati con successo', $casemanager);

    } elseif ($action === 'create') {
        // Crea nuova registrazione
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $user_username = trim($input['username'] ?? '');
        $user_password = $input['password'] ?? '';
        $ruolo = $input['ruolo'] ?? '';
        $settore = trim($input['settore'] ?? '');
        $classe = trim($input['classe'] ?? '');
        $id_sede = intval($input['id_sede'] ?? 1); // Default alla sede principale

        // Validazioni
        if (empty($nome) || empty($cognome) || empty($user_username) || empty($user_password) || empty($ruolo)) {
            jsonResponse(false, 'Tutti i campi sono obbligatori');
        }

        if (strlen($nome) < 2 || strlen($cognome) < 2) {
            jsonResponse(false, 'Nome e cognome devono avere almeno 2 caratteri');
        }

        if (strlen($user_password) < 6) {
            jsonResponse(false, 'La password deve avere almeno 6 caratteri');
        }

        if (strpos($user_username, '@') !== false && !validateEmail($user_username)) {
            jsonResponse(false, 'Formato email non valido');
        }

        // Verifica che il ruolo sia valido
        $ruoli_validi = ['amministratore', 'educatore', 'paziente', 'direttore', 'casemanager'];
        if (!in_array($ruolo, $ruoli_validi)) {
            jsonResponse(false, 'Ruolo non valido');
        }

        // IMPEDIRE creazione di sviluppatori tramite API (solo manualmente nel database)
        if ($ruolo === 'sviluppatore') {
            jsonResponse(false, 'Il ruolo sviluppatore non può essere assegnato tramite questa interfaccia');
        }

        // CONTROLLO AUTORIZZAZIONI GERARCHICHE
        $calling_user_role = $_POST['calling_user_role'] ?? $input['calling_user_role'] ?? '';

        // 🔓 BYPASS COMPLETO PER SVILUPPATORE - può fare tutto senza limiti
        if ($calling_user_role === 'sviluppatore') {
            // Sviluppatore ha accesso completo a tutte le operazioni
            // Salta tutti i controlli gerarchici
        } else {
            // Verifica gerarchia permessi per altri ruoli
            if ($ruolo === 'amministratore') {
                // Solo gli sviluppatori possono creare amministratori
                jsonResponse(false, 'Solo gli sviluppatori possono creare account amministratore');
            } elseif ($ruolo === 'direttore' || $ruolo === 'casemanager') {
                // Solo sviluppatori e amministratori possono creare direttori/casemanager
                if (!in_array($calling_user_role, ['amministratore'])) {
                    jsonResponse(false, 'Non hai i permessi per creare account direttore/casemanager');
                }
            } elseif ($ruolo === 'educatore') {
                // Amministratori, direttori e casemanager possono creare educatori
                if (!in_array($calling_user_role, ['amministratore', 'direttore', 'casemanager'])) {
                    jsonResponse(false, 'Non hai i permessi per creare account educatore');
                }
            } elseif ($ruolo === 'paziente') {
                // Amministratori, direttori, casemanager ed educatori possono creare pazienti
                if (!in_array($calling_user_role, ['amministratore', 'educatore', 'direttore', 'casemanager'])) {
                    jsonResponse(false, 'Non hai i permessi per creare account paziente');
                }
            }
        }

        // Verifica che l'username non esista già
        $stmt = $pdo->prepare("SELECT id_registrazione FROM registrazioni WHERE username_registrazione = :username");
        $stmt->execute([':username' => $user_username]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Username già esistente. Scegli un altro username o email.');
        }

        // ✅ NON hashare: password in chiaro per compatibilità
        // $hashedPassword = hashPassword($user_password);

        // Inizia transazione
        $pdo->beginTransaction();

        try {
            // Inserisci nuova registrazione
            $stmt = $pdo->prepare("
                INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione,
                                         password_registrazione, ruolo_registrazione, id_sede, data_registrazione)
                VALUES (:nome, :cognome, :username, :password, :ruolo, :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y'))
            ");

            $result = $stmt->execute([
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':username' => $user_username,
                ':password' => $user_password,  // Password in chiaro
                ':ruolo' => $ruolo,
                ':id_sede' => $id_sede
            ]);

            if (!$result) {
                throw new Exception('Errore inserimento registrazione');
            }

            // Se il ruolo è educatore, paziente, direttore o casemanager, inserisci anche nella tabella specifica
            $id_registrazione = $pdo->lastInsertId();

            if ($ruolo === 'direttore' || $ruolo === 'casemanager') {
                // Tabella direttori/casemanager (NOTE: la tabella deve essere creata nel database)
                // CREATE TABLE direttori (
                //     id_direttore INT AUTO_INCREMENT PRIMARY KEY,
                //     id_registrazione INT UNIQUE,
                //     nome VARCHAR(100),
                //     cognome VARCHAR(100),
                //     settore VARCHAR(100),
                //     classe VARCHAR(50),
                //     id_sede INT,
                //     telefono VARCHAR(20),
                //     email_contatto VARCHAR(255),
                //     ruolo_specifico ENUM('direttore', 'casemanager'),
                //     data_creazione VARCHAR(19),
                //     stato_direttore ENUM('attivo', 'sospeso', 'inattivo'),
                //     FOREIGN KEY (id_registrazione) REFERENCES registrazioni(id_registrazione)
                // );

                $stmt_direttore = $pdo->prepare("
                    INSERT INTO direttori (id_registrazione, nome, cognome, settore, classe, id_sede, ruolo_specifico, data_creazione, stato_direttore)
                    VALUES (:id_registrazione, :nome, :cognome, :settore, :classe, :id_sede, :ruolo_specifico, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'), 'attivo')
                ");

                $result_direttore = $stmt_direttore->execute([
                    ':id_registrazione' => $id_registrazione,
                    ':nome' => $nome,
                    ':cognome' => $cognome,
                    ':settore' => $settore,
                    ':classe' => $classe,
                    ':id_sede' => $id_sede,
                    ':ruolo_specifico' => $ruolo
                ]);

                if (!$result_direttore) {
                    throw new Exception('Errore creazione profilo direttore/casemanager');
                }

            } elseif ($ruolo === 'educatore') {
                $stmt_educatore = $pdo->prepare("
                    INSERT INTO educatori (id_registrazione, nome, cognome, settore, classe, id_sede, data_creazione)
                    VALUES (:id_registrazione, :nome, :cognome, :settore, :classe, :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
                ");

                $result_educatore = $stmt_educatore->execute([
                    ':id_registrazione' => $id_registrazione,
                    ':nome' => $nome,
                    ':cognome' => $cognome,
                    ':settore' => $settore,
                    ':classe' => $classe,
                    ':id_sede' => $id_sede
                ]);

                if (!$result_educatore) {
                    throw new Exception('Errore creazione profilo educatore');
                }

            } elseif ($ruolo === 'paziente') {
                $stmt_paziente = $pdo->prepare("
                    INSERT INTO pazienti (id_registrazione, nome, cognome, settore, classe, id_sede, data_creazione)
                    VALUES (:id_registrazione, :nome, :cognome, :settore, :classe, :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
                ");

                $result_paziente = $stmt_paziente->execute([
                    ':id_registrazione' => $id_registrazione,
                    ':nome' => $nome,
                    ':cognome' => $cognome,
                    ':settore' => $settore,
                    ':classe' => $classe,
                    ':id_sede' => $id_sede
                ]);

                if (!$result_paziente) {
                    throw new Exception('Errore creazione profilo paziente');
                }

                // ✅ Se è specificato un educatore, associalo al paziente
                $id_educatore = intval($input['id_educatore'] ?? 0);
                if ($id_educatore > 0) {
                    // Verifica che l'educatore esista
                    $stmt_check_edu = $pdo->prepare("SELECT id_educatore FROM educatori WHERE id_educatore = :id");
                    $stmt_check_edu->execute([':id' => $id_educatore]);
                    if ($stmt_check_edu->fetch()) {
                        // Crea associazione in educatori_pazienti
                        $stmt_assoc = $pdo->prepare("
                            INSERT INTO educatori_pazienti (id_educatore, id_paziente, data_associazione, is_attiva)
                            VALUES (:id_educatore, :id_paziente, DATE_FORMAT(NOW(), '%d/%m/%Y'), 1)
                        ");

                        // Recupera l'id_paziente appena creato
                        $stmt_get_paz = $pdo->prepare("SELECT id_paziente FROM pazienti WHERE id_registrazione = :id_registrazione");
                        $stmt_get_paz->execute([':id_registrazione' => $id_registrazione]);
                        $paziente = $stmt_get_paz->fetch(PDO::FETCH_ASSOC);

                        if ($paziente) {
                            $stmt_assoc->execute([
                                ':id_educatore' => $id_educatore,
                                ':id_paziente' => $paziente['id_paziente']
                            ]);
                        }
                    }
                }
            }

            // Commit transazione
            $pdo->commit();

            logOperation('CREATE_USER', $user_username, $ip);
            jsonResponse(true, 'Registrazione creata con successo');

        } catch (Exception $e) {
            // Rollback in caso di errore
            $pdo->rollBack();
            jsonResponse(false, $e->getMessage());
        }

    } elseif ($action === 'update') {
        // Aggiorna registrazione esistente
        $id = $input['id'] ?? '';
        $nome = trim($input['nome'] ?? '');
        $cognome = trim($input['cognome'] ?? '');
        $user_username = trim($input['username'] ?? '');
        $user_password = $input['password'] ?? '';
        $ruolo = $input['ruolo'] ?? '';
        $id_sede = $input['id_sede'] ?? null;
        $settore = $input['settore'] ?? null;

        if (empty($id) || empty($nome) || empty($cognome) || empty($user_username) || empty($ruolo)) {
            jsonResponse(false, 'Tutti i campi obbligatori devono essere compilati');
        }

        // PROTEZIONE: Verifica che non si stia tentando di modificare uno sviluppatore
        $stmt_check = $pdo->prepare("SELECT ruolo_registrazione FROM registrazioni WHERE id_registrazione = :id");
        $stmt_check->execute([':id' => $id]);
        $existing_user = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if ($existing_user && $existing_user['ruolo_registrazione'] === 'sviluppatore') {
            jsonResponse(false, 'Gli account sviluppatore non possono essere modificati tramite questa interfaccia');
        }

        // Validazioni
        if (strlen($nome) < 2 || strlen($cognome) < 2) {
            jsonResponse(false, 'Nome e cognome devono avere almeno 2 caratteri');
        }

        // Se password non è 'nochange', validala
        $hashedPassword = null;
        if ($user_password && $user_password !== 'nochange') {
            if (strlen($user_password) < 6) {
                jsonResponse(false, 'La password deve avere almeno 6 caratteri');
            }
            $hashedPassword = hashPassword($user_password);
        }

        // Verifica che il ruolo sia valido
        $ruoli_validi = ['amministratore', 'educatore', 'paziente', 'direttore', 'casemanager'];
        if (!in_array($ruolo, $ruoli_validi)) {
            jsonResponse(false, 'Ruolo non valido');
        }

        // Verifica che l'username non sia già utilizzato da un altro utente
        $stmt = $pdo->prepare("SELECT id_registrazione FROM registrazioni WHERE username_registrazione = :username AND id_registrazione != :id");
        $stmt->execute([':username' => $user_username, ':id' => $id]);
        if ($stmt->fetch()) {
            jsonResponse(false, 'Username già utilizzato da un altro utente');
        }

        // Aggiorna la registrazione - se password è 'nochange', non la aggiorna
        // NOTA: il campo settore NON è in registrazioni, va solo in direttori
        if ($hashedPassword) {
            $stmt = $pdo->prepare("
                UPDATE registrazioni
                SET nome_registrazione = :nome,
                    cognome_registrazione = :cognome,
                    username_registrazione = :username,
                    password_registrazione = :password,
                    ruolo_registrazione = :ruolo,
                    id_sede = :id_sede
                WHERE id_registrazione = :id
            ");

            $result = $stmt->execute([
                ':id' => $id,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':username' => $user_username,
                ':password' => $hashedPassword,
                ':ruolo' => $ruolo,
                ':id_sede' => $id_sede
            ]);
        } else {
            $stmt = $pdo->prepare("
                UPDATE registrazioni
                SET nome_registrazione = :nome,
                    cognome_registrazione = :cognome,
                    username_registrazione = :username,
                    ruolo_registrazione = :ruolo,
                    id_sede = :id_sede
                WHERE id_registrazione = :id
            ");

            $result = $stmt->execute([
                ':id' => $id,
                ':nome' => $nome,
                ':cognome' => $cognome,
                ':username' => $user_username,
                ':ruolo' => $ruolo,
                ':id_sede' => $id_sede
            ]);
        }

        if ($result) {
            // Aggiorna/crea il record nella tabella specifica (direttori o casemanager)
            if ($ruolo === 'direttore') {
                try {
                    // Verifica se esiste un record in direttori
                    $stmt_check = $pdo->prepare("SELECT id_direttore FROM direttori WHERE id_registrazione = :id");
                    $stmt_check->execute([':id' => $id]);
                    $existing_direttore = $stmt_check->fetch(PDO::FETCH_ASSOC);

                    if ($existing_direttore) {
                        // Aggiorna il record esistente
                        $stmt_update = $pdo->prepare("
                            UPDATE direttori
                            SET id_settore = :id_settore,
                                id_sede = :id_sede
                            WHERE id_registrazione = :id
                        ");
                        $stmt_update->execute([
                            ':id_settore' => $settore,
                            ':id_sede' => $id_sede,
                            ':id' => $id
                        ]);
                    } else {
                        // Crea un nuovo record
                        $date_time = date('Y-m-d H:i:s');
                        $stmt_insert = $pdo->prepare("
                            INSERT INTO direttori (id_registrazione, nome, cognome, id_settore, id_sede, data_creazione, stato_direttore)
                            VALUES (:id, :nome, :cognome, :id_settore, :id_sede, :data_creazione, 'attivo')
                        ");
                        $stmt_insert->execute([
                            ':id' => $id,
                            ':nome' => $nome,
                            ':cognome' => $cognome,
                            ':id_settore' => $settore,
                            ':id_sede' => $id_sede,
                            ':data_creazione' => $date_time
                        ]);
                    }
                } catch (PDOException $e) {
                    error_log("Errore aggiornamento tabella direttori: " . $e->getMessage());
                }
            } elseif ($ruolo === 'casemanager') {
                try {
                    // Verifica se esiste un record in casemanager
                    $stmt_check = $pdo->prepare("SELECT id_casemanager FROM casemanager WHERE id_registrazione = :id");
                    $stmt_check->execute([':id' => $id]);
                    $existing_cm = $stmt_check->fetch(PDO::FETCH_ASSOC);

                    if ($existing_cm) {
                        // Aggiorna il record esistente
                        $stmt_update = $pdo->prepare("
                            UPDATE casemanager
                            SET id_settore = :id_settore,
                                id_sede = :id_sede
                            WHERE id_registrazione = :id
                        ");
                        $stmt_update->execute([
                            ':id_settore' => $settore,
                            ':id_sede' => $id_sede,
                            ':id' => $id
                        ]);
                    } else {
                        // Crea un nuovo record
                        $date_time = date('Y-m-d H:i:s');
                        $stmt_insert = $pdo->prepare("
                            INSERT INTO casemanager (id_registrazione, nome, cognome, id_settore, id_sede, data_creazione, stato_casemanager)
                            VALUES (:id, :nome, :cognome, :id_settore, :id_sede, :data_creazione, 'attivo')
                        ");
                        $stmt_insert->execute([
                            ':id' => $id,
                            ':nome' => $nome,
                            ':cognome' => $cognome,
                            ':id_settore' => $settore,
                            ':id_sede' => $id_sede,
                            ':data_creazione' => $date_time
                        ]);
                    }
                } catch (PDOException $e) {
                    error_log("Errore aggiornamento tabella casemanager: " . $e->getMessage());
                }
            }

            logOperation('UPDATE_USER', $user_username, $ip);
            jsonResponse(true, 'Registrazione aggiornata con successo');
        } else {
            jsonResponse(false, 'Errore nell\'aggiornamento della registrazione');
        }

    } elseif ($action === 'delete') {
        // Elimina registrazione
        $id = $input['id'] ?? '';

        if (empty($id)) {
            jsonResponse(false, 'ID registrazione non specificato');
        }

        // Ottieni informazioni utente prima di eliminare (incluso il ruolo per protezione)
        $stmt = $pdo->prepare("SELECT username_registrazione, ruolo_registrazione FROM registrazioni WHERE id_registrazione = :id");
        $stmt->execute([':id' => $id]);
        $user_data = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user_data) {
            jsonResponse(false, 'Registrazione non trovata');
        }

        // PROTEZIONE: Non permettere l'eliminazione di sviluppatori
        if ($user_data['ruolo_registrazione'] === 'sviluppatore') {
            jsonResponse(false, 'Gli account sviluppatore non possono essere eliminati tramite questa interfaccia');
        }

        $stmt = $pdo->prepare("DELETE FROM registrazioni WHERE id_registrazione = :id");
        $result = $stmt->execute([':id' => $id]);

        if ($result) {
            logOperation('DELETE_USER', $user_data['username_registrazione'], $ip);
            jsonResponse(true, 'Registrazione eliminata con successo');
        } else {
            jsonResponse(false, 'Errore nell\'eliminazione della registrazione');
        }

    } elseif ($action === 'change_password') {
        // Cambia password dell'utente loggato
        $id_registrazione = intval($input['id_registrazione'] ?? 0);
        $username_registrazione = trim($input['username_registrazione'] ?? '');
        $password_registrazione = $input['password_registrazione'] ?? '';

        // Validazioni
        if (empty($id_registrazione)) {
            jsonResponse(false, 'ID registrazione non specificato');
        }

        if (empty($username_registrazione)) {
            jsonResponse(false, 'Username non specificato');
        }

        if (empty($password_registrazione)) {
            jsonResponse(false, 'Password non specificata');
        }

        if (strlen($password_registrazione) < 6) {
            jsonResponse(false, 'La password deve avere almeno 6 caratteri');
        }

        // Verifica che l'ID esista
        $stmt_check = $pdo->prepare("SELECT username_registrazione, ruolo_registrazione FROM registrazioni WHERE id_registrazione = :id");
        $stmt_check->execute([':id' => $id_registrazione]);
        $existing_user = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if (!$existing_user) {
            jsonResponse(false, 'Registrazione non trovata');
        }

        // Usa la password così com'è (in chiaro come richiesto)
        $stmt = $pdo->prepare("
            UPDATE registrazioni
            SET password_registrazione = :password,
                username_registrazione = :username
            WHERE id_registrazione = :id
        ");

        $result = $stmt->execute([
            ':id' => $id_registrazione,
            ':password' => $password_registrazione,
            ':username' => $username_registrazione
        ]);

        if ($result) {
            logOperation('CHANGE_PASSWORD', $username_registrazione, $ip);
            jsonResponse(true, 'Password aggiornata con successo');
        } else {
            jsonResponse(false, 'Errore nell\'aggiornamento della password');
        }

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in auth_registrazioni.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in auth_registrazioni.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>