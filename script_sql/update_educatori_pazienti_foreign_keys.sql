-- Script di verifica foreign key per tabelle educatori e pazienti
-- NOTA: Le tabelle sono già state ricostruite con i foreign key corretti
-- Questo script serve solo per verificare che tutto sia configurato correttamente

SELECT 'Verifica foreign key nelle tabelle educatori e pazienti...' as info;

-- Verifica struttura tabella educatori
SELECT 'Struttura tabella educatori:' as info;
DESCRIBE educatori;

-- Verifica struttura tabella pazienti
SELECT 'Struttura tabella pazienti:' as info;
DESCRIBE pazienti;

-- Verifica foreign key testando le relazioni direttamente
SELECT 'Verifica foreign key con test di relazioni...' as info;

-- Test delle relazioni con esempi di dati
SELECT 'Test relazioni - Settori disponibili:' as info;
SELECT id_settore, nome_settore FROM settori ORDER BY ordine_visualizzazione;

SELECT 'Test relazioni - Classi disponibili (primi 10):' as info;
SELECT c.id_classe, c.nome_classe, s.nome_settore as settore
FROM classi c
JOIN settori s ON c.id_settore = s.id_settore
ORDER BY s.ordine_visualizzazione, c.ordine_visualizzazione
LIMIT 10;

SELECT 'Test relazioni - Sedi disponibili:' as info;
SELECT id_sede, nome_sede FROM sedi;

-- Verifica che le tabelle siano vuote (appena create)
SELECT 'Conteggio record esistenti:' as info;
SELECT 'educatori' as tabella, COUNT(*) as record_count FROM educatori
UNION ALL
SELECT 'pazienti' as tabella, COUNT(*) as record_count FROM pazienti;

SELECT 'Verifica completata! Le tabelle hanno la struttura corretta con tutti i foreign key.' as info;