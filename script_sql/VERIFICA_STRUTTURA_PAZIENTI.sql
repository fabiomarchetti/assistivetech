-- =====================================================================
-- SCRIPT: VERIFICA_STRUTTURA_PAZIENTI.sql
-- SCOPO: Verificare se anche pazienti ha lo stesso problema
-- =====================================================================

-- 1. STRUTTURA TABELLA PAZIENTI
SHOW COLUMNS FROM pazienti;

-- 2. VERIFICA COLONNE settore/classe vs id_settore/id_classe
SHOW COLUMNS FROM pazienti LIKE '%settore%';
SHOW COLUMNS FROM pazienti LIKE '%classe%';