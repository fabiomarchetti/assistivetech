<?php
/**
 * API per upload immagini personalizzate
 * Endpoint: /training_cognitivo/strumenti/sequenze_colori/api/upload_image.php
 */

// Abilita error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0); // Non mostrare a video
ini_set('log_errors', 1);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Cattura tutti gli errori
try {

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(false, 'Metodo non consentito');
}

// Verifica presenza file
if (!isset($_FILES['image'])) {
    jsonResponse(false, 'Nessun file caricato');
}

$file = $_FILES['image'];

// Verifica errori upload
if ($file['error'] !== UPLOAD_ERR_OK) {
    jsonResponse(false, 'Errore durante l\'upload del file');
}

    // Validazione tipo file (fallback se finfo_open non disponibile)
    $allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

    $mime_type = null;

    // Prova con finfo_open (preferito)
    if (function_exists('finfo_open')) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime_type = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);
    }

    // Fallback: controlla estensione e mime type da $_FILES
    $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));

    if (!in_array($extension, $allowed_extensions)) {
        jsonResponse(false, 'Estensione file non consentita. Solo JPG, PNG, GIF, WebP');
    }

    // Verifica mime type se disponibile
    if ($mime_type && !in_array($mime_type, $allowed_types)) {
        jsonResponse(false, 'Tipo file non consentito. Solo immagini JPG, PNG, GIF, WebP');
    }

    // Verifica anche il mime type dichiarato dal browser (meno affidabile ma meglio di niente)
    if (!$mime_type && $file['type'] && !in_array($file['type'], $allowed_types)) {
        jsonResponse(false, 'Tipo file non valido');
    }

// Validazione dimensione (max 5MB)
$max_size = 5 * 1024 * 1024; // 5MB
if ($file['size'] > $max_size) {
    jsonResponse(false, 'File troppo grande. Max 5MB');
}

    // Genera nome file unico (usa l'estensione già estratta sopra)
    // $extension è già definito nella validazione precedente
    if (empty($extension)) {
        jsonResponse(false, 'Estensione file non valida');
    }
    $new_filename = 'img_' . uniqid() . '.' . $extension;

    // Directory upload
    $upload_dir = __DIR__ . '/../assets/images/';
    if (!file_exists($upload_dir)) {
        if (!mkdir($upload_dir, 0755, true)) {
            jsonResponse(false, 'Impossibile creare la directory uploads');
        }
    }

    $destination = $upload_dir . $new_filename;

    // Verifica permessi scrittura
    if (!is_writable($upload_dir)) {
        jsonResponse(false, 'Directory uploads non scrivibile. Controlla i permessi.');
    }

    // Sposta file
    if (!move_uploaded_file($file['tmp_name'], $destination)) {
        jsonResponse(false, 'Errore nel salvataggio del file. Controlla i permessi della directory.');
    }

    // URL relativo
    $url = 'assets/images/' . $new_filename;

    jsonResponse(true, 'File caricato con successo', [
        'filename' => $new_filename,
        'url' => $url,
        'size' => $file['size']
    ]);

} catch (Exception $e) {
    error_log("Upload Error: " . $e->getMessage());
    jsonResponse(false, 'Errore server: ' . $e->getMessage());
} catch (Error $e) {
    error_log("Upload Fatal Error: " . $e->getMessage());
    jsonResponse(false, 'Errore critico: ' . $e->getMessage());
}

