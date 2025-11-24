-- Script SQL per aggiungere campi link alle tabelle training cognitivo
-- AssistiveTech.it - Database MySQL Aruba
-- Data: 20/09/2025

-- Aggiunta campo link alla tabella categorie_esercizi
ALTER TABLE `categorie_esercizi`
ADD COLUMN `link` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Link alla pagina della categoria nel training cognitivo'
AFTER `note_categoria`;

-- Aggiunta campo link alla tabella esercizi
ALTER TABLE `esercizi`
ADD COLUMN `link` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Link all\'app Flutter dell\'esercizio specifico'
AFTER `stato_esercizio`;

-- Aggiunta indici per performance sui nuovi campi
CREATE INDEX `idx_categorie_link` ON `categorie_esercizi` (`link`);
CREATE INDEX `idx_esercizi_link` ON `esercizi` (`link`);

-- Esempio di popolamento automatico dei link (da eseguire dopo la creazione delle cartelle)
-- UPDATE `categorie_esercizi` SET `link` = CONCAT('/training_cognitivo/', REPLACE(LOWER(nome_categoria), ' ', '_'), '/') WHERE `link` IS NULL;
-- UPDATE `esercizi` SET `link` = CONCAT('/training_cognitivo/', (SELECT REPLACE(LOWER(c.nome_categoria), ' ', '_') FROM categorie_esercizi c WHERE c.id_categoria = esercizi.id_categoria), '/', REPLACE(LOWER(nome_esercizio), ' ', '_'), '/') WHERE `link` IS NULL;