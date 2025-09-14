-- Script per aggiungere il campo id_sede alle tabelle educatori e pazienti
-- Da eseguire DOPO aver creato la tabella sedi

-- Aggiunge id_sede alla tabella educatori
ALTER TABLE educatori
ADD COLUMN id_sede INT DEFAULT 1 AFTER classe,
ADD INDEX idx_sede (id_sede),
ADD FOREIGN KEY (id_sede) REFERENCES sedi(id_sede) ON DELETE SET NULL;

-- Aggiunge id_sede alla tabella pazienti
ALTER TABLE pazienti
ADD COLUMN id_sede INT DEFAULT 1 AFTER classe,
ADD INDEX idx_sede (id_sede),
ADD FOREIGN KEY (id_sede) REFERENCES sedi(id_sede) ON DELETE SET NULL;

-- Aggiorna tutti i record esistenti per utilizzare la sede principale (id=1)
UPDATE educatori SET id_sede = 1 WHERE id_sede IS NULL;
UPDATE pazienti SET id_sede = 1 WHERE id_sede IS NULL;

-- Verifica modifiche
SELECT 'Tabelle aggiornate con id_sede!' as info;

SELECT 'Struttura educatori:' as info;
DESCRIBE educatori;

SELECT 'Struttura pazienti:' as info;
DESCRIBE pazienti;

SELECT 'Educatori con sede:' as info;
SELECT e.nome, e.cognome, s.nome_sede
FROM educatori e
JOIN sedi s ON e.id_sede = s.id_sede;

SELECT 'Pazienti con sede:' as info;
SELECT p.nome, p.cognome, s.nome_sede
FROM pazienti p
JOIN sedi s ON p.id_sede = s.id_sede;