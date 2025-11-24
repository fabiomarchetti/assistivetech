<?php
/**
 * CONFIGURAZIONE DATABASE PRODUZIONE ARUBA
 * Connessione diretta al database MySQL Aruba per AssistiveTech
 */

class DatabaseConfig {
    // Configurazione fissa per produzione Aruba
    private static $config = [
        'environment' => 'production',
        'host' => '31.11.39.242',
        'username' => 'Sql1073852',
        'password' => '5k58326940',
        'database' => 'Sql1073852_1',
        'port' => 3306,
        'charset' => 'utf8mb4',
        'description' => 'Database MySQL Aruba - AssistiveTech Produzione'
    ];

    /**
     * Restituisce la configurazione database
     */
    public static function getConfig() {
        return self::$config;
    }

    /**
     * Crea connessione PDO al database Aruba
     */
    public static function createConnection() {
        $config = self::$config;

        try {
            $dsn = "mysql:host={$config['host']};dbname={$config['database']};charset={$config['charset']}";
            $pdo = new PDO($dsn, $config['username'], $config['password']);
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
            return $pdo;
        } catch (PDOException $e) {
            throw new Exception("Errore connessione database Aruba: " . $e->getMessage());
        }
    }

    /**
     * Restituisce informazioni debug database
     */
    public static function getDebugInfo() {
        return [
            'environment' => self::$config['environment'],
            'description' => self::$config['description'],
            'database_info' => [
                'host' => self::$config['host'],
                'database' => self::$config['database'],
                'username' => self::$config['username'],
                'charset' => self::$config['charset']
            ],
            'timestamp' => date('d/m/Y H:i:s')
        ];
    }
}

// Se chiamato direttamente, mostra info debug
if (basename(__FILE__) === basename($_SERVER['SCRIPT_NAME'])) {
    header('Content-Type: application/json');
    echo json_encode(DatabaseConfig::getDebugInfo(), JSON_PRETTY_PRINT);
}
?>