-- PASSO 2: Aggiunta foreign key (eseguire dopo il passo 1)
ALTER TABLE registrazioni
ADD CONSTRAINT fk_registrazioni_sede
FOREIGN KEY (id_sede) REFERENCES sedi(id_sede)
ON DELETE SET NULL
ON UPDATE CASCADE;