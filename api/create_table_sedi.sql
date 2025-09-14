-- Script per creare la tabella sedi
-- Da eseguire nel database MySQL Aruba (Sql1073852_1)

-- Elimina tabella sedi se esiste
DROP TABLE IF EXISTS sedi;

-- Crea la tabella sedi
CREATE TABLE sedi (
    id_sede INT AUTO_INCREMENT PRIMARY KEY,
    nome_sede VARCHAR(200) NOT NULL UNIQUE,
    indirizzo VARCHAR(255),
    citta VARCHAR(100),
    provincia CHAR(2),
    cap VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(255),
    data_creazione VARCHAR(19) NOT NULL,
    stato_sede ENUM('attiva', 'sospesa', 'chiusa') DEFAULT 'attiva',

    INDEX idx_nome_sede (nome_sede),
    INDEX idx_citta (citta),
    INDEX idx_provincia (provincia),
    INDEX idx_stato (stato_sede)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inserisce una sede di default per iniziare
INSERT INTO sedi (nome_sede, data_creazione)
VALUES ('Sede Principale', DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'));

-- Verifica creazione
SELECT 'Tabella sedi creata con successo!' as info;
DESCRIBE sedi;
SELECT * FROM sedi;