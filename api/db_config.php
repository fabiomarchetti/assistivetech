<?php
/**
 * Database Config per API mysqli
 * Wrapper compatibile con config.php esistente
 */

// Includi configurazione principale
require_once __DIR__ . '/config.php';

/**
 * Funzione per ottenere connessione MySQLi
 * Compatibile con le API che usano mysqli invece di PDO
 * 
 * @return mysqli Connessione database
 * @throws Exception se la connessione fallisce
 */
function getDbConnectionMySQLi() {
    // Usa le variabili globali da config.php
    global $host, $username, $password, $database, $port;
    
    // Crea connessione mysqli
    $conn = new mysqli($host, $username, $password, $database, $port);
    
    // Verifica errori connessione
    if ($conn->connect_error) {
        if (defined('DEBUG_MODE') && DEBUG_MODE) {
            error_log("Errore connessione MySQLi: " . $conn->connect_error);
            die(json_encode([
                'success' => false,
                'error' => 'Errore connessione database: ' . $conn->connect_error
            ]));
        } else {
            die(json_encode([
                'success' => false,
                'error' => 'Errore temporaneo del servizio. Riprova più tardi.'
            ]));
        }
    }
    
    // Imposta charset UTF-8
    $conn->set_charset("utf8mb4");
    
    return $conn;
}

// NOTA: Esporta la funzione MySQLi con alias diverso per evitare conflitti
// Le API possono chiamare getDbConnectionMySQLi() per ottenere una connessione mysqli

?>

