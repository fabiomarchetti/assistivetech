<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

// Usa la configurazione auto-ambiente
require_once __DIR__ . '/config.php';

function respond($ok, $msg, $data = null) {
  echo json_encode(['success' => $ok, 'message' => $msg, 'data' => $data], JSON_UNESCAPED_UNICODE);
  exit();
}

try {
  $pdo = getDbConnection();

  // 1) Trova la categoria 'categorizzazione'
  $stmt = $pdo->prepare("SELECT id_categoria, nome_categoria FROM categorie_esercizi WHERE LOWER(nome_categoria) = 'categorizzazione' LIMIT 1");
  $stmt->execute();
  $cat = $stmt->fetch(PDO::FETCH_ASSOC);
  if (!$cat) {
    respond(false, "Categoria 'categorizzazione' non trovata");
  }
  $id_categoria = (int) $cat['id_categoria'];

  // 2) Dati esercizio
  $nome = 'cerca veicoli di terra';
  $descrizione = "Seleziona solo i veicoli di terra in una griglia di immagini ARASAAC. TTS opzionale, logging tempi di reazione ed errori.";
  $stato = 'attivo';
  $link = '/training_cognitivo/categorizzazione/cerca_veicoli_di_terra/';

  // 3) Esiste già?
  $stmt = $pdo->prepare("SELECT id_esercizio, link FROM esercizi WHERE nome_esercizio = :n AND id_categoria = :c LIMIT 1");
  $stmt->execute([':n' => $nome, ':c' => $id_categoria]);
  $found = $stmt->fetch(PDO::FETCH_ASSOC);
  if ($found) {
    respond(true, 'Esercizio già presente', ['id_esercizio' => (int)$found['id_esercizio'], 'link' => $found['link']]);
  }

  // 4) Inserisci
  $stmt = $pdo->prepare("INSERT INTO esercizi (nome_esercizio, descrizione_esercizio, id_categoria, stato_esercizio, data_creazione, link) VALUES (:n, :d, :c, :s, :dt, :l)");
  $ok = $stmt->execute([
    ':n' => $nome,
    ':d' => $descrizione,
    ':c' => $id_categoria,
    ':s' => $stato,
    ':dt' => date('d/m/Y H:i:s'),
    ':l' => $link,
  ]);

  if (!$ok) {
    respond(false, 'Inserimento fallito');
  }

  $newId = (int) $pdo->lastInsertId();

  // 5) Risposta
  respond(true, 'Esercizio creato', [
    'id_esercizio' => $newId,
    'id_categoria' => $id_categoria,
    'link' => $link,
  ]);

} catch (Throwable $e) {
  respond(false, 'Errore: ' . $e->getMessage());
}
?>




