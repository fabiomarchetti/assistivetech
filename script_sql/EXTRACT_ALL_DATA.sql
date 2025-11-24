-- ===============================================
-- SCRIPT DI ESTRAZIONE COMPLETA DATI ASSISTIVETECH.IT
-- Esegue query per estrarre tutti i contenuti del database
-- ===============================================

-- Informazioni generali sul database
SELECT '=== INFORMAZIONI DATABASE ===' as sezione;
SELECT 
    DATABASE() as database_name,
    VERSION() as mysql_version,
    NOW() as data_estrazione;

-- Verifica tabelle esistenti
SELECT '=== TABELLE ESISTENTI ===' as sezione;
SHOW TABLES;

-- ===============================================
-- 1. TABELLA REGISTRAZIONI (Utenti del sistema)
-- ===============================================
SELECT '=== REGISTRAZIONI (UTENTI) ===' as sezione;

-- Struttura tabella
DESCRIBE registrazioni;

-- Contenuto tabella
SELECT 
    id_registrazione,
    nome_registrazione,
    cognome_registrazione,
    username_registrazione,
    ruolo_registrazione,
    data_registrazione,
    ultimo_accesso,
    stato_account
FROM registrazioni 
ORDER BY data_registrazione;

-- Statistiche per ruolo
SELECT 
    ruolo_registrazione,
    COUNT(*) as totale_utenti,
    SUM(CASE WHEN stato_account = 'attivo' THEN 1 ELSE 0 END) as utenti_attivi,
    SUM(CASE WHEN stato_account = 'sospeso' THEN 1 ELSE 0 END) as utenti_sospesi,
    SUM(CASE WHEN stato_account = 'eliminato' THEN 1 ELSE 0 END) as utenti_eliminati
FROM registrazioni 
GROUP BY ruolo_registrazione;

-- ===============================================
-- 2. TABELLA SEDI
-- ===============================================
SELECT '=== SEDI ===' as sezione;

-- Struttura tabella
DESCRIBE sedi;

-- Contenuto tabella
SELECT 
    id_sede,
    nome_sede,
    indirizzo,
    citta,
    provincia,
    cap,
    telefono,
    email,
    data_creazione,
    stato_sede
FROM sedi 
ORDER BY id_sede;

-- ===============================================
-- 3. TABELLA EDUCATORI
-- ===============================================
SELECT '=== EDUCATORI ===' as sezione;

-- Verifica se la tabella esiste
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tabella educatori ESISTE'
        ELSE 'Tabella educatori NON ESISTE'
    END as stato_tabella
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
AND table_name = 'educatori';

-- Se la tabella esiste, estrai i dati
SELECT 
    id_educatore,
    id_registrazione,
    nome,
    cognome,
    settore,
    classe,
    id_sede,
    telefono,
    email_contatto,
    note_professionali,
    stato_educatore,
    data_creazione
FROM educatori 
ORDER BY id_educatore;

-- Statistiche educatori per sede
SELECT 
    s.nome_sede,
    COUNT(e.id_educatore) as totale_educatori,
    SUM(CASE WHEN e.stato_educatore = 'attivo' THEN 1 ELSE 0 END) as educatori_attivi
FROM sedi s
LEFT JOIN educatori e ON s.id_sede = e.id_sede
GROUP BY s.id_sede, s.nome_sede;

-- ===============================================
-- 4. TABELLA PAZIENTI
-- ===============================================
SELECT '=== PAZIENTI ===' as sezione;

-- Verifica se la tabella esiste
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tabella pazienti ESISTE'
        ELSE 'Tabella pazienti NON ESISTE'
    END as stato_tabella
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
AND table_name = 'pazienti';

-- Se la tabella esiste, estrai i dati
SELECT 
    id_paziente,
    id_registrazione,
    nome,
    cognome,
    settore,
    classe,
    id_sede,
    data_creazione
FROM pazienti 
ORDER BY id_paziente;

-- Statistiche pazienti per settore e classe
SELECT 
    settore,
    classe,
    COUNT(*) as totale_pazienti
FROM pazienti 
WHERE settore IS NOT NULL
GROUP BY settore, classe
ORDER BY settore, classe;

-- ===============================================
-- 5. TABELLA ASSOCIAZIONI EDUCATORI-PAZIENTI
-- ===============================================
SELECT '=== ASSOCIAZIONI EDUCATORI-PAZIENTI ===' as sezione;

-- Verifica se la tabella esiste
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tabella educatori_pazienti ESISTE'
        ELSE 'Tabella educatori_pazienti NON ESISTE'
    END as stato_tabella
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
AND table_name = 'educatori_pazienti';

-- Se la tabella esiste, estrai i dati
SELECT 
    ep.id_associazione,
    ep.id_educatore,
    e.nome as nome_educatore,
    e.cognome as cognome_educatore,
    ep.id_paziente,
    p.nome as nome_paziente,
    p.cognome as cognome_paziente,
    ep.data_associazione,
    ep.is_attiva,
    ep.note
FROM educatori_pazienti ep
LEFT JOIN educatori e ON ep.id_educatore = e.id_educatore
LEFT JOIN pazienti p ON ep.id_paziente = p.id_paziente
ORDER BY ep.id_associazione;

-- Statistiche associazioni
SELECT 
    COUNT(*) as totale_associazioni,
    SUM(CASE WHEN is_attiva = 1 THEN 1 ELSE 0 END) as associazioni_attive,
    SUM(CASE WHEN is_attiva = 0 THEN 1 ELSE 0 END) as associazioni_disattivate
FROM educatori_pazienti;

-- ===============================================
-- 6. TABELLA LOG ACCESSI
-- ===============================================
SELECT '=== LOG ACCESSI ===' as sezione;

-- Verifica se la tabella esiste
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tabella log_accessi ESISTE'
        ELSE 'Tabella log_accessi NON ESISTE'
    END as stato_tabella
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
AND table_name = 'log_accessi';

-- Se la tabella esiste, estrai i dati (ultimi 50 accessi)
SELECT 
    id_log,
    username,
    esito,
    indirizzo_ip,
    user_agent,
    timestamp_accesso
FROM log_accessi 
ORDER BY timestamp_accesso DESC 
LIMIT 50;

-- Statistiche accessi
SELECT 
    esito,
    COUNT(*) as totale_accessi,
    COUNT(DISTINCT username) as utenti_unici
FROM log_accessi 
GROUP BY esito;

-- Accessi per giorno (ultimi 7 giorni)
SELECT 
    DATE(timestamp_accesso) as data_accesso,
    COUNT(*) as totale_accessi,
    SUM(CASE WHEN esito = 'successo' THEN 1 ELSE 0 END) as accessi_riusciti,
    SUM(CASE WHEN esito = 'fallimento' THEN 1 ELSE 0 END) as accessi_falliti
FROM log_accessi 
WHERE timestamp_accesso >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(timestamp_accesso)
ORDER BY data_accesso DESC;

-- ===============================================
-- 7. TABELLA SESSIONI UTENTE
-- ===============================================
SELECT '=== SESSIONI UTENTE ===' as sezione;

-- Verifica se la tabella esiste
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'Tabella sessioni_utente ESISTE'
        ELSE 'Tabella sessioni_utente NON ESISTE'
    END as stato_tabella
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
AND table_name = 'sessioni_utente';

-- Se la tabella esiste, estrai i dati
SELECT 
    id_sessione,
    id_utente,
    r.username_registrazione,
    timestamp_creazione,
    timestamp_ultimo_accesso,
    indirizzo_ip,
    is_attiva
FROM sessioni_utente s
LEFT JOIN registrazioni r ON s.id_utente = r.id_registrazione
ORDER BY timestamp_creazione DESC;

-- Statistiche sessioni
SELECT 
    COUNT(*) as totale_sessioni,
    SUM(CASE WHEN is_attiva = 1 THEN 1 ELSE 0 END) as sessioni_attive,
    COUNT(DISTINCT id_utente) as utenti_con_sessioni
FROM sessioni_utente;

-- ===============================================
-- 8. VERIFICA INTEGRITÀ DATI
-- ===============================================
SELECT '=== VERIFICA INTEGRITÀ DATI ===' as sezione;

-- Verifica foreign key rotte
SELECT 'Educatori senza registrazione:' as controllo;
SELECT e.id_educatore, e.nome, e.cognome
FROM educatori e
LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
WHERE r.id_registrazione IS NULL;

SELECT 'Pazienti senza registrazione:' as controllo;
SELECT p.id_paziente, p.nome, p.cognome
FROM pazienti p
LEFT JOIN registrazioni r ON p.id_registrazione = r.id_registrazione
WHERE r.id_registrazione IS NULL;

SELECT 'Associazioni con educatori inesistenti:' as controllo;
SELECT ep.id_associazione, ep.id_educatore
FROM educatori_pazienti ep
LEFT JOIN educatori e ON ep.id_educatore = e.id_educatore
WHERE e.id_educatore IS NULL;

SELECT 'Associazioni con pazienti inesistenti:' as controllo;
SELECT ep.id_associazione, ep.id_paziente
FROM educatori_pazienti ep
LEFT JOIN pazienti p ON ep.id_paziente = p.id_paziente
WHERE p.id_paziente IS NULL;

-- ===============================================
-- 9. RIEPILOGO FINALE
-- ===============================================
SELECT '=== RIEPILOGO FINALE ===' as sezione;

SELECT 
    'REGISTRAZIONI' as tabella,
    COUNT(*) as record_totali
FROM registrazioni
UNION ALL
SELECT 
    'SEDI' as tabella,
    COUNT(*) as record_totali
FROM sedi
UNION ALL
SELECT 
    'EDUCATORI' as tabella,
    COUNT(*) as record_totali
FROM educatori
UNION ALL
SELECT 
    'PAZIENTI' as tabella,
    COUNT(*) as record_totali
FROM pazienti
UNION ALL
SELECT 
    'EDUCATORI_PAZIENTI' as tabella,
    COUNT(*) as record_totali
FROM educatori_pazienti
UNION ALL
SELECT 
    'LOG_ACCESSI' as tabella,
    COUNT(*) as record_totali
FROM log_accessi
UNION ALL
SELECT 
    'SESSIONI_UTENTE' as tabella,
    COUNT(*) as record_totali
FROM sessioni_utente;

-- Data e ora di estrazione
SELECT 
    'ESTRAZIONE COMPLETATA' as stato,
    NOW() as timestamp_estrazione,
    'Tutti i dati sono stati estratti con successo' as messaggio;
