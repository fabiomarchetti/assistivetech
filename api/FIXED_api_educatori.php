<?php
// CORREZIONE per api_educatori.php
// PROBLEMA: JOIN con tabelle settori/classi che potrebbero non esistere

// Sostituire la query alle righe 56-80 con questa versione corretta:

if ($action === 'get_all') {
    // Query corretta SENZA JOIN problematici su settori e classi
    $stmt = $pdo->prepare("
        SELECT
            e.id_educatore,
            e.id_registrazione,
            e.nome,
            e.cognome,
            e.id_settore,
            e.id_classe,
            e.telefono,
            e.email_contatto,
            e.note_professionali,
            e.stato_educatore,
            e.data_creazione,
            s.nome_sede,
            r.username_registrazione,
            -- Mostra gli ID invece dei nomi per ora
            CONCAT('Settore ID: ', IFNULL(e.id_settore, 'Non assegnato')) as nome_settore,
            CONCAT('Classe ID: ', IFNULL(e.id_classe, 'Non assegnata')) as nome_classe
        FROM educatori e
        LEFT JOIN sedi s ON e.id_sede = s.id_sede
        LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
        WHERE e.stato_educatore != 'eliminato'
        ORDER BY e.data_creazione DESC
    ");
    $stmt->execute();
    $educatori = $stmt->fetchAll(PDO::FETCH_ASSOC);

    jsonResponse(true, 'Educatori recuperati con successo', $educatori);
}

// ALTERNATIVA: Se vuoi mantenere i JOIN ma gestire tabelle mancanti:
/*
if ($action === 'get_all') {
    // Verifica se le tabelle esistono prima del JOIN
    $tables_check = $pdo->query("SHOW TABLES LIKE 'settori'")->rowCount();
    $settori_exists = $tables_check > 0;

    $tables_check = $pdo->query("SHOW TABLES LIKE 'classi'")->rowCount();
    $classi_exists = $tables_check > 0;

    $settori_join = $settori_exists ? "LEFT JOIN settori st ON e.id_settore = st.id_settore" : "";
    $classi_join = $classi_exists ? "LEFT JOIN classi cl ON e.id_classe = cl.id_classe" : "";

    $settori_select = $settori_exists ? "st.nome_settore" : "CONCAT('Settore ID: ', IFNULL(e.id_settore, 'Non assegnato')) as nome_settore";
    $classi_select = $classi_exists ? "cl.nome_classe" : "CONCAT('Classe ID: ', IFNULL(e.id_classe, 'Non assegnata')) as nome_classe";

    $query = "
        SELECT
            e.id_educatore,
            e.id_registrazione,
            e.nome,
            e.cognome,
            e.id_settore,
            e.id_classe,
            e.telefono,
            e.email_contatto,
            e.note_professionali,
            e.stato_educatore,
            e.data_creazione,
            s.nome_sede,
            $settori_select,
            $classi_select,
            r.username_registrazione
        FROM educatori e
        LEFT JOIN sedi s ON e.id_sede = s.id_sede
        $settori_join
        $classi_join
        LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
        WHERE e.stato_educatore != 'eliminato'
        ORDER BY e.data_creazione DESC
    ";

    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $educatori = $stmt->fetchAll(PDO::FETCH_ASSOC);

    jsonResponse(true, 'Educatori recuperati con successo', $educatori);
}
*/

echo "Applicare questa correzione al file api_educatori.php\n";
?>