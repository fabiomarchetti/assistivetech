-- Script per aggiungere il ruolo 'sviluppatore' al sistema esistente
-- Da eseguire nel database MySQL Aruba (Sql1073852_1)
-- Questo script aggiunge il nuovo ruolo e converte l'account esistente

-- Step 1: Modificare l'ENUM della tabella registrazioni per includere 'sviluppatore'
ALTER TABLE registrazioni 
MODIFY COLUMN ruolo_registrazione ENUM('amministratore', 'educatore', 'paziente', 'sviluppatore') NOT NULL;

-- Step 2: Aggiornare l'account esistente di Fabio Marchetti da 'amministratore' a 'sviluppatore'
UPDATE registrazioni 
SET ruolo_registrazione = 'sviluppatore' 
WHERE username_registrazione = 'marchettisoft@gmail.com';

-- Step 3: Verifica che l'aggiornamento sia andato a buon fine
SELECT 
    id_registrazione,
    nome_registrazione,
    cognome_registrazione,
    username_registrazione,
    ruolo_registrazione,
    data_registrazione,
    stato_account
FROM registrazioni 
WHERE username_registrazione = 'marchettisoft@gmail.com';

-- Query di verifica per tutti gli utenti (per controllo)
-- SELECT 
--     id_registrazione,
--     nome_registrazione,
--     cognome_registrazione,
--     username_registrazione,
--     ruolo_registrazione,
--     data_registrazione
-- FROM registrazioni 
-- ORDER BY ruolo_registrazione, data_registrazione;