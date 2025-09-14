<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Verifica che sia stato inviato un file
        if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
            echo json_encode([
                'success' => false,
                'message' => 'Nessun file ricevuto o errore durante l\'upload'
            ]);
            exit;
        }

        $uploadedFile = $_FILES['image'];
        $fileName = $uploadedFile['name'];
        $tmpName = $uploadedFile['tmp_name'];
        $fileSize = $uploadedFile['size'];
        $fileType = $uploadedFile['type'];

        // Verifica che sia un'immagine
        $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
        if (!in_array($fileType, $allowedTypes)) {
            echo json_encode([
                'success' => false,
                'message' => 'Tipo di file non supportato. Usa JPG, PNG, GIF o WebP.'
            ]);
            exit;
        }

        // Verifica dimensione file (max 5MB)
        $maxSize = 5 * 1024 * 1024; // 5MB
        if ($fileSize > $maxSize) {
            echo json_encode([
                'success' => false,
                'message' => 'File troppo grande. Dimensione massima: 5MB.'
            ]);
            exit;
        }

        // Crea nome file sicuro con timestamp
        $fileExtension = pathinfo($fileName, PATHINFO_EXTENSION);
        $safeName = preg_replace('/[^a-zA-Z0-9._-]/', '_', pathinfo($fileName, PATHINFO_FILENAME));
        $timestamp = time();
        $newFileName = $safeName . '_' . $timestamp . '.' . $fileExtension;

        // Directory di destinazione
        $uploadDir = '../assets/images/';
        
        // Crea la directory se non esiste
        if (!is_dir($uploadDir)) {
            if (!mkdir($uploadDir, 0755, true)) {
                echo json_encode([
                    'success' => false,
                    'message' => 'Impossibile creare la directory di upload'
                ]);
                exit;
            }
        }

        $targetPath = $uploadDir . $newFileName;

        // Sposta il file caricato
        if (move_uploaded_file($tmpName, $targetPath)) {
            // Restituisce il path relativo per l'applicazione
            $relativePath = '/agenda/assets/images/' . $newFileName;
            
            echo json_encode([
                'success' => true,
                'message' => 'File caricato con successo',
                'filename' => $newFileName,
                'path' => $relativePath,
                'size' => $fileSize,
                'type' => $fileType
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Errore durante il salvataggio del file'
            ]);
        }

    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Errore del server: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Metodo non supportato. Usa POST.'
    ]);
}
?>