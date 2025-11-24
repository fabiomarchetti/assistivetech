<?php
// CORREZIONE TEMPORANEA PER auth_registrazioni.php
// PROBLEMA: Query INSERT errata per tabella registrazioni - include id_sede che potrebbe non esistere

// Sostituire la sezione CREATE (righe 162-175) in auth_registrazioni.php con questo codice:

/*
// VERSIONE CORRETTA - Inserisci registrazione SENZA id_sede
$stmt = $pdo->prepare("
    INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione,
                             password_registrazione, ruolo_registrazione, data_registrazione)
    VALUES (:nome, :cognome, :username, :password, :ruolo, DATE_FORMAT(NOW(), '%d/%m/%Y'))
");

$result = $stmt->execute([
    ':nome' => $nome,
    ':cognome' => $cognome,
    ':username' => $user_username,
    ':password' => $hashedPassword,
    ':ruolo' => $ruolo
]);
*/

// ALTERNATIVA: Se la colonna id_sede esiste in registrazioni, controllare prima:
/*
// Verifica se la colonna id_sede esiste
$columns_check = $pdo->query("SHOW COLUMNS FROM registrazioni LIKE 'id_sede'");
$id_sede_exists = $columns_check->rowCount() > 0;

if ($id_sede_exists) {
    // Query con id_sede
    $stmt = $pdo->prepare("
        INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione,
                                 password_registrazione, ruolo_registrazione, id_sede, data_registrazione)
        VALUES (:nome, :cognome, :username, :password, :ruolo, :id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y'))
    ");

    $result = $stmt->execute([
        ':nome' => $nome,
        ':cognome' => $cognome,
        ':username' => $user_username,
        ':password' => $hashedPassword,
        ':ruolo' => $ruolo,
        ':id_sede' => $id_sede
    ]);
} else {
    // Query senza id_sede
    $stmt = $pdo->prepare("
        INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione,
                                 password_registrazione, ruolo_registrazione, data_registrazione)
        VALUES (:nome, :cognome, :username, :password, :ruolo, DATE_FORMAT(NOW(), '%d/%m/%Y'))
    ");

    $result = $stmt->execute([
        ':nome' => $nome,
        ':cognome' => $cognome,
        ':username' => $user_username,
        ':password' => $hashedPassword,
        ':ruolo' => $ruolo
    ]);
}
*/

echo "Questo file contiene le correzioni per auth_registrazioni.php\n";
echo "Vedere i commenti per le modifiche da applicare.\n";
?>