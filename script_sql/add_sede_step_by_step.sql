-- PASSO 1: Solo aggiunta colonna (eseguire per primo)
ALTER TABLE registrazioni
ADD COLUMN id_sede INT DEFAULT 1 AFTER ruolo_registrazione;