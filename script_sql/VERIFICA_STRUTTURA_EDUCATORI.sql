-- =====================================================================
-- SCRIPT: VERIFICA_STRUTTURA_EDUCATORI.sql
-- SCOPO: Verificare struttura esatta tabella educatori
-- PROBLEMA: API inserisce ma fallisce il secondo INSERT
-- =====================================================================

-- 1. STRUTTURA COMPLETA TABELLA EDUCATORI
SHOW COLUMNS FROM educatori;

-- 2. VERIFICA COLONNE CHE L'API STA TENTANDO DI INSERIRE
-- L'API usa: id_registrazione, nome, cognome, settore, classe, id_sede, data_creazione
SELECT 'VERIFICA COLONNE API:' as INFO;

-- Verifica se esistono le colonne che l'API cerca di usare
SHOW COLUMNS FROM educatori LIKE 'id_registrazione';
SHOW COLUMNS FROM educatori LIKE 'nome';
SHOW COLUMNS FROM educatori LIKE 'cognome';
SHOW COLUMNS FROM educatori LIKE 'settore';
SHOW COLUMNS FROM educatori LIKE 'classe';
SHOW COLUMNS FROM educatori LIKE 'id_sede';
SHOW COLUMNS FROM educatori LIKE 'data_creazione';

-- 3. DAI RISULTATI PRECEDENTI HO VISTO CHE ESISTONO ANCHE:
-- id_settore, id_classe (invece di settore, classe)
SELECT 'COLONNE AGGIUNTIVE TROVATE:' as INFO;
SHOW COLUMNS FROM educatori LIKE '%settore%';
SHOW COLUMNS FROM educatori LIKE '%classe%';

-- 4. QUERY CORRETTA PER L'API (basata sulla struttura reale)
SELECT 'QUERY API CORRETTA DOVREBBE ESSERE:' as INFO;

-- Se la tabella ha id_settore/id_classe invece di settore/classe:
SELECT 'POSSIBILE CORREZIONE 1 - Usare id_settore/id_classe:' as SUGGERIMENTO;
/*
INSERT INTO educatori (
    id_registrazione,
    nome,
    cognome,
    id_settore,     -- invece di settore
    id_classe,      -- invece di classe
    id_sede,
    data_creazione
) VALUES (?, ?, ?, ?, ?, ?, ?);
*/

-- Se la tabella ha ancora settore/classe come VARCHAR:
SELECT 'POSSIBILE CORREZIONE 2 - Settore/classe come stringhe:' as SUGGERIMENTO;
/*
INSERT INTO educatori (
    id_registrazione,
    nome,
    cognome,
    settore,
    classe,
    id_sede,
    data_creazione
) VALUES (?, ?, ?, ?, ?, ?, ?);
*/

-- 5. TEST INSERIMENTO MANUALE (decommentare per testare)
/*
-- Prima trova un id_registrazione di un educatore esistente
SELECT id_registrazione FROM registrazioni WHERE ruolo_registrazione = 'educatore' LIMIT 1;

-- Poi testa l'inserimento (sostituire XX con l'id trovato sopra)
INSERT INTO educatori (
    id_registrazione,
    nome,
    cognome,
    id_sede,
    data_creazione
) VALUES (
    4,  -- Sostituire con id_registrazione esistente
    'Test',
    'Educatore',
    1,
    DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')
);
*/

-- 6. VERIFICA FOREIGN KEY CONSTRAINTS
SELECT 'FOREIGN KEYS EDUCATORI:' as INFO;
-- Questa query potrebbe non funzionare su Aruba, ma proviamo
SHOW CREATE TABLE educatori;