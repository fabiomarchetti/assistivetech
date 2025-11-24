-- Script SQL per creare le tabelle per il sistema di autenticazione AssistiveTech.it
-- Da eseguire nel database MySQL Aruba (Sql1073852_1)
-- ATTENZIONE: Questo script elimina e ricrea le tabelle esistenti!

-- Elimina tabelle esistenti (nell'ordine corretto per le foreign key)
DROP TABLE IF EXISTS sessioni_utente;
DROP TABLE IF EXISTS log_accessi;
DROP TABLE IF EXISTS educatori_pazienti;
DROP TABLE IF EXISTS registrazioni;

-- Tabella principale per le registrazioni utenti
CREATE TABLE registrazioni (
    id_registrazione INT AUTO_INCREMENT PRIMARY KEY,
    nome_registrazione VARCHAR(100) NOT NULL,
    cognome_registrazione VARCHAR(100) NOT NULL,
    username_registrazione VARCHAR(255) NOT NULL UNIQUE,
    password_registrazione VARCHAR(255) NOT NULL,
    ruolo_registrazione ENUM('amministratore', 'educatore', 'paziente') NOT NULL,
    data_registrazione VARCHAR(10) NOT NULL,
    ultimo_accesso VARCHAR(19) NULL,
    stato_account ENUM('attivo', 'sospeso', 'eliminato') DEFAULT 'attivo',

    INDEX idx_username (username_registrazione),
    INDEX idx_ruolo (ruolo_registrazione),
    INDEX idx_stato (stato_account),
    INDEX idx_data_registrazione (data_registrazione)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella per le associazioni educatori-pazienti
CREATE TABLE educatori_pazienti (
    id_associazione INT AUTO_INCREMENT PRIMARY KEY,
    id_educatore INT NOT NULL,
    id_paziente INT NOT NULL,
    data_associazione VARCHAR(10) NOT NULL,
    is_attiva BOOLEAN DEFAULT TRUE,
    note TEXT,

    INDEX idx_educatore (id_educatore),
    INDEX idx_paziente (id_paziente),
    INDEX idx_attiva (is_attiva),
    INDEX idx_data_associazione (data_associazione),

    FOREIGN KEY (id_educatore) REFERENCES registrazioni(id_registrazione) ON DELETE CASCADE,
    FOREIGN KEY (id_paziente) REFERENCES registrazioni(id_registrazione) ON DELETE CASCADE,

    UNIQUE KEY unique_associazione (id_educatore, id_paziente, is_attiva)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella per log degli accessi (per sicurezza)
CREATE TABLE log_accessi (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    esito ENUM('successo', 'fallimento') NOT NULL,
    indirizzo_ip VARCHAR(45),
    user_agent TEXT,
    timestamp_accesso VARCHAR(19) NOT NULL,

    INDEX idx_username (username),
    INDEX idx_timestamp (timestamp_accesso),
    INDEX idx_esito (esito)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella per sessioni utente (per gestione avanzata sessioni)
CREATE TABLE sessioni_utente (
    id_sessione VARCHAR(128) PRIMARY KEY,
    id_utente INT NOT NULL,
    timestamp_creazione VARCHAR(19) NOT NULL,
    timestamp_ultimo_accesso VARCHAR(19) NOT NULL,
    indirizzo_ip VARCHAR(45),
    user_agent TEXT,
    is_attiva BOOLEAN DEFAULT TRUE,

    INDEX idx_utente (id_utente),
    INDEX idx_timestamp_creazione (timestamp_creazione),
    INDEX idx_attiva (is_attiva),

    FOREIGN KEY (id_utente) REFERENCES registrazioni(id_registrazione) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inserimento dell'amministratore principale (Fabio Marchetti)
INSERT INTO registrazioni (
    nome_registrazione,
    cognome_registrazione,
    username_registrazione,
    password_registrazione,
    ruolo_registrazione,
    data_registrazione,
    stato_account
) VALUES (
    'Fabio',
    'Marchetti',
    'marchettisoft@gmail.com',
    'Filohori11!',
    'amministratore',
    DATE_FORMAT(NOW(), '%d/%m/%Y'),
    'attivo'
);

-- Query di verifica (commentate, da usare per controlli)
-- SELECT 'Registrazioni create:' as info;
-- SELECT id_registrazione, nome_registrazione, cognome_registrazione, username_registrazione, ruolo_registrazione, data_registrazione
-- FROM registrazioni ORDER BY data_registrazione;

-- SELECT 'Associazioni create:' as info;
-- SELECT ep.*,
--        e.nome_registrazione as nome_educatore, e.cognome_registrazione as cognome_educatore,
--        p.nome_registrazione as nome_paziente, p.cognome_registrazione as cognome_paziente
-- FROM educatori_pazienti ep
-- JOIN registrazioni e ON ep.id_educatore = e.id_registrazione
-- JOIN registrazioni p ON ep.id_paziente = p.id_registrazione;

-- SELECT 'Struttura tabelle:' as info;
-- DESCRIBE registrazioni;
-- DESCRIBE educatori_pazienti;
-- DESCRIBE log_accessi;
-- DESCRIBE sessioni_utente;