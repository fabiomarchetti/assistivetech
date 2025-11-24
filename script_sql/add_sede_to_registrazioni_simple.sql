-- Script semplificato per aggiungere campo sede alla tabella registrazioni
-- Data: 17/09/2024
-- Versione: Senza INFORMATION_SCHEMA (per limitazioni permessi Aruba)

-- 1. Aggiungi colonna id_sede alla tabella registrazioni
ALTER TABLE registrazioni
ADD COLUMN id_sede INT DEFAULT 1 AFTER ruolo_registrazione;

-- 2. Aggiungi foreign key constraint verso tabella sedi
ALTER TABLE registrazioni
ADD CONSTRAINT fk_registrazioni_sede
FOREIGN KEY (id_sede) REFERENCES sedi(id_sede)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- 3. Verifica risultato (struttura tabella)
DESCRIBE registrazioni;

-- 4. Test: mostra alcune registrazioni con sede
SELECT
    r.id_registrazione,
    r.nome_registrazione,
    r.cognome_registrazione,
    r.ruolo_registrazione,
    r.id_sede,
    s.nome_sede
FROM registrazioni r
LEFT JOIN sedi s ON r.id_sede = s.id_sede
LIMIT 5;