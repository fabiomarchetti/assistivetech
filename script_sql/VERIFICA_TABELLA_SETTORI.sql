-- =====================================================================
-- SCRIPT: VERIFICA_TABELLA_SETTORI.sql
-- SCOPO: Verificare struttura tabella settori per correggere visualizzazione
-- =====================================================================

-- 1. VERIFICA ESISTENZA TABELLA SETTORI
SELECT 'VERIFICA TABELLA SETTORI' as INFO;
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'settori')
        THEN 'ESISTE: settori'
        ELSE 'NON ESISTE: settori'
    END as RISULTATO;

-- 2. STRUTTURA TABELLA SETTORI
SHOW COLUMNS FROM settori;

-- 3. TUTTI I SETTORI ESISTENTI
SELECT * FROM settori ORDER BY id_settore;

-- 4. TEST JOIN CON EDUCATORI
SELECT 'TEST JOIN SETTORI-EDUCATORI' as INFO;
SELECT
    e.id_educatore,
    e.nome,
    e.cognome,
    e.id_settore,
    s.nome as nome_settore_reale
FROM educatori e
LEFT JOIN settori s ON e.id_settore = s.id_settore
ORDER BY e.id_educatore;

-- 5. VERIFICA ANCHE CLASSI
SELECT 'VERIFICA TABELLA CLASSI' as INFO;
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'classi')
        THEN 'ESISTE: classi'
        ELSE 'NON ESISTE: classi'
    END as RISULTATO;

-- 6. SE ESISTE, MOSTRA STRUTTURA CLASSI
-- SHOW COLUMNS FROM classi;
-- SELECT * FROM classi ORDER BY id_classe;

-- 7. TEST JOIN COMPLETO (se le tabelle esistono)
SELECT 'TEST JOIN COMPLETO' as INFO;
SELECT
    e.id_educatore,
    e.nome,
    e.cognome,
    e.id_settore,
    e.id_classe,
    s.nome as nome_settore,
    c.nome as nome_classe
FROM educatori e
LEFT JOIN settori s ON e.id_settore = s.id_settore
LEFT JOIN classi c ON e.id_classe = c.id_classe
ORDER BY e.id_educatore;