-- =====================================================================
-- SCRIPT: CHECK_TABELLE_SETTORI_CLASSI.sql
-- SCOPO: Verificare se esistono le tabelle settori e classi
-- PROBLEMA: L'API fa JOIN su tabelle che potrebbero non esistere
-- =====================================================================

-- 1. VERIFICA ESISTENZA TABELLE
SELECT 'VERIFICA TABELLE:' as INFO;

SELECT
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'settori')
        THEN 'ESISTE: settori'
        ELSE 'NON ESISTE: settori'
    END as check_settori,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'classi')
        THEN 'ESISTE: classi'
        ELSE 'NON ESISTE: classi'
    END as check_classi;

-- 2. SE LE TABELLE NON ESISTONO, FACCIAMO QUERY SEMPLIFICATA
SELECT 'EDUCATORI SENZA JOIN PROBLEMATICI:' as INFO;

SELECT
    e.id_educatore,
    e.id_registrazione,
    e.nome,
    e.cognome,
    e.id_settore,
    e.id_classe,
    e.telefono,
    e.email_contatto,
    e.note_professionali,
    e.stato_educatore,
    e.data_creazione,
    s.nome_sede,
    r.username_registrazione
FROM educatori e
LEFT JOIN sedi s ON e.id_sede = s.id_sede
LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
WHERE e.stato_educatore != 'eliminato'
ORDER BY e.data_creazione DESC;

-- 3. CONTA GLI EDUCATORI
SELECT 'CONTA EDUCATORI:' as INFO;
SELECT COUNT(*) as totale_educatori FROM educatori WHERE stato_educatore != 'eliminato';

-- 4. VERIFICA PROBLEMA: CI DOVREBBE ESSERE ALMENO 1 EDUCATORE
SELECT 'VERIFICA INCONSISTENZA:' as INFO;
SELECT
    (SELECT COUNT(*) FROM registrazioni WHERE ruolo_registrazione = 'educatore') as educatori_in_registrazioni,
    (SELECT COUNT(*) FROM educatori WHERE stato_educatore != 'eliminato') as educatori_in_educatori;