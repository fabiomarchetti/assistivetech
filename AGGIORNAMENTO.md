## Procedura di aggiornamento Aruba (deploy + verifica DB)

### 1) Preparazione locale (prima di caricare)
- Verifica che l'app funzioni in locale: pagine, API, esercizi.
- Se hai modificato l'app Flutter `agenda/`, rigenera la build web.
- Assicurati che i file modificati siano pronti per l'upload (no credenziali).

### 2) Backup produzione (obbligatorio)
- Pannello MySQL Aruba → DB `Sql1073852_1` → Export completo (schema+dati) in SQL.
- (Consigliato) Scarica una copia dei file lato FTP se prevedi modifiche massicce.

### 3) Allineamento database produzione (migrazione SAFE)
- Esegui in MySQL Aruba il file:
  - `script_sql/DEPLOY_SAFE_MIGRATION_20251018.sql`
- Scopo: allineare `risultati_esercizi` allo schema locale in modo idempotente e non distruttivo.

### 4) Verifica database (post-migrazione)
- Esegui in MySQL Aruba:
  - `script_sql/VERIFY_RISULTATI_20251018.sql`
- Controlla che:
  - La colonna `data_esecuzione` sia di tipo DATE.
  - Esistano `ora_inizio_esercizio`, `ora_fine_esercizio`, `item_corretto`, `item_errato`, `items_totali_utilizzati`.
  - Indici presenti: `idx_educatore_paziente`, `idx_categoria_esercizio`, `idx_data_esecuzione`, `idx_item_corretto`.
  - Conteggio record > 0, “date_nulle” ≤ attese.

### 5) Upload file via FTP (solo file cambiati)
- Carica su Aruba:
  - `api/` (tutti i PHP aggiornati). Non sovrascrivere `api/config.override.php`.
  - `risultati/` (pagine report risultati: HTML/JS/CSS).
  - `training_cognitivo/` (solo cartelle esercizi modificati).
  - `admin/` (se aggiornato).
  - Root: eventuali `index.html`, `login.html`, `register.html`, `dashboard.html`.
  - `agenda/` solo se hai rigenerato la build PWA (includi `assets/`, `main.dart.js`, `flutter_service_worker.js`, `version.json`).
- Permessi `logs/`: directory 755, file 644.

### 6) Configurazione produzione (una tantum o quando serve)
- Su Aruba crea/aggiorna `api/config.override.php` (non versionare):
```php
<?php
$host = '31.11.39.242';
$username = 'Sql1073852';
$password = '5k58326940';
$database = 'Sql1073852_1';
$port = 3306;
define('APP_TZ', 'Europe/Rome');
```
- Non caricare credenziali nel repository.

### 7) Test funzionali (post-upload)
- API risultati:
```bash
curl "https://assistivetech.it/api/api_risultati_esercizi.php?action=get_statistics"
curl "https://assistivetech.it/api/api_risultati_esercizi.php?action=get_results&limit=10"
```
- UI risultati: `https://assistivetech.it/risultati/`
- Admin (se aggiornato): `https://assistivetech.it/admin/`
- Agenda (se aggiornata): `https://assistivetech.it/agenda/`

### 8) Checklist di chiusura
- [ ] Migrazione DB eseguita senza errori
- [ ] Script verifica DB ok (schema/indici/conti)
- [ ] File aggiornati caricati
- [ ] API rispondono correttamente
- [ ] Pagine principali funzionano

### 9) Rollback (se necessario)
- Ripristina il dump DB eseguito al punto 2.
- Ripristina i file precedenti via FTP (o ricarica l'ultima versione stabile).

### Note
- Gli script in `script_sql/` sono idempotenti e possono essere rieseguiti senza effetti collaterali distruttivi.
- Per nuovi cambi di schema ripetuti nel tempo, duplica `DEPLOY_SAFE_MIGRATION_YYYYMMDD.sql` con nuova data e includi solo le differenze.


