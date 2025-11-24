-- =========================================
-- SCRIPT CREAZIONE TABELLE DIRETTORI E CASEMANAGER
-- Database: assistivetech_local (e Aruba)
-- Data: 05/11/2025
-- Descrizione:
--   - Crea tabella DIRETTORI (direzione settori)
--   - Crea tabella CASEMANAGER (coordinamento pazienti)
--   - Relazione: 1 Direttore → N CaseManager
--   - Entrambi hanno: sede, settore, classe
-- =========================================

-- =========================================
-- 1. TABELLA DIRETTORI
-- =========================================
CREATE TABLE IF NOT EXISTS `direttori` (
  `id_direttore` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Chiave primaria univoca',
  `id_registrazione` INT(11) NOT NULL UNIQUE COMMENT 'FK verso registrazioni (1:1 unique)',
  `nome` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nome del direttore',
  `cognome` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Cognome del direttore',
  `id_sede` INT(11) DEFAULT 1 COMMENT 'FK verso sedi',
  `id_settore` INT(11) DEFAULT NULL COMMENT 'FK verso settori (settore di competenza)',
  `id_classe` INT(11) DEFAULT NULL COMMENT 'FK verso classi (classe di competenza)',
  `telefono` VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Telefono contatto',
  `email_contatto` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email contatto',
  `note_direttive` TEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Note direttive e istruzioni',
  `data_creazione` VARCHAR(19) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Data creazione (dd/mm/yyyy hh:mm:ss)',
  `stato_direttore` ENUM('attivo','sospeso','inattivo') COLLATE utf8mb4_unicode_ci DEFAULT 'attivo' COMMENT 'Stato del direttore',

  PRIMARY KEY (`id_direttore`),
  UNIQUE KEY `uq_registrazione` (`id_registrazione`),

  -- Foreign Keys
  CONSTRAINT `fk_direttori_registrazioni`
    FOREIGN KEY (`id_registrazione`)
    REFERENCES `registrazioni` (`id_registrazione`)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT `fk_direttori_sedi`
    FOREIGN KEY (`id_sede`)
    REFERENCES `sedi` (`id_sede`)
    ON DELETE SET DEFAULT ON UPDATE CASCADE,

  CONSTRAINT `fk_direttori_settori`
    FOREIGN KEY (`id_settore`)
    REFERENCES `settori` (`id_settore`)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT `fk_direttori_classi`
    FOREIGN KEY (`id_classe`)
    REFERENCES `classi` (`id_classe`)
    ON DELETE SET NULL ON UPDATE CASCADE,

  -- Indici per performance
  KEY `idx_sede` (`id_sede`),
  KEY `idx_settore` (`id_settore`),
  KEY `idx_classe` (`id_classe`),
  KEY `idx_stato` (`stato_direttore`),
  KEY `idx_data_creazione` (`data_creazione`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tabella direttori - Gestione direzione per settori/classi';

-- =========================================
-- 2. TABELLA CASEMANAGER
-- =========================================
CREATE TABLE IF NOT EXISTS `casemanager` (
  `id_casemanager` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Chiave primaria univoca',
  `id_registrazione` INT(11) NOT NULL UNIQUE COMMENT 'FK verso registrazioni (1:1 unique)',
  `id_direttore` INT(11) DEFAULT NULL COMMENT 'FK verso direttori (N:1 gerarchia)',
  `nome` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nome del case manager',
  `cognome` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Cognome del case manager',
  `id_sede` INT(11) DEFAULT 1 COMMENT 'FK verso sedi',
  `id_settore` INT(11) DEFAULT NULL COMMENT 'FK verso settori (settore di competenza)',
  `id_classe` INT(11) DEFAULT NULL COMMENT 'FK verso classi (classe di competenza)',
  `telefono` VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Telefono contatto',
  `email_contatto` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Email contatto',
  `specializzazione` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Area specializzazione (es: Cognitivo, Comportamentale)',
  `data_creazione` VARCHAR(19) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Data creazione (dd/mm/yyyy hh:mm:ss)',
  `stato_casemanager` ENUM('attivo','sospeso','inattivo') COLLATE utf8mb4_unicode_ci DEFAULT 'attivo' COMMENT 'Stato del case manager',

  PRIMARY KEY (`id_casemanager`),
  UNIQUE KEY `uq_registrazione` (`id_registrazione`),

  -- Foreign Keys
  CONSTRAINT `fk_casemanager_registrazioni`
    FOREIGN KEY (`id_registrazione`)
    REFERENCES `registrazioni` (`id_registrazione`)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT `fk_casemanager_direttori`
    FOREIGN KEY (`id_direttore`)
    REFERENCES `direttori` (`id_direttore`)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT `fk_casemanager_sedi`
    FOREIGN KEY (`id_sede`)
    REFERENCES `sedi` (`id_sede`)
    ON DELETE SET DEFAULT ON UPDATE CASCADE,

  CONSTRAINT `fk_casemanager_settori`
    FOREIGN KEY (`id_settore`)
    REFERENCES `settori` (`id_settore`)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT `fk_casemanager_classi`
    FOREIGN KEY (`id_classe`)
    REFERENCES `classi` (`id_classe`)
    ON DELETE SET NULL ON UPDATE CASCADE,

  -- Indici per performance
  KEY `idx_direttore` (`id_direttore`),
  KEY `idx_sede` (`id_sede`),
  KEY `idx_settore` (`id_settore`),
  KEY `idx_classe` (`id_classe`),
  KEY `idx_stato` (`stato_casemanager`),
  KEY `idx_data_creazione` (`data_creazione`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tabella case manager - Coordinamento pazienti e programmi';

-- =========================================
-- 3. TABELLA ASSOCIAZIONE CASEMANAGER-PAZIENTI (Opzionale)
-- Permette 1 paziente → N case manager (per situazioni complesse)
-- =========================================
CREATE TABLE IF NOT EXISTS `casemanager_pazienti` (
  `id_associazione` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Chiave primaria',
  `id_casemanager` INT(11) NOT NULL COMMENT 'FK verso casemanager',
  `id_paziente` INT(11) NOT NULL COMMENT 'FK verso pazienti',
  `data_associazione` VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Data associazione (dd/mm/yyyy)',
  `is_attiva` TINYINT(1) DEFAULT 1 COMMENT '1=attiva, 0=disattivata (soft delete)',
  `note` TEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Note specifiche associazione',

  PRIMARY KEY (`id_associazione`),
  UNIQUE KEY `uq_associazione` (`id_casemanager`, `id_paziente`, `is_attiva`),

  -- Foreign Keys
  CONSTRAINT `fk_casemanager_pazienti_casemanager`
    FOREIGN KEY (`id_casemanager`)
    REFERENCES `casemanager` (`id_casemanager`)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT `fk_casemanager_pazienti_pazienti`
    FOREIGN KEY (`id_paziente`)
    REFERENCES `pazienti` (`id_paziente`)
    ON DELETE CASCADE ON UPDATE CASCADE,

  -- Indici
  KEY `idx_casemanager` (`id_casemanager`),
  KEY `idx_paziente` (`id_paziente`),
  KEY `idx_attiva` (`is_attiva`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Associazione N:M case manager-pazienti';

-- =========================================
-- 4. VERIFICA ENUM REGISTRAZIONI
-- =========================================
-- Verifica che i ruoli 'direttore' e 'casemanager' siano in registrazioni
-- Se non presenti, eseguire:
-- ALTER TABLE registrazioni MODIFY COLUMN ruolo_registrazione
-- ENUM('amministratore','educatore','paziente','sviluppatore','direttore','casemanager');

-- =========================================
-- 5. VIEW DI SUPPORTO - Direttori con Dettagli
-- =========================================
CREATE OR REPLACE VIEW vw_direttori_dettagli AS
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

-- =========================================
-- 6. VIEW DI SUPPORTO - CaseManager con Dettagli
-- =========================================
CREATE OR REPLACE VIEW vw_casemanager_dettagli AS
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

-- =========================================
-- 7. VIEW DI SUPPORTO - Gerarchia Completa
-- =========================================
CREATE OR REPLACE VIEW vw_gerarchia_organizzativa AS
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

-- =========================================
-- 8. STORED PROCEDURE - Crea Direttore
-- =========================================
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS `sp_create_direttore`(
  IN p_nome VARCHAR(100),
  IN p_cognome VARCHAR(100),
  IN p_username VARCHAR(255),
  IN p_password VARCHAR(255),
  IN p_id_sede INT,
  IN p_id_settore INT,
  IN p_id_classe INT,
  IN p_telefono VARCHAR(20),
  IN p_email VARCHAR(255),
  IN p_note_direttive TEXT,
  OUT p_id_direttore INT,
  OUT p_success TINYINT,
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE v_id_registrazione INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SET p_success = 0;
    SET p_message = 'Errore nella creazione del direttore';
    ROLLBACK;
  END;

  START TRANSACTION;

  -- 1. Crea registrazione
  INSERT INTO registrazioni (
    nome_registrazione, cognome_registrazione, username_registrazione,
    password_registrazione, ruolo_registrazione, id_sede, data_registrazione
  ) VALUES (
    p_nome, p_cognome, p_username, p_password, 'direttore', p_id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y')
  );

  SET v_id_registrazione = LAST_INSERT_ID();

  -- 2. Crea direttore
  INSERT INTO direttori (
    id_registrazione, nome, cognome, id_sede, id_settore, id_classe,
    telefono, email_contatto, note_direttive, data_creazione, stato_direttore
  ) VALUES (
    v_id_registrazione, p_nome, p_cognome, p_id_sede, p_id_settore, p_id_classe,
    p_telefono, p_email, p_note_direttive, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'), 'attivo'
  );

  SET p_id_direttore = LAST_INSERT_ID();
  SET p_success = 1;
  SET p_message = 'Direttore creato con successo';

  COMMIT;
END //

DELIMITER ;

-- =========================================
-- 9. STORED PROCEDURE - Crea CaseManager
-- =========================================
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS `sp_create_casemanager`(
  IN p_nome VARCHAR(100),
  IN p_cognome VARCHAR(100),
  IN p_username VARCHAR(255),
  IN p_password VARCHAR(255),
  IN p_id_direttore INT,
  IN p_id_sede INT,
  IN p_id_settore INT,
  IN p_id_classe INT,
  IN p_telefono VARCHAR(20),
  IN p_email VARCHAR(255),
  IN p_specializzazione VARCHAR(255),
  OUT p_id_casemanager INT,
  OUT p_success TINYINT,
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE v_id_registrazione INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SET p_success = 0;
    SET p_message = 'Errore nella creazione del case manager';
    ROLLBACK;
  END;

  START TRANSACTION;

  -- 1. Crea registrazione
  INSERT INTO registrazioni (
    nome_registrazione, cognome_registrazione, username_registrazione,
    password_registrazione, ruolo_registrazione, id_sede, data_registrazione
  ) VALUES (
    p_nome, p_cognome, p_username, p_password, 'casemanager', p_id_sede, DATE_FORMAT(NOW(), '%d/%m/%Y')
  );

  SET v_id_registrazione = LAST_INSERT_ID();

  -- 2. Crea case manager
  INSERT INTO casemanager (
    id_registrazione, id_direttore, nome, cognome, id_sede, id_settore, id_classe,
    telefono, email_contatto, specializzazione, data_creazione, stato_casemanager
  ) VALUES (
    v_id_registrazione, p_id_direttore, p_nome, p_cognome, p_id_sede, p_id_settore, p_id_classe,
    p_telefono, p_email, p_specializzazione, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'), 'attivo'
  );

  SET p_id_casemanager = LAST_INSERT_ID();
  SET p_success = 1;
  SET p_message = 'Case manager creato con successo';

  COMMIT;
END //

DELIMITER ;

-- =========================================
-- 10. FINE SCRIPT
-- =========================================
-- Script completato con successo
--
-- Tabelle create:
--   ✅ direttori
--   ✅ casemanager
--   ✅ casemanager_pazienti
--
-- Views create:
--   ✅ vw_direttori_dettagli
--   ✅ vw_casemanager_dettagli
--   ✅ vw_gerarchia_organizzativa
--
-- Stored Procedures create:
--   ✅ sp_create_direttore
--   ✅ sp_create_casemanager
--
-- Prossimi step:
-- 1. Verificare registrazioni.ruolo_registrazione enum
-- 2. Aggiornare API files per direttori/casemanager
-- 3. Testare creazione utenti
-- =========================================
