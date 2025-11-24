-- ============================================
-- Fix tabella categorie_esercizi
-- Aggiunge AUTO_INCREMENT a id_categoria
-- ============================================
-- Eseguire su ENTRAMBI i computer (Mac e Windows)
-- Data: 2025-11-16
-- ============================================

-- Fix campo id_categoria con AUTO_INCREMENT
ALTER TABLE `categorie_esercizi`
MODIFY `id_categoria` INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- Verifica struttura
DESCRIBE `categorie_esercizi`;

-- ============================================
-- NOTA: Questo fix è necessario perché il database
-- importato non aveva AUTO_INCREMENT sul campo id_categoria
-- ============================================
