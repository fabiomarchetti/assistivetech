<?php
/**
 * Configurazione Database Multi-Ambiente
 * Auto-rileva ambiente (locale vs produzione) e usa credenziali corrette
 *
 * IMPORTANTE: Questo file funziona sia in locale (MAMP) che su Aruba (FTP)
 * Non modificare manualmente - tutto è automatico!
 */

// Rileva ambiente basandosi sull'host
$current_host = $_SERVER['HTTP_HOST'] ?? 'localhost';
$is_local = (
    strpos($current_host, 'localhost') !== false ||
    strpos($current_host, '127.0.0.1') !== false ||
    strpos($current_host, '192.168.') !== false ||
    strpos($current_host, '10.0.') !== false
);

// ==========================================
// 🔧 MODALITÀ SVILUPPO: Scegli una delle due opzioni
// ==========================================
// Opzione 1: USA_DB_LOCALE = true   → Database locale MAMP (sviluppo isolato)
// Opzione 2: USA_DB_LOCALE = false  → Database cloud Aruba (sviluppo con dati reali)
define('USA_DB_LOCALE', true); // 👈 CAMBIA QUI: true=locale, false=cloud

if ($is_local) {
    if (USA_DB_LOCALE) {
        // ==========================================
        // CONFIGURAZIONE LOCALE (MAMP) - DATABASE LOCALE
        // ==========================================
        $host = 'localhost';
        $username = 'root';
        $password = 'root';
        $database = 'assistivetech_local';
        $port = 3306; // MAMP su porta standard MySQL

        // Debug mode attivo in locale
        define('DEBUG_MODE', true);
        error_reporting(E_ALL);
        ini_set('display_errors', 1);

        // Base path per URL assoluti in locale MAMP
        define('BASE_PATH', '/Assistivetech'); // MAMP: necessario per routing corretto

    } else {
        // ==========================================
        // CONFIGURAZIONE LOCALE (MAMP) - DATABASE CLOUD ARUBA
        // ==========================================
        $host = '31.11.39.242';
        $username = 'Sql1073852';
        $password = '5k58326940';
        $database = 'Sql1073852_1';
        $port = 3306;

        // Debug mode attivo in locale
        define('DEBUG_MODE', true);
        error_reporting(E_ALL);
        ini_set('display_errors', 1);

        // Base path per URL assoluti in locale MAMP
        define('BASE_PATH', '/Assistivetech'); // MAMP: necessario per routing corretto
    }

} else {
    // ==========================================
    // CONFIGURAZIONE PRODUZIONE (ARUBA)
    // ==========================================
    $host = '31.11.39.242';
    $username = 'Sql1073852';
    $password = '5k58326940';
    $database = 'Sql1073852_1';
    $port = 3306;

    // Debug mode disattivato in produzione
    define('DEBUG_MODE', false);
    error_reporting(0);
    ini_set('display_errors', 0);

    // In produzione il sito è in root
    define('BASE_PATH', '');
}

// Permetti override tramite file locale (non versionato) se presente
// Il file può ridefinire: $host, $username, $password, $database, $port
// e opzionalmente definire APP_TZ
if (file_exists(__DIR__ . '/config.override.php')) {
    /** @noinspection PhpIncludeInspection */
    require __DIR__ . '/config.override.php';
}

// DSN per PDO
// Usa sempre porta esplicita per compatibilità
$dsn = "mysql:host=$host;port=$port;dbname=$database;charset=utf8mb4";

// Timezone applicativo (default Europe/Rome) – può essere impostato via env o override
$__appTz = getenv('APP_TZ') ?: (defined('APP_TZ') ? APP_TZ : 'Europe/Rome');
@date_default_timezone_set($__appTz);

// Log ambiente rilevato (solo in debug)
if (DEBUG_MODE) {
    error_log("AssistiveTech - Ambiente rilevato: " . ($is_local ? "LOCALE" : "PRODUZIONE"));
    error_log("AssistiveTech - Host: $current_host");
    error_log("AssistiveTech - Database: $database @ $host:$port");
}

/**
 * Funzione helper per creare connessione PDO
 * Uso: $pdo = getDbConnection();
 */
function getDbConnection() {
    global $dsn, $username, $password;

    try {
        $pdo = new PDO($dsn, $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

        return $pdo;
    } catch (PDOException $e) {
        if (DEBUG_MODE) {
            error_log("AssistiveTech - Errore connessione DB: " . $e->getMessage());
            die(json_encode([
                'success' => false,
                'message' => 'Errore connessione database',
                'debug' => $e->getMessage()
            ]));
        } else {
            die(json_encode([
                'success' => false,
                'message' => 'Errore temporaneo del servizio. Riprova più tardi.'
            ]));
        }
    }
}

// Export variabili per backward compatibility con codice esistente
// Così i file API che usano $host, $username, etc. continuano a funzionare
?>
