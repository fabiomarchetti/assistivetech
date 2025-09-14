-- Script per inserire gli educatori esistenti nella tabella educatori
-- Da eseguire DOPO aver creato la tabella educatori
-- Inserisce automaticamente tutti gli utenti con ruolo 'educatore' dalla tabella registrazioni

INSERT INTO educatori (id_registrazione, data_abilitazione, data_creazione)
SELECT
    id_registrazione,
    DATE_FORMAT(NOW(), '%d/%m/%Y') as data_abilitazione,
    DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s') as data_creazione
FROM registrazioni
WHERE ruolo_registrazione = 'educatore'
AND id_registrazione NOT IN (SELECT id_registrazione FROM educatori);

-- Verifica inserimenti
SELECT 'Educatori inseriti:' as info;
SELECT
    e.id_educatore,
    r.nome_registrazione,
    r.cognome_registrazione,
    r.username_registrazione,
    e.data_abilitazione,
    e.stato_educatore
FROM educatori e
JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
ORDER BY e.id_educatore;