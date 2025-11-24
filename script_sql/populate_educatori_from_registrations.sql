-- Script per popolare i dati educatori dalla tabella registrazioni
-- Eseguire DOPO aver aggiunto i campi mancanti

-- Popola i dati degli educatori esistenti con le informazioni dalla tabella registrazioni
UPDATE educatori e
INNER JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
SET
    e.nome = r.nome_registrazione,
    e.cognome = r.cognome_registrazione,
    e.data_creazione = CONCAT(r.data_registrazione, ' 12:00:00'),
    e.stato_educatore = 'attivo'
WHERE r.ruolo_registrazione = 'educatore';

-- Verifica risultato
SELECT
    e.id_educatore,
    e.nome,
    e.cognome,
    e.id_sede,
    e.stato_educatore,
    r.username_registrazione
FROM educatori e
INNER JOIN registrazioni r ON e.id_registrazione = r.id_registrazione;