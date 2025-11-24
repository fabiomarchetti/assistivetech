-- =====================================================================
-- SCRIPT: DEBUG_INSERIMENTO_EDUCATORI.sql
-- SCOPO: Debug e risoluzione problema inserimento educatori
-- PROBLEMA: L'API tenta di inserire id_sede in registrazioni ma la colonna potrebbe non esistere
-- DATA: Settembre 2024
-- =====================================================================

-- 1. VERIFICA STRUTTURA TABELLA REGISTRAZIONI
SELECT 'REGISTRAZIONI TABLE STRUCTURE' as DEBUG_SECTION,
       COLUMN_NAME,
       COLUMN_TYPE,
       IS_NULLABLE,
       COLUMN_DEFAULT,
       COLUMN_KEY,
       EXTRA
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sql1073852_1'
  AND TABLE_NAME = 'registrazioni'
ORDER BY ORDINAL_POSITION;

-- 2. VERIFICA SE ESISTE COLONNA id_sede IN REGISTRAZIONI
SELECT 'ID_SEDE COLUMN CHECK' as DEBUG_SECTION,
       CASE
           WHEN EXISTS (
               SELECT 1
               FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_SCHEMA = 'Sql1073852_1'
                 AND TABLE_NAME = 'registrazioni'
                 AND COLUMN_NAME = 'id_sede'
           )
           THEN 'COLONNA id_sede ESISTE in registrazioni'
           ELSE 'COLONNA id_sede NON ESISTE in registrazioni - QUESTO È IL PROBLEMA!'
       END as RESULT;

-- 3. VERIFICA TABELLA EDUCATORI
SELECT 'EDUCATORI TABLE STRUCTURE' as DEBUG_SECTION,
       COLUMN_NAME,
       COLUMN_TYPE,
       IS_NULLABLE,
       COLUMN_DEFAULT,
       COLUMN_KEY,
       EXTRA
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sql1073852_1'
  AND TABLE_NAME = 'educatori'
ORDER BY ORDINAL_POSITION;

-- 4. TEST INSERIMENTO EDUCATORE (SIMULAZIONE)
-- Questo test fallirà se la colonna id_sede non esiste in registrazioni

-- Prima proviamo senza id_sede in registrazioni
SELECT 'INSERIMENTO TEST' as DEBUG_SECTION,
       'TENTATIVO INSERT SENZA id_sede' as TEST_TYPE;

-- SOLUZIONE 1: Query corretta senza id_sede in registrazioni
-- INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione,
--                          password_registrazione, ruolo_registrazione, data_registrazione)
-- VALUES ('Test', 'Educatore', 'test.educatore@test.com', 'password123', 'educatore', DATE_FORMAT(NOW(), '%d/%m/%Y'));

-- 5. VERIFICARE FOREIGN KEY CONSTRAINTS
SELECT 'FOREIGN KEY CONSTRAINTS' as DEBUG_SECTION,
       CONSTRAINT_NAME,
       TABLE_NAME,
       COLUMN_NAME,
       REFERENCED_TABLE_NAME,
       REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'Sql1073852_1'
  AND TABLE_NAME IN ('registrazioni', 'educatori', 'pazienti')
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 6. CONTEGGIO RECORDS ESISTENTI
SELECT 'RECORD COUNTS' as DEBUG_SECTION,
       'registrazioni' as TABLE_NAME,
       COUNT(*) as TOTAL_COUNT,
       COUNT(CASE WHEN ruolo_registrazione = 'educatore' THEN 1 END) as EDUCATORI_COUNT
FROM registrazioni;

SELECT 'RECORD COUNTS' as DEBUG_SECTION,
       'educatori' as TABLE_NAME,
       COUNT(*) as TOTAL_COUNT
FROM educatori;

-- 7. VERIFICA INCONSISTENZE
SELECT 'DATA INTEGRITY CHECK' as DEBUG_SECTION,
       'EDUCATORI SENZA REGISTRAZIONE' as CHECK_TYPE,
       COUNT(*) as COUNT
FROM educatori e
LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
WHERE r.id_registrazione IS NULL;

SELECT 'DATA INTEGRITY CHECK' as DEBUG_SECTION,
       'REGISTRAZIONI EDUCATORI SENZA PROFILO' as CHECK_TYPE,
       COUNT(*) as COUNT
FROM registrazioni r
LEFT JOIN educatori e ON r.id_registrazione = e.id_registrazione
WHERE r.ruolo_registrazione = 'educatore' AND e.id_educatore IS NULL;

-- 8. MOSTRA ULTIMI TENTATIVI DI INSERIMENTO
SELECT 'LAST REGISTRATIONS' as DEBUG_SECTION,
       id_registrazione,
       nome_registrazione,
       cognome_registrazione,
       username_registrazione,
       ruolo_registrazione,
       data_registrazione
FROM registrazioni
ORDER BY id_registrazione DESC
LIMIT 5;

-- 9. SCRIPT DI CORREZIONE (DA ESEGUIRE SOLO SE NECESSARIO)
SELECT 'CORRECTION SCRIPT' as DEBUG_SECTION,
       'EXECUTE_IF_NEEDED' as ACTION,
       'ALTER TABLE registrazioni ADD COLUMN id_sede INT DEFAULT 1' as SQL_COMMAND;

-- 10. TEST QUERY CORRETTE PER API
SELECT 'CORRECT API QUERIES' as DEBUG_SECTION,
       'REGISTRAZIONI_INSERT' as QUERY_TYPE,
       'INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione, password_registrazione, ruolo_registrazione, data_registrazione) VALUES (?, ?, ?, ?, ?, DATE_FORMAT(NOW(), "%d/%m/%Y"))' as CORRECT_QUERY;

SELECT 'CORRECT API QUERIES' as DEBUG_SECTION,
       'EDUCATORI_INSERT' as QUERY_TYPE,
       'INSERT INTO educatori (id_registrazione, nome, cognome, settore, classe, id_sede, data_creazione) VALUES (?, ?, ?, ?, ?, ?, DATE_FORMAT(NOW(), "%d/%m/%Y %H:%i:%s"))' as CORRECT_QUERY;