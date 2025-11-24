-- =====================================================================
-- SCRIPT: TEST_INSERT_EDUCATORE.sql
-- SCOPO: Testare esattamente la query dell'API che fallisce
-- STRUTTURA CONFERMATA: registrazioni.id_sede ESISTE (INT, default 1)
-- =====================================================================

-- 1. VERIFICA STRUTTURA REGISTRAZIONI (colonna id_sede presente)
SELECT 'VERIFICA id_sede' as INFO;
SHOW COLUMNS FROM registrazioni WHERE Field = 'id_sede';

-- 2. VERIFICA STRUTTURA EDUCATORI
SELECT 'VERIFICA EDUCATORI' as INFO;
SHOW COLUMNS FROM educatori WHERE Field = 'id_sede';

-- 3. VERIFICA SEDI ESISTENTI
SELECT 'SEDI DISPONIBILI' as INFO;
SELECT id_sede, nome_sede, stato_sede FROM sedi ORDER BY id_sede;

-- 4. TEST ESATTO DELLA QUERY API (senza eseguire effettivamente)
SELECT 'QUERY API ORIGINALE' as INFO,
'INSERT INTO registrazioni (nome_registrazione, cognome_registrazione, username_registrazione, password_registrazione, ruolo_registrazione, id_sede, data_registrazione) VALUES ("Test", "Educatore", "test.educatore@debug.com", "password123", "educatore", 1, DATE_FORMAT(NOW(), "%d/%m/%Y"))' as QUERY_ORIGINALE;

-- 5. TENTATIVO INSERT REALE (commentato per sicurezza - decommentare per testare)
/*
INSERT INTO registrazioni (
    nome_registrazione,
    cognome_registrazione,
    username_registrazione,
    password_registrazione,
    ruolo_registrazione,
    id_sede,
    data_registrazione
) VALUES (
    'Debug',
    'Test',
    'debug.test@assistivetech.it',
    'password123',
    'educatore',
    1,
    DATE_FORMAT(NOW(), '%d/%m/%Y')
);
*/

-- 6. SE L'INSERT SOPRA FUNZIONA, TESTARE ANCHE INSERT EDUCATORI
/*
SET @last_id = LAST_INSERT_ID();

INSERT INTO educatori (
    id_registrazione,
    nome,
    cognome,
    settore,
    classe,
    id_sede,
    data_creazione
) VALUES (
    @last_id,
    'Debug',
    'Test',
    'Test Settore',
    'Test Classe',
    1,
    DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')
);
*/

-- 7. VERIFICA FOREIGN KEY CONSTRAINTS che potrebbero causare problemi
SELECT 'FOREIGN KEYS registrazioni' as INFO;
SELECT
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'registrazioni'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 8. VERIFICA FOREIGN KEYS educatori
SELECT 'FOREIGN KEYS educatori' as INFO;
SELECT
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'educatori'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 9. CONTROLLO VALORI ENUM ruolo_registrazione
SELECT 'ENUM RUOLI' as INFO;
SHOW COLUMNS FROM registrazioni WHERE Field = 'ruolo_registrazione';

-- 10. CONTROLLO ULTIMI INSERIMENTI FALLITI (se ci sono log di errore)
SELECT 'ULTIMI TENTATIVI' as INFO;
SELECT * FROM registrazioni
WHERE ruolo_registrazione = 'educatore'
ORDER BY id_registrazione DESC
LIMIT 3;

-- 11. DIAGNOSI POSSIBILI CAUSE FALLIMENTO
SELECT 'POSSIBILI CAUSE ERRORE' as DIAGNOSI,
    CASE
        WHEN (SELECT COUNT(*) FROM sedi WHERE id_sede = 1) = 0
        THEN 'ERRORE: id_sede=1 non esiste in tabella sedi'
        ELSE 'OK: id_sede=1 esiste'
    END as CHECK_SEDE_DEFAULT,
    CASE
        WHEN (SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
              WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'registrazioni'
              AND COLUMN_NAME = 'ruolo_registrazione') NOT LIKE '%educatore%'
        THEN 'ERRORE: ruolo "educatore" non ammesso in ENUM'
        ELSE 'OK: ruolo educatore ammesso'
    END as CHECK_RUOLO_ENUM;