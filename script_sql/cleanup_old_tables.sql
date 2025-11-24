-- Script per eliminare tabelle obsolete prima della ricostruzione
-- Da eseguire PRIMA di tutti gli altri script
-- ATTENZIONE: Questo script elimina definitivamente i dati esistenti!

-- Disabilita temporaneamente i controlli delle foreign key per evitare errori
SET FOREIGN_KEY_CHECKS = 0;

-- Elimina tabelle nell'ordine corretto (figlie prima, poi genitori)
DROP TABLE IF EXISTS educatori_pazienti;
DROP TABLE IF EXISTS sessioni_utente;
DROP TABLE IF EXISTS log_accessi;
DROP TABLE IF EXISTS pazienti;
DROP TABLE IF EXISTS educatori;
DROP TABLE IF EXISTS classi;
DROP TABLE IF EXISTS settori;
DROP TABLE IF EXISTS sedi;

-- MANTIENI SOLO la tabella registrazioni (autenticazione principale)
-- DROP TABLE IF EXISTS registrazioni;  -- COMMENTATO per sicurezza

-- Riabilita i controlli delle foreign key
SET FOREIGN_KEY_CHECKS = 1;

-- Verifica che le tabelle siano state eliminate
SELECT 'Tabelle rimanenti nel database:' as info;
SHOW TABLES;

-- Mostra struttura tabella registrazioni (che deve rimanere)
SELECT 'Struttura tabella registrazioni (mantenuta):' as info;
DESCRIBE registrazioni;