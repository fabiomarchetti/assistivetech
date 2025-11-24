# 🏢 Deployment: Aggiunta Sede agli Amministratori

## 📋 Panoramica
Script per aggiungere il campo `id_sede` alla tabella `registrazioni` per associare gli amministratori a sedi specifiche.

## 🗄️ Modifiche Database

### 1. Script SQL da Eseguire
**File:** `api/add_sede_to_registrazioni.sql`

```sql
-- Aggiungi colonna id_sede
ALTER TABLE registrazioni
ADD COLUMN id_sede INT DEFAULT 1 AFTER ruolo_registrazione;

-- Aggiungi foreign key
ALTER TABLE registrazioni
ADD CONSTRAINT fk_registrazioni_sede
FOREIGN KEY (id_sede) REFERENCES sedi(id_sede)
ON DELETE SET NULL
ON UPDATE CASCADE;
```

### 2. Procedura di Deployment
1. **Accedi a MySQL Aruba**: http://mysql.aruba.it
2. **Seleziona database**: Sql1073852_1
3. **Esegui script**: Copia e incolla il contenuto di `add_sede_to_registrazioni.sql`
4. **Verifica risultato**: Controlla che la colonna sia stata aggiunta

## 🔧 Modifiche Codice

### API Aggiornata
**File:** `api/auth_registrazioni.php`
- ✅ Campo `id_sede` incluso nella INSERT
- ✅ Foreign key relationship gestita
- ✅ Default sede = 1 se non specificata

### Form Esistente
**File:** `admin/index.html`
- ✅ Campo sede già presente nel form amministratori
- ✅ Dropdown sedi già caricato dinamicamente
- ✅ Validazione lato client funzionante

## 🧪 Test

### File di Test
**File:** `test_admin_sede.html`
- Verifica schema tabella registrazioni
- Test creazione amministratore con sede
- Controllo ultima registrazione

### Come Testare
1. **Apri:** `https://assistivetech.it/test_admin_sede.html`
2. **Verifica Schema:** Clicca "Controlla Schema"
3. **Test Creazione:** Compila form e crea admin test
4. **Verifica DB:** Controlla che la sede sia salvata

## 🔍 Verifiche Post-Deployment

### Query di Controllo
```sql
-- Verifica struttura tabella
DESCRIBE registrazioni;

-- Verifica foreign key
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'Sql1073852_1'
AND TABLE_NAME = 'registrazioni'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Verifica registrazioni con sede
SELECT
    r.id_registrazione,
    r.nome_registrazione,
    r.cognome_registrazione,
    r.username_registrazione,
    r.ruolo_registrazione,
    r.id_sede,
    s.nome_sede,
    r.data_registrazione
FROM registrazioni r
LEFT JOIN sedi s ON r.id_sede = s.id_sede
WHERE r.ruolo_registrazione = 'amministratore'
ORDER BY r.id_registrazione DESC;
```

## ⚠️ Note Importanti

1. **Backup:** Fare backup del database prima delle modifiche
2. **Default Value:** Gli amministratori esistenti avranno `id_sede = 1`
3. **Foreign Key:** Se la sede viene eliminata, `id_sede` diventerà NULL
4. **Compatibilità:** Mantenuta retrocompatibilità con codice esistente

## 🎯 Risultato Finale

Dopo il deployment:
- ✅ Gli amministratori sono associati a sedi specifiche
- ✅ Il form di registrazione salva correttamente la sede
- ✅ Le query possono filtrare amministratori per sede
- ✅ Relazione database coerente con educatori e pazienti

## 🚀 Ordine di Esecuzione

1. Eseguire script SQL `add_sede_to_registrazioni.sql`
2. Verificare schema con `test_admin_sede.html`
3. Testare creazione nuovo amministratore
4. Deploy file aggiornati via FTP
5. Test finale su produzione