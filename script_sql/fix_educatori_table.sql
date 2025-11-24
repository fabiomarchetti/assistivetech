-- Script per completare la struttura della tabella educatori
-- Data: 17/09/2024
-- Problema: Mancano i campi nome, cognome, telefono, note_professionali, stato_educatore, data_creazione

-- 1. Aggiungi tutti i campi mancanti
ALTER TABLE educatori
ADD COLUMN nome VARCHAR(100) AFTER id_registrazione,
ADD COLUMN cognome VARCHAR(100) AFTER nome,
ADD COLUMN telefono VARCHAR(20) AFTER email_contatto,
ADD COLUMN note_professionali TEXT AFTER telefono,
ADD COLUMN stato_educatore ENUM('attivo', 'sospeso', 'in_formazione', 'eliminato') DEFAULT 'attivo' AFTER note_professionali,
ADD COLUMN data_creazione VARCHAR(19) AFTER stato_educatore;

-- 2. Verifica risultato
DESCRIBE educatori;