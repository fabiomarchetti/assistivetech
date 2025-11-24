-- =====================================================================
-- SCRIPT: VERIFICA_STRUTTURA_SETTORI.sql
-- SCOPO: Verificare se id_sede esiste già nella tabella settori
-- =====================================================================

-- 1. STRUTTURA TABELLA SETTORI
SELECT 'STRUTTURA TABELLA SETTORI' as INFO;
SHOW COLUMNS FROM settori;

-- 2. VERIFICA PRESENZA id_sede
SELECT 'VERIFICA PRESENZA id_sede' as INFO;
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'settori'
            AND COLUMN_NAME = 'id_sede'
        )
        THEN '✅ COLONNA id_sede ESISTE GIÀ'
        ELSE '❌ COLONNA id_sede NON ESISTE'
    END as RISULTATO;

-- 3. SETTORI CON SEDE ASSEGNATA
SELECT 'SETTORI CON SEDE ASSEGNATA' as INFO;
SELECT
    s.id_settore,
    s.nome_settore,
    s.id_sede,
    se.nome_sede
FROM settori s
LEFT JOIN sedi se ON s.id_sede = se.id_sede
ORDER BY s.id_settore;

-- 4. VERIFICA GERARCHIA COMPLETA
SELECT 'GERARCHIA COMPLETA: SEDE -> SETTORE -> CLASSE' as INFO;
SELECT
    se.id_sede,
    se.nome_sede,
    s.id_settore,
    s.nome_settore,
    c.id_classe,
    c.nome_classe
FROM sedi se
LEFT JOIN settori s ON se.id_sede = s.id_sede
LEFT JOIN classi c ON s.id_settore = c.id_settore
ORDER BY se.id_sede, s.id_settore, c.id_classe;

-- 5. CONTEGGIO SETTORI PER SEDE
SELECT 'CONTEGGIO SETTORI PER SEDE' as INFO;
SELECT
    se.id_sede,
    se.nome_sede,
    COUNT(s.id_settore) as num_settori
FROM sedi se
LEFT JOIN settori s ON se.id_sede = s.id_sede
GROUP BY se.id_sede, se.nome_sede
ORDER BY se.id_sede;

SELECT '===== VERIFICA COMPLETATA =====' as FINE;