<?php
/**
 * Script per inserire la categoria "Scrivi" e l'esercizio "scrivi_parole"
 * nel database del sistema Training Cognitivo
 *
 * Eseguire questo script UNA VOLTA per popolare il database
 */

header('Content-Type: application/json; charset=utf-8');

// Configurazione database centralizzata (auto locale/produzione)
require_once __DIR__ . '/config.php';

try {
    // Connessione al database
    $pdo = getDbConnection();

    echo "✓ Connessione al database riuscita\n\n";

    // ====================
    // STEP 1: Verifica se la categoria "Scrivi" esiste già
    // ====================
    $stmt_check_categoria = $pdo->prepare("SELECT id_categoria FROM categorie_esercizi WHERE nome_categoria = :nome");
    $stmt_check_categoria->execute([':nome' => 'Scrivi']);
    $categoria_esistente = $stmt_check_categoria->fetch(PDO::FETCH_ASSOC);

    if ($categoria_esistente) {
        echo "⚠️  La categoria 'Scrivi' esiste già con ID: {$categoria_esistente['id_categoria']}\n";
        $id_categoria = $categoria_esistente['id_categoria'];
    } else {
        // ====================
        // STEP 2: Inserisci categoria "Scrivi"
        // ====================
        $stmt_categoria = $pdo->prepare("
            INSERT INTO categorie_esercizi (nome_categoria, descrizione_categoria, note_categoria, link)
            VALUES (:nome, :descrizione, :note, :link)
        ");

        $result_categoria = $stmt_categoria->execute([
            ':nome' => 'Scrivi',
            ':descrizione' => 'Esercizi di scrittura con sillabe e composizione parole utilizzando pittogrammi ARASAAC',
            ':note' => 'Categoria dedicata all\'apprendimento della scrittura attraverso la composizione di parole con sillabe',
            ':link' => '/training_cognitivo/scrivi/'
        ]);

        if ($result_categoria) {
            $id_categoria = $pdo->lastInsertId();
            echo "✓ Categoria 'Scrivi' creata con successo (ID: $id_categoria)\n";
        } else {
            throw new Exception("Errore nella creazione della categoria");
        }
    }

    // ====================
    // STEP 3: Verifica se l'esercizio "scrivi_parole" esiste già
    // ====================
    $stmt_check_esercizio = $pdo->prepare("
        SELECT id_esercizio FROM esercizi
        WHERE nome_esercizio = :nome AND id_categoria = :id_categoria
    ");
    $stmt_check_esercizio->execute([
        ':nome' => 'Scrivi con le Sillabe',
        ':id_categoria' => $id_categoria
    ]);
    $esercizio_esistente = $stmt_check_esercizio->fetch(PDO::FETCH_ASSOC);

    if ($esercizio_esistente) {
        echo "⚠️  L'esercizio 'Scrivi con le Sillabe' esiste già con ID: {$esercizio_esistente['id_esercizio']}\n";
    } else {
        // ====================
        // STEP 4: Inserisci esercizio "scrivi_parole"
        // ====================
        $data_creazione = date('d/m/Y H:i:s');

        $stmt_esercizio = $pdo->prepare("
            INSERT INTO esercizi (id_categoria, nome_esercizio, descrizione_esercizio, data_creazione, stato_esercizio, link)
            VALUES (:id_categoria, :nome, :descrizione, :data_creazione, :stato, :link)
        ");

        $result_esercizio = $stmt_esercizio->execute([
            ':id_categoria' => $id_categoria,
            ':nome' => 'Scrivi con le Sillabe',
            ':descrizione' => 'Esercizio interattivo per comporre parole utilizzando sillabe. L\'app permette di lavorare con 2 o 3 sillabe, visualizzare pittogrammi ARASAAC corrispondenti alle parole composte, ascoltare la pronuncia con sintesi vocale italiana, e ricevere feedback audio e visivo immediato. Include modalità maestra per preparare le sillabe da proporre.',
            ':data_creazione' => $data_creazione,
            ':stato' => 'attivo',
            ':link' => '/training_cognitivo/scrivi/scrivi_parole/'
        ]);

        if ($result_esercizio) {
            $id_esercizio = $pdo->lastInsertId();
            echo "✓ Esercizio 'Scrivi con le Sillabe' creato con successo (ID: $id_esercizio)\n";
        } else {
            throw new Exception("Errore nella creazione dell'esercizio");
        }
    }

    echo "\n";
    echo "═══════════════════════════════════════════════════════\n";
    echo "✓ OPERAZIONE COMPLETATA CON SUCCESSO!\n";
    echo "═══════════════════════════════════════════════════════\n";
    echo "\n";
    echo "📊 Riepilogo:\n";
    echo "   • Categoria 'Scrivi' → ID: $id_categoria\n";
    echo "   • Link categoria: /training_cognitivo/scrivi/\n";
    echo "   • Esercizio 'Scrivi con le Sillabe' inserito\n";
    echo "   • Link esercizio: /training_cognitivo/scrivi/scrivi_parole/\n";
    echo "\n";
    echo "🌐 Test URL:\n";
    echo "   • Categoria: https://assistivetech.it/training_cognitivo/scrivi/\n";
    echo "   • Esercizio: https://assistivetech.it/training_cognitivo/scrivi/scrivi_parole/\n";
    echo "\n";

} catch (PDOException $e) {
    echo "❌ Errore database: " . $e->getMessage() . "\n";
    http_response_code(500);
} catch (Exception $e) {
    echo "❌ Errore: " . $e->getMessage() . "\n";
    http_response_code(500);
}
?>
