<?php
// Scopri la struttura della tabella registrazioni
require_once __DIR__ . '/../../../../api/db_config.php';

$conn = getDbConnectionMySQLi();

echo "<h2>Struttura tabella registrazioni</h2>";
echo "<pre>";

$result = $conn->query("DESCRIBE registrazioni");

echo "COLONNE:\n";
while ($row = $result->fetch_assoc()) {
    echo "- " . $row['Field'] . " (" . $row['Type'] . ")\n";
}

echo "\n\nPRIMI 3 RECORD:\n";
$result = $conn->query("SELECT * FROM registrazioni LIMIT 3");

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        print_r($row);
        echo "\n";
    }
} else {
    echo "Nessun record trovato\n";
}

$conn->close();
echo "</pre>";
?>


