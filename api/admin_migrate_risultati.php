<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit(); }

require_once __DIR__ . '/config.php';

function respond($ok, $msg, $data=null){ echo json_encode(['success'=>$ok,'message'=>$msg,'data'=>$data], JSON_UNESCAPED_UNICODE); exit; }

try {
  $pdo = getDbConnection();
  $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $changes = [ 'columns_added'=>[], 'rows_updated'=>[], 'indices_created'=>[] ];

  // Helpers
  $colExists = function(string $col) use($pdo): bool {
    $stmt = $pdo->prepare("SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='risultati_esercizi' AND COLUMN_NAME = :c");
    $stmt->execute([':c'=>$col]);
    return (bool)$stmt->fetch(PDO::FETCH_NUM);
  };
  $idxExists = function(string $idx) use($pdo): bool {
    $stmt = $pdo->prepare("SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='risultati_esercizi' AND INDEX_NAME=:i");
    $stmt->execute([':i'=>$idx]);
    return (bool)$stmt->fetch(PDO::FETCH_NUM);
  };

  // 1) Add columns if missing
  if (!$colExists('started_at')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN started_at DATETIME NULL AFTER data_esecuzione");
    $changes['columns_added'][] = 'started_at';
  }
  if (!$colExists('clicked_at')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN clicked_at DATETIME NULL AFTER started_at");
    $changes['columns_added'][] = 'clicked_at';
  }
  if (!$colExists('created_at')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER clicked_at");
    $changes['columns_added'][] = 'created_at';
  }
  if (!$colExists('items_totali')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN items_totali INT NULL");
    $changes['columns_added'][] = 'items_totali';
  }

  // Nuovi campi: conteggi e nomi item corretti/errati, più dettaglio selezione
  if (!$colExists('items_corrette')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN items_corrette INT NULL AFTER items_totali");
    $changes['columns_added'][] = 'items_corrette';
  }
  if (!$colExists('items_errate')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN items_errate INT NULL AFTER items_corrette");
    $changes['columns_added'][] = 'items_errate';
  }
  if (!$colExists('nomi_items_corrette')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN nomi_items_corrette TEXT NULL AFTER items_errate");
    $changes['columns_added'][] = 'nomi_items_corrette';
  }
  if (!$colExists('nomi_items_errate')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN nomi_items_errate TEXT NULL AFTER nomi_items_corrette");
    $changes['columns_added'][] = 'nomi_items_errate';
  }
  if (!$colExists('item_nome')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN item_nome VARCHAR(150) NULL AFTER nomi_items_errate");
    $changes['columns_added'][] = 'item_nome';
  }
  if (!$colExists('item_corretto')) {
    $pdo->exec("ALTER TABLE risultati_esercizi ADD COLUMN item_corretto TINYINT(1) NULL AFTER item_nome");
    $changes['columns_added'][] = 'item_corretto';
  }

  // 2) Populate started_at from data_esecuzione (dd/mm/YYYY HH:MM:SS)
  $count = $pdo->exec("UPDATE risultati_esercizi
    SET started_at = STR_TO_DATE(data_esecuzione, '%d/%m/%Y %H:%i:%s')
    WHERE started_at IS NULL AND data_esecuzione REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}'");
  $changes['rows_updated'][] = ['started_at_from_data_esecuzione' => $count];

  // 3) From data_esercizio (timestamp native)
  $count = $pdo->exec("UPDATE risultati_esercizi SET started_at = data_esercizio WHERE started_at IS NULL AND data_esercizio IS NOT NULL");
  $changes['rows_updated'][] = ['started_at_from_data_esercizio' => $count];

  // 4) From timestamp_inizio (epoch ms)
  $count = $pdo->exec("UPDATE risultati_esercizi SET started_at = FROM_UNIXTIME(timestamp_inizio/1000)
    WHERE started_at IS NULL AND timestamp_inizio IS NOT NULL AND timestamp_inizio > 2000000000");
  $changes['rows_updated'][] = ['started_at_from_epoch_ms' => $count];

  // 5) From timestamp_inizio (epoch s)
  $count = $pdo->exec("UPDATE risultati_esercizi SET started_at = FROM_UNIXTIME(timestamp_inizio)
    WHERE started_at IS NULL AND timestamp_inizio IS NOT NULL AND timestamp_inizio BETWEEN 100000000 AND 2000000000");
  $changes['rows_updated'][] = ['started_at_from_epoch_s' => $count];

  // 6) clicked_at from timestamp_click
  $count = $pdo->exec("UPDATE risultati_esercizi SET clicked_at = FROM_UNIXTIME(timestamp_click/1000)
    WHERE clicked_at IS NULL AND timestamp_click IS NOT NULL AND timestamp_click > 2000000000");
  $changes['rows_updated'][] = ['clicked_at_from_epoch_ms' => $count];

  $count = $pdo->exec("UPDATE risultati_esercizi SET clicked_at = FROM_UNIXTIME(timestamp_click)
    WHERE clicked_at IS NULL AND timestamp_click IS NOT NULL AND timestamp_click BETWEEN 100000000 AND 2000000000");
  $changes['rows_updated'][] = ['clicked_at_from_epoch_s' => $count];

  // 7) If only date present in data_esecuzione (dd/mm/YYYY)
  $count = $pdo->exec("UPDATE risultati_esercizi
    SET started_at = STR_TO_DATE(data_esecuzione, '%d/%m/%Y')
    WHERE started_at IS NULL AND data_esecuzione REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'");
  $changes['rows_updated'][] = ['started_at_from_date_only' => $count];

  // 8) created_at fallback
  $count = $pdo->exec("UPDATE risultati_esercizi SET created_at = IFNULL(created_at, IFNULL(started_at, NOW())) WHERE created_at IS NULL");
  $changes['rows_updated'][] = ['created_at_populated' => $count];

  // 9) Recompute latency if missing and both timestamps available
  $count = $pdo->exec("UPDATE risultati_esercizi
    SET tempo_latenza = ROUND(TIMESTAMPDIFF(MICROSECOND, started_at, clicked_at)/1000000, 3)
    WHERE (tempo_latenza IS NULL OR tempo_latenza = 0)
      AND started_at IS NOT NULL AND clicked_at IS NOT NULL");
  $changes['rows_updated'][] = ['tempo_latenza_recomputed' => $count];

  // 10) Indices
  if (!$idxExists('idx_ris_cat_ex_started')) {
    $pdo->exec("CREATE INDEX idx_ris_cat_ex_started ON risultati_esercizi (categoria_esercizio, nome_esercizio, started_at)");
    $changes['indices_created'][] = 'idx_ris_cat_ex_started';
  }
  if (!$idxExists('idx_ris_educ_started')) {
    $pdo->exec("CREATE INDEX idx_ris_educ_started ON risultati_esercizi (nome_educatore, started_at)");
    $changes['indices_created'][] = 'idx_ris_educ_started';
  }
  if (!$idxExists('idx_ris_paz_started')) {
    $pdo->exec("CREATE INDEX idx_ris_paz_started ON risultati_esercizi (nome_paziente, started_at)");
    $changes['indices_created'][] = 'idx_ris_paz_started';
  }

  respond(true, 'Migrazione completata', $changes);
} catch (Throwable $e) {
  respond(false, 'Errore migrazione: '.$e->getMessage());
}
?>


