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

// Usa configurazione auto-ambiente
require_once __DIR__ . '/config.php';
// Imposta fuso orario applicativo leggendo da ENV (fallback Europe/Rome)
$__appTz = getenv('APP_TZ') ?: 'Europe/Rome';
@date_default_timezone_set($__appTz);

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
    $logFile = '../logs/risultati_esercizi.log';
    $logDir = dirname($logFile);

    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $action - $details - IP: $ip\n";

    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

function columnExists(PDO $pdo, string $table, string $column): bool {
    try {
        $stmt = $pdo->prepare("SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = :t AND COLUMN_NAME = :c LIMIT 1");
        $stmt->execute([':t' => $table, ':c' => $column]);
        return (bool)$stmt->fetch(PDO::FETCH_NUM);
    } catch (Throwable $e) {
        return false;
    }
}

try {
    // Connessione al database (auto ambiente)
    $pdo = getDbConnection();

    // Leggi i dati JSON dalla richiesta
    $input = json_decode(file_get_contents('php://input'), true);
    $debug = isset($_GET['debug']) ? ($_GET['debug'] === '1') : ((isset($input['debug']) && $input['debug'] === '1'));
    $action = $input['action'] ?? $_GET['action'] ?? '';
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    // ===================== START SESSIONE =====================
    if ($action === 'start_session') {
        $nome_educatore = trim($input['nome_educatore'] ?? '') ?: 'Sviluppatore';
        $nome_paziente = trim($input['nome_paziente'] ?? '') ?: 'Anonimo';
        $categoria_esercizio = trim($input['categoria_esercizio'] ?? '');
        $nome_esercizio = trim($input['nome_esercizio'] ?? '');
        $tempo_latenza = floatval($input['tempo_latenza'] ?? 0); // impostazione timer
        $items_totali_utilizzati = intval($input['items_totali_utilizzati'] ?? 0);
        $session_started_at = intval($input['session_started_at'] ?? 0) ?: (int)round(microtime(true)*1000);

        if ($categoria_esercizio === '' || $nome_esercizio === '') { jsonResponse(false, 'Categoria/Esercizio obbligatori'); }

        $data_esecuzione_sql = date('Y-m-d', (int)floor($session_started_at/1000));
        $ora_inizio_sql = date('H:i:s', (int)floor($session_started_at/1000));
        $datetime_inizio_sql = date('Y-m-d H:i:s', (int)floor($session_started_at/1000));

        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        // Costruzione dinamica colonne
        $cols = [ 'nome_educatore','nome_paziente','categoria_esercizio','nome_esercizio','tempo_latenza','items_totali_utilizzati','ip_address','user_agent' ];
        $place = [ ':nome_educatore',':nome_paziente',':categoria_esercizio',':nome_esercizio',':tempo_latenza',':items_totali_utilizzati',':ip_address',':user_agent' ];
        $bind = [
            ':nome_educatore'=>$nome_educatore,
            ':nome_paziente'=>$nome_paziente,
            ':categoria_esercizio'=>$categoria_esercizio,
            ':nome_esercizio'=>$nome_esercizio,
            ':tempo_latenza'=>$tempo_latenza,
            ':items_totali_utilizzati'=>$items_totali_utilizzati,
            ':ip_address'=>$ip,
            ':user_agent'=>$user_agent,
        ];
        if (columnExists($pdo,'risultati_esercizi','data_esecuzione')) { $cols[]='data_esecuzione'; $place[]=':data_esecuzione'; $bind[':data_esecuzione']=$data_esecuzione_sql; }
        if (columnExists($pdo,'risultati_esercizi','ora_inizio_esercizio')) { $cols[]='ora_inizio_esercizio'; $place[]=':ora_inizio'; $bind[':ora_inizio']=$ora_inizio_sql; }
        if (columnExists($pdo,'risultati_esercizi','data_esercizio')) { $cols[]='data_esercizio'; $place[]=':data_esercizio_ts'; $bind[':data_esercizio_ts']=$datetime_inizio_sql; }
        if (columnExists($pdo,'risultati_esercizi','started_at')) { $cols[]='started_at'; $place[]=':started_at'; $bind[':started_at']=$datetime_inizio_sql; }

        $sql = 'INSERT INTO risultati_esercizi ('.implode(',', $cols).') VALUES ('.implode(',', $place).')';
        error_log('▶️ start_session SQL: '.$sql);
        $stmt = $pdo->prepare($sql);
        $ok = $stmt->execute($bind);
        if (!$ok) { jsonResponse(false, 'Impossibile avviare la sessione'); }
        $new_id = (int)$pdo->lastInsertId();

        // Best-effort: assicurati che data/ora siano impostati anche se non inclusi nella INSERT
        $sets2 = [];
        $bind2 = [ ':id' => $new_id ];
        if (columnExists($pdo,'risultati_esercizi','data_esecuzione')) { $sets2[] = 'data_esecuzione = :data2'; $bind2[':data2'] = $data_esecuzione_sql; }
        if (columnExists($pdo,'risultati_esercizi','ora_inizio_esercizio')) { $sets2[] = 'ora_inizio_esercizio = :ora2'; $bind2[':ora2'] = $ora_inizio_sql; }
        if (columnExists($pdo,'risultati_esercizi','data_esercizio')) { $sets2[] = 'data_esercizio = :dt2'; $bind2[':dt2'] = $datetime_inizio_sql; }
        if (!empty($sets2)) {
            $sql2 = 'UPDATE risultati_esercizi SET '.implode(',', $sets2).' WHERE id_risultato = :id';
            try { $pdo->prepare($sql2)->execute($bind2); } catch (Throwable $e) { /* ignore */ }
        }

        jsonResponse(true, 'Sessione avviata', [ 'id_risultato' => $new_id, 'data_esecuzione' => $data_esecuzione_sql, 'ora_inizio' => $ora_inizio_sql ]);

    // ===================== FINE SESSIONE =====================
    } elseif ($action === 'end_session') {
        $id = intval($input['id_risultato'] ?? 0);
        $timestamp_click = intval($input['timestamp_click'] ?? 0) ?: (int)round(microtime(true)*1000);
        if ($id <= 0) { jsonResponse(false, 'id_risultato mancante'); }
        $ora_fine_sql = date('H:i:s', (int)floor($timestamp_click/1000));
        $datetime_fine_sql = date('Y-m-d H:i:s', (int)floor($timestamp_click/1000));
        $sets = [];
        $bind = [ ':id'=>$id ];
        if (columnExists($pdo,'risultati_esercizi','ora_fine_esercizio')) { $sets[]='ora_fine_esercizio = :fine'; $bind[':fine']=$ora_fine_sql; }
        if (empty($sets) && columnExists($pdo,'risultati_esercizi','data_esercizio')) { $sets[]='data_esercizio = :fine_dt'; $bind[':fine_dt']=$datetime_fine_sql; }
        if (empty($sets)) { jsonResponse(true, 'Sessione terminata (nessun campo orario disponibile)'); }
        $sql = 'UPDATE risultati_esercizi SET '.implode(',', $sets).' WHERE id_risultato = :id';
        error_log('⏹ end_session SQL: '.$sql);
        $stmt = $pdo->prepare($sql);
        $ok = $stmt->execute($bind);
        if (!$ok) { jsonResponse(false, 'Impossibile chiudere la sessione'); }
        jsonResponse(true, 'Sessione terminata', [ 'id_risultato' => $id, 'ora_fine_esercizio' => $ora_fine_sql ]);

    // ===================== SALVATAGGIO RISULTATI =====================
    } elseif ($action === 'save_result') {
        // LOG: Richiesta ricevuta
        error_log("📥 API save_result - Richiesta ricevuta");
        error_log("📦 Input raw: " . json_encode($input));

        // Validazione input
        $nome_educatore = trim($input['nome_educatore'] ?? '');
        $nome_paziente = trim($input['nome_paziente'] ?? '');
        $categoria_esercizio = trim($input['categoria_esercizio'] ?? '');
        $nome_esercizio = trim($input['nome_esercizio'] ?? '');
        $tempo_latenza = floatval($input['tempo_latenza'] ?? 0);
        $sessione_numero = intval($input['sessione_numero'] ?? 1);
        $items_totali_utilizzati = intval($input['items_totali_utilizzati'] ?? ($input['items_totali'] ?? 0));
        $tempo_visualizzazione = floatval($input['tempo_visualizzazione'] ?? 30.0);
        $feedback_tipo = trim($input['feedback_tipo'] ?? 'nessuno');
        $feedback_testo = trim($input['feedback_testo'] ?? '');
        $session_started_at = intval($input['session_started_at'] ?? ($input['timestamp_inizio'] ?? 0));
        $timestamp_click = intval($input['timestamp_click'] ?? 0);

        // Nuovi campi opzionali per tracking dettagliato
        $items_corrette = isset($input['items_corrette']) ? intval($input['items_corrette']) : null;
        $items_errate = isset($input['items_errate']) ? intval($input['items_errate']) : null;
        $nomi_items_corrette = $input['nomi_items_corrette'] ?? null; // array o stringa JSON
        $nomi_items_errate = $input['nomi_items_errate'] ?? null;     // array o stringa JSON
        $item_nome = isset($input['item_nome']) ? trim((string)$input['item_nome']) : null;
        $item_corretto = isset($input['item_corretto']) ? (intval($input['item_corretto']) ? 1 : 0) : null;

        // Default per sviluppatore: se mancanti, usa Sviluppatore/Anonimo
        if ($nome_educatore === '') { $nome_educatore = 'Sviluppatore'; }
        if ($nome_paziente === '') { $nome_paziente = 'Anonimo'; }
        // Validazione campi obbligatori
        if (empty($nome_educatore)) { jsonResponse(false, 'Nome educatore è obbligatorio'); }
        if (empty($nome_paziente)) { jsonResponse(false, 'Nome paziente è obbligatorio'); }
        if (empty($categoria_esercizio)) { jsonResponse(false, 'Categoria esercizio è obbligatoria'); }
        if (empty($nome_esercizio)) { jsonResponse(false, 'Nome esercizio è obbligatorio'); }
        // Se è un evento "riassunto" (con conteggi/elenchi) o per-item (item_nome presente), consenti 0
        $is_summary_event = ($items_corrette !== null) || ($items_errate !== null) || ($nomi_items_corrette !== null) || ($nomi_items_errate !== null);
        $is_item_event = ($item_nome !== null) || ($item_corretto !== null);
        if ($tempo_latenza <= 0 && !$is_summary_event && !$is_item_event) { jsonResponse(false, 'Tempo di latenza non valido'); }

        // Validazione feedback_tipo
        $feedback_tipi_validi = ['nessuno', 'applauso', 'tts'];
        if (!in_array($feedback_tipo, $feedback_tipi_validi)) { $feedback_tipo = 'nessuno'; }
        if ($feedback_tipo === 'tts' && empty($feedback_testo)) { $feedback_tipo = 'nessuno'; $feedback_testo = null; }
        if ($feedback_tipo !== 'tts') { $feedback_testo = null; }

        // Timestamp di default e normalizzazione per nuova tabella
        $nowMs = (int)round(microtime(true)*1000);
        if ($session_started_at <= 0) { $session_started_at = $nowMs; }
        if ($timestamp_click <= 0) { $timestamp_click = $nowMs; }
        $data_esecuzione_sql = date('Y-m-d', (int)floor($session_started_at/1000));
        $ora_inizio_sql = date('H:i:s', (int)floor($session_started_at/1000));
        $ora_fine_sql = date('H:i:s', (int)floor($timestamp_click/1000));

        // User agent per debugging
        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? '';

        // Prepara insert per nuova tabella
        if ($item_corretto === null && $item_nome !== null) { $item_corretto = 1; } // fallback: se non specificato ma c'è un nome, considera corretto
        if ($item_corretto === 1 && empty($nomi_items_corrette)) { $nomi_items_corrette = $item_nome; }
        if ($item_corretto === 0 && empty($nomi_items_errate)) { $nomi_items_errate = $item_nome; }

        // Logica: se item_corretto=1, popola nome_item_corretto, altrimenti nome_item_errato
        $nome_item_corretto = null;
        $nome_item_errato = null;
        $item_errato_flag = 0;

        // DEBUG LOG
        error_log("🎨 CERCA COLORE - item_nome: " . var_export($item_nome, true) . " | item_corretto: " . var_export($item_corretto, true));

        if ($item_corretto === 1) {
            $nome_item_corretto = $item_nome;
            $item_errato_flag = 0;
            error_log("✅ CORRETTO - nome_item_corretto: " . var_export($nome_item_corretto, true));
        } elseif ($item_corretto === 0) {
            $nome_item_errato = $item_nome;
            $item_errato_flag = 1;
            error_log("❌ ERRATO - nome_item_errato: " . var_export($nome_item_errato, true));
        }

        $stmt = $pdo->prepare("INSERT INTO risultati_esercizi (
            nome_educatore,
            nome_paziente,
            categoria_esercizio,
            nome_esercizio,
            tempo_latenza,
            items_totali_utilizzati,
            item_corretto,
            item_errato,
            nome_item_corretto,
            nome_item_errato,
            data_esecuzione,
            ora_inizio_esercizio,
            ora_fine_esercizio,
            ip_address,
            user_agent
        ) VALUES (
            :nome_educatore,
            :nome_paziente,
            :categoria_esercizio,
            :nome_esercizio,
            :tempo_latenza,
            :items_totali_utilizzati,
            :item_corretto,
            :item_errato,
            :nome_item_corretto,
            :nome_item_errato,
            :data_esecuzione,
            :ora_inizio,
            :ora_fine,
            :ip_address,
            :user_agent
        )");

        $params = [
            ':nome_educatore'=>$nome_educatore,
            ':nome_paziente'=>$nome_paziente,
            ':categoria_esercizio'=>$categoria_esercizio,
            ':nome_esercizio'=>$nome_esercizio,
            ':tempo_latenza'=>$tempo_latenza,
            ':items_totali_utilizzati'=>$items_totali_utilizzati,
            ':item_corretto'=>$item_corretto ?? 0,
            ':item_errato'=>$item_errato_flag,
            ':nome_item_corretto'=>$nome_item_corretto,
            ':nome_item_errato'=>$nome_item_errato,
            ':data_esecuzione'=>$data_esecuzione_sql,
            ':ora_inizio'=>$ora_inizio_sql,
            ':ora_fine'=>$ora_fine_sql,
            ':ip_address'=>$ip,
            ':user_agent'=>$user_agent
        ];

        // LOG: Parametri prima INSERT
        error_log("💾 Parametri INSERT: " . json_encode($params, JSON_UNESCAPED_UNICODE));

        try {
            $result = $stmt->execute($params);
            error_log("✅ INSERT eseguito con successo, result: " . ($result ? 'true' : 'false'));
        } catch (PDOException $e) {
            error_log("❌ ERRORE INSERT: " . $e->getMessage());
            error_log("❌ SQL State: " . $e->getCode());
            jsonResponse(false, 'Errore database: ' . $e->getMessage());
        }

        if ($result) {
            $new_id = $pdo->lastInsertId();

            logOperation(
                'SAVE_RESULT',
                "Educatore: $nome_educatore, Paziente: $nome_paziente, Esercizio: $nome_esercizio, Latenza: {$tempo_latenza}s",
                $ip
            );

            jsonResponse(true, 'Risultato salvato con successo', [
                'id_risultato' => $new_id,
                'tempo_latenza' => $tempo_latenza,
                'data_esecuzione' => $data_esecuzione_sql
            ]);
        } else {
            jsonResponse(false, 'Errore nel salvataggio del risultato');
        }

    // ===================== RECUPERO RISULTATI =====================
    } elseif ($action === 'get_results') {
        // Filtri opzionali
        $educatore = trim($input['educatore'] ?? $_GET['educatore'] ?? '');
        $paziente = trim($input['paziente'] ?? $_GET['paziente'] ?? '');
        $categoria = trim($input['categoria'] ?? $_GET['categoria'] ?? '');
        $esercizio = trim($input['esercizio'] ?? $_GET['esercizio'] ?? '');
        $data_da = trim($input['data_da'] ?? $_GET['data_da'] ?? '');
        $data_a = trim($input['data_a'] ?? $_GET['data_a'] ?? '');
        $items = trim($input['items'] ?? $_GET['items'] ?? '');
        $fascia_oraria = trim($input['fascia_oraria'] ?? $_GET['fascia_oraria'] ?? ''); // 'mattina' | 'pomeriggio'
        $limit = intval($input['limit'] ?? $_GET['limit'] ?? 50);

        // Validazione limit
        if ($limit <= 0 || $limit > 1000) { $limit = 50; }

        // Costruisci query con filtri
        $where_conditions = [];
        $params = [];

        if (!empty($educatore)) { $where_conditions[] = 'nome_educatore LIKE :educatore'; $params[':educatore'] = "%$educatore%"; }
        if (!empty($paziente)) { $where_conditions[] = 'nome_paziente LIKE :paziente'; $params[':paziente'] = "%$paziente%"; }
        if (!empty($categoria)) { $where_conditions[] = 'categoria_esercizio LIKE :categoria'; $params[':categoria'] = "%$categoria%"; }
        if (!empty($esercizio)) { $where_conditions[] = 'nome_esercizio LIKE :esercizio'; $params[':esercizio'] = "%$esercizio%"; }
        if (!empty($items)) {
            $has_items_util = columnExists($pdo, 'risultati_esercizi', 'items_totali_utilizzati');
            $has_items_tot = columnExists($pdo, 'risultati_esercizi', 'items_totali');
            if ($has_items_util) { $where_conditions[] = 'items_totali_utilizzati = :items'; $params[':items'] = intval($items); }
            elseif ($has_items_tot) { $where_conditions[] = 'items_totali = :items'; $params[':items'] = intval($items); }
        }

        // Filtri data: accetta dd/mm/yyyy dal client e converte a YYYY-MM-DD (DATE)
        $toSqlDate = function($s){
            $s = trim($s);
            if ($s==='') return '';
            if (strpos($s,'/')!==false) { // dd/mm/yyyy -> yyyy-mm-dd
                [$d,$m,$y] = array_map('intval', explode('/', $s));
                if ($y && $m && $d) { return sprintf('%04d-%02d-%02d', $y, $m, $d); }
            }
            return $s; // già in yyyy-mm-dd
        };
        $has_started_at = columnExists($pdo, 'risultati_esercizi', 'started_at');
        $has_data_esecuzione = columnExists($pdo, 'risultati_esercizi', 'data_esecuzione');
        $has_data_esercizio_ts = columnExists($pdo, 'risultati_esercizi', 'data_esercizio');
        if ($has_started_at) {
            if (!empty($data_da)) { $data_da_sql = $toSqlDate($data_da); if($data_da_sql){ $where_conditions[] = 'started_at IS NOT NULL AND DATE(started_at) >= :data_da'; $params[':data_da'] = $data_da_sql; } }
            if (!empty($data_a)) { $data_a_sql = $toSqlDate($data_a); if($data_a_sql){ $where_conditions[] = 'started_at IS NOT NULL AND DATE(started_at) <= :data_a'; $params[':data_a'] = $data_a_sql; } }
            if (!empty($fascia_oraria)) {
                if ($fascia_oraria === 'mattina') {
                    $where_conditions[] = "started_at IS NOT NULL AND TIME(started_at) BETWEEN '08:00:00' AND '13:59:59'";
                } elseif ($fascia_oraria === 'pomeriggio') {
                    $where_conditions[] = "started_at IS NOT NULL AND TIME(started_at) BETWEEN '14:00:00' AND '20:59:59'";
                }
            }
        } elseif ($has_data_esecuzione) {
            if (!empty($data_da)) { $data_da_sql = $toSqlDate($data_da); if($data_da_sql){ $where_conditions[] = 'data_esecuzione >= :data_da'; $params[':data_da'] = $data_da_sql; } }
            if (!empty($data_a)) { $data_a_sql = $toSqlDate($data_a); if($data_a_sql){ $where_conditions[] = 'data_esecuzione <= :data_a'; $params[':data_a'] = $data_a_sql; } }
            if (!empty($fascia_oraria)) {
                $has_ora_inizio = columnExists($pdo,'risultati_esercizi','ora_inizio_esercizio');
                $has_ora_fine = columnExists($pdo,'risultati_esercizi','ora_fine_esercizio');
                if ($fascia_oraria === 'mattina') {
                    if ($has_ora_inizio) { $where_conditions[] = "TIME(ora_inizio_esercizio) BETWEEN '08:00:00' AND '13:59:59'"; }
                    elseif ($has_ora_fine) { $where_conditions[] = "TIME(ora_fine_esercizio) BETWEEN '08:00:00' AND '13:59:59'"; }
                } elseif ($fascia_oraria === 'pomeriggio') {
                    if ($has_ora_inizio) { $where_conditions[] = "TIME(ora_inizio_esercizio) BETWEEN '14:00:00' AND '20:59:59'"; }
                    elseif ($has_ora_fine) { $where_conditions[] = "TIME(ora_fine_esercizio) BETWEEN '14:00:00' AND '20:59:59'"; }
                }
            }
        }

        $where_clause = '';
        if (!empty($where_conditions)) { $where_clause = 'WHERE ' . implode(' AND ', $where_conditions); }

        // Costruisci SELECT dinamica in base alle colonne presenti
        $sel = [];
        $sel[] = 'id_risultato';
        $sel[] = 'nome_educatore';
        $sel[] = 'nome_paziente';
        $sel[] = 'categoria_esercizio';
        $sel[] = 'nome_esercizio';
        $sel[] = 'tempo_latenza';
        $sel[] = columnExists($pdo,'risultati_esercizi','items_totali_utilizzati') ? 'items_totali_utilizzati' : (columnExists($pdo,'risultati_esercizi','items_totali') ? 'items_totali AS items_totali_utilizzati' : 'NULL AS items_totali_utilizzati');
        $sel[] = columnExists($pdo,'risultati_esercizi','item_corretto') ? 'item_corretto' : 'NULL AS item_corretto';
        $sel[] = columnExists($pdo,'risultati_esercizi','item_errato') ? 'item_errato' : 'NULL AS item_errato';
        $sel[] = columnExists($pdo,'risultati_esercizi','nome_item_corretto') ? 'nome_item_corretto' : 'NULL AS nome_item_corretto';
        $sel[] = columnExists($pdo,'risultati_esercizi','nome_item_errato') ? 'nome_item_errato' : 'NULL AS nome_item_errato';
        // legacy singolo nome item
        $sel[] = columnExists($pdo,'risultati_esercizi','item_nome') ? 'item_nome' : 'NULL AS item_nome';
        $sel[] = columnExists($pdo,'risultati_esercizi','nomi_items_corrette') ? 'nomi_items_corrette' : 'NULL AS nomi_items_corrette';
        $sel[] = columnExists($pdo,'risultati_esercizi','nomi_items_errate') ? 'nomi_items_errate' : 'NULL AS nomi_items_errate';
        // conteggi opzionali, se esistono
        $sel[] = columnExists($pdo,'risultati_esercizi','items_corrette') ? 'items_corrette' : 'NULL AS items_corrette';
        $sel[] = columnExists($pdo,'risultati_esercizi','items_errate') ? 'items_errate' : 'NULL AS items_errate';
        // data/ora: preferisci colonne nuove, altrimenti prova a derivarle
        if (columnExists($pdo,'risultati_esercizi','data_esecuzione')) { $sel[]='data_esecuzione'; } else { $sel[]='NULL AS data_esecuzione'; }
        if (columnExists($pdo,'risultati_esercizi','ora_inizio_esercizio')) { $sel[]='ora_inizio_esercizio'; } else { $sel[]='NULL AS ora_inizio_esercizio'; }
        if (columnExists($pdo,'risultati_esercizi','ora_fine_esercizio')) { $sel[]='ora_fine_esercizio'; } else { $sel[]='NULL AS ora_fine_esercizio'; }
        // Se disponibile, includi started_at per uso client
        if ($has_started_at) { $sel[] = 'started_at'; }
        $sel[] = 'ip_address';
        // colonne legacy possibili per fallback data/ora
        if (columnExists($pdo,'risultati_esercizi','timestamp_inizio')) { $sel[] = 'timestamp_inizio'; } else { $sel[] = 'NULL AS timestamp_inizio'; }
        if (columnExists($pdo,'risultati_esercizi','timestamp_click')) { $sel[] = 'timestamp_click'; } else { $sel[] = 'NULL AS timestamp_click'; }
        if (columnExists($pdo,'risultati_esercizi','created_at')) { $sel[] = 'created_at'; } else { $sel[] = 'NULL AS created_at'; }
        if (columnExists($pdo,'risultati_esercizi','data_esercizio')) { $sel[] = 'data_esercizio AS __data_esercizio_ts'; } else { $sel[] = 'NULL AS __data_esercizio_ts'; }

        $order = 'ORDER BY id_risultato DESC';
        if ($has_data_esecuzione) {
            $has_ora_inizio = columnExists($pdo,'risultati_esercizi','ora_inizio_esercizio');
            $order = 'ORDER BY data_esecuzione DESC' . ($has_ora_inizio ? ', ora_inizio_esercizio DESC' : '');
        }

        // Aggiungi started_at e riattiva ORDER se disponibile
        if ($has_started_at) { $sel[] = 'started_at'; }
        $sql = 'SELECT '.implode(",\n                ", $sel)."\n            FROM risultati_esercizi\n            $where_clause\n            ".($has_started_at ? 'ORDER BY started_at DESC' : 'ORDER BY id_risultato DESC')."\n            LIMIT :limit";
        try { $stmt = $pdo->prepare($sql); }
        catch (PDOException $e) { if ($debug) { jsonResponse(false, 'DB ERROR: '.$e->getMessage(), ['sql'=>'prepare.get_results','query'=>$sql]); } throw $e; }

        foreach ($params as $key => $value) { $stmt->bindValue($key, $value); }
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);

        try { $stmt->execute(); }
        catch (PDOException $e) { if ($debug) { jsonResponse(false, 'DB ERROR: '.$e->getMessage(), ['sql'=>'get_results']); } throw $e; }
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Normalizza campi elenco in array JSON e calcola percentuali
        foreach ($results as &$row) {
            // Fallback per data/ora se nulli
            if (empty($row['data_esecuzione'])) {
                $ts = $row['timestamp_inizio'] ?? null;
                if ($ts !== null && $ts !== '') {
                    $tsNum = (int)$ts;
                    if ($tsNum > 20000000000) { $tsNum = (int)floor($tsNum/1000); } // ms -> s
                    if ($tsNum > 0) {
                        $row['data_esecuzione'] = date('Y-m-d', $tsNum);
                        if (empty($row['ora_inizio_esercizio'])) { $row['ora_inizio_esercizio'] = date('H:i:s', $tsNum); }
                    }
                } elseif (!empty($row['__data_esercizio_ts'])) {
                    $t = strtotime((string)$row['__data_esercizio_ts']);
                    if ($t && $t > 0) { $row['data_esecuzione'] = date('Y-m-d', $t); if (empty($row['ora_inizio_esercizio'])) { $row['ora_inizio_esercizio'] = date('H:i:s', $t); } }
                } elseif (!empty($row['created_at'])) {
                    // tenta parse generico
                    $t = strtotime((string)$row['created_at']);
                    if ($t && $t > 0) { $row['data_esecuzione'] = date('Y-m-d', $t); if (empty($row['ora_inizio_esercizio'])) { $row['ora_inizio_esercizio'] = date('H:i:s', $t); } }
                }
            }
            // Decode liste se stringhe JSON altrimenti prova split su virgola
            foreach ([['key'=>'nomi_items_corrette'], ['key'=>'nomi_items_errate']] as $info) {
                $k = $info['key'];
                if (array_key_exists($k, $row)) {
                    $v = $row[$k];
                    if (is_string($v) && $v !== '') {
                        $decoded = json_decode($v, true);
                        if (json_last_error() === JSON_ERROR_NONE && is_array($decoded)) {
                            $row[$k] = $decoded;
                        } else {
                            // split semplice su virgola
                            $parts = array_filter(array_map('trim', explode(',', $v)), function($s){ return $s !== ''; });
                            $row[$k] = array_values($parts);
                        }
                    }
                }
            }
            // Deriva conteggi da liste se mancanti
            if (!isset($row['items_corrette']) || $row['items_corrette'] === null) {
                if (isset($row['nomi_items_corrette']) && is_array($row['nomi_items_corrette'])) { $row['items_corrette'] = count($row['nomi_items_corrette']); }
            }
            if (!isset($row['items_errate']) || $row['items_errate'] === null) {
                if (isset($row['nomi_items_errate']) && is_array($row['nomi_items_errate'])) { $row['items_errate'] = count($row['nomi_items_errate']); }
            }
            // Se è evento per-item, popola un nome item unificato per compatibilità UI
            if (empty($row['item_nome'])) {
                if (!empty($row['nome_item_corretto'])) { $row['item_nome'] = $row['nome_item_corretto']; }
                elseif (!empty($row['nome_item_errato'])) { $row['item_nome'] = $row['nome_item_errato']; }
            }
            // Percentuali se disponibili i conteggi
            $tot = isset($row['items_totali_utilizzati']) ? (int)$row['items_totali_utilizzati'] : (isset($row['items_totali']) ? (int)$row['items_totali'] : 0);
            $cor = isset($row['items_corrette']) ? (int)$row['items_corrette'] : null;
            $err = isset($row['items_errate']) ? (int)$row['items_errate'] : null;
            if ($tot > 0 && $cor !== null) {
                $row['percentuale_corrette'] = round(($cor * 100.0) / $tot, 2);
            }
            if ($tot > 0 && $err !== null) {
                $row['percentuale_errate'] = round(($err * 100.0) / $tot, 2);
            }
        }

        $payload = [
            'risultati' => $results,
            'count' => count($results),
            'filtri_applicati' => [
                'educatore' => $educatore,
                'paziente' => $paziente,
                'categoria' => $categoria,
                'esercizio' => $esercizio,
                'data_da' => $data_da,
                'data_a' => $data_a,
                'fascia_oraria' => $fascia_oraria,
                'limit' => $limit
            ]
        ];
        if ($debug) {
            $payload['debug'] = [
                'selected_columns' => $sel,
                'order_clause' => $order,
                'where_clause' => $where_clause,
                'sample_row' => isset($results[0]) ? $results[0] : null
            ];
        }
        jsonResponse(true, 'Risultati recuperati con successo', $payload);

    // ===================== STATISTICHE =====================
    } elseif ($action === 'get_statistics') {
        // Statistiche generali
        $stmt_general = $pdo->prepare("SELECT
                COUNT(*) as totale_sessioni,
                COUNT(DISTINCT nome_educatore) as numero_educatori,
                COUNT(DISTINCT nome_paziente) as numero_pazienti,
                COUNT(DISTINCT CONCAT(categoria_esercizio, '-', nome_esercizio)) as numero_esercizi_unici,
                AVG(tempo_latenza) as tempo_medio,
                MIN(tempo_latenza) as tempo_minimo,
                MAX(tempo_latenza) as tempo_massimo
            FROM risultati_esercizi");
        try { $stmt_general->execute(); }
        catch (PDOException $e) { if ($debug) { jsonResponse(false, 'DB ERROR: '.$e->getMessage(), ['sql'=>'get_statistics.general']); } throw $e; }
        $stats_general = $stmt_general->fetch(PDO::FETCH_ASSOC);

        // Statistiche per esercizio
        $stmt_exercises = $pdo->prepare("SELECT
                categoria_esercizio,
                nome_esercizio,
                COUNT(*) as numero_sessioni,
                AVG(tempo_latenza) as tempo_medio,
                MIN(tempo_latenza) as tempo_minimo,
                MAX(tempo_latenza) as tempo_massimo,
                COUNT(DISTINCT nome_paziente) as pazienti_unici,
                AVG(items_totali_utilizzati) as media_items
            FROM risultati_esercizi
            GROUP BY categoria_esercizio, nome_esercizio
            ORDER BY numero_sessioni DESC");
        try { $stmt_exercises->execute(); }
        catch (PDOException $e) { if ($debug) { jsonResponse(false, 'DB ERROR: '.$e->getMessage(), ['sql'=>'get_statistics.exercises']); } throw $e; }
        $stats_exercises = $stmt_exercises->fetchAll(PDO::FETCH_ASSOC);

        // Statistiche feedback
        // Feedback rimossi dal nuovo flusso: ritorna vuoto
        $stats_feedback = [];

        jsonResponse(true, 'Statistiche recuperate con successo', [
            'generali' => $stats_general ?: new stdClass(),
            'per_esercizio' => $stats_exercises ?: [],
            'feedback' => $stats_feedback ?: []
        ]);

    } elseif ($action === 'get_distinct') {
        $educatori = $pdo->query("SELECT DISTINCT nome_educatore FROM risultati_esercizi WHERE nome_educatore IS NOT NULL AND nome_educatore<>'' ORDER BY nome_educatore")->fetchAll(PDO::FETCH_COLUMN);
        $pazienti = $pdo->query("SELECT DISTINCT nome_paziente FROM risultati_esercizi WHERE nome_paziente IS NOT NULL AND nome_paziente<>'' ORDER BY nome_paziente")->fetchAll(PDO::FETCH_COLUMN);

        // Prendi TUTTE le categorie dalla tabella categorie_esercizi invece che solo quelle con risultati
        try {
            $categorie = $pdo->query("SELECT nome_categoria FROM categorie_esercizi ORDER BY nome_categoria")->fetchAll(PDO::FETCH_COLUMN);
        } catch (PDOException $e) {
            // Fallback alla query originale se la tabella categorie_esercizi non esiste
            $categorie = $pdo->query("SELECT DISTINCT categoria_esercizio FROM risultati_esercizi WHERE categoria_esercizio IS NOT NULL AND categoria_esercizio<>'' ORDER BY categoria_esercizio")->fetchAll(PDO::FETCH_COLUMN);
        }

        $esercizi = $pdo->query("SELECT DISTINCT nome_esercizio FROM risultati_esercizi WHERE nome_esercizio IS NOT NULL AND nome_esercizio<>'' ORDER BY nome_esercizio")->fetchAll(PDO::FETCH_COLUMN);
        jsonResponse(true,'Distinct OK',[ 'educatori'=>$educatori, 'pazienti'=>$pazienti, 'categorie'=>$categorie, 'esercizi'=>$esercizi ]);

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_risultati_esercizi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore temporaneo del servizio. Riprova più tardi.');
} catch (Exception $e) {
    error_log("Errore generale in api_risultati_esercizi.php: " . $e->getMessage());
    jsonResponse(false, 'Errore del server. Riprova più tardi.');
}
?>