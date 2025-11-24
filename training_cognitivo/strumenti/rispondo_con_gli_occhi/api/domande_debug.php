<?php
/**
 * API per gestione domande Eye Tracking - VERSIONE DEBUG
 * Endpoints: GET, POST, PUT, DELETE
 */

// ABILITA ERRORI PER DEBUG
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Gestione preflight OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// DEBUG: Mostra percorsi
echo json_encode([
    'debug' => true,
    'message' => 'Test percorsi',
    '__DIR__' => __DIR__,
    'DOCUMENT_ROOT' => $_SERVER['DOCUMENT_ROOT'],
    'percorso_relativo' => __DIR__ . '/../../../../api/db_config.php',
    'percorso_assoluto' => $_SERVER['DOCUMENT_ROOT'] . '/api/db_config.php',
    'file_exists_relativo' => file_exists(__DIR__ . '/../../../../api/db_config.php'),
    'file_exists_assoluto' => file_exists($_SERVER['DOCUMENT_ROOT'] . '/api/db_config.php')
]);
exit();


