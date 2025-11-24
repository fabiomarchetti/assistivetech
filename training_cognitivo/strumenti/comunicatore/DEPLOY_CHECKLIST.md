# ✅ Checklist Rapida Deployment Aruba

## Prima del Deploy

- [ ] Hai accesso FTP ad Aruba
- [ ] Hai accesso phpMyAdmin su Aruba
- [ ] Hai generato le icone PWA (192x192 e 512x512)

---

## Passi Deploy (15 minuti)

### 1. Upload Files via FTP
```
📁 Carica: /comunicatore/ → /training_cognitivo/strumenti/comunicatore/
```
- [ ] Tutti i file caricati
- [ ] Verifica esistenza `/api/config.php`

### 2. Database (phpMyAdmin)
```sql
-- Apri phpMyAdmin → Database: Sql1073852_1 → SQL
```
- [ ] Esegui `comunicatore/api/setup_database.sql`
- [ ] Verifica tabelle create:
  - `comunicatore_pagine`
  - `comunicatore_items`
  - `comunicatore_log`

### 3. Icone PWA
```
📁 Carica in: /comunicatore/assets/icons/
```
- [ ] icon-192.png (192x192px)
- [ ] icon-512.png (512x512px)

### 4. Permessi
```bash
chmod 755 comunicatore/assets/images/
```
- [ ] Cartella `images` scrivibile

### 5. Test
- [ ] Apri: `https://tuosito.it/training_cognitivo/strumenti/comunicatore/`
- [ ] Test API: `/comunicatore/api/pagine.php?action=list&id_paziente=1`
- [ ] Crea pagina come educatore
- [ ] Visualizza come paziente
- [ ] Test swipe tra pagine
- [ ] Installa PWA su mobile

---

## URL Importanti

```
🏠 Home:      https://tuosito.it/training_cognitivo/strumenti/comunicatore/
👨‍🏫 Educatore: https://tuosito.it/training_cognitivo/strumenti/comunicatore/gestione.html
🧑 Paziente:   https://tuosito.it/training_cognitivo/strumenti/comunicatore/comunicatore.html
🔧 Install:   https://tuosito.it/training_cognitivo/strumenti/comunicatore/api/install_tables.php
```

---

## ⚠️ Problema Comune

### "Config file not found"
➡️ Carica `/api/config.php` (deve essere in root)

### "Nessun utente nel dropdown"
➡️ Popola tabella `pazienti` su phpMyAdmin

### "Icone non appaiono"
➡️ Verifica esistenza in `/assets/icons/`

### "Upload immagini fallisce"
➡️ `chmod 777 comunicatore/assets/images/`

---

## ✅ Fatto!

Comunicatore è ora online, funzionante e installabile come PWA!

