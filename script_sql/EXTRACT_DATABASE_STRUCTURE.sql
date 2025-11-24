-- =====================================================================
-- SCRIPT: EXTRACT_DATABASE_STRUCTURE.sql
-- SCOPO: Estrazione completa struttura e dati database AssistiveTech.it
-- DATA: Settembre 2024
-- AUTORE: Claude Code per debugging inserimento educatori
-- =====================================================================

-- 1. INFORMAZIONI GENERALI DATABASE
SELECT 'DATABASE INFO' as SECTION_TYPE,
       'AssistiveTech Database Status' as INFO;

-- 2. LISTA TUTTE LE TABELLE ESISTENTI
SELECT 'TABLES LIST' as SECTION_TYPE,
       TABLE_NAME as TABLE_NAME,
       TABLE_TYPE as TYPE,
       ENGINE as ENGINE,
       VERSION as VERSION,
       ROW_FORMAT as ROW_FORMAT,
       TABLE_ROWS as ESTIMATED_ROWS,
       AVG_ROW_LENGTH as AVG_ROW_LENGTH,
       DATA_LENGTH as DATA_SIZE,
       CREATE_TIME as CREATED,
       UPDATE_TIME as LAST_UPDATED,
       TABLE_COMMENT as COMMENT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'Sql1073852_1'
ORDER BY TABLE_NAME;

-- 3. STRUTTURA COMPLETA TABELLA REGISTRAZIONI
SELECT 'REGISTRAZIONI STRUCTURE' as SECTION_TYPE,
       COLUMN_NAME,
       COLUMN_TYPE,
       IS_NULLABLE,
       COLUMN_DEFAULT,
       COLUMN_KEY,
       EXTRA,
       COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sql1073852_1'
  AND TABLE_NAME = 'registrazioni'
ORDER BY ORDINAL_POSITION;

-- 4. DATI TABELLA REGISTRAZIONI (PRIMI 10 RECORDS)
SELECT 'REGISTRAZIONI DATA' as SECTION_TYPE,
       r.*
FROM registrazioni r
ORDER BY id_registrazione DESC
LIMIT 10;

-- 5. STRUTTURA COMPLETA TABELLA SEDI
SELECT 'SEDI STRUCTURE' as SECTION_TYPE,
       COLUMN_NAME,
       COLUMN_TYPE,
       IS_NULLABLE,
       COLUMN_DEFAULT,
       COLUMN_KEY,
       EXTRA,
       COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sql1073852_1'
  AND TABLE_NAME = 'sedi'
ORDER BY ORDINAL_POSITION;

-- 6. DATI TABELLA SEDI (TUTTE LE SEDI)
SELECT 'SEDI DATA' as SECTION_TYPE,
       s.*
FROM sedi s
ORDER BY id_sede;

-- 7. STRUTTURA COMPLETA TABELLA EDUCATORI
SELECT 'EDUCATORI STRUCTURE' as SECTION_TYPE,
       COLUMN_NAME,
       COLUMN_TYPE,
       IS_NULLABLE,
       COLUMN_DEFAULT,
       COLUMN_KEY,
       EXTRA,
       COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sql1073852_1'
  AND TABLE_NAME = 'educatori'
ORDER BY ORDINAL_POSITION;

-- 8. DATI TABELLA EDUCATORI (TUTTI I RECORDS)
SELECT 'EDUCATORI DATA' as SECTION_TYPE,
       e.*
FROM educatori e
ORDER BY id_educatore DESC;

-- 9. STRUTTURA COMPLETA TABELLA PAZIENTI
SELECT 'PAZIENTI STRUCTURE' as SECTION_TYPE,
       COLUMN_NAME,
       COLUMN_TYPE,
       IS_NULLABLE,
       COLUMN_DEFAULT,
       COLUMN_KEY,
       EXTRA,
       COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sql1073852_1'
  AND TABLE_NAME = 'pazienti'
ORDER BY ORDINAL_POSITION;

-- 10. DATI TABELLA PAZIENTI (TUTTI I RECORDS)
SELECT 'PAZIENTI DATA' as SECTION_TYPE,
       p.*
FROM pazienti p
ORDER BY id_paziente DESC;

-- 11. STRUTTURA COMPLETA TABELLA EDUCATORI_PAZIENTI
SELECT 'EDUCATORI_PAZIENTI STRUCTURE' as SECTION_TYPE,
       COLUMN_NAME,
       COLUMN_TYPE,
       IS_NULLABLE,
       COLUMN_DEFAULT,
       COLUMN_KEY,
       EXTRA,
       COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sql1073852_1'
  AND TABLE_NAME = 'educatori_pazienti'
ORDER BY ORDINAL_POSITION;

-- 12. DATI TABELLA EDUCATORI_PAZIENTI (TUTTE LE ASSOCIAZIONI)
SELECT 'EDUCATORI_PAZIENTI DATA' as SECTION_TYPE,
       ep.*
FROM educatori_pazienti ep
ORDER BY id_associazione DESC;

-- 13. FOREIGN KEY CONSTRAINTS
SELECT 'FOREIGN KEYS' as SECTION_TYPE,
       CONSTRAINT_NAME,
       TABLE_NAME,
       COLUMN_NAME,
       REFERENCED_TABLE_NAME,
       REFERENCED_COLUMN_NAME,
       UPDATE_RULE,
       DELETE_RULE
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'Sql1073852_1'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- 14. INDICI E CHIAVI
SELECT 'INDEXES' as SECTION_TYPE,
       TABLE_NAME,
       NON_UNIQUE,
       INDEX_NAME,
       SEQ_IN_INDEX,
       COLUMN_NAME,
       COLLATION,
       CARDINALITY,
       SUB_PART,
       PACKED,
       NULLABLE,
       INDEX_TYPE,
       COMMENT
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'Sql1073852_1'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- 15. VERIFICA INTEGRITÀ RELAZIONI
SELECT 'INTEGRITY CHECK' as SECTION_TYPE,
       'EDUCATORI-REGISTRAZIONI' as RELATION_TYPE,
       COUNT(*) as TOTAL_EDUCATORI,
       COUNT(CASE WHEN r.id_registrazione IS NULL THEN 1 END) as ORPHANED_EDUCATORI
FROM educatori e
LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione;

SELECT 'INTEGRITY CHECK' as SECTION_TYPE,
       'EDUCATORI-SEDI' as RELATION_TYPE,
       COUNT(*) as TOTAL_EDUCATORI,
       COUNT(CASE WHEN s.id_sede IS NULL THEN 1 END) as EDUCATORI_WITHOUT_SEDE
FROM educatori e
LEFT JOIN sedi s ON e.id_sede = s.id_sede;

-- 16. CONTEGGI GENERALI
SELECT 'COUNTS' as SECTION_TYPE,
       'registrazioni' as TABLE_NAME,
       COUNT(*) as TOTAL_RECORDS,
       COUNT(CASE WHEN ruolo_registrazione = 'amministratore' THEN 1 END) as AMMINISTRATORI,
       COUNT(CASE WHEN ruolo_registrazione = 'educatore' THEN 1 END) as EDUCATORI,
       COUNT(CASE WHEN ruolo_registrazione = 'paziente' THEN 1 END) as PAZIENTI,
       COUNT(CASE WHEN ruolo_registrazione = 'sviluppatore' THEN 1 END) as SVILUPPATORI
FROM registrazioni;

SELECT 'COUNTS' as SECTION_TYPE,
       'sedi' as TABLE_NAME,
       COUNT(*) as TOTAL_RECORDS,
       COUNT(CASE WHEN stato_sede = 'attiva' THEN 1 END) as SEDI_ATTIVE,
       COUNT(CASE WHEN stato_sede = 'sospesa' THEN 1 END) as SEDI_SOSPESE,
       COUNT(CASE WHEN stato_sede = 'chiusa' THEN 1 END) as SEDI_CHIUSE
FROM sedi;

-- 17. ULTIMI INSERIMENTI (per debug)
SELECT 'LAST INSERTS' as SECTION_TYPE,
       'registrazioni' as TABLE_NAME,
       id_registrazione,
       nome_registrazione,
       cognome_registrazione,
       username_registrazione,
       ruolo_registrazione,
       data_registrazione,
       stato_account
FROM registrazioni
ORDER BY id_registrazione DESC
LIMIT 5;

-- 18. VERIFICA PROBLEMI COMUNI
SELECT 'COMMON ISSUES' as SECTION_TYPE,
       'DUPLICATE_USERNAMES' as ISSUE_TYPE,
       username_registrazione,
       COUNT(*) as OCCURRENCES
FROM registrazioni
GROUP BY username_registrazione
HAVING COUNT(*) > 1;

SELECT 'COMMON ISSUES' as SECTION_TYPE,
       'INVALID_ROLES' as ISSUE_TYPE,
       ruolo_registrazione,
       COUNT(*) as OCCURRENCES
FROM registrazioni
WHERE ruolo_registrazione NOT IN ('amministratore', 'educatore', 'paziente', 'sviluppatore')
GROUP BY ruolo_registrazione;

-- 19. SCRIPT COMPLETATO
SELECT 'EXTRACTION COMPLETED' as SECTION_TYPE,
       NOW() as TIMESTAMP,
       'Database structure and data extracted successfully' as MESSAGE;