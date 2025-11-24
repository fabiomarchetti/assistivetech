-- Script per aggiungere campo sede alla tabella registrazioni
-- Data: 17/09/2024
-- Descrizione: Aggiunge id_sede come foreign key per associare amministratori a sedi specifiche

-- 1. Aggiungi colonna id_sede alla tabella registrazioni
ALTER TABLE registrazioni
ADD COLUMN id_sede INT DEFAULT 1 AFTER ruolo_registrazione;

-- 2. Aggiungi foreign key constraint verso tabella sedi
ALTER TABLE registrazioni
ADD CONSTRAINT fk_registrazioni_sede
FOREIGN KEY (id_sede) REFERENCES sedi(id_sede)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- 3. Aggiorna commento tabella
ALTER TABLE registrazioni COMMENT = 'Tabella utenti sistema con associazione sede - aggiornata 17/09/2024';

-- 4. Verifica risultato
DESCRIBE registrazioni;

-- 5. Mostra foreign keys
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'Sql1073852_1'
AND TABLE_NAME = 'registrazioni'
AND REFERENCED_TABLE_NAME IS NOT NULL;