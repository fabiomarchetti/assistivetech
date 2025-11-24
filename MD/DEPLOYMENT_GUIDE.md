# Guida al Deployment su Server Aruba

## Credenziali Server Aruba
- **Host FTP**: ftp.assistivetech.it
- **Username**: assistivetech.it
- **Password**: [Verificare nel file dati_aruba.txt]
- **Database Host**: 31.11.39.242
- **Database Username**: Sql1073852
- **Database Password**: 5k58326940
- **Database Name**: Sql1073852_1

## Files da Caricare

### 1. Root Directory (/)
- `index.html` - Pagina principale
- `login.html` - Pagina di login
- `register.html` - Pagina di registrazione
- `dashboard.html` - Dashboard educatori
- `style.css` - CSS personalizzato (se presente)

### 2. Directory /api/
- `auth_login.php` - API per login
- `auth_registrazioni.php` - API per gestione utenti
- `create_database.sql` - Script creazione database

### 3. Directory /admin/
- `index.html` - Pannello amministrativo

### 4. Directory /agenda/ (intera cartella)
- Tutta la cartella agenda con l'app Flutter PWA
- Mantenere la struttura originale

## Procedura di Deployment

### Step 1: Upload Files via FTP
```bash
# Connettersi via FTP al server
# Caricare tutti i files mantenendo la struttura directory
```

### Step 2: Configurazione Database
1. Accedere al pannello MySQL di Aruba
2. Eseguire lo script `api/create_database.sql`
3. Verificare che le tabelle siano state create correttamente

### Step 3: Test delle Funzionalità
1. **Test Homepage**: `https://assistivetech.it/`
2. **Test Login**: `https://assistivetech.it/login.html`
   - Admin: marchettisoft@gmail.com / Filohori11!
3. **Test Registrazione**: `https://assistivetech.it/register.html`
4. **Test Agenda**: `https://assistivetech.it/agenda/`
5. **Test Admin Panel**: `https://assistivetech.it/admin/`

### Step 4: Verifiche Finali
- [ ] Homepage carica correttamente
- [ ] Login funziona con credenziali admin
- [ ] Registrazione nuovi utenti funziona
- [ ] Dashboard educatori accessibile
- [ ] Agenda Flutter PWA funziona
- [ ] Pannello admin gestisce utenti
- [ ] API rispondono correttamente

## Struttura Finale su Server
```
assistivetech.it/
├── index.html              # Homepage principale
├── login.html              # Pagina login
├── register.html           # Pagina registrazione
├── dashboard.html          # Dashboard educatori
├── api/                    # API PHP
│   ├── auth_login.php
│   ├── auth_registrazioni.php
│   └── create_database.sql
├── admin/                  # Pannello amministrativo
│   └── index.html
└── agenda/                 # App Flutter PWA
    ├── lib/
    ├── web/
    └── pubspec.yaml
```

## Note Importanti
- Le password sono attualmente in chiaro (line 36-38 in auth_registrazioni.php)
- In futuro implementare hashing con password_hash()
- Log degli accessi salvati in `/logs/` (creare directory)
- CORS configurato per accettare tutte le origini (*)

## Credenziali di Test
- **Admin**: marchettisoft@gmail.com / Filohori11!
- **Educatore**: maria.rossi@example.com / educatore123
- **Paziente**: luca.bianchi@example.com / paziente123