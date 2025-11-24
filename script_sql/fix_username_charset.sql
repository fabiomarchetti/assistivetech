-- Fix charset username_registrazione - Risolve il problema di perdita di caratteri
-- Assicura che username sia in UTF8MB4

-- 1. Controlla lo stato attuale
SHOW FULL COLUMNS FROM registrazioni WHERE Field = 'username_registrazione';

-- 2. Ricrea la colonna con charset corretto
ALTER TABLE registrazioni
MODIFY COLUMN username_registrazione VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE;

-- 3. Verifica il risultato
SHOW FULL COLUMNS FROM registrazioni WHERE Field = 'username_registrazione';

-- 4. Opzionale: Converti anche password_registrazione
ALTER TABLE registrazioni
MODIFY COLUMN password_registrazione LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;

-- 5. Verifica
SHOW FULL COLUMNS FROM registrazioni;
