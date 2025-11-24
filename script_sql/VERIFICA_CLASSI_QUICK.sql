-- Verifica veloce struttura classi
SHOW COLUMNS FROM classi;

-- Test rapido con nomi colonne corretti
SELECT
    e.id_educatore,
    e.nome,
    e.cognome,
    e.id_settore,
    e.id_classe,
    s.nome_settore,
    c.nome_classe
FROM educatori e
LEFT JOIN settori s ON e.id_settore = s.id_settore
LEFT JOIN classi c ON e.id_classe = c.id_classe
ORDER BY e.id_educatore;