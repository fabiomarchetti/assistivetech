-- =====================================================================
-- SCRIPT: CHECK_TABLES_EXISTS.sql
-- SCOPO: Verificare quali tabelle esistono realmente nel database
-- =====================================================================

-- 1. LISTA TUTTE LE TABELLE DEL DATABASE
SHOW TABLES;

-- 2. INFORMAZIONI DETTAGLIATE TABELLE
SELECT TABLE_NAME,
       TABLE_TYPE,
       ENGINE,
       TABLE_ROWS,
       CREATE_TIME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME;

-- 3. VERIFICA ESISTENZA TABELLE SPECIFICHE
SELECT
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'registrazioni')
        THEN 'ESISTE: registrazioni'
        ELSE 'NON ESISTE: registrazioni'
    END as CHECK_REGISTRAZIONI,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sedi')
        THEN 'ESISTE: sedi'
        ELSE 'NON ESISTE: sedi'
    END as CHECK_SEDI,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori')
        THEN 'ESISTE: educatori'
        ELSE 'NON ESISTE: educatori'
    END as CHECK_EDUCATORI,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pazienti')
        THEN 'ESISTE: pazienti'
        ELSE 'NON ESISTE: pazienti'
    END as CHECK_PAZIENTI;

-- 4. SE ESISTONO TABELLE, MOSTRA STRUTTURA registrazioni
SELECT 'ESTRUTURA registrazioni' as INFO;
SHOW COLUMNS FROM registrazioni;

-- 5. PRIMI 5 RECORDS TABELLA registrazioni (se esiste)
SELECT * FROM registrazioni LIMIT 5;