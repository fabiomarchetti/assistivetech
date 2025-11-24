# 🚀 Guida Installazione Rapida

## Step 1: Database

Apri phpMyAdmin e esegui lo script SQL:

```bash
File: api/setup_database.sql
```

Oppure da terminale:

```bash
cd Assistivetech/training_cognitivo/strumenti/rispondo_con_gli_occhi
mysql -u root -p assistivetech_local < api/setup_database.sql
```

## Step 2: Verifica Configurazione DB

Controlla che il file `/Assistivetech/api/db_config.php` esista e sia configurato correttamente:

```php
<?php
function getDbConnection() {
    $host = 'localhost';
    $dbname = 'assistivetech_local';
    $username = 'root';
    $password = 'root'; // Modifica se necessario
    
    $conn = new mysqli($host, $username, $password, $dbname);
    
    if ($conn->connect_error) {
        die("Connessione fallita: " . $conn->connect_error);
    }
    
    $conn->set_charset("utf8mb4");
    return $conn;
}
?>
```

Se non esiste, crealo nella cartella `Assistivetech/api/`.

## Step 3: Registra l'Applicazione

Inserisci l'app nel database nella categoria "Strumenti":

```sql
-- 1. Trova l'ID della categoria Strumenti
SELECT id_categoria, nome_categoria FROM categorie_esercizi;

-- 2. Inserisci l'esercizio (sostituisci [ID_CATEGORIA] con l'ID corretto)
INSERT INTO esercizi (id_categoria, nome_esercizio, descrizione_esercizio, stato_esercizio, link)
VALUES 
  ([ID_CATEGORIA], 
   'Rispondo con gli Occhi',
   'Sistema di comunicazione alternativa basato su eye tracking e head pose estimation. Permette di rispondere a domande SI/NO attraverso lo sguardo.',
   'attivo',
   '/Assistivetech/training_cognitivo/strumenti/rispondo_con_gli_occhi/');
```

## Step 4: Testa l'Applicazione

### Test Landing Page
```
http://localhost/Assistivetech/training_cognitivo/strumenti/rispondo_con_gli_occhi/
```

Dovresti vedere:
- ✅ Pagina con titolo "Rispondo con gli Occhi"
- ✅ Due card: Educatore e Paziente
- ✅ Badge tecnologie (MediaPipe, OpenCV, etc.)

### Test Interfaccia Educatore
```
http://localhost/Assistivetech/training_cognitivo/strumenti/rispondo_con_gli_occhi/gestione.html
```

Test:
1. ✅ Clicca "Nuova Domanda"
2. ✅ Inserisci testo domanda
3. ✅ Cerca pittogrammi ARASAAC (es: "acqua")
4. ✅ Seleziona immagini e salva
5. ✅ Verifica che la domanda appaia nella lista

### Test Interfaccia Paziente
```
http://localhost/Assistivetech/training_cognitivo/strumenti/rispondo_con_gli_occhi/rispondo.html
```

Test:
1. ✅ Seleziona utente
2. ✅ Clicca "Avvia Esercizio"
3. ✅ Autorizza webcam
4. ✅ Verifica che il video appaia in basso
5. ✅ Verifica badge "Volto Rilevato" diventa verde
6. ✅ Prova a guardare sinistra/destra
7. ✅ Verifica che le barre di progresso si riempiano

## Step 5: Troubleshooting Comune

### ❌ Errore "getDbConnection is not defined"

**Soluzione**: Crea il file `Assistivetech/api/db_config.php` con il codice dello Step 2.

### ❌ Errore "Table 'domande_eye_tracking' doesn't exist"

**Soluzione**: Esegui lo script SQL dello Step 1.

### ❌ ARASAAC non carica immagini

**Soluzione**: Verifica connessione internet. ARASAAC API richiede connessione.

### ❌ Webcam non si avvia

**Soluzione**: 
- Usa Chrome o Edge
- Verifica permessi browser
- Usa HTTPS o localhost

### ❌ TTS non funziona

**Soluzione**: 
- Il browser deve supportare Web Speech API
- Controlla volume sistema
- Chrome/Edge hanno miglior supporto

## Step 6: Crea Domande di Test

Vai nell'interfaccia educatore e crea almeno 3 domande:

**Domanda 1:**
- Testo: "Vuoi bere dell'acqua?"
- Sinistra: NO
- Destra: SI
- Immagini: Cerca "acqua" in ARASAAC

**Domanda 2:**
- Testo: "Ti piace questo gioco?"
- Sinistra: NO
- Destra: SI

**Domanda 3:**
- Testo: "Preferisci il colore rosso o blu?"
- Sinistra: ROSSO
- Destra: BLU
- Immagini: Cerca "rosso" e "blu"

## Step 7: Test Completo End-to-End

1. Crea 3 domande (educatore)
2. Avvia interfaccia paziente
3. Seleziona utente
4. Completa l'esercizio rispondendo alle domande
5. Verifica nel database che le risposte siano salvate:

```sql
SELECT * FROM risposte_eye_tracking ORDER BY data_risposta DESC LIMIT 10;
```

## Step 8: Integrazione nel Menu Principale

Verifica che l'app appaia nel menu "Strumenti":

```
http://localhost/Assistivetech/training_cognitivo/strumenti/
```

Dovresti vedere la card "Rispondo con gli Occhi".

## ✅ Checklist Installazione Completata

- [ ] Database creato (tabelle domande_eye_tracking, risposte_eye_tracking)
- [ ] File db_config.php configurato
- [ ] Esercizio registrato nel database
- [ ] Landing page funzionante
- [ ] Interfaccia educatore funzionante
- [ ] ARASAAC carica pittogrammi
- [ ] Interfaccia paziente funzionante
- [ ] Webcam si avvia
- [ ] Eye tracking rileva volto
- [ ] Direzione sguardo rilevata correttamente
- [ ] Progress bar si riempie guardando sinistra/destra
- [ ] TTS verbalizza domande
- [ ] Risposte salvate nel database
- [ ] App visibile nel menu Strumenti

## 🎉 Congratulazioni!

Se tutti i check sono ✅, l'applicazione è installata e funzionante!

---

## 📞 Supporto

Per problemi consulta:
- `README.md` - Documentazione completa
- Console browser (F12) - Errori JavaScript
- Log PHP - Errori server

---

**Buon lavoro! 👁️**


