-- =====================================================================
-- SCRIPT: SINCRONIZZA_EDUCATORI_MANCANTI.sql
-- SCOPO: Creare profili educatori mancanti per utenti già in registrazioni
-- PROBLEMA: Educatori in registrazioni senza profilo in educatori
-- =====================================================================

-- 1. MOSTRA GLI EDUCATORI MANCANTI
SELECT 'EDUCATORI SENZA PROFILO:' as INFO;
SELECT
    r.id_registrazione,
    r.nome_registrazione,
    r.cognome_registrazione,
    r.username_registrazione,
    r.ruolo_registrazione,
    r.data_registrazione
FROM registrazioni r
LEFT JOIN educatori e ON r.id_registrazione = e.id_registrazione
WHERE r.ruolo_registrazione = 'educatore'
AND e.id_educatore IS NULL;

-- 2. CREA I PROFILI EDUCATORI MANCANTI (decommentare per eseguire)
-- ATTENZIONE: Questo inserirà i profili mancanti

/*
INSERT INTO educatori (
    id_registrazione,
    nome,
    cognome,
    id_settore,
    id_classe,
    id_sede,
    data_creazione,
    stato_educatore
)
SELECT
    r.id_registrazione,
    r.nome_registrazione,
    r.cognome_registrazione,
    NULL, -- id_settore (NULL per ora)
    NULL, -- id_classe (NULL per ora)
    1,    -- id_sede default
    DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'),
    'attivo'
FROM registrazioni r
LEFT JOIN educatori e ON r.id_registrazione = e.id_registrazione
WHERE r.ruolo_registrazione = 'educatore'
AND e.id_educatore IS NULL;
*/

-- 3. VERIFICA RISULTATO (dopo aver eseguito l'INSERT)
SELECT 'VERIFICA DOPO SINCRONIZZAZIONE:' as INFO;
SELECT
    (SELECT COUNT(*) FROM registrazioni WHERE ruolo_registrazione = 'educatore') as educatori_in_registrazioni,
    (SELECT COUNT(*) FROM educatori WHERE stato_educatore != 'eliminato') as educatori_in_educatori,
    CASE
        WHEN (SELECT COUNT(*) FROM registrazioni WHERE ruolo_registrazione = 'educatore') =
             (SELECT COUNT(*) FROM educatori WHERE stato_educatore != 'eliminato')
        THEN '✅ SINCRONIZZATI'
        ELSE '❌ ANCORA NON SINCRONIZZATI'
    END as stato_sincronizzazione;

-- 4. MOSTRA TUTTI GLI EDUCATORI DOPO SINCRONIZZAZIONE
SELECT 'TUTTI GLI EDUCATORI:' as INFO;
SELECT
    e.id_educatore,
    e.nome,
    e.cognome,
    r.username_registrazione,
    e.stato_educatore,
    e.data_creazione,
    s.nome_sede
FROM educatori e
JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
LEFT JOIN sedi s ON e.id_sede = s.id_sede
WHERE e.stato_educatore != 'eliminato'
ORDER BY e.id_educatore;