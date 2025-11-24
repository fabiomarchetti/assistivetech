-- ============================================================================
-- Script: Creazione tabella agende_items
-- Descrizione: Tabella per gestire item dentro le agende (semplici, link, video)
-- Data: 2025-10-28
-- ============================================================================

-- Creazione tabella agende_items
CREATE TABLE IF NOT EXISTS agende_items (
    id_item INT PRIMARY KEY AUTO_INCREMENT,
    id_agenda INT NOT NULL,
    tipo_item ENUM('semplice', 'link_agenda', 'video_youtube') NOT NULL,
    titolo VARCHAR(255) NOT NULL,
    posizione INT NOT NULL DEFAULT 0 COMMENT 'Ordinamento drag&drop',

    -- Per item semplici e link agenda
    tipo_immagine ENUM('arasaac', 'upload', 'nessuna') DEFAULT 'nessuna',
    id_arasaac INT NULL COMMENT 'ID pittogramma ARASAAC',
    url_immagine VARCHAR(500) NULL COMMENT 'Path immagine uploadata',

    -- Per link ad altra agenda
    id_agenda_collegata INT NULL COMMENT 'ID agenda da aprire con longclick',

    -- Per video YouTube
    video_youtube_id VARCHAR(50) NULL COMMENT 'ID video YouTube (es: dQw4w9WgXcQ)',
    video_youtube_title VARCHAR(255) NULL,
    video_youtube_thumbnail VARCHAR(500) NULL,

    data_creazione VARCHAR(19),
    stato ENUM('attivo', 'archiviato') DEFAULT 'attivo',

    -- Foreign Keys
    FOREIGN KEY (id_agenda) REFERENCES agende_strumenti(id_agenda) ON DELETE CASCADE,
    FOREIGN KEY (id_agenda_collegata) REFERENCES agende_strumenti(id_agenda) ON DELETE SET NULL,

    -- Indici per performance
    INDEX idx_agenda (id_agenda),
    INDEX idx_posizione (id_agenda, posizione),
    INDEX idx_tipo (tipo_item),
    INDEX idx_stato (stato),
    INDEX idx_agenda_collegata (id_agenda_collegata)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Log creazione
INSERT INTO log_operazioni (operazione, descrizione, data_operazione)
VALUES ('CREATE_TABLE', 'Creata tabella agende_items', NOW())
ON DUPLICATE KEY UPDATE data_operazione = NOW();
