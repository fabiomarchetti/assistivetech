-- =====================================================================
-- SCRIPT: ADD_ID_SEDE_TO_SETTORI.sql
-- SCOPO: Aggiungere id_sede alla tabella settori per gerarchia sede->settore->classe
-- IMPORTANTE: Questo script modifica la struttura database per implementare
--            la gerarchia corretta SEDE -> SETTORE -> CLASSE
-- =====================================================================

-- 1. BACKUP DATI ESISTENTI (per sicurezza)
SELECT 'BACKUP SETTORI ATTUALI' as INFO;
SELECT * FROM settori;

-- 2. AGGIUNTA COLONNA id_sede ALLA TABELLA SETTORI
ALTER TABLE settori
ADD COLUMN id_sede INT AFTER id_settore,
ADD INDEX idx_settori_sede (id_sede);

-- 3. AGGIUNTA FOREIGN KEY CONSTRAINT (opzionale, ma consigliata)
ALTER TABLE settori
ADD CONSTRAINT fk_settori_sede
FOREIGN KEY (id_sede) REFERENCES sedi(id_sede)
ON UPDATE CASCADE ON DELETE SET NULL;

-- 4. ASSEGNAZIONE SETTORI ALLE SEDI ESISTENTI
-- Strategia: Assegna tutti i settori esistenti alla "Sede Principale" (id_sede = 1)
UPDATE settori SET id_sede = 1 WHERE id_sede IS NULL;

-- 5. VERIFICA DELLA NUOVA STRUTTURA
SELECT 'NUOVA STRUTTURA SETTORI' as INFO;
SHOW COLUMNS FROM settori;

-- 6. VERIFICA DATI AGGIORNATI
SELECT 'SETTORI CON SEDE ASSEGNATA' as INFO;
SELECT
    s.id_settore,
    s.nome_settore,
    s.id_sede,
    se.nome_sede
FROM settori s
LEFT JOIN sedi se ON s.id_sede = se.id_sede
ORDER BY s.id_settore;

-- 7. VERIFICA GERARCHIA COMPLETA SEDE->SETTORE->CLASSE
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

-- 8. VERIFICA EDUCATORI CON NUOVA GERARCHIA
SELECT 'EDUCATORI CON GERARCHIA CORRETTA' as INFO;
SELECT
    e.id_educatore,
    e.nome,
    e.cognome,
    se.nome_sede as sede,
    s.nome_settore as settore,
    c.nome_classe as classe
FROM educatori e
LEFT JOIN sedi se ON e.id_sede = se.id_sede
LEFT JOIN settori s ON e.id_settore = s.id_settore AND s.id_sede = e.id_sede
LEFT JOIN classi c ON e.id_classe = c.id_classe AND c.id_settore = s.id_settore
ORDER BY e.id_educatore;

SELECT '===== MODIFICA COMPLETATA =====' as FINE;