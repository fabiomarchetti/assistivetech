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

        // Verifica dimensione file (max 2MB per pittogrammi)
        $maxSize = 2 * 1024 * 1024; // 2MB
        if ($fileSize > $maxSize) {
            echo json_encode([
                'success' => false,
                'message' => 'File troppo grande. Dimensione massima: 2MB.'
            ]);
            exit;
        }

        // Estrai informazioni dal nome file se presente
        $fileInfo = pathinfo($fileName);
        $baseName = $fileInfo['filename'];
        $extension = $fileInfo['extension'];

        // Se il nome contiene ID ARASAAC, estrailo
        $arasaacId = null;
        if (preg_match('/_(\d+)$/', $baseName, $matches)) {
            $arasaacId = $matches[1];
            $baseName = preg_replace('/_\d+$/', '', $baseName);
        }

        // Crea nome file sicuro
        $safeName = preg_replace('/[^a-zA-Z0-9._-]/', '_', $baseName);
        $timestamp = time();

        if ($arasaacId) {
            $newFileName = $safeName . '_arasaac_' . $arasaacId . '_' . $timestamp . '.' . $extension;
        } else {
            $newFileName = $safeName . '_' . $timestamp . '.' . $extension;
        }

        // Directory di destinazione per pittogrammi training cognitivo
        $uploadDir = '../training_cognitivo/causa_effetto/accendi_la_luce/assets/images/';

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
            $relativePath = '/training_cognitivo/causa_effetto/accendi_la_luce/assets/images/' . $newFileName;

            // Log dell'operazione
            $logFile = '../logs/pictogram_uploads.log';
            $logDir = dirname($logFile);
            if (!file_exists($logDir)) {
                mkdir($logDir, 0755, true);
            }

            $logEntry = date('Y-m-d H:i:s') . " - Upload pittogramma: $newFileName";
            if ($arasaacId) {
                $logEntry .= " (ARASAAC ID: $arasaacId)";
            }
            $logEntry .= " - IP: " . ($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown') . "\n";
            file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);

            echo json_encode([
                'success' => true,
                'message' => 'Pittogramma caricato con successo',
                'filename' => $newFileName,
                'path' => $relativePath,
                'arasaac_id' => $arasaacId,
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