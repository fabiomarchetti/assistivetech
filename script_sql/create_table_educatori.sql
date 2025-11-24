-- Script SQL per creare la tabella educatori
-- Da eseguire nel database MySQL Aruba (Sql1073852_1)
-- Tabella per gestire informazioni specifiche degli educatori

-- Elimina tabella educatori se esiste
DROP TABLE IF EXISTS educatori;

-- Tabella per informazioni specifiche degli educatori
CREATE TABLE educatori (
    id_educatore INT AUTO_INCREMENT PRIMARY KEY,
    id_registrazione INT NOT NULL UNIQUE,
    specializzazione VARCHAR(200),
    titolo_studio VARCHAR(200),
    esperienza_anni INT DEFAULT 0,
    telefono VARCHAR(20),
    email_contatto VARCHAR(255),
    data_abilitazione VARCHAR(10) NOT NULL,
    data_scadenza_abilitazione VARCHAR(10),
    note_professionali TEXT,
    max_pazienti_gestibili INT DEFAULT 20,
    pazienti_attivi_count INT DEFAULT 0,
    stato_educatore ENUM('attivo', 'sospeso', 'in_formazione') DEFAULT 'attivo',
    data_creazione VARCHAR(19) NOT NULL,
    data_ultima_modifica VARCHAR(19),

    INDEX idx_registrazione (id_registrazione),
    INDEX idx_stato (stato_educatore),
    INDEX idx_abilitazione (data_abilitazione),
    INDEX idx_scadenza (data_scadenza_abilitazione),
    INDEX idx_data_creazione (data_creazione),

    FOREIGN KEY (id_registrazione) REFERENCES registrazioni(id_registrazione) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Query di verifica (commentata)
-- SELECT 'Tabella educatori creata con successo!' as info;
-- DESCRIBE educatori;