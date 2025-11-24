-- ============================================================================
-- Script: Creazione tabella agende_strumenti
-- Descrizione: Tabella per gestire agende principali e sub-agende
-- Data: 2025-10-28
-- ============================================================================

-- Creazione tabella agende_strumenti
CREATE TABLE IF NOT EXISTS agende_strumenti (
    id_agenda INT PRIMARY KEY AUTO_INCREMENT,
    nome_agenda VARCHAR(200) NOT NULL,
    id_paziente INT NOT NULL,
    id_educatore INT NOT NULL,
    id_agenda_parent INT NULL COMMENT 'NULL per agenda principale, altrimenti ID agenda genitore',
    tipo_agenda ENUM('principale', 'sottomenu') DEFAULT 'principale',
    data_creazione VARCHAR(19),
    stato ENUM('attiva', 'archiviata') DEFAULT 'attiva',

    -- Foreign Keys
    FOREIGN KEY (id_paziente) REFERENCES pazienti(id_paziente) ON DELETE CASCADE,
    FOREIGN KEY (id_educatore) REFERENCES educatori(id_educatore) ON DELETE CASCADE,
    FOREIGN KEY (id_agenda_parent) REFERENCES agende_strumenti(id_agenda) ON DELETE CASCADE,

    -- Indici per performance
    INDEX idx_paziente (id_paziente),
    INDEX idx_educatore (id_educatore),
    INDEX idx_parent (id_agenda_parent),
    INDEX idx_stato (stato),
    INDEX idx_tipo (tipo_agenda)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log creazione
INSERT INTO log_operazioni (operazione, descrizione, data_operazione)
VALUES ('CREATE_TABLE', 'Creata tabella agende_strumenti', NOW())
ON DUPLICATE KEY UPDATE data_operazione = NOW();
