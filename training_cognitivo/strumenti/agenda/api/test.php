<?php
header('Content-Type: application/json; charset=utf-8');
echo json_encode([
    'success' => true,
    'message' => 'Test API funziona',
    'request_method' => $_SERVER['REQUEST_METHOD'],
    'server_document_root' => $_SERVER['DOCUMENT_ROOT'],
    'server_script_filename' => $_SERVER['SCRIPT_FILENAME'],
    'request_uri' => $_SERVER['REQUEST_URI'],
    'php_info' => phpversion()
]);
?>
