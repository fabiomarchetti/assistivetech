# Script SQL - AssistiveTech.it

Questa cartella contiene tutti gli script SQL utilizzati per la gestione del database MySQL del progetto AssistiveTech.it.

## 📁 Organizzazione Script

### Script di Base Sistema
- `create_database.sql` - Creazione database e schema principale
- `create_table_sedi.sql` - Creazione tabella sedi (step 1)
- `create_table_educatori.sql` - Creazione tabella educatori
- `create_table_pazienti.sql` - Creazione tabella pazienti
- `create_table_settori_classi.sql` - Tabelle settori e classi per organizzazione

### Script di Evoluzione Database
- `update_table_educatori.sql` - Aggiornamento struttura educatori
- `add_id_sede_to_tables.sql` - Aggiunta foreign key verso sedi
- `add_sede_to_registrazioni.sql` - Integrazione sedi nella tabella registrazioni
- `add_developer_role.sql` - Aggiunta ruolo sviluppatore al sistema

### Script di Migrazione Dati
- `insert_existing_users.sql` - Migrazione utenti esistenti nelle nuove tabelle
- `insert_existing_educatori.sql` - Popolamento tabella educatori
- `populate_educatori_from_registrations.sql` - Sincronizzazione dati educatori

### Script di Deployment
- `DEPLOY_COMPLETE.sql` - Script completo per nuovo deployment
- `DEPLOY_MINIMAL.sql` - Deployment minimale per aggiornamenti
- `fix_educatori_table.sql` - Fix per problemi struttura educatori

### Script di Diagnostica
- `DATABASE_STATUS.sql` - Verifica stato completo database
- `DATABASE_STATUS_SIMPLE.sql` - Verifica semplificata
- `DATABASE_BASIC_CHECK.sql` - Check di base funzionalità
- `EXTRACT_ALL_DATA.sql` - Estrazione completa dati per backup

### Script di Manutenzione
- `cleanup_old_tables.sql` - Pulizia tabelle obsolete
- `update_educatori_pazienti_foreign_keys.sql` - Aggiornamento chiavi esterne
- `verify_changes_step3.sql` - Verifica modifiche step by step

## 🚀 Ordine di Esecuzione per Nuovo Deploy

### Setup Iniziale (Primo Deploy)
1. `create_database.sql`
2. `create_table_sedi.sql`
3. `create_table_educatori.sql`
4. `create_table_pazienti.sql`
5. `add_id_sede_to_tables.sql`
6. `add_developer_role.sql`
7. `insert_existing_users.sql`

### Aggiornamento Sistema Esistente
1. `DATABASE_STATUS.sql` (verifica stato attuale)
2. `DEPLOY_MINIMAL.sql` o script specifici necessari
3. `DATABASE_STATUS.sql` (verifica post-aggiornamento)

## ⚠️ Note Importanti

### Credenziali Database Aruba
- **Host**: 31.11.39.242
- **Username**: Sql1073852
- **Password**: 5k58326940
- **Database**: Sql1073852_1

### Backup Prima di Modifiche
Eseguire sempre backup tramite pannello MySQL Aruba prima di eseguire script strutturali.

### Formato Date
Il sistema utilizza formato italiano dd/mm/yyyy per le date (VARCHAR, non DATETIME).

### Ruoli Utente
- `sviluppatore` - Accesso completo, protetto e invisibile
- `amministratore` - Gestione utenti e sedi
- `educatore` - Gestione pazienti assegnati
- `paziente` - Utilizzo agenda

## 🔧 Utilizzo Script

### Esecuzione via MySQL Aruba Panel
1. Accedere a http://mysql.aruba.it
2. Selezionare database Sql1073852_1
3. Copiare contenuto script nella query console
4. Eseguire e verificare risultati

### Esecuzione via CLI MySQL
```bash
mysql -h 31.11.39.242 -u Sql1073852 -p Sql1073852_1 < script_name.sql
```

### Test Connessione
```bash
mysql -h 31.11.39.242 -u Sql1073852 -p
# Password: 5k58326940
USE Sql1073852_1;
SHOW TABLES;
```

## 📊 Struttura Database Finale

```sql
registrazioni     # Autenticazione base multi-ruolo
├── sedi         # Gestione multi-location
├── educatori    # Profili educatori con sede/settore/classe
├── pazienti     # Profili pazienti con sede/settore/classe
├── educatori_pazienti  # Associazioni educatore-paziente
└── log_accessi  # Log sistema per sicurezza
```

## 🔄 Manutenzione Periodica

- **Backup**: Settimanale via pannello Aruba
- **Log Cleanup**: Mensile pulizia log_accessi
- **Verifica Integrità**: `DATABASE_STATUS.sql`
- **Monitoraggio**: Check foreign key constraints

Per supporto: marchettisoft@gmail.com