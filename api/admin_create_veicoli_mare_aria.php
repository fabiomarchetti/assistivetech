<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/config.php';

function out($ok,$msg,$data=null){ echo json_encode(['success'=>$ok,'message'=>$msg,'data'=>$data], JSON_UNESCAPED_UNICODE); exit; }

try{
  $pdo = getDbConnection();
  $stmt = $pdo->prepare("SELECT id_categoria FROM categorie_esercizi WHERE LOWER(nome_categoria)='categorizzazione' LIMIT 1");
  $stmt->execute();
  $cat = $stmt->fetch(PDO::FETCH_ASSOC);
  if(!$cat){ out(false, "Categoria 'categorizzazione' non trovata"); }
  $idc = (int)$cat['id_categoria'];

  $items = [
    ['nome'=>'cerca veicoli di mare','descr'=>'Seleziona solo i veicoli di mare (ARASAAC). TTS opzionale, logging tempi/errori.','link'=>'/training_cognitivo/categorizzazione/veicoli_mare/'],
    ['nome'=>'cerca veicoli di aria','descr'=>'Seleziona solo i veicoli di aria (ARASAAC). TTS opzionale, logging tempi/errori.','link'=>'/training_cognitivo/categorizzazione/veicoli_aria/'],
  ];

  $created = [];
  foreach($items as $it){
    $q = $pdo->prepare("SELECT id_esercizio FROM esercizi WHERE nome_esercizio=:n AND id_categoria=:c LIMIT 1");
    $q->execute([':n'=>$it['nome'], ':c'=>$idc]);
    $row = $q->fetch(PDO::FETCH_ASSOC);
    if($row){ $created[] = ['nome'=>$it['nome'], 'id_esercizio'=>(int)$row['id_esercizio'], 'status'=>'exists']; continue; }
    $ins = $pdo->prepare("INSERT INTO esercizi (nome_esercizio, descrizione_esercizio, id_categoria, stato_esercizio, data_creazione, link) VALUES (:n,:d,:c,'attivo',:dt,:l)");
    $ok = $ins->execute([':n'=>$it['nome'], ':d'=>$it['descr'], ':c'=>$idc, ':dt'=>date('d/m/Y H:i:s'), ':l'=>$it['link']]);
    if($ok){ $created[] = ['nome'=>$it['nome'], 'id_esercizio'=>(int)$pdo->lastInsertId(), 'status'=>'created']; }
  }

  out(true,'Operazione completata',$created);
}catch(Throwable $e){ out(false,'Errore: '.$e->getMessage()); }
?>




