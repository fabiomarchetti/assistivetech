-- =====================================================================
-- SCRIPT: EXTRACT_DATABASE_STRUCTURE_SAFE.sql
-- SCOPO: Estrazione sicura struttura database (gestisce tabelle inesistenti)
-- =====================================================================

-- 1. DATABASE E TABELLE ESISTENTI
SELECT 'DATABASE INFO' as SECTION_TYPE,
       DATABASE() as CURRENT_DATABASE,
       NOW() as TIMESTAMP;

SHOW TABLES;

-- 2. STRUTTURA TABELLA registrazioni (se esiste)
SELECT 'registrazioni' as TABLE_NAME, 'STRUCTURE' as INFO;
DESCRIBE registrazioni;

SELECT 'registrazioni' as TABLE_NAME, 'SAMPLE DATA' as INFO;
SELECT * FROM registrazioni ORDER BY id_registrazione DESC LIMIT 3;

-- 3. STRUTTURA TABELLA sedi (se esiste)
SELECT 'sedi' as TABLE_NAME, 'STRUCTURE' as INFO;
DESCRIBE sedi;

SELECT 'sedi' as TABLE_NAME, 'DATA' as INFO;
SELECT * FROM sedi ORDER BY id_sede;

-- 4. STRUTTURA TABELLA educatori (se esiste)
SELECT 'educatori' as TABLE_NAME, 'STRUCTURE' as INFO;
DESCRIBE educatori;

SELECT 'educatori' as TABLE_NAME, 'DATA' as INFO;
SELECT * FROM educatori ORDER BY id_educatore DESC LIMIT 5;

-- 5. STRUTTURA TABELLA pazienti (se esiste)
SELECT 'pazienti' as TABLE_NAME, 'STRUCTURE' as INFO;
DESCRIBE pazienti;

SELECT 'pazienti' as TABLE_NAME, 'DATA' as INFO;
SELECT * FROM pazienti ORDER BY id_paziente DESC LIMIT 5;

-- 6. FOREIGN KEYS E RELAZIONI
SELECT 'FOREIGN KEYS' as INFO;
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 7. CONTEGGI E STATISTICHE
SELECT 'COUNTS' as INFO;
SELECT
    'registrazioni' as TABELLA,
    COUNT(*) as TOTALE_RECORDS,
    COUNT(CASE WHEN ruolo_registrazione = 'amministratore' THEN 1 END) as ADMIN,
    COUNT(CASE WHEN ruolo_registrazione = 'educatore' THEN 1 END) as EDUCATORI,
    COUNT(CASE WHEN ruolo_registrazione = 'paziente' THEN 1 END) as PAZIENTI,
    COUNT(CASE WHEN ruolo_registrazione = 'sviluppatore' THEN 1 END) as SVILUPPATORI
FROM registrazioni;

-- 8. VERIFICA PROBLEMA COLONNA id_sede
SELECT 'VERIFICA id_sede IN registrazioni' as INFO;
SHOW COLUMNS FROM registrazioni LIKE '%sede%';

-- 9. TEST INSERIMENTO (SENZA ESEGUIRE)
SELECT 'TEST QUERY PER DEBUG' as INFO,
       'INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione, password_registrazione, ruolo_registrazione, data_registrazione) VALUES ("Test", "Nome", "test@test.com", "password", "educatore", DATE_FORMAT(NOW(), "%d/%m/%Y"))' as QUERY_CORRETTA_SENZA_ID_SEDE;

-- 10. ULTIMA REGISTRAZIONE INSERITA
SELECT 'ULTIMA REGISTRAZIONE' as INFO;
SELECT * FROM registrazioni ORDER BY id_registrazione DESC LIMIT 1;