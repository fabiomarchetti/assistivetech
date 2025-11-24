-- =====================================================================
-- SCRIPT: ESTRAZIONE_COMPLETA_DATABASE.sql
-- SCOPO: Estrazione completa di tutte le tabelle e strutture del database
-- UTILIZZO: Riferimento preciso per sviluppo futuro
-- DATA: Settembre 2024
-- =====================================================================

-- ===================================================================== --
-- SEZIONE 1: INFORMAZIONI GENERALI DATABASE
-- ===================================================================== --

SELECT '======= INFORMAZIONI DATABASE =======' as SEZIONE;

SELECT
    DATABASE() as NOME_DATABASE,
    VERSION() as VERSIONE_MYSQL,
    NOW() as TIMESTAMP_ESTRAZIONE,
    USER() as UTENTE_CONNESSO;

-- Lista tutte le tabelle del database
SELECT '======= LISTA TABELLE =======' as SEZIONE;
SHOW TABLES;

-- ===================================================================== --
-- SEZIONE 2: TABELLA REGISTRAZIONI (Sistema Autenticazione)
-- ===================================================================== --

SELECT '======= TABELLA: registrazioni =======' as SEZIONE;

-- Struttura tabella
DESCRIBE registrazioni;

-- Tutti i record con tutti i campi
SELECT * FROM registrazioni ORDER BY id_registrazione;

-- Conteggi per ruolo
SELECT 'STATISTICHE registrazioni' as TIPO;
SELECT
    ruolo_registrazione,
    COUNT(*) as totale,
    COUNT(CASE WHEN stato_account = 'attivo' THEN 1 END) as attivi,
    COUNT(CASE WHEN stato_account = 'sospeso' THEN 1 END) as sospesi,
    COUNT(CASE WHEN stato_account = 'eliminato' THEN 1 END) as eliminati
FROM registrazioni
GROUP BY ruolo_registrazione;

-- ===================================================================== --
-- SEZIONE 3: TABELLA SEDI (Gestione Multi-Location)
-- ===================================================================== --

SELECT '======= TABELLA: sedi =======' as SEZIONE;

-- Struttura tabella
DESCRIBE sedi;

-- Tutti i record con tutti i campi
SELECT * FROM sedi ORDER BY id_sede;

-- Statistiche sedi
SELECT 'STATISTICHE sedi' as TIPO;
SELECT
    stato_sede,
    COUNT(*) as totale
FROM sedi
GROUP BY stato_sede;

-- ===================================================================== --
-- SEZIONE 4: TABELLA EDUCATORI (Profili Educatori)
-- ===================================================================== --

SELECT '======= TABELLA: educatori =======' as SEZIONE;

-- Struttura tabella
DESCRIBE educatori;

-- Tutti i record con tutti i campi
SELECT * FROM educatori ORDER BY id_educatore;

-- Join con registrazioni per vista completa
SELECT 'VISTA COMPLETA educatori + registrazioni' as TIPO;
SELECT
    e.*,
    r.username_registrazione,
    r.password_registrazione,
    r.ruolo_registrazione,
    r.data_registrazione,
    r.ultimo_accesso,
    r.stato_account,
    s.nome_sede
FROM educatori e
LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
LEFT JOIN sedi s ON e.id_sede = s.id_sede
ORDER BY e.id_educatore;

-- Statistiche educatori
SELECT 'STATISTICHE educatori' as TIPO;
SELECT
    stato_educatore,
    COUNT(*) as totale
FROM educatori
GROUP BY stato_educatore;

-- ===================================================================== --
-- SEZIONE 5: TABELLA PAZIENTI (Profili Pazienti)
-- ===================================================================== --

SELECT '======= TABELLA: pazienti =======' as SEZIONE;

-- Struttura tabella
DESCRIBE pazienti;

-- Tutti i record con tutti i campi
SELECT * FROM pazienti ORDER BY id_paziente;

-- Join con registrazioni per vista completa
SELECT 'VISTA COMPLETA pazienti + registrazioni' as TIPO;
SELECT
    p.*,
    r.username_registrazione,
    r.password_registrazione,
    r.ruolo_registrazione,
    r.data_registrazione,
    r.ultimo_accesso,
    r.stato_account,
    s.nome_sede
FROM pazienti p
LEFT JOIN registrazioni r ON p.id_registrazione = r.id_registrazione
LEFT JOIN sedi s ON p.id_sede = s.id_sede
ORDER BY p.id_paziente;

-- ===================================================================== --
-- SEZIONE 6: TABELLA EDUCATORI_PAZIENTI (Associazioni)
-- ===================================================================== --

SELECT '======= TABELLA: educatori_pazienti =======' as SEZIONE;

-- Verifica se la tabella esiste
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'educatori_pazienti')
        THEN 'TABELLA educatori_pazienti ESISTE'
        ELSE 'TABELLA educatori_pazienti NON ESISTE'
    END as VERIFICA_TABELLA;

-- Se esiste, mostra struttura e dati
-- DESCRIBE educatori_pazienti;
-- SELECT * FROM educatori_pazienti ORDER BY id_associazione;

-- ===================================================================== --
-- SEZIONE 7: TABELLA SETTORI (se esiste)
-- ===================================================================== --

SELECT '======= TABELLA: settori =======' as SEZIONE;

-- Verifica esistenza
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'settori')
        THEN 'TABELLA settori ESISTE'
        ELSE 'TABELLA settori NON ESISTE'
    END as VERIFICA_TABELLA;

-- Se esiste, decommentare:
-- DESCRIBE settori;
-- SELECT * FROM settori ORDER BY id_settore;

-- ===================================================================== --
-- SEZIONE 8: TABELLA CLASSI (se esiste)
-- ===================================================================== --

SELECT '======= TABELLA: classi =======' as SEZIONE;

-- Verifica esistenza
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'classi')
        THEN 'TABELLA classi ESISTE'
        ELSE 'TABELLA classi NON ESISTE'
    END as VERIFICA_TABELLA;

-- Se esiste, decommentare:
-- DESCRIBE classi;
-- SELECT * FROM classi ORDER BY id_classe;

-- ===================================================================== --
-- SEZIONE 9: TABELLA LOG_ACCESSI (se esiste)
-- ===================================================================== --

SELECT '======= TABELLA: log_accessi =======' as SEZIONE;

-- Verifica esistenza
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'log_accessi')
        THEN 'TABELLA log_accessi ESISTE'
        ELSE 'TABELLA log_accessi NON ESISTE'
    END as VERIFICA_TABELLA;

-- Se esiste, mostra ultimi 10 accessi:
-- SELECT * FROM log_accessi ORDER BY timestamp_accesso DESC LIMIT 10;

-- ===================================================================== --
-- SEZIONE 10: FOREIGN KEY E VINCOLI
-- ===================================================================== --

SELECT '======= FOREIGN KEY E VINCOLI =======' as SEZIONE;

-- Foreign key constraints (potrebbe non funzionare su tutti i server)
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- ===================================================================== --
-- SEZIONE 11: INDICI E CHIAVI
-- ===================================================================== --

SELECT '======= INDICI E CHIAVI =======' as SEZIONE;

-- Indici per ogni tabella principale
SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE,
    INDEX_TYPE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME IN ('registrazioni', 'sedi', 'educatori', 'pazienti')
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- ===================================================================== --
-- SEZIONE 12: VERIFICA INTEGRITÀ DATI
-- ===================================================================== --

SELECT '======= VERIFICA INTEGRITÀ DATI =======' as SEZIONE;

-- Verifica coerenza educatori
SELECT 'INTEGRITÀ educatori' as CONTROLLO;
SELECT
    'EDUCATORI' as TABELLA,
    (SELECT COUNT(*) FROM registrazioni WHERE ruolo_registrazione = 'educatore') as IN_REGISTRAZIONI,
    (SELECT COUNT(*) FROM educatori) as IN_EDUCATORI,
    CASE
        WHEN (SELECT COUNT(*) FROM registrazioni WHERE ruolo_registrazione = 'educatore') = (SELECT COUNT(*) FROM educatori)
        THEN '✅ COERENTE'
        ELSE '❌ INCOERENTE'
    END as STATO;

-- Verifica coerenza pazienti
SELECT 'INTEGRITÀ pazienti' as CONTROLLO;
SELECT
    'PAZIENTI' as TABELLA,
    (SELECT COUNT(*) FROM registrazioni WHERE ruolo_registrazione = 'paziente') as IN_REGISTRAZIONI,
    (SELECT COUNT(*) FROM pazienti) as IN_PAZIENTI,
    CASE
        WHEN (SELECT COUNT(*) FROM registrazioni WHERE ruolo_registrazione = 'paziente') = (SELECT COUNT(*) FROM pazienti)
        THEN '✅ COERENTE'
        ELSE '❌ INCOERENTE'
    END as STATO;

-- Verifica sedi referenziate
SELECT 'SEDI REFERENZIATE' as CONTROLLO;
SELECT
    s.id_sede,
    s.nome_sede,
    (SELECT COUNT(*) FROM educatori WHERE id_sede = s.id_sede) as EDUCATORI_ASSEGNATI,
    (SELECT COUNT(*) FROM pazienti WHERE id_sede = s.id_sede) as PAZIENTI_ASSEGNATI
FROM sedi s
ORDER BY s.id_sede;

-- ===================================================================== --
-- SEZIONE 13: RIEPILOGO FINALE
-- ===================================================================== --

SELECT '======= RIEPILOGO FINALE =======' as SEZIONE;

SELECT
    'TOTALE UTENTI' as METRIC,
    COUNT(*) as VALORE
FROM registrazioni
UNION ALL
SELECT
    'AMMINISTRATORI' as METRIC,
    COUNT(*) as VALORE
FROM registrazioni WHERE ruolo_registrazione = 'amministratore'
UNION ALL
SELECT
    'SVILUPPATORI' as METRIC,
    COUNT(*) as VALORE
FROM registrazioni WHERE ruolo_registrazione = 'sviluppatore'
UNION ALL
SELECT
    'EDUCATORI' as METRIC,
    COUNT(*) as VALORE
FROM registrazioni WHERE ruolo_registrazione = 'educatore'
UNION ALL
SELECT
    'PAZIENTI' as METRIC,
    COUNT(*) as VALORE
FROM registrazioni WHERE ruolo_registrazione = 'paziente'
UNION ALL
SELECT
    'SEDI TOTALI' as METRIC,
    COUNT(*) as VALORE
FROM sedi
UNION ALL
SELECT
    'SEDI ATTIVE' as METRIC,
    COUNT(*) as VALORE
FROM sedi WHERE stato_sede = 'attiva';

SELECT '======= ESTRAZIONE COMPLETATA =======' as FINE,
       NOW() as TIMESTAMP_FINE;