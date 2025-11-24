-- ================================================
-- SCRIPT DI VERIFICA STATUS DATABASE ASSISTIVETECH.IT
-- Da eseguire su MySQL Aruba per estrarre tutto il contenuto
-- ================================================

-- INFORMAZIONI GENERALI DATABASE
-- ================================================
SELECT 'DATABASE INFO' as tipo_info, DATABASE() as database_name, NOW() as timestamp_verifica;

-- ELENCO TABELLE ESISTENTI
-- ================================================
SELECT 'TABELLE ESISTENTI' as tipo_info;
SHOW TABLES;

-- STRUTTURA TABELLA REGISTRAZIONI
-- ================================================
SELECT 'STRUTTURA REGISTRAZIONI' as tipo_info;
SELECT 
    COLUMN_NAME as campo,
    DATA_TYPE as tipo,
    IS_NULLABLE as nullable,
    COLUMN_DEFAULT as default_value,
    EXTRA as extra
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'registrazioni'
ORDER BY ORDINAL_POSITION;

-- STRUTTURA TABELLE (solo se esistono)
-- ================================================
SELECT 'VERIFICA ESISTENZA TABELLE' as tipo_info;
SELECT 
    TABLE_NAME as tabella_esistente,
    TABLE_TYPE as tipo_tabella
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE();

-- Struttura sedi (se esiste)
SELECT 'STRUTTURA SEDI' as tipo_info;
SELECT 
    COLUMN_NAME as campo,
    DATA_TYPE as tipo,
    IS_NULLABLE as nullable,
    COLUMN_DEFAULT as default_value,
    EXTRA as extra
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sedi'
ORDER BY ORDINAL_POSITION;

-- Struttura educatori (se esiste)
SELECT 'STRUTTURA EDUCATORI' as tipo_info;
SELECT 
    COLUMN_NAME as campo,
    DATA_TYPE as tipo,
    IS_NULLABLE as nullable,
    COLUMN_DEFAULT as default_value,
    EXTRA as extra
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori'
ORDER BY ORDINAL_POSITION;

-- Struttura pazienti (se esiste)
SELECT 'STRUTTURA PAZIENTI' as tipo_info;
SELECT 
    COLUMN_NAME as campo,
    DATA_TYPE as tipo,
    IS_NULLABLE as nullable,
    COLUMN_DEFAULT as default_value,
    EXTRA as extra
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pazienti'
ORDER BY ORDINAL_POSITION;

-- Struttura educatori_pazienti (se esiste)
SELECT 'STRUTTURA EDUCATORI_PAZIENTI' as tipo_info;
SELECT 
    COLUMN_NAME as campo,
    DATA_TYPE as tipo,
    IS_NULLABLE as nullable,
    COLUMN_DEFAULT as default_value,
    EXTRA as extra
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori_pazienti'
ORDER BY ORDINAL_POSITION;

-- CONTENUTO COMPLETO REGISTRAZIONI
-- ================================================
SELECT 'CONTENUTO REGISTRAZIONI' as tipo_info;
SELECT * FROM registrazioni ORDER BY id_registrazione;

-- CONTENUTO TABELLE ESISTENTI
-- ================================================

-- Contenuto sedi (solo se esiste)
SELECT 'CONTENUTO SEDI' as tipo_info;
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sedi') > 0 
        THEN 'Tabella sedi trovata - contenuto estratto sotto'
        ELSE 'Tabella sedi NON ESISTE'
    END as stato_tabella_sedi;

-- Query condizionale per sedi (se esiste mostrerà i dati, altrimenti sarà vuota)
SELECT * FROM sedi ORDER BY id_sede 
WHERE (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sedi') > 0;

-- Contenuto educatori (solo se esiste)
SELECT 'CONTENUTO EDUCATORI' as tipo_info;
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori') > 0 
        THEN 'Tabella educatori trovata - contenuto estratto sotto'
        ELSE 'Tabella educatori NON ESISTE'
    END as stato_tabella_educatori;

-- Query condizionale per educatori
SELECT * FROM educatori ORDER BY id_educatore 
WHERE (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori') > 0;

-- Contenuto pazienti (solo se esiste)
SELECT 'CONTENUTO PAZIENTI' as tipo_info;
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pazienti') > 0 
        THEN 'Tabella pazienti trovata - contenuto estratto sotto'
        ELSE 'Tabella pazienti NON ESISTE'
    END as stato_tabella_pazienti;

-- Query condizionale per pazienti
SELECT * FROM pazienti ORDER BY id_paziente 
WHERE (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pazienti') > 0;

-- Contenuto associazioni (solo se esiste)
SELECT 'CONTENUTO EDUCATORI_PAZIENTI' as tipo_info;
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori_pazienti') > 0 
        THEN 'Tabella educatori_pazienti trovata - contenuto estratto sotto'
        ELSE 'Tabella educatori_pazienti NON ESISTE'
    END as stato_tabella_associazioni;

-- Query condizionale per associazioni
SELECT * FROM educatori_pazienti ORDER BY id_associazione 
WHERE (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori_pazienti') > 0;

-- STATISTICHE GENERALI
-- ================================================
SELECT 'STATISTICHE UTENTI' as tipo_info;
SELECT 
    ruolo_registrazione,
    COUNT(*) as numero_utenti,
    SUM(CASE WHEN stato_account = 'attivo' THEN 1 ELSE 0 END) as utenti_attivi
FROM registrazioni 
GROUP BY ruolo_registrazione;

-- VERIFICA FOREIGN KEY E INTEGRITÀ (solo se tabelle esistono)
-- ================================================
SELECT 'VERIFICA INTEGRITÀ' as tipo_info;

-- Conteggio registrazioni per ruolo
SELECT 'CONTEGGIO PER RUOLO' as verifica;
SELECT 
    ruolo_registrazione as ruolo,
    COUNT(*) as numero_utenti
FROM registrazioni 
GROUP BY ruolo_registrazione;

-- Verifica tabelle correlate (solo se esistono)
SELECT 'VERIFICA TABELLE CORRELATE' as verifica;

-- Controlla se esistono tabelle correlate
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'TABELLA SEDI ESISTE'
        ELSE 'TABELLA SEDI NON ESISTE'
    END as stato_sedi
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sedi';

SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'TABELLA EDUCATORI ESISTE'
        ELSE 'TABELLA EDUCATORI NON ESISTE'
    END as stato_educatori
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori';

SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'TABELLA PAZIENTI ESISTE'
        ELSE 'TABELLA PAZIENTI NON ESISTE'
    END as stato_pazienti
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pazienti';

-- RIEPILOGO FINALE
-- ================================================
SELECT 'RIEPILOGO FINALE' as tipo_info;

-- Conteggio sicuro delle tabelle esistenti
SELECT 
    (SELECT COUNT(*) FROM registrazioni) as totale_registrazioni;

-- Conteggio tabelle secondarie (solo se esistono)
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sedi') > 0 
        THEN (SELECT COUNT(*) FROM sedi)
        ELSE 0
    END as totale_sedi;

SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori') > 0 
        THEN (SELECT COUNT(*) FROM educatori)
        ELSE 0
    END as totale_educatori;

SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pazienti') > 0 
        THEN (SELECT COUNT(*) FROM pazienti)
        ELSE 0
    END as totale_pazienti;

-- FINE SCRIPT
SELECT '✅ VERIFICA DATABASE COMPLETATA' as RISULTATO;