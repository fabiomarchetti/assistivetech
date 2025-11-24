-- ================================================
-- VERIFICA BASE DATABASE ASSISTIVETECH.IT
-- Script minimale per controllo database
-- ================================================

-- Info database
SELECT DATABASE() as nome_database, NOW() as timestamp_verifica;

-- Lista tabelle
SHOW TABLES;

-- Contenuto registrazioni (sicuramente esiste)
SELECT 'REGISTRAZIONI - TUTTI I RECORD:' as info;
SELECT * FROM registrazioni;

-- Conteggio per ruolo
SELECT 'CONTEGGIO PER RUOLO:' as info;
SELECT ruolo_registrazione, COUNT(*) as numero 
FROM registrazioni 
GROUP BY ruolo_registrazione;

-- Verifica account sviluppatore
SELECT 'VERIFICA ACCOUNT SVILUPPATORE:' as info;
SELECT * FROM registrazioni 
WHERE username_registrazione = 'marchettisoft@gmail.com';

-- Fine verifica
SELECT 'VERIFICA COMPLETATA' as risultato;