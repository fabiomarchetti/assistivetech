<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Salva i dati JSON
    $input = json_decode(file_get_contents('php://input'), true);
    
    if ($input !== null) {
        $dataFile = '../assets/data.json';
        
        // Crea la directory se non esiste
        $dir = dirname($dataFile);
        if (!is_dir($dir)) {
            mkdir($dir, 0755, true);
        }
        
        // Salva i dati
        if (file_put_contents($dataFile, json_encode($input, JSON_PRETTY_PRINT))) {
            echo json_encode([
                'success' => true,
                'message' => 'Data saved successfully'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to save data'
            ]);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid JSON data'
        ]);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Carica i dati JSON
    $dataFile = '../assets/data.json';
    
    if (file_exists($dataFile)) {
        $data = file_get_contents($dataFile);
        echo $data;
    } else {
        echo json_encode([
            'users' => [],
            'agendas' => [],
            'activities' => []
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
}
?>