<?php
// SEZIONE CORRETTA PER auth_registrazioni.php
// CORREZIONE LINEE 184-202: INSERT educatori con struttura corretta

// Sostituire questa sezione nell'auth_registrazioni.php originale:

if ($ruolo === 'educatore') {
    // CORREZIONE: Usare id_settore e id_classe invece di settore e classe
    // Per ora impostiamo valori di default o NULL se non forniti

    // Converti settore/classe stringa in ID (se forniti)
    $id_settore = null;
    $id_classe = null;

    // Se hai una tabella settori/classi, cerca l'ID corrispondente
    // Altrimenti lascia NULL per ora

    $stmt_educatore = $pdo->prepare("
        INSERT INTO educatori (id_registrazione, nome, cognome, id_settore, id_classe, id_sede, data_creazione)
        VALUES (:id_registrazione, :nome, :cognome, :id_settore, :id_classe, :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
    ");

    $result_educatore = $stmt_educatore->execute([
        ':id_registrazione' => $id_registrazione,
        ':nome' => $nome,
        ':cognome' => $cognome,
        ':id_settore' => $id_settore,    // NULL per ora
        ':id_classe' => $id_classe,      // NULL per ora
        ':id_sede' => $id_sede
    ]);

    if (!$result_educatore) {
        throw new Exception('Errore creazione profilo educatore: ' . implode(', ', $stmt_educatore->errorInfo()));
    }
}

// ALTERNATIVA SEMPLIFICATA (se non vuoi gestire settori/classi per ora):
/*
if ($ruolo === 'educatore') {
    $stmt_educatore = $pdo->prepare("
        INSERT INTO educatori (id_registrazione, nome, cognome, id_sede, data_creazione)
        VALUES (:id_registrazione, :nome, :cognome, :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'))
    ");

    $result_educatore = $stmt_educatore->execute([
        ':id_registrazione' => $id_registrazione,
        ':nome' => $nome,
        ':cognome' => $cognome,
        ':id_sede' => $id_sede
    ]);

    if (!$result_educatore) {
        throw new Exception('Errore creazione profilo educatore: ' . implode(', ', $stmt_educatore->errorInfo()));
    }
}
*/

echo "Applicare questa correzione al file auth_registrazioni.php originale\n";
?>