-- ===============================================
-- SCRIPT COMPLETO DEPLOYMENT ASSISTIVETECH.IT  
-- Da eseguire su MySQL Aruba in ORDINE SEQUENZIALE
-- ===============================================

-- STEP 1: Aggiungere ruolo sviluppatore
-- ===============================================
ALTER TABLE registrazioni 
MODIFY COLUMN ruolo_registrazione ENUM('amministratore', 'educatore', 'paziente', 'sviluppatore') NOT NULL;

-- Convertire account Fabio da amministratore a sviluppatore
UPDATE registrazioni 
SET ruolo_registrazione = 'sviluppatore' 
WHERE username_registrazione = 'marchettisoft@gmail.com';

-- STEP 2: Creare tabella sedi (se non esiste)
-- ===============================================
CREATE TABLE IF NOT EXISTS sedi (
    id_sede INT AUTO_INCREMENT PRIMARY KEY,
    nome_sede VARCHAR(200) NOT NULL UNIQUE,
    indirizzo VARCHAR(255),
    citta VARCHAR(100),
    provincia CHAR(2),
    cap VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(255),
    data_creazione VARCHAR(19) DEFAULT '',
    stato_sede ENUM('attiva', 'sospesa', 'chiusa') DEFAULT 'attiva',
    
    INDEX idx_nome_sede (nome_sede),
    INDEX idx_stato_sede (stato_sede)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inserire sede principale se non esiste
INSERT IGNORE INTO sedi (nome_sede, indirizzo, citta, provincia, cap, telefono, email, data_creazione) 
VALUES ('Sede Principale', 'Via Roma 1', 'Milano', 'MI', '20100', '02-12345678', 'info@assistivetech.it', DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'));

-- STEP 3: Creare tabella educatori (se non esiste)
-- ===============================================
CREATE TABLE IF NOT EXISTS educatori (
    id_educatore INT AUTO_INCREMENT PRIMARY KEY,
    id_registrazione INT UNIQUE,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    settore VARCHAR(100),
    classe VARCHAR(50),
    id_sede INT DEFAULT 1,
    telefono VARCHAR(20),
    email_contatto VARCHAR(255),
    note_professionali TEXT,
    stato_educatore ENUM('attivo', 'sospeso', 'in_formazione', 'eliminato') DEFAULT 'attivo',
    data_creazione VARCHAR(19) DEFAULT '',
    
    INDEX idx_nome (nome, cognome),
    INDEX idx_settore (settore),
    INDEX idx_stato (stato_educatore),
    
    FOREIGN KEY (id_registrazione) REFERENCES registrazioni(id_registrazione) ON DELETE CASCADE,
    FOREIGN KEY (id_sede) REFERENCES sedi(id_sede) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- STEP 4: Creare tabella pazienti (se non esiste)
-- ===============================================
CREATE TABLE IF NOT EXISTS pazienti (
    id_paziente INT AUTO_INCREMENT PRIMARY KEY,
    id_registrazione INT UNIQUE,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    settore VARCHAR(100),
    classe VARCHAR(50),
    id_sede INT DEFAULT 1,
    data_creazione VARCHAR(19) DEFAULT '',
    
    INDEX idx_nome (nome, cognome),
    INDEX idx_settore (settore),
    
    FOREIGN KEY (id_registrazione) REFERENCES registrazioni(id_registrazione) ON DELETE CASCADE,
    FOREIGN KEY (id_sede) REFERENCES sedi(id_sede) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- STEP 5: Creare tabella associazioni educatori-pazienti (se non esiste)
-- ===============================================
CREATE TABLE IF NOT EXISTS educatori_pazienti (
    id_associazione INT AUTO_INCREMENT PRIMARY KEY,
    id_educatore INT NOT NULL,
    id_paziente INT NOT NULL,
    data_associazione VARCHAR(10) NOT NULL,
    is_attiva BOOLEAN DEFAULT TRUE,
    note TEXT,
    
    INDEX idx_educatore (id_educatore),
    INDEX idx_paziente (id_paziente),
    INDEX idx_attiva (is_attiva),
    
    FOREIGN KEY (id_educatore) REFERENCES educatori(id_educatore) ON DELETE CASCADE,
    FOREIGN KEY (id_paziente) REFERENCES pazienti(id_paziente) ON DELETE CASCADE,
    
    UNIQUE KEY unique_associazione_attiva (id_educatore, id_paziente, is_attiva)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- STEP 6: Verifiche finali
-- ===============================================

-- Verifica account sviluppatore
SELECT 'Verifica Account Sviluppatore:' as info;
SELECT id_registrazione, nome_registrazione, cognome_registrazione, username_registrazione, ruolo_registrazione
FROM registrazioni 
WHERE username_registrazione = 'marchettisoft@gmail.com';

-- Verifica tabelle create
SELECT 'Verifica Tabelle Create:' as info;
SHOW TABLES LIKE '%educatori%';
SHOW TABLES LIKE '%pazienti%';
SHOW TABLES LIKE '%sedi%';

-- Verifica sede principale
SELECT 'Verifica Sede Principale:' as info;
SELECT id_sede, nome_sede, stato_sede FROM sedi WHERE nome_sede = 'Sede Principale';

-- DEPLOYMENT COMPLETATO CORRETTAMENTE!
SELECT '✅ DEPLOYMENT COMPLETATO! Tutte le tabelle e ruoli sono pronti.' as RISULTATO;