-- Creazione tabella direttori/casemanager per gestione educatori e sedi
-- Tabella per la gestione dei direttori e case manager del sistema

CREATE TABLE IF NOT EXISTS `direttori` (
    `id_direttore` INT AUTO_INCREMENT PRIMARY KEY,
    `id_registrazione` INT UNIQUE NOT NULL,
    `nome` VARCHAR(100) NOT NULL,
    `cognome` VARCHAR(100) NOT NULL,
    `settore` VARCHAR(100),
    `classe` VARCHAR(50),
    `id_sede` INT,
    `telefono` VARCHAR(20),
    `email_contatto` VARCHAR(255),
    `ruolo_specifico` ENUM('direttore', 'casemanager') DEFAULT 'direttore',
    `data_creazione` VARCHAR(19) NOT NULL,
    `stato_direttore` ENUM('attivo', 'sospeso', 'inattivo') DEFAULT 'attivo',

    -- Foreign key verso registrazioni
    CONSTRAINT `fk_direttori_registrazioni`
        FOREIGN KEY (`id_registrazione`)
        REFERENCES `registrazioni`(`id_registrazione`)
        ON DELETE CASCADE,

    -- Foreign key verso sedi (se id_sede è specificato)
    CONSTRAINT `fk_direttori_sedi`
        FOREIGN KEY (`id_sede`)
        REFERENCES `sedi`(`id_sede`)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indici per performance
CREATE INDEX `idx_direttori_sede` ON `direttori` (`id_sede`);
CREATE INDEX `idx_direttori_settore` ON `direttori` (`settore`);
CREATE INDEX `idx_direttori_stato` ON `direttori` (`stato_direttore`);
CREATE INDEX `idx_direttori_ruolo` ON `direttori` (`ruolo_specifico`);
