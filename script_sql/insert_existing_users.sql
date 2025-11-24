-- Script per inserire utenti esistenti nelle nuove tabelle educatori e pazienti
-- Da eseguire DOPO aver creato/aggiornato le tabelle educatori e pazienti

-- Inserisce educatori esistenti (prende nome e cognome dalla tabella registrazioni)
INSERT INTO educatori (id_registrazione, nome, cognome, id_sede, data_creazione)
SELECT
    id_registrazione,
    nome_registrazione,
    cognome_registrazione,
    1 as id_sede, -- Assegna alla sede principale
    DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s') as data_creazione
FROM registrazioni
WHERE ruolo_registrazione = 'educatore'
AND id_registrazione NOT IN (SELECT id_registrazione FROM educatori WHERE id_registrazione IS NOT NULL);

-- Inserisce pazienti esistenti (prende nome e cognome dalla tabella registrazioni)
INSERT INTO pazienti (id_registrazione, nome, cognome, id_sede, data_creazione)
SELECT
    id_registrazione,
    nome_registrazione,
    cognome_registrazione,
    1 as id_sede, -- Assegna alla sede principale
    DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s') as data_creazione
FROM registrazioni
WHERE ruolo_registrazione = 'paziente'
AND id_registrazione NOT IN (SELECT id_registrazione FROM pazienti WHERE id_registrazione IS NOT NULL);

-- Verifica inserimenti
SELECT 'Educatori inseriti:' as info;
SELECT
    e.id_educatore,
    e.nome,
    e.cognome,
    e.settore,
    e.classe,
    e.stato_educatore,
    r.username_registrazione
FROM educatori e
JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
ORDER BY e.id_educatore;

SELECT 'Pazienti inseriti:' as info;
SELECT
    p.id_paziente,
    p.nome,
    p.cognome,
    p.settore,
    p.classe,
    r.username_registrazione
FROM pazienti p
JOIN registrazioni r ON p.id_registrazione = r.id_registrazione
ORDER BY p.id_paziente;