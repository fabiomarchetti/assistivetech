-- Script per creare tabelle settori e classi con relazione 1:N
-- Da eseguire nel database MySQL Aruba (Sql1073852_1)
-- IMPORTANTE: Eseguire DOPO cleanup_old_tables.sql

-- Sicurezza: elimina tabelle se esistono (nell'ordine corretto per le foreign key)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS classi;
DROP TABLE IF EXISTS settori;
SET FOREIGN_KEY_CHECKS = 1;

-- Tabella settori (1 settore -> N classi)
CREATE TABLE settori (
    id_settore INT AUTO_INCREMENT PRIMARY KEY,
    nome_settore VARCHAR(100) NOT NULL UNIQUE,
    descrizione TEXT,
    ordine_visualizzazione INT DEFAULT 0,
    stato_settore ENUM('attivo', 'sospeso') DEFAULT 'attivo',
    data_creazione VARCHAR(19) NOT NULL,

    INDEX idx_nome_settore (nome_settore),
    INDEX idx_stato (stato_settore),
    INDEX idx_ordine (ordine_visualizzazione)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella classi (N classi -> 1 settore)
CREATE TABLE classi (
    id_classe INT AUTO_INCREMENT PRIMARY KEY,
    id_settore INT NOT NULL,
    nome_classe VARCHAR(50) NOT NULL,
    descrizione VARCHAR(255),
    ordine_visualizzazione INT DEFAULT 0,
    stato_classe ENUM('attiva', 'sospesa') DEFAULT 'attiva',
    data_creazione VARCHAR(19) NOT NULL,

    INDEX idx_settore (id_settore),
    INDEX idx_nome_classe (nome_classe),
    INDEX idx_stato (stato_classe),
    INDEX idx_ordine (ordine_visualizzazione),

    FOREIGN KEY (id_settore) REFERENCES settori(id_settore) ON DELETE CASCADE,

    UNIQUE KEY unique_classe_settore (id_settore, nome_classe)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inserimento dati iniziali settori - Lega del Filo d'Oro
INSERT INTO settori (nome_settore, descrizione, ordine_visualizzazione, data_creazione) VALUES
('Scolare', 'Settore educativo scolastico', 1, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
('Trattamenti Intensivi', 'Percorsi terapeutici intensivi specializzati', 2, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
('Centro Diagnostico', 'Valutazioni e diagnosi specialistiche', 3, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
('Diurno', 'Servizi diurni di supporto e riabilitazione', 4, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
('Adulti', 'Programmi per utenti adulti', 5, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'));

-- Inserimento classi per settore SCOLARE
INSERT INTO classi (id_settore, nome_classe, ordine_visualizzazione, data_creazione) VALUES
(1, 'Rosa', 1, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(1, 'Mimosa', 2, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'));

-- Inserimento classi per settore TRATTAMENTI INTENSIVI
INSERT INTO classi (id_settore, nome_classe, ordine_visualizzazione, data_creazione) VALUES
(2, 'Viola 1', 1, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(2, 'Viola 2', 2, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(2, 'Lavanda 1', 3, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(2, 'Lavanda 2', 4, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(2, 'Tulipano 1', 5, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(2, 'Tulipano 2', 6, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(2, 'Geraneo 1', 7, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(2, 'Geraneo 2', 8, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'));

-- Inserimento classi per settore CENTRO DIAGNOSTICO
INSERT INTO classi (id_settore, nome_classe, ordine_visualizzazione, data_creazione) VALUES
(3, 'Papavero 1', 1, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(3, 'Papavero 2', 2, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(3, 'Margherita 1', 3, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(3, 'Margherita 2', 4, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(3, 'Primula 1', 5, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(3, 'Primula 2', 6, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(3, 'Girasole 1', 7, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(3, 'Girasole 2', 8, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'));

-- Inserimento classi per settore DIURNO
INSERT INTO classi (id_settore, nome_classe, ordine_visualizzazione, data_creazione) VALUES
(4, 'Diurno 1', 1, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(4, 'Diurno 2', 2, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(4, 'Diurno 3', 3, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'));

-- Inserimento classi per settore ADULTI
INSERT INTO classi (id_settore, nome_classe, ordine_visualizzazione, data_creazione) VALUES
(5, 'AD1 Celeste 1', 1, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD2 Celeste 2', 2, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD3 Celeste 2', 3, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD4 Viola 2', 4, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD5 Viola 1', 5, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD6 Viola 2', 6, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD7 Viola 1', 7, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD8 Celeste 2', 8, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD9 Celeste 1', 9, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD10 Viola 1', 10, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD11 Celeste 1', 11, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s')),
(5, 'AD12 Viola 3', 12, DATE_FORMAT(NOW(), '%d/%m/%Y %H:%i:%s'));

-- Verifica inserimenti
SELECT 'Settori creati:' as info;
SELECT id_settore, nome_settore, descrizione, stato_settore
FROM settori
ORDER BY ordine_visualizzazione;

SELECT 'Classi create per settore:' as info;
SELECT
    s.nome_settore,
    c.nome_classe,
    c.descrizione,
    c.stato_classe
FROM classi c
JOIN settori s ON c.id_settore = s.id_settore
ORDER BY s.ordine_visualizzazione, c.ordine_visualizzazione;

-- Query di esempio per contare classi per settore
SELECT 'Conteggio classi per settore:' as info;
SELECT
    s.nome_settore,
    COUNT(c.id_classe) as numero_classi
FROM settori s
LEFT JOIN classi c ON s.id_settore = c.id_settore
GROUP BY s.id_settore, s.nome_settore
ORDER BY s.ordine_visualizzazione;