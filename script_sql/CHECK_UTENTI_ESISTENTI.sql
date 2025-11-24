-- =====================================================================
-- SCRIPT: CHECK_UTENTI_ESISTENTI.sql
-- SCOPO: Verificare tutti gli username esistenti per evitare duplicati
-- =====================================================================

-- 1. TUTTI GLI USERNAME ESISTENTI
SELECT 'USERNAME ESISTENTI:' as INFO;
SELECT
    id_registrazione,
    nome_registrazione,
    cognome_registrazione,
    username_registrazione,
    ruolo_registrazione,
    data_registrazione
FROM registrazioni
ORDER BY id_registrazione;

-- 2. VERIFICA SPECIFICA edu1@gmail.com
SELECT 'VERIFICA edu1@gmail.com:' as INFO;
SELECT * FROM registrazioni WHERE username_registrazione = 'edu1@gmail.com';

-- 3. CONTEGGIO PER RUOLO
SELECT 'CONTEGGIO PER RUOLO:' as INFO;
SELECT
    ruolo_registrazione,
    COUNT(*) as totale
FROM registrazioni
GROUP BY ruolo_registrazione;

-- 4. SUGGERIMENTI USERNAME LIBERI
SELECT 'SUGGERIMENTI USERNAME LIBERI:' as INFO;
SELECT
    CASE
        WHEN NOT EXISTS (SELECT 1 FROM registrazioni WHERE username_registrazione = 'educatore.test@gmail.com')
        THEN 'LIBERO: educatore.test@gmail.com'
        ELSE 'OCCUPATO: educatore.test@gmail.com'
    END as username1,
    CASE
        WHEN NOT EXISTS (SELECT 1 FROM registrazioni WHERE username_registrazione = 'mario.rossi@assistivetech.it')
        THEN 'LIBERO: mario.rossi@assistivetech.it'
        ELSE 'OCCUPATO: mario.rossi@assistivetech.it'
    END as username2,
    CASE
        WHEN NOT EXISTS (SELECT 1 FROM registrazioni WHERE username_registrazione = 'nuovo.educatore@example.com')
        THEN 'LIBERO: nuovo.educatore@example.com'
        ELSE 'OCCUPATO: nuovo.educatore@example.com'
    END as username3;