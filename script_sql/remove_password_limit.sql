-- Rimuove il limite di caratteri per le password
-- Cambia password_registrazione da VARCHAR(255) a LONGTEXT

ALTER TABLE registrazioni
MODIFY COLUMN password_registrazione LONGTEXT NOT NULL;

-- Verifica la modifica
SHOW COLUMNS FROM registrazioni WHERE Field = 'password_registrazione';
