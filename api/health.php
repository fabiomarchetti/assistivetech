<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

// Config centralizzato (auto locale/produzione) + timezone
require_once __DIR__ . '/config.php';

$status = [
  'success' => true,
  'app' => 'AssistiveTech',
  'env' => ($_SERVER['HTTP_HOST'] ?? 'local'),
  'timezone' => date_default_timezone_get(),
  'time' => date('Y-m-d H:i:s'),
  'db' => [ 'connected' => false ],
];

try {
  $pdo = getDbConnection();
  $stmt = $pdo->query('SELECT 1 AS ok');
  $row = $stmt->fetch();
  $status['db'] = [
    'connected' => true,
    'ping' => isset($row['ok']) ? (int)$row['ok'] === 1 : false,
  ];
} catch (Throwable $e) {
  $status['success'] = false;
  $status['db'] = [ 'connected' => false, 'error' => $e->getMessage() ];
}

echo json_encode($status, JSON_UNESCAPED_UNICODE);
exit;
?>



