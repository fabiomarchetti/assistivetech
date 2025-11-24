-- =====================================================================
-- SCRIPT: SIMPLE_TEST_EDUCATORE.sql
-- SCOPO: Test semplificato senza INFORMATION_SCHEMA (causa errori Aruba)
-- Usando solo comandi MySQL standard
-- =====================================================================

-- 1. VERIFICA COLONNA id_sede IN registrazioni
SHOW COLUMNS FROM registrazioni LIKE 'id_sede';

-- 2. VERIFICA SEDI ESISTENTI (importante per foreign key)
SELECT 'SEDI DISPONIBILI:' as INFO;
SELECT id_sede, nome_sede, stato_sede FROM sedi ORDER BY id_sede;

-- 3. VERIFICA ENUM RUOLI AMMESSI
SHOW COLUMNS FROM registrazioni LIKE 'ruolo_registrazione';

-- 4. CONTA EDUCATORI ESISTENTI
SELECT 'CONTEGGIO EDUCATORI:' as INFO;
SELECT COUNT(*) as totale_registrazioni FROM registrazioni;
SELECT COUNT(*) as educatori_registrazioni FROM registrazioni WHERE ruolo_registrazione = 'educatore';
SELECT COUNT(*) as educatori_profili FROM educatori;

-- 5. ULTIMI 3 RECORDS registrazioni
SELECT 'ULTIMI 3 RECORDS REGISTRAZIONI:' as INFO;
SELECT * FROM registrazioni ORDER BY id_registrazione DESC LIMIT 3;

-- 6. ULTIMI 3 RECORDS educatori
SELECT 'ULTIMI 3 EDUCATORI:' as INFO;
SELECT * FROM educatori ORDER BY id_educatore DESC LIMIT 3;

-- 7. TEST QUERY SEMPLIFICATA (decommentare per testare)
/*
-- TEST INSERIMENTO registrazione
INSERT INTO registrazioni (
    nome_registrazione,
    cognome_registrazione,
    username_registrazione,
    password_registrazione,
    ruolo_registrazione,
    id_sede,
    data_registrazione
) VALUES (
    'Test Simple',
    'Debug',
    'simple.test@debug.com',
    'password123',
    'educatore',
    1,
    DATE_FORMAT(NOW(), '%d/%m/%Y')
);
*/

-- 8. VERIFICA SE ESISTE id_sede = 1 (CRITICO)
SELECT 'VERIFICA SEDE DEFAULT:' as INFO;
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM sedi WHERE id_sede = 1)
        THEN 'OK: Sede con id=1 esiste'
        ELSE 'ERRORE: Sede con id=1 NON ESISTE - Causa del problema!'
    END as risultato_verifica;

-- 9. SE NON ESISTE SEDE 1, MOSTRA TUTTE LE SEDI
SELECT 'TUTTE LE SEDI PER DEBUG:' as INFO;
SELECT * FROM sedi;

-- 10. ULTIMA VERIFICA: USERNAME DUPLICATI
SELECT 'CHECK USERNAME DUPLICATI:' as INFO;
SELECT username_registrazione, COUNT(*) as occorrenze
FROM registrazioni
GROUP BY username_registrazione
HAVING COUNT(*) > 1;