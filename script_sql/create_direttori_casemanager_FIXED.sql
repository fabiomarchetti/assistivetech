/* =========================================
   CREAZIONE TABELLE DIRETTORI E CASEMANAGER
   Database: assistivetech_local / Aruba
   Data: 05/11/2025
   ========================================= */

/* ===== 1. TABELLA DIRETTORI ===== */
CREATE TABLE IF NOT EXISTS `direttori` (
  `id_direttore` INT(11) NOT NULL AUTO_INCREMENT,
  `id_registrazione` INT(11) NOT NULL UNIQUE,
  `nome` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cognome` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_sede` INT(11) DEFAULT 1,
  `id_settore` INT(11) DEFAULT NULL,
  `id_classe` INT(11) DEFAULT NULL,
  `telefono` VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_contatto` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note_direttive` TEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_creazione` VARCHAR(19) COLLATE utf8mb4_unicode_ci NOT NULL,
  `stato_direttore` ENUM('attivo','sospeso','inattivo') COLLATE utf8mb4_unicode_ci DEFAULT 'attivo',
  PRIMARY KEY (`id_direttore`),
  UNIQUE KEY `uq_registrazione` (`id_registrazione`),
  KEY `idx_sede` (`id_sede`),
  KEY `idx_settore` (`id_settore`),
  KEY `idx_classe` (`id_classe`),
  KEY `idx_stato` (`stato_direttore`),
  KEY `idx_data_creazione` (`data_creazione`),
  CONSTRAINT `fk_direttori_registrazioni` FOREIGN KEY (`id_registrazione`) REFERENCES `registrazioni` (`id_registrazione`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_direttori_sedi` FOREIGN KEY (`id_sede`) REFERENCES `sedi` (`id_sede`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_direttori_settori` FOREIGN KEY (`id_settore`) REFERENCES `settori` (`id_settore`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_direttori_classi` FOREIGN KEY (`id_classe`) REFERENCES `classi` (`id_classe`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ===== 2. TABELLA CASEMANAGER ===== */
CREATE TABLE IF NOT EXISTS `casemanager` (
  `id_casemanager` INT(11) NOT NULL AUTO_INCREMENT,
  `id_registrazione` INT(11) NOT NULL UNIQUE,
  `id_direttore` INT(11) DEFAULT NULL,
  `nome` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cognome` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_sede` INT(11) DEFAULT 1,
  `id_settore` INT(11) DEFAULT NULL,
  `id_classe` INT(11) DEFAULT NULL,
  `telefono` VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_contatto` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `specializzazione` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_creazione` VARCHAR(19) COLLATE utf8mb4_unicode_ci NOT NULL,
  `stato_casemanager` ENUM('attivo','sospeso','inattivo') COLLATE utf8mb4_unicode_ci DEFAULT 'attivo',
  PRIMARY KEY (`id_casemanager`),
  UNIQUE KEY `uq_registrazione` (`id_registrazione`),
  KEY `idx_direttore` (`id_direttore`),
  KEY `idx_sede` (`id_sede`),
  KEY `idx_settore` (`id_settore`),
  KEY `idx_classe` (`id_classe`),
  KEY `idx_stato` (`stato_casemanager`),
  KEY `idx_data_creazione` (`data_creazione`),
  CONSTRAINT `fk_casemanager_registrazioni` FOREIGN KEY (`id_registrazione`) REFERENCES `registrazioni` (`id_registrazione`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_casemanager_direttori` FOREIGN KEY (`id_direttore`) REFERENCES `direttori` (`id_direttore`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_casemanager_sedi` FOREIGN KEY (`id_sede`) REFERENCES `sedi` (`id_sede`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_casemanager_settori` FOREIGN KEY (`id_settore`) REFERENCES `settori` (`id_settore`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_casemanager_classi` FOREIGN KEY (`id_classe`) REFERENCES `classi` (`id_classe`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ===== 3. TABELLA CASEMANAGER_PAZIENTI ===== */
CREATE TABLE IF NOT EXISTS `casemanager_pazienti` (
  `id_associazione` INT(11) NOT NULL AUTO_INCREMENT,
  `id_casemanager` INT(11) NOT NULL,
  `id_paziente` INT(11) NOT NULL,
  `data_associazione` VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_attiva` TINYINT(1) DEFAULT 1,
  `note` TEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_associazione`),
  UNIQUE KEY `uq_associazione` (`id_casemanager`, `id_paziente`, `is_attiva`),
  KEY `idx_casemanager` (`id_casemanager`),
  KEY `idx_paziente` (`id_paziente`),
  KEY `idx_attiva` (`is_attiva`),
  CONSTRAINT `fk_casemanager_pazienti_casemanager` FOREIGN KEY (`id_casemanager`) REFERENCES `casemanager` (`id_casemanager`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_casemanager_pazienti_pazienti` FOREIGN KEY (`id_paziente`) REFERENCES `pazienti` (`id_paziente`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ===== 4. AGGIORNAMENTO REGISTRAZIONI ENUM ===== */
ALTER TABLE `registrazioni` MODIFY COLUMN `ruolo_registrazione` ENUM('amministratore','educatore','paziente','sviluppatore','direttore','casemanager') COLLATE utf8mb4_unicode_ci NOT NULL;

/* ===== 5. VIEW DIRETTORI DETTAGLI ===== */
CREATE OR REPLACE VIEW `vw_direttori_dettagli` AS
SELECT
  d.id_direttore,
  d.id_registrazione,
  r.username_registrazione,
  CONCAT(d.nome, ' ', d.cognome) AS nome_completo,
  d.telefono,
  d.email_contatto,
  s.nome_sede,
  st.nome_settore,
  cl.nome_classe,
  d.stato_direttore,
  d.data_creazione,
  COUNT(DISTINCT cm.id_casemanager) AS numero_casemanager_assegnati
FROM direttori d
LEFT JOIN registrazioni r ON d.id_registrazione = r.id_registrazione
LEFT JOIN sedi s ON d.id_sede = s.id_sede
LEFT JOIN settori st ON d.id_settore = st.id_settore
LEFT JOIN classi cl ON d.id_classe = cl.id_classe
LEFT JOIN casemanager cm ON d.id_direttore = cm.id_direttore AND cm.stato_casemanager = 'attivo'
GROUP BY d.id_direttore
ORDER BY d.data_creazione DESC;

/* ===== 6. VIEW CASEMANAGER DETTAGLI ===== */
CREATE OR REPLACE VIEW `vw_casemanager_dettagli` AS
SELECT
  cm.id_casemanager,
  cm.id_registrazione,
  r.username_registrazione,
  CONCAT(cm.nome, ' ', cm.cognome) AS nome_completo,
  cm.telefono,
  cm.email_contatto,
  cm.specializzazione,
  s.nome_sede,
  st.nome_settore,
  cl.nome_classe,
  CONCAT(d.nome, ' ', d.cognome) AS direttore_assegnato,
  cm.stato_casemanager,
  cm.data_creazione,
  COUNT(DISTINCT cp.id_paziente) AS numero_pazienti_assegnati
FROM casemanager cm
LEFT JOIN registrazioni r ON cm.id_registrazione = r.id_registrazione
LEFT JOIN sedi s ON cm.id_sede = s.id_sede
LEFT JOIN settori st ON cm.id_settore = st.id_settore
LEFT JOIN classi cl ON cm.id_classe = cl.id_classe
LEFT JOIN direttori d ON cm.id_direttore = d.id_direttore
LEFT JOIN casemanager_pazienti cp ON cm.id_casemanager = cp.id_casemanager AND cp.is_attiva = 1
GROUP BY cm.id_casemanager
ORDER BY cm.data_creazione DESC;

/* ===== 7. VIEW GERARCHIA ORGANIZZATIVA ===== */
CREATE OR REPLACE VIEW `vw_gerarchia_organizzativa` AS
SELECT
  'Direttore' AS ruolo,
  d.id_direttore AS id_persona,
  CONCAT(d.nome, ' ', d.cognome) AS nome_completo,
  r.username_registrazione,
  s.nome_sede,
  st.nome_settore,
  d.stato_direttore AS stato,
  d.data_creazione,
  NULL AS id_superiore,
  NULL AS superiore_nome
FROM direttori d
LEFT JOIN registrazioni r ON d.id_registrazione = r.id_registrazione
LEFT JOIN sedi s ON d.id_sede = s.id_sede
LEFT JOIN settori st ON d.id_settore = st.id_settore

UNION ALL

SELECT
  'Case Manager' AS ruolo,
  cm.id_casemanager AS id_persona,
  CONCAT(cm.nome, ' ', cm.cognome) AS nome_completo,
  r.username_registrazione,
  s.nome_sede,
  st.nome_settore,
  cm.stato_casemanager AS stato,
  cm.data_creazione,
  cm.id_direttore AS id_superiore,
  CONCAT(d.nome, ' ', d.cognome) AS superiore_nome
FROM casemanager cm
LEFT JOIN registrazioni r ON cm.id_registrazione = r.id_registrazione
LEFT JOIN sedi s ON cm.id_sede = s.id_sede
LEFT JOIN settori st ON cm.id_settore = st.id_settore
LEFT JOIN direttori d ON cm.id_direttore = d.id_direttore

UNION ALL

SELECT
  'Educatore' AS ruolo,
  e.id_educatore AS id_persona,
  CONCAT(e.nome, ' ', e.cognome) AS nome_completo,
  r.username_registrazione,
  s.nome_sede,
  st.nome_settore,
  e.stato_educatore AS stato,
  e.data_creazione,
  NULL AS id_superiore,
  NULL AS superiore_nome
FROM educatori e
LEFT JOIN registrazioni r ON e.id_registrazione = r.id_registrazione
LEFT JOIN sedi s ON e.id_sede = s.id_sede
LEFT JOIN settori st ON e.id_settore = st.id_settore

ORDER BY nome_sede, ruolo, data_creazione DESC;

/* ===== SCRIPT COMPLETATO ===== */
