-- Script per modificare la struttura della tabella educatori
-- Rimuove campi non necessari e aggiunge nome, cognome, settore, classe

-- Elimina e ricrea la tabella educatori con la nuova struttura
DROP TABLE IF EXISTS educatori;

-- Crea la nuova tabella educatori semplificata
CREATE TABLE educatori (
    id_educatore INT AUTO_INCREMENT PRIMARY KEY,
    id_registrazione INT NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    settore VARCHAR(100),
    classe VARCHAR(50),
    telefono VARCHAR(20),
    email_contatto VARCHAR(255),
    note_professionali TEXT,
    stato_educatore ENUM('attivo', 'sospeso', 'in_formazione') DEFAULT 'attivo',
    data_creazione VARCHAR(19) NOT NULL,

    INDEX idx_registrazione (id_registrazione),
    INDEX idx_stato (stato_educatore),
    INDEX idx_settore (settore),
    INDEX idx_classe (classe),
    INDEX idx_data_creazione (data_creazione),

    FOREIGN KEY (id_registrazione) REFERENCES registrazioni(id_registrazione) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verifica creazione
SELECT 'Tabella educatori aggiornata con successo!' as info;
DESCRIBE educatori;