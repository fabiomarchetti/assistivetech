-- Script per creare la tabella pazienti
-- Da eseguire nel database MySQL Aruba (Sql1073852_1)

-- Elimina tabella pazienti se esiste
DROP TABLE IF EXISTS pazienti;

-- Crea la tabella pazienti
CREATE TABLE pazienti (
    id_paziente INT AUTO_INCREMENT PRIMARY KEY,
    id_registrazione INT NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    settore VARCHAR(100),
    classe VARCHAR(50),
    data_creazione VARCHAR(19) NOT NULL,

    INDEX idx_registrazione (id_registrazione),
    INDEX idx_settore (settore),
    INDEX idx_classe (classe),
    INDEX idx_data_creazione (data_creazione),

    FOREIGN KEY (id_registrazione) REFERENCES registrazioni(id_registrazione) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verifica creazione
SELECT 'Tabella pazienti creata con successo!' as info;
DESCRIBE pazienti;