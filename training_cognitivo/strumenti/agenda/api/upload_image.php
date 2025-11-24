<?php
/**
 * API per upload immagini
 * Endpoint: /Assistivetech/training_cognitivo/strumenti/agenda/api/upload_image.php
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

/**
 * Risposta JSON standardizzata
 */
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(false, 'Metodo non consentito');
}

try {
    // Directory upload
    $upload_dir = __DIR__ . '/../assets/images/';

    // Verifica e crea la directory se necessario
    if (!is_dir($upload_dir)) {
        if (!mkdir($upload_dir, 0755, true)) {
            jsonResponse(false, 'Errore: impossibile creare la cartella di upload. Contatta l\'amministratore.');
        }
    }

    // Verifica permessi di scrittura
    if (!is_writable($upload_dir)) {
        jsonResponse(false, 'Errore: la cartella di upload non è scrivibile. Contatta l\'amministratore.');
    }

    // Controlla se è upload file o base64
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        // Upload tradizionale da form
        $file = $_FILES['image'];

        // Validazione dimensione (max 5MB)
        if ($file['size'] > 5 * 1024 * 1024) {
            jsonResponse(false, 'File troppo grande (max 5MB)');
        }

        // Validazione estensione file
        $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

        if (!in_array($extension, $allowed_extensions)) {
            jsonResponse(false, 'Tipo file non consentito. Sono ammessi: ' . implode(', ', $allowed_extensions));
        }

        // Validazione tipo MIME (se disponibile)
        if (function_exists('finfo_file')) {
            $finfo = finfo_open(FILEINFO_MIME_TYPE);
            if ($finfo) {
                $mime_type = finfo_file($finfo, $file['tmp_name']);
                finfo_close($finfo);

                $allowed_mimes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
                if (!in_array($mime_type, $allowed_mimes)) {
                    jsonResponse(false, 'Tipo MIME non consentito: ' . $mime_type);
                }
            }
        }

        // Genera nome univoco
        $filename = uniqid('img_', true) . '.' . $extension;
        $filepath = $upload_dir . $filename;

        // Sposta file
        if (!move_uploaded_file($file['tmp_name'], $filepath)) {
            jsonResponse(false, 'Errore durante lo spostamento del file. Verifica i permessi della cartella.');
        }

        // Verifica che il file sia stato creato
        if (!file_exists($filepath)) {
            jsonResponse(false, 'File caricato ma non trovato nel percorso di destinazione.');
        }

        // Path relativo per il database
        $relative_path = '/Assistivetech/training_cognitivo/strumenti/agenda/assets/images/' . $filename;

        jsonResponse(true, 'Immagine caricata con successo', [
            'filename' => $filename,
            'url' => $relative_path,
            'size' => $file['size']
        ]);

    } elseif (isset($_POST['image_base64'])) {
        // Upload base64 (per web app)
        $base64_data = $_POST['image_base64'];

        // Rimuovi header data:image/xxx;base64, se presente
        if (preg_match('/^data:image\/(\w+);base64,/', $base64_data, $matches)) {
            $extension = $matches[1];
            $base64_data = substr($base64_data, strpos($base64_data, ',') + 1);
        } else {
            $extension = 'png'; // default
        }

        // Decodifica
        $image_data = base64_decode($base64_data);

        if ($image_data === false) {
            jsonResponse(false, 'Dati base64 non validi');
        }

        // Validazione dimensione
        if (strlen($image_data) > 5 * 1024 * 1024) {
            jsonResponse(false, 'Immagine troppo grande (max 5MB)');
        }

        // Genera nome univoco
        $filename = uniqid('img_', true) . '.' . $extension;
        $filepath = $upload_dir . $filename;

        // Salva file
        if (file_put_contents($filepath, $image_data) === false) {
            jsonResponse(false, 'Errore durante il salvataggio');
        }

        // Path relativo
        $relative_path = '/Assistivetech/training_cognitivo/strumenti/agenda/assets/images/' . $filename;

        jsonResponse(true, 'Immagine caricata con successo', [
            'filename' => $filename,
            'url' => $relative_path,
            'size' => strlen($image_data)
        ]);

    } else {
        jsonResponse(false, 'Nessuna immagine fornita');
    }

} catch (Exception $e) {
    error_log("Errore upload_image.php: " . $e->getMessage());
    jsonResponse(false, 'Errore durante l\'upload: ' . $e->getMessage());
} catch (Throwable $e) {
    error_log("Errore fatale upload_image.php: " . $e->getMessage());
    jsonResponse(false, 'Errore fatale durante l\'upload');
}
