-- =====================================================================
-- SCRIPT: TEST_FINALE_INSERIMENTI.sql
-- SCOPO: Testare gli inserimenti corretti dopo le correzioni API
-- =====================================================================

-- 1. PRIMA: Conta i record attuali
SELECT 'CONTEGGIO INIZIALE' as FASE;
SELECT
    COUNT(*) as registrazioni_totali,
    COUNT(CASE WHEN ruolo_registrazione = 'educatore' THEN 1 END) as educatori_registrazioni,
    COUNT(CASE WHEN ruolo_registrazione = 'paziente' THEN 1 END) as pazienti_registrazioni
FROM registrazioni;

SELECT COUNT(*) as educatori_profili FROM educatori;
SELECT COUNT(*) as pazienti_profili FROM pazienti;

-- 2. TEST INSERIMENTO MANUALE EDUCATORE (per verificare che funzioni)
SELECT 'TEST INSERIMENTO EDUCATORE' as FASE;

-- Decommentare per testare:
/*
START TRANSACTION;

INSERT INTO registrazioni (
    nome_registrazione,
    cognome_registrazione,
    username_registrazione,
    password_registrazione,
    ruolo_registrazione,
    id_sede,
    data_registrazione
) VALUES (
    'Test',
    'Educatore SQL',
    'test.educatore.sql@debug.com',
    'password123',
    'educatore',
    1,
    DATE_FORMAT(NOW(), '%d/%m/%Y')
);

SET @new_id = LAST_INSERT_ID();

INSERT INTO educatori (
    id_registrazione,
    nome,
    cognome,
    id_settore,
    id_classe,
    id_sede,
    data_creazione
) VALUES (
    @new_id,
    'Test',
    'Educatore SQL',
    NULL,
    NULL,
    1,
    DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')
);

COMMIT;
*/

-- 3. TEST INSERIMENTO MANUALE PAZIENTE
SELECT 'TEST INSERIMENTO PAZIENTE' as FASE;

-- Decommentare per testare:
/*
START TRANSACTION;

INSERT INTO registrazioni (
    nome_registrazione,
    cognome_registrazione,
    username_registrazione,
    password_registrazione,
    ruolo_registrazione,
    id_sede,
    data_registrazione
) VALUES (
    'Test',
    'Paziente SQL',
    'test.paziente.sql@debug.com',
    'password123',
    'paziente',
    1,
    DATE_FORMAT(NOW(), '%d/%m/%Y')
);

SET @new_paziente_id = LAST_INSERT_ID();

INSERT INTO pazienti (
    id_registrazione,
    id_settore,
    id_classe,
    id_sede,
    data_creazione
) VALUES (
    @new_paziente_id,
    NULL,
    NULL,
    1,
    DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')
);

COMMIT;
*/

-- 4. VERIFICA RISULTATI FINALI
SELECT 'CONTEGGIO FINALE (dopo test)' as FASE;
SELECT
    COUNT(*) as registrazioni_totali,
    COUNT(CASE WHEN ruolo_registrazione = 'educatore' THEN 1 END) as educatori_registrazioni,
    COUNT(CASE WHEN ruolo_registrazione = 'paziente' THEN 1 END) as pazienti_registrazioni
FROM registrazioni;

SELECT COUNT(*) as educatori_profili FROM educatori;
SELECT COUNT(*) as pazienti_profili FROM pazienti;

-- 5. ULTIMI INSERIMENTI
SELECT 'ULTIMI 3 EDUCATORI' as INFO;
SELECT * FROM educatori ORDER BY id_educatore DESC LIMIT 3;

SELECT 'ULTIMI 3 PAZIENTI' as INFO;
SELECT * FROM pazienti ORDER BY id_paziente DESC LIMIT 3;

-- 6. VERIFICA INTEGRITÀ DATI
SELECT 'VERIFICA INTEGRITÀ' as INFO;
SELECT
    r.id_registrazione,
    r.nome_registrazione,
    r.cognome_registrazione,
    r.ruolo_registrazione,
    CASE WHEN e.id_educatore IS NOT NULL THEN 'OK' ELSE 'MANCANTE' END as profilo_educatore
FROM registrazioni r
LEFT JOIN educatori e ON r.id_registrazione = e.id_registrazione
WHERE r.ruolo_registrazione = 'educatore'
ORDER BY r.id_registrazione DESC;