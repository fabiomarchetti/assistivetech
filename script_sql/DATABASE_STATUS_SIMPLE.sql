-- ================================================
-- SCRIPT SEMPLIFICATO DI VERIFICA DATABASE
-- ASSISTIVETECH.IT - VERSIONE SICURA
-- ================================================

-- INFORMAZIONI GENERALI
-- ================================================
SELECT 'INFO DATABASE' as tipo, DATABASE() as database_name, NOW() as timestamp;

-- ELENCO TUTTE LE TABELLE
-- ================================================
SELECT 'ELENCO TABELLE' as tipo;
SHOW TABLES;

-- CONTENUTO TABELLA REGISTRAZIONI (sempre presente)
-- ================================================
SELECT 'TABELLA REGISTRAZIONI - STRUTTURA' as tipo;
SHOW COLUMNS FROM registrazioni;

SELECT 'TABELLA REGISTRAZIONI - CONTENUTO' as tipo;
SELECT * FROM registrazioni ORDER BY id_registrazione;

-- STATISTICHE UTENTI PER RUOLO
-- ================================================
SELECT 'STATISTICHE RUOLI' as tipo;
SELECT 
    ruolo_registrazione as ruolo,
    COUNT(*) as numero_utenti,
    SUM(CASE WHEN stato_account = 'attivo' THEN 1 ELSE 0 END) as attivi,
    SUM(CASE WHEN stato_account = 'sospeso' THEN 1 ELSE 0 END) as sospesi
FROM registrazioni 
GROUP BY ruolo_registrazione;

-- VERIFICA ESISTENZA ALTRE TABELLE
-- ================================================
SELECT 'VERIFICA TABELLE OPZIONALI' as tipo;

-- Test esistenza tabella sedi
SELECT 'TEST SEDI' as verifica, 
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('ESISTE - ', COUNT(*), ' record')
        ELSE 'NON TROVATA'
    END as risultato
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sedi';

-- Test esistenza tabella educatori  
SELECT 'TEST EDUCATORI' as verifica,
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('ESISTE - tabella trovata')
        ELSE 'NON TROVATA'
    END as risultato
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori';

-- Test esistenza tabella pazienti
SELECT 'TEST PAZIENTI' as verifica,
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('ESISTE - tabella trovata')
        ELSE 'NON TROVATA'
    END as risultato
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pazienti';

-- FINE VERIFICA
-- ================================================
SELECT 'COMPLETATO' as stato, 'Verifica database terminata' as messaggio;