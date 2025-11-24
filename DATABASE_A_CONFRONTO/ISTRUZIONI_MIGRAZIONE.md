# 📋 Istruzioni per la Migrazione del Database Aruba

## 📊 Riepilogo Confronto Database

### ✅ Database Locale (assistivetech_local.sql)
- **Tabelle totali**: 21
- **Versione**: Completa e aggiornata
- **Ultimo export**: Non specificato

### ⚠️ Database Aruba (Sql1073852_1.sql)
- **Tabelle totali**: 13
- **Versione**: Incompleta
- **Ultimo export**: 09/11/2025 ore 07:56

---

## 🔍 Differenze Rilevate

### 1. **Tabella `registrazioni`**
- **Problema**: Mancano 2 ruoli nell'ENUM
- **Ruoli attuali su Aruba**: `'amministratore','educatore','paziente','sviluppatore'`
- **Ruoli da aggiungere**: `'direttore'`, `'casemanager'`

### 2. **Tabelle Mancanti su Aruba**

| Tabella | Descrizione | Record Presenti | Priorità |
|---------|-------------|-----------------|----------|
| `video_yt` | **🎵 Video per "Ascolto la Musica"** | 11 | **CRITICA** |
| `direttori` | Gestione direttori di settore | 2 | Alta |
| `casemanager` | Gestione case manager | 7 | Alta |
| `casemanager_pazienti` | Associazioni case manager-pazienti | 0 | Media |
| `strumenti_youtube` | Strumenti YouTube avanzati | 0 | Media |

### 3. **Viste (VIEW) Mancanti**
- `vw_casemanager_dettagli`
- `vw_direttori_dettagli`
- `vw_gerarchia_organizzativa`

---

## 🚀 Procedura di Migrazione

### ⚠️ STEP 0: BACKUP OBBLIGATORIO

**PRIMA di procedere, esegui un backup completo del database Aruba:**

1. Accedi a **phpMyAdmin** su Aruba
2. Seleziona il database `Sql1073852_1`
3. Vai su **Export** (Esporta)
4. Scegli **Metodo**: Rapido
5. Formato: SQL
6. Click su **Esegui**
7. Salva il file come `Sql1073852_1_BACKUP_PRIMA_DELLA_MIGRAZIONE.sql`

### ✅ STEP 1: Verifica Prerequisiti

Prima di eseguire lo script di migrazione, verifica:

```sql
-- Connettiti al database Aruba e verifica:

-- 1. Verifica che la tabella video_yt NON esista
SHOW TABLES LIKE 'video_yt';
-- Se restituisce risultati, FERMA TUTTO e contattami

-- 2. Verifica i ruoli attuali in registrazioni
SHOW CREATE TABLE registrazioni;
-- Guarda il campo ruolo_registrazione

-- 3. Verifica che esistano gli ID di registrazione 20-28
SELECT id_registrazione, nome_registrazione, cognome_registrazione, ruolo_registrazione
FROM registrazioni
WHERE id_registrazione BETWEEN 20 AND 28;
-- Se NON esistono tutti, dovrai modificare lo script
```

### ✅ STEP 2: Modifica lo Script (se necessario)

**SE gli ID di registrazione 20-28 non esistono**, apri il file `MIGRATION_aruba_update.sql` e:

#### Opzione A: Rimuovi i dati di esempio
Commenta le righe 60-63 (INSERT per direttori) e 124-131 (INSERT per casemanager):

```sql
-- INSERT INTO `direttori` ...
-- (1, 20, 'Catia', 'Sartini', ...),
-- (2, 26, 'Nicoletta', 'Marconi', ...);
```

#### Opzione B: Crea prima gli account di registrazione

Prima di eseguire lo script di migrazione, inserisci gli account mancanti:

```sql
-- Esempio: crea gli account di registrazione necessari
INSERT INTO registrazioni (id_registrazione, nome_registrazione, cognome_registrazione, username_registrazione, password_registrazione, ruolo_registrazione, data_registrazione, stato_account)
VALUES
(20, 'Catia', 'Sartini', 'catia.sartini@example.com', 'password_provvisoria', 'direttore', '2025-11-05', 'attivo'),
(21, 'Veronica', 'Berre', 'veronica.berre@example.com', 'password_provvisoria', 'casemanager', '2025-11-05', 'attivo');
-- ... continua per gli altri ID
```

### ✅ STEP 3: Esegui lo Script di Migrazione

#### Via phpMyAdmin (Consigliato):

1. Accedi a **phpMyAdmin** su Aruba
2. Seleziona il database `Sql1073852_1`
3. Vai su **SQL** (in alto)
4. Apri il file `MIGRATION_aruba_update.sql` in un editor di testo
5. **Copia TUTTO il contenuto** del file
6. **Incolla** nella finestra SQL di phpMyAdmin
7. Click su **Esegui**
8. Attendi il completamento (potrebbe richiedere 20-30 secondi)

#### Via linea di comando:

```bash
# Se hai accesso SSH ad Aruba
mysql -u [username] -p [database_name] < MIGRATION_aruba_update.sql
```

### ✅ STEP 4: Verifica l'Esecuzione

Dopo l'esecuzione, verifica che tutto sia andato a buon fine:

```sql
-- 1. Verifica che le nuove tabelle esistano
SHOW TABLES;
-- Dovresti vedere: video_yt, direttori, casemanager, ecc.

-- 2. Verifica i dati in video_yt (CRITICA per "Ascolto la Musica")
SELECT COUNT(*) as totale_video FROM video_yt;
-- Dovrebbe restituire: 11

SELECT * FROM video_yt LIMIT 3;
-- Dovrebbe mostrare alcuni video

-- 3. Verifica gli indici
SHOW INDEX FROM video_yt;
-- Dovrebbe mostrare: PRIMARY, idx_video_yt_nome_utente, idx_video_yt_categoria

-- 4. Verifica le foreign key
SHOW CREATE TABLE casemanager;
-- Controlla che le foreign key siano presenti

-- 5. Verifica i nuovi ruoli
SHOW CREATE TABLE registrazioni;
-- ruolo_registrazione dovrebbe includere 'direttore' e 'casemanager'

-- 6. Verifica le viste (se le hai eseguite)
SHOW FULL TABLES WHERE Table_type = 'VIEW';
-- Dovrebbe mostrare le 3 viste
```

### ✅ STEP 5: Testa l'Applicazione

1. Vai all'applicazione **"Ascolto la Musica"**:
   ```
   https://assistivetech.it/training_cognitivo/strumenti/ascolto_la_musica/
   ```

2. **Testa l'Area Educatore**:
   - Login come educatore
   - Seleziona un utente
   - Prova ad **aggiungere un nuovo video** (cerca su YouTube)
   - Prova a **salvare** il video
   - Verifica che il video appaia nella lista

3. **Testa l'Area Utente**:
   - Vai nell'area utente
   - Seleziona un utente
   - Verifica che i **video salvati** appaiano nella lista
   - Clicca su un brano e verifica che **si avvii la riproduzione**
   - Prova a **eliminare** un brano

4. **Controlla i log PHP**:
   - Monitora i log di errore PHP per eventuali problemi con la nuova tabella
   - Path tipico su Aruba: `/home/[username]/logs/php_error.log`

---

## 🐛 Risoluzione Problemi

### Errore: "Table 'video_yt' already exists"
**Causa**: La tabella esiste già
**Soluzione**: Salta la creazione di quella tabella o verifica la struttura esistente

### Errore: "Cannot add foreign key constraint"
**Causa**: Gli ID di riferimento non esistono nelle tabelle padri
**Soluzione**: 
1. Verifica che le tabelle `registrazioni`, `sedi`, `settori`, `classi` esistano
2. Verifica che gli ID di riferimento siano validi
3. Rimuovi temporaneamente le foreign key e aggiungile dopo

### Errore: "Duplicate entry for key 'PRIMARY'"
**Causa**: Gli ID specificati negli INSERT esistono già
**Soluzione**: Modifica gli ID negli INSERT o rimuovi gli INSERT e lascia che gli AUTO_INCREMENT assegnino nuovi ID

### L'applicazione "Ascolto la Musica" non funziona
**Diagnostica**:
1. Verifica che la tabella `video_yt` esista: `SHOW TABLES LIKE 'video_yt';`
2. Verifica la struttura: `DESCRIBE video_yt;`
3. Verifica i dati: `SELECT * FROM video_yt;`
4. Controlla il file PHP `api_video_yt.php` per errori di connessione
5. Abilita la visualizzazione degli errori PHP temporaneamente

---

## 📝 Note Importanti

### Tabella `video_yt` - CRITICA per "Ascolto la Musica"

Questa è la tabella **più importante** per il funzionamento dell'applicazione "Ascolto la Musica":

```sql
-- Struttura
CREATE TABLE `video_yt` (
  `id_video` int(11) NOT NULL AUTO_INCREMENT,
  `nome_video` varchar(150) NOT NULL,
  `categoria` varchar(100) NOT NULL,
  `link_youtube` varchar(500) NOT NULL,
  `nome_utente` varchar(100) NOT NULL,
  `data_creazione` varchar(19) NOT NULL,
  PRIMARY KEY (`id_video`)
);
```

**Campi**:
- `id_video`: ID univoco del video
- `nome_video`: Nome descrittivo (es: "coccodrillo")
- `categoria`: Categoria del video (es: "canzone bambini")
- `link_youtube`: URL completo del video YouTube
- `nome_utente`: Nome dell'utente a cui è associato
- `data_creazione`: Data e ora di creazione (formato: dd/mm/yyyy HH:mm:ss)

### Viste (VIEWS) - Opzionali

Le 3 viste create sono **opzionali** e servono per:
- Gestire gerarchie organizzative (direttori → case manager → educatori)
- Generare report dettagliati
- Semplificare query complesse

Se non le usi, puoi **commentare la SEZIONE 7** dello script di migrazione.

---

## 📞 Supporto

Se incontri problemi durante la migrazione:

1. **NON procedere** con ulteriori modifiche
2. Ripristina il **BACKUP** che hai creato nello STEP 0
3. Documenta l'errore esatto (messaggio, riga dello script)
4. Verifica i prerequisiti dello STEP 1
5. Contatta l'assistenza con:
   - Messaggio di errore completo
   - Risultati delle query di verifica
   - Screenshot di phpMyAdmin (se possibile)

---

## ✅ Checklist Finale

Prima di considerare completata la migrazione, verifica:

- [ ] Backup del database Aruba eseguito e salvato
- [ ] Script di migrazione eseguito senza errori
- [ ] Tabella `video_yt` creata con 11 record
- [ ] Tabella `direttori` creata
- [ ] Tabella `casemanager` creata
- [ ] Tabella `casemanager_pazienti` creata
- [ ] Tabella `strumenti_youtube` creata
- [ ] Ruoli 'direttore' e 'casemanager' aggiunti a `registrazioni`
- [ ] Viste create (se necessarie)
- [ ] Applicazione "Ascolto la Musica" testata e funzionante
- [ ] Educatore può aggiungere nuovi video
- [ ] Utente può vedere e riprodurre i video
- [ ] Eliminazione video funziona correttamente
- [ ] Nessun errore nei log PHP

---

## 🎉 Conclusione

Se tutti i test sono passati, la migrazione è completa e il database Aruba è ora **allineato** al database locale.

L'applicazione **"Ascolto la Musica"** dovrebbe funzionare correttamente su Aruba!

**Buon lavoro! 🚀**

