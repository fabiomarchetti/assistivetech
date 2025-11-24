<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/config.php';

function respond($ok, $msg, $data = null) {
  echo json_encode(['success' => $ok, 'message' => $msg, 'data' => $data], JSON_UNESCAPED_UNICODE);
  exit;
}

try {
  $pdo = getDbConnection();

  // Categoria 'categorizzazione'
  $stmt = $pdo->prepare("SELECT id_categoria FROM categorie_esercizi WHERE LOWER(nome_categoria)='categorizzazione' LIMIT 1");
  $stmt->execute();
  $cat = $stmt->fetch(PDO::FETCH_ASSOC);
  if (!$cat) {
    respond(false, "Categoria 'categorizzazione' non trovata");
  }
  $idc = (int)$cat['id_categoria'];

  $now = date('d/m/Y H:i:s');
  $items = [
    [
      'nome' => 'cerca animali',
      'descr' => 'Seleziona solo gli animali in una griglia di immagini ARASAAC. TTS opzionale, logging tempi/errori.',
      'link' => '/training_cognitivo/categorizzazione/animali/'
    ],
    [
      'nome' => 'cerca frutti',
      'descr' => 'Seleziona solo i frutti in una griglia di immagini ARASAAC. TTS opzionale, logging tempi/errori.',
      'link' => '/training_cognitivo/categorizzazione/frutti/'
    ]
  ];

  $result = [];
  foreach ($items as $it) {
    // Esiste già?
    $q = $pdo->prepare("SELECT id_esercizio FROM esercizi WHERE nome_esercizio = :n AND id_categoria = :c LIMIT 1");
    $q->execute([':n' => $it['nome'], ':c' => $idc]);
    $row = $q->fetch(PDO::FETCH_ASSOC);
    if ($row) {
      $result[] = ['nome' => $it['nome'], 'id_esercizio' => (int)$row['id_esercizio'], 'status' => 'exists'];
      continue;
    }

    $ins = $pdo->prepare("INSERT INTO esercizi (nome_esercizio, descrizione_esercizio, id_categoria, stato_esercizio, data_creazione, link) VALUES (:n, :d, :c, 'attivo', :dt, :l)");
    $ok = $ins->execute([
      ':n' => $it['nome'],
      ':d' => $it['descr'],
      ':c' => $idc,
      ':dt' => $now,
      ':l' => $it['link']
    ]);
    if ($ok) {
      $result[] = ['nome' => $it['nome'], 'id_esercizio' => (int)$pdo->lastInsertId(), 'status' => 'created'];
    }
  }

  respond(true, 'Operazione completata', $result);
} catch (Throwable $e) {
  respond(false, 'Errore: ' . $e->getMessage());
}
?>




