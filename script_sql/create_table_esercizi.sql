-- Script SQL per creazione tabella esercizi
-- AssistiveTech.it - Database MySQL Aruba
-- Data: 20/09/2025

-- Creazione tabella esercizi
CREATE TABLE IF NOT EXISTS `esercizi` (
  `id_esercizio` int NOT NULL AUTO_INCREMENT,
  `id_categoria` int NOT NULL,
  `nome_esercizio` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descrizione_esercizio` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_creazione` varchar(19) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stato_esercizio` enum('attivo','sospeso','archiviato') COLLATE utf8mb4_unicode_ci DEFAULT 'attivo',
  PRIMARY KEY (`id_esercizio`),
  KEY `idx_categoria` (`id_categoria`),
  KEY `idx_nome_esercizio` (`nome_esercizio`),
  KEY `idx_stato` (`stato_esercizio`),
  CONSTRAINT `fk_esercizi_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorie_esercizi` (`id_categoria`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Aggiunta indici per performance
CREATE INDEX `idx_esercizi_categoria_nome` ON `esercizi` (`id_categoria`, `nome_esercizio`);
CREATE INDEX `idx_esercizi_stato_categoria` ON `esercizi` (`stato_esercizio`, `id_categoria`);

-- Commenti sulle colonne
ALTER TABLE `esercizi`
  MODIFY COLUMN `id_esercizio` int NOT NULL AUTO_INCREMENT COMMENT 'Chiave primaria univoca per ogni esercizio',
  MODIFY COLUMN `id_categoria` int NOT NULL COMMENT 'Riferimento alla tabella categorie_esercizi',
  MODIFY COLUMN `nome_esercizio` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nome descrittivo dell\'esercizio',
  MODIFY COLUMN `descrizione_esercizio` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Descrizione dettagliata obiettivi e modalità',
  MODIFY COLUMN `data_creazione` varchar(19) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Data e ora creazione formato dd/mm/yyyy hh:mm:ss',
  MODIFY COLUMN `stato_esercizio` enum('attivo','sospeso','archiviato') COLLATE utf8mb4_unicode_ci DEFAULT 'attivo' COMMENT 'Stato operativo dell\'esercizio';