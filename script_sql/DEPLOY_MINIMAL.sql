-- ===============================================
-- SCRIPT MINIMALE - SOLO RUOLO SVILUPPATORE E SEDI
-- Tabelle educatori, pazienti, educatori_pazienti GIÀ ESISTENTI
-- ===============================================

-- STEP 1: Aggiungere ruolo sviluppatore (solo se non esiste)
-- ===============================================
ALTER TABLE registrazioni 
MODIFY COLUMN ruolo_registrazione ENUM('amministratore', 'educatore', 'paziente', 'sviluppatore') NOT NULL;

-- STEP 2: Convertire account Fabio da amministratore a sviluppatore
-- ===============================================
UPDATE registrazioni 
SET ruolo_registrazione = 'sviluppatore' 
WHERE username_registrazione = 'marchettisoft@gmail.com';

-- STEP 3: Creare tabella sedi SOLO se non esiste (senza toccare dati esistenti)
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

-- STEP 4: Inserire sede principale SOLO se non esiste
-- ===============================================
INSERT IGNORE INTO sedi (nome_sede, indirizzo, citta, provincia, cap, telefono, email, data_creazione) 
VALUES ('Sede Principale', 'Via Roma 1', 'Milano', 'MI', '20100', '02-12345678', 'info@assistivetech.it', DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'));

-- STEP 5: Verifiche finali (senza toccare dati esistenti)
-- ===============================================

-- Verifica conversione account sviluppatore
SELECT 'Verifica Account Sviluppatore:' as info;
SELECT id_registrazione, nome_registrazione, cognome_registrazione, username_registrazione, ruolo_registrazione
FROM registrazioni 
WHERE username_registrazione = 'marchettisoft@gmail.com';

-- Verifica che le tabelle esistenti siano integre
SELECT 'Verifica Tabelle Esistenti:' as info;
SELECT COUNT(*) as educatori_count FROM educatori;
SELECT COUNT(*) as pazienti_count FROM pazienti;
SELECT COUNT(*) as associazioni_count FROM educatori_pazienti;

-- Verifica sede principale
SELECT 'Verifica Sedi:' as info;
SELECT COUNT(*) as sedi_count FROM sedi;

-- DEPLOYMENT MINIMALE COMPLETATO!
SELECT '✅ DEPLOYMENT MINIMALE COMPLETATO! Solo ruolo sviluppatore e sedi aggiunti.' as RISULTATO;