<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Gestione richieste OPTIONS per CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurazione database automatica (locale/produzione)
require_once __DIR__ . '/config.php';

// Funzione per rispondere con JSON
function jsonResponse($success, $message = '', $data = null) {
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Normalizza link categoria per ambiente corrente
function normalizeLink($link) {
    $base = defined('BASE_PATH') ? BASE_PATH : '';
    if ($base === '' || $link === null || $link === '') {
        return $link;
    }
    if (strpos($link, $base . '/') === 0) {
        return $link;
    }
    if (strpos($link, '/training_cognitivo/') === 0) {
        return $base . $link;
    }
    return $link;
}

// Funzione per log delle operazioni
function logOperation($action, $details, $ip) {
    $logFile = '../logs/categorie_esercizi.log';
    $logDir = dirname($logFile);

    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $action - $details - IP: $ip\n";

    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);
}

// Funzione per creare template index.html per categoria
function createCategoryIndexTemplate($nome_categoria, $id_categoria) {
    return <<<HTML
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$nome_categoria - Training Cognitivo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .category-header {
            background: linear-gradient(135deg, #673AB7, #9C27B0);
            color: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
        }
        .exercise-card {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .exercise-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .exercise-link {
            text-decoration: none;
            color: inherit;
        }
        .exercise-link:hover {
            color: inherit;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <!-- Header Categoria -->
        <div class="category-header">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="mb-1">
                        <i class="bi bi-bookmark-star"></i> $nome_categoria
                    </h1>
                    <p class="mb-0">Esercizi di training cognitivo</p>
                </div>
                <div class="col-md-4 text-md-end">
                    <a href="../" class="btn btn-light">
                        <i class="bi bi-arrow-left"></i> Torna alle Categorie
                    </a>
                </div>
            </div>
        </div>

        <!-- Contenuto Esercizi -->
        <div id="exercises-container">
            <div class="text-center">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Caricamento esercizi...</span>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const CATEGORY_ID = $id_categoria;

        async function loadExercises() {
            try {
                const response = await fetch(`../../api/api_esercizi.php?action=get_esercizi&id_categoria=\${CATEGORY_ID}`);
                const result = await response.json();

                const container = document.getElementById('exercises-container');

                if (result.success && result.data && result.data.length > 0) {
                    container.innerHTML = `
                        <div class="row">
                            \${result.data.map(exercise => `
                                <div class="col-md-6 col-lg-4 mb-4">
                                    <a href="\${exercise.link || '#'}" class="exercise-link">
                                        <div class="exercise-card p-4 h-100">
                                            <div class="text-center mb-3">
                                                <i class="bi bi-puzzle display-4 text-primary"></i>
                                            </div>
                                            <h5 class="card-title text-center mb-3">\${exercise.nome_esercizio}</h5>
                                            <p class="card-text text-muted">\${exercise.descrizione_esercizio.substring(0, 100)}\${exercise.descrizione_esercizio.length > 100 ? '...' : ''}</p>
                                            <div class="text-center mt-3">
                                                <span class="badge bg-\${getStatusColor(exercise.stato_esercizio)}">\${exercise.stato_esercizio}</span>
                                            </div>
                                        </div>
                                    </a>
                                </div>
                            `).join('')}
                        </div>
                    `;
                } else {
                    container.innerHTML = `
                        <div class="text-center py-5">
                            <i class="bi bi-puzzle display-1 text-muted"></i>
                            <h3 class="mt-3 text-muted">Nessun esercizio disponibile</h3>
                            <p class="text-muted">Gli esercizi per questa categoria verranno aggiunti presto.</p>
                        </div>
                    `;
                }
            } catch (error) {
                document.getElementById('exercises-container').innerHTML = `
                    <div class="alert alert-danger text-center">
                        <i class="bi bi-exclamation-triangle"></i>
                        Errore nel caricamento degli esercizi
                    </div>
                `;
            }
        }

        function getStatusColor(status) {
            switch(status) {
                case 'attivo': return 'success';
                case 'sospeso': return 'warning';
                case 'archiviato': return 'secondary';
                default: return 'secondary';
            }
        }

        // Carica esercizi al caricamento della pagina
        document.addEventListener('DOMContentLoaded', loadExercises);
    </script>
</body>
</html>
HTML;
}

try {
    // Connessione al database (auto ambiente)
    $pdo = getDbConnection();

    // Leggi i dati JSON dalla richiesta (gestisci body vuoto)
    $rawBody = file_get_contents('php://input');
    $input = json_decode($rawBody ?: '[]', true);
    $action = $input['action'] ?? $_GET['action'] ?? '';
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    // ===================== GESTIONE CATEGORIE ESERCIZI =====================
    if ($action === 'get_categorie') {
        // Recupera tutte le categorie esercizi
        $stmt = $pdo->prepare("
            SELECT
                id_categoria,
                nome_categoria,
                descrizione_categoria,
                note_categoria,
                link
            FROM categorie_esercizi
            ORDER BY nome_categoria ASC
        ");
        $stmt->execute();
        $categorie = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($categorie as &$row) {
            if (isset($row['link'])) {
                $row['link'] = normalizeLink($row['link']);
            }
        }
        unset($row);

        jsonResponse(true, 'Categorie recuperate con successo', $categorie);

    } elseif ($action === 'get_categoria') {
        // Recupera una categoria specifica per ID
        $id_categoria = intval($input['id'] ?? $_GET['id'] ?? 0);

        if ($id_categoria <= 0) {
            jsonResponse(false, 'ID categoria non valido');
        }

        $stmt = $pdo->prepare("
            SELECT
                id_categoria,
                nome_categoria,
                descrizione_categoria,
                note_categoria,
                link
            FROM categorie_esercizi
            WHERE id_categoria = :id
        ");
        $stmt->execute([':id' => $id_categoria]);
        $categoria = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($categoria && isset($categoria['link'])) {
            $categoria['link'] = normalizeLink($categoria['link']);
        }

        if ($categoria) {
            jsonResponse(true, 'Categoria recuperata con successo', $categoria);
        } else {
            jsonResponse(false, 'Categoria non trovata');
        }

    } elseif ($action === 'create_categoria') {
        // Crea nuova categoria esercizio
        $nome_categoria = trim($input['nome_categoria'] ?? '');
        $descrizione_categoria = trim($input['descrizione_categoria'] ?? '');
        $note_categoria = trim($input['note_categoria'] ?? '');

        if (empty($nome_categoria)) {
            jsonResponse(false, 'Nome categoria è obbligatorio');
        }

        if (empty($descrizione_categoria)) {
            jsonResponse(false, 'Descrizione categoria è obbligatoria');
        }

        // Verifica se la categoria esiste già
        $stmt_check = $pdo->prepare("SELECT COUNT(*) as count FROM categorie_esercizi WHERE nome_categoria = :nome");
        $stmt_check->execute([':nome' => $nome_categoria]);
        $exists = $stmt_check->fetch(PDO::FETCH_ASSOC);

        if ($exists['count'] > 0) {
            jsonResponse(false, 'Una categoria con questo nome esiste già nel sistema');
        }

        // Genera percorso e link automatici
        $nome_cartella = strtolower(str_replace([' ', 'à', 'è', 'é', 'ì', 'ò', 'ù', 'ç'], ['_', 'a', 'e', 'e', 'i', 'o', 'u', 'c'], $nome_categoria));
        $nome_cartella = preg_replace('/[^a-z0-9_]/', '', $nome_cartella); // Solo caratteri alfanumerici e underscore
        $base = defined('BASE_PATH') ? BASE_PATH : '';
        $link_categoria = "$base/training_cognitivo/$nome_cartella/";
        $percorso_cartella = "../training_cognitivo/$nome_cartella";

        // Inserisci nuova categoria con link
        $stmt = $pdo->prepare("
            INSERT INTO categorie_esercizi (nome_categoria, descrizione_categoria, note_categoria, link)
            VALUES (:nome, :descrizione, :note, :link)
        ");
        $result = $stmt->execute([
            ':nome' => $nome_categoria,
            ':descrizione' => $descrizione_categoria,
            ':note' => $note_categoria,
            ':link' => $link_categoria
        ]);

        if ($result) {
            $new_id = $pdo->lastInsertId();

            // Crea automaticamente la cartella per la categoria
            if (!file_exists($percorso_cartella)) {
                if (!file_exists('../training_cognitivo')) {
                    mkdir('../training_cognitivo', 0775, true);
                    chmod('../training_cognitivo', 0775);
                }
                mkdir($percorso_cartella, 0775, true);
                chmod($percorso_cartella, 0775);

                // Crea file index.html di base per la categoria
                $index_content = createCategoryIndexTemplate($nome_categoria, $new_id);
                file_put_contents("$percorso_cartella/index.html", $index_content);
                chmod("$percorso_cartella/index.html", 0664);
            }

            logOperation('CREATE_CATEGORIA', "Nome: $nome_categoria, ID: $new_id, Cartella: $percorso_cartella", $ip);
            jsonResponse(true, 'Categoria creata con successo', [
                'id_categoria' => $new_id,
                'nome_categoria' => $nome_categoria,
                'link' => $link_categoria,
                'cartella_creata' => file_exists($percorso_cartella)
            ]);
        } else {
            jsonResponse(false, 'Errore nella creazione della categoria');
        }

    } elseif ($action === 'update_categoria') {
        // Aggiorna categoria esistente
        $id_categoria = intval($input['id_categoria'] ?? 0);
        $nome_categoria = trim($input['nome_categoria'] ?? '');
        $descrizione_categoria = trim($input['descrizione_categoria'] ?? '');
        $note_categoria = trim($input['note_categoria'] ?? '');

        if ($id_categoria <= 0) {
            jsonResponse(false, 'ID categoria non valido');
        }

        if (empty($nome_categoria)) {
            jsonResponse(false, 'Nome categoria è obbligatorio');
        }

        if (empty($descrizione_categoria)) {
            jsonResponse(false, 'Descrizione categoria è obbligatoria');
        }

        // Verifica se la categoria esiste
        $stmt_exists = $pdo->prepare("SELECT COUNT(*) as count FROM categorie_esercizi WHERE id_categoria = :id");
        $stmt_exists->execute([':id' => $id_categoria]);
        $exists = $stmt_exists->fetch(PDO::FETCH_ASSOC);

        if ($exists['count'] == 0) {
            jsonResponse(false, 'Categoria non trovata');
        }

        // Verifica se il nome è già utilizzato da un'altra categoria
        $stmt_check_name = $pdo->prepare("SELECT COUNT(*) as count FROM categorie_esercizi WHERE nome_categoria = :nome AND id_categoria != :id");
        $stmt_check_name->execute([':nome' => $nome_categoria, ':id' => $id_categoria]);
        $name_exists = $stmt_check_name->fetch(PDO::FETCH_ASSOC);

        if ($name_exists['count'] > 0) {
            jsonResponse(false, 'Una categoria con questo nome esiste già nel sistema');
        }

        // Aggiorna categoria
        $stmt = $pdo->prepare("
            UPDATE categorie_esercizi
            SET nome_categoria = :nome,
                descrizione_categoria = :descrizione,
                note_categoria = :note
            WHERE id_categoria = :id
        ");
        $result = $stmt->execute([
            ':nome' => $nome_categoria,
            ':descrizione' => $descrizione_categoria,
            ':note' => $note_categoria,
            ':id' => $id_categoria
        ]);

        if ($result) {
            logOperation('UPDATE_CATEGORIA', "ID: $id_categoria, Nome: $nome_categoria", $ip);
            jsonResponse(true, 'Categoria aggiornata con successo', ['id_categoria' => $id_categoria, 'nome_categoria' => $nome_categoria]);
        } else {
            jsonResponse(false, 'Errore nell\'aggiornamento della categoria');
        }

    } elseif ($action === 'delete_categoria') {
        // Elimina categoria (solo se non è utilizzata)
        $id_categoria = intval($input['id_categoria'] ?? 0);

        if ($id_categoria <= 0) {
            jsonResponse(false, 'ID categoria non valido');
        }

        // Verifica se la categoria esiste
        $stmt_exists = $pdo->prepare("SELECT nome_categoria FROM categorie_esercizi WHERE id_categoria = :id");
        $stmt_exists->execute([':id' => $id_categoria]);
        $categoria = $stmt_exists->fetch(PDO::FETCH_ASSOC);

        if (!$categoria) {
            jsonResponse(false, 'Categoria non trovata');
        }

        // TODO: Verifica se la categoria è utilizzata in tabelle esercizi (quando saranno create)
        // Per ora eliminiamo direttamente dato che la tabella esercizi non esiste ancora

        // Elimina categoria
        $stmt = $pdo->prepare("DELETE FROM categorie_esercizi WHERE id_categoria = :id");
        $result = $stmt->execute([':id' => $id_categoria]);

        if ($result) {
            logOperation('DELETE_CATEGORIA', "ID: $id_categoria, Nome: {$categoria['nome_categoria']}", $ip);
            jsonResponse(true, 'Categoria eliminata con successo');
        } else {
            jsonResponse(false, 'Errore nell\'eliminazione della categoria');
        }

    // ===================== STATISTICHE =====================
    } elseif ($action === 'get_statistics') {
        // Recupera statistiche sulle categorie
        $stmt_count = $pdo->prepare("SELECT COUNT(*) as totale_categorie FROM categorie_esercizi");
        $stmt_count->execute();
        $stats = $stmt_count->fetch(PDO::FETCH_ASSOC);

        // TODO: Aggiungere statistiche utilizzo quando saranno create le tabelle esercizi

        jsonResponse(true, 'Statistiche recuperate con successo', [
            'totale_categorie' => $stats['totale_categorie'],
            'utilizzo_esercizi' => 0  // Placeholder per future implementazioni
        ]);

    } else {
        jsonResponse(false, 'Azione non riconosciuta');
    }

} catch (PDOException $e) {
    error_log("Errore database in api_categorie_esercizi.php: " . $e->getMessage());
    $msg = 'Errore temporaneo del servizio. Riprova più tardi.';
    if (defined('DEBUG_MODE') && DEBUG_MODE) {
        $msg .= ' | DEBUG: ' . $e->getMessage();
    }
    jsonResponse(false, $msg);
} catch (Exception $e) {
    error_log("Errore generale in api_categorie_esercizi.php: " . $e->getMessage());
    $msg = 'Errore del server. Riprova più tardi.';
    if (defined('DEBUG_MODE') && DEBUG_MODE) {
        $msg .= ' | DEBUG: ' . $e->getMessage();
    }
    jsonResponse(false, $msg);
}
?>