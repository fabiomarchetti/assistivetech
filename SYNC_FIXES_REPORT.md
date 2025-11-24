# Rapporto di Correzione - Sincronizzazione Dati Tabelle

## 📋 Sommario Esecutivo

Sono stati identificati e corretti **3 problemi critici** di sincronizzazione dati tra le tabelle:

1. ✅ **Educatori**: Nome/cognome non sincronizzati con registrazioni
2. ✅ **Pazienti**: Nome/cognome non sincronizzati con registrazioni
3. ✅ **Direttori/CaseManager**: Ruolo mancante dal sistema

---

## 🔴 PROBLEMI IDENTIFICATI E CORRETTI

### 1️⃣ Problema: Sincronizzazione Educatori (RISOLTO)

**File**: `api/api_educatori.php`
**Azione**: UPDATE (modifica educatore)

**Problema trovato (linee 154-230)**:
```php
// ❌ PRIMA: Solo aggiornamento in educatori + password in registrazioni
UPDATE educatori SET nome = :nome, cognome = :cognome, ...
UPDATE registrazioni SET password_registrazione = :password
// MANCA: Nome/cognome non aggiornati in registrazioni
```

**Soluzione implementata (linee 203-216)**:
```php
// ✅ DOPO: Sincronizzazione completa nome/cognome
UPDATE direttori SET nome = :nome, cognome = :cognome, ...
UPDATE registrazioni SET nome_registrazione = :nome, cognome_registrazione = :cognome
UPDATE registrazioni SET password_registrazione = :password (se fornita)
```

**Effetto**: Quando modifichi nome/cognome di un educatore nel pannello, ora vengono automaticamente sincronizzati anche nella tabella `registrazioni`.

---

### 2️⃣ Problema: Sincronizzazione Pazienti (RISOLTO)

**File**: `api/api_pazienti.php`
**Azione**: UPDATE (modifica paziente)

**Problema trovato (linee 165-233)**:
```php
// ❌ PRIMA: Solo aggiornamento in pazienti
UPDATE pazienti SET nome_paziente = :nome, cognome_paziente = :cognome, ...
// MANCA: Nessun aggiornamento in registrazioni
```

**Soluzione implementata (linee 203-216)**:
```php
// ✅ DOPO: Sincronizzazione con registrazioni
UPDATE pazienti SET nome_paziente = :nome, cognome_paziente = :cognome, ...
UPDATE registrazioni SET nome_registrazione = :nome, cognome_registrazione = :cognome
// Gestione educatori modificata di conseguenza
```

**Effetto**: Quando modifichi nome/cognome di un paziente, ora vengono automaticamente sincronizzati anche nella tabella `registrazioni`.

---

### 3️⃣ Problema: Ruoli Direttore/CaseManager Mancanti (RISOLTO)

**File**: `api/auth_registrazioni.php`

**Problema trovato (linea 113)**:
```php
// ❌ PRIMA: Ruoli limitati a amministratore, educatore, paziente
$ruoli_validi = ['amministratore', 'educatore', 'paziente'];
```

**Soluzione implementata**:

#### A) Aggiunta ruoli (linea 113):
```php
// ✅ DOPO: Aggiunto direttore e casemanager
$ruoli_validi = ['amministratore', 'educatore', 'paziente', 'direttore', 'casemanager'];
```

#### B) Gerarchia autorizzazioni aggiornata (linee 132-147):
```php
// Direttori/CaseManager
if ($ruolo === 'direttore' || $ruolo === 'casemanager') {
    // Solo sviluppatori e amministratori possono creare
    if (!in_array($calling_user_role, ['sviluppatore', 'amministratore'])) {
        jsonResponse(false, 'Non hai i permessi...');
    }
}

// Educatori
if ($ruolo === 'educatore') {
    // Sviluppatori, amministratori E DIRETTORI/CASEMANAGER possono creare
    if (!in_array($calling_user_role, ['sviluppatore', 'amministratore', 'direttore', 'casemanager'])) {
        jsonResponse(false, 'Non hai i permessi...');
    }
}

// Pazienti
if ($ruolo === 'paziente') {
    // Sviluppatori, amministratori, direttori, casemanager ED EDUCATORI
    if (!in_array($calling_user_role, ['sviluppatore', 'amministratore', 'educatore', 'direttore', 'casemanager'])) {
        jsonResponse(false, 'Non hai i permessi...');
    }
}
```

#### C) Creazione record direttori aggiunta (linee 186-221):
```php
if ($ruolo === 'direttore' || $ruolo === 'casemanager') {
    // Inserimento nella tabella direttori (da creare nel database)
    INSERT INTO direttori (id_registrazione, nome, cognome, settore, classe, id_sede,
                          ruolo_specifico, data_creazione, stato_direttore)
    VALUES (...)
}
```

---

## 📁 File NUOVI CREATI

### 1. `script_sql/create_table_direttori.sql`
**Descrizione**: Script SQL per creare la tabella `direttori`

**Contenuto**:
```sql
CREATE TABLE direttori (
    id_direttore INT AUTO_INCREMENT PRIMARY KEY,
    id_registrazione INT UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    settore VARCHAR(100),
    classe VARCHAR(50),
    id_sede INT,
    telefono VARCHAR(20),
    email_contatto VARCHAR(255),
    ruolo_specifico ENUM('direttore', 'casemanager'),
    data_creazione VARCHAR(19) NOT NULL,
    stato_direttore ENUM('attivo', 'sospeso', 'inattivo'),
    FOREIGN KEY (id_registrazione) REFERENCES registrazioni(id_registrazione),
    FOREIGN KEY (id_sede) REFERENCES sedi(id_sede)
);
```

**Quando eseguire**: Su Aruba (http://mysql.aruba.it) dopo il deployment.

---

### 2. `api/api_direttori.php` (NUOVO)
**Descrizione**: API completa per gestione direttori/casemanager

**Funzionalità implementate**:
- ✅ `action=get_all` - Recupera tutti i direttori attivi
- ✅ `action=create` - Crea nuovo direttore/casemanager
- ✅ `action=update` - Modifica con sincronizzazione automatica nome/cognome/password in registrazioni
- ✅ `action=delete` - Soft delete (cambio stato a 'inattivo')

**Caratteristiche**:
- Sincronizzazione automatica con tabella `registrazioni`
- Transazioni database per garantire coerenza dati
- Log operazioni su `logs/direttori.log`
- Supporto per entrambi i ruoli: `direttore` e `casemanager`

---

## 🗄️ FILE MODIFICATI

| File | Modifica | Linee |
|------|----------|-------|
| `api/api_educatori.php` | Aggiunto sincronizzazione nome/cognome in registrazioni | 203-216 |
| `api/api_pazienti.php` | Aggiunto sincronizzazione nome/cognome in registrazioni | 203-216 |
| `api/auth_registrazioni.php` | Aggiunto ruoli e logica autorizzazione direttori/casemanager | 113, 132-147, 186-221 |

---

## 🔄 SINCRONIZZAZIONE DATI SPIEGATA

### Flusso Educatori (Prima)
```
Admin modifica educatore
    ↓
UPDATE educatori (nome, cognome, ...)
    ↓
❌ registrazioni rimane vecchia
    ↓
PROBLEMA: Dati inconsistenti!
```

### Flusso Educatori (Dopo)
```
Admin modifica educatore
    ↓
UPDATE educatori (nome, cognome, ...)
    ↓
UPDATE registrazioni (nome_registrazione, cognome_registrazione) ← SINCRONIZZAZIONE
    ↓
✅ Dati sincronizzati!
```

### Lo stesso vale per Pazienti e Direttori

---

## 🛠️ ISTRUZIONI DI IMPLEMENTAZIONE

### Fase 1: Locale (MAMP)

1. **Aggiornare i file PHP**:
   - ✅ Già fatto: `api/api_educatori.php`
   - ✅ Già fatto: `api/api_pazienti.php`
   - ✅ Già fatto: `api/auth_registrazioni.php`
   - ✅ Già fatto: `api/api_direttori.php` (nuovo)

2. **Testare localmente**:
   ```bash
   # Aprire il pannello admin
   http://localhost:8000/admin/

   # Testare:
   - Modificare un educatore (controllare registrazioni)
   - Modificare un paziente (controllare registrazioni)
   - Creare un direttore (se tabella esiste localmente)
   ```

### Fase 2: Production (Aruba)

1. **Uploadare file PHP via FTP**:
   ```
   Carica su: /
   - api/api_educatori.php (modificato)
   - api/api_pazienti.php (modificato)
   - api/auth_registrazioni.php (modificato)
   - api/api_direttori.php (nuovo)
   ```

2. **Eseguire script SQL** su http://mysql.aruba.it:
   ```sql
   -- 1. Creare la tabella direttori
   [Contenuto di: script_sql/create_table_direttori.sql]
   ```

3. **Verificare le correzioni**:
   - Accedere al pannello admin: https://assistivetech.it/admin/
   - Modificare un educatore → Verificare che nome/cognome siano sincronizzati in registrazioni
   - Modificare un paziente → Verificare che nome/cognome siano sincronizzati in registrazioni
   - (Opzionale) Creare un direttore/casemanager

---

## 📊 Tabella di Sincronizzazione

| Entità | Tabella Principale | Tabella Secondaria | Campi Sincronizzati |
|--------|-------------------|--------------------|-------------------|
| Educatore | `educatori` | `registrazioni` | nome, cognome, password |
| Paziente | `pazienti` | `registrazioni` | nome, cognome |
| Direttore | `direttori` | `registrazioni` | nome, cognome, password, ruolo |

---

## ✅ Checklist di Verifica

- [ ] File PHP aggiornati e testati localmente
- [ ] SQL `create_table_direttori.sql` pronto per Aruba
- [ ] File uploadati su Aruba (api_educatori.php, api_pazienti.php, auth_registrazioni.php, api_direttori.php)
- [ ] Script SQL eseguito su http://mysql.aruba.it
- [ ] Pannello admin testato su https://assistivetech.it/admin/
- [ ] Modifica educatore sincronizzata ✓
- [ ] Modifica paziente sincronizzata ✓
- [ ] (Opzionale) Creazione direttore testata ✓

---

## 🚨 Note Importanti

### Per i Direttori:
- La tabella `direttori` **NON esiste ancora** e deve essere creata su Aruba
- Due ruoli disponibili: `direttore` e `casemanager` (intercambiabili)
- Soft delete: settare `stato_direttore = 'inattivo'` (dati preservati)

### Integrità Dati:
- Tutte le modifiche usano transazioni per garantire coerenza
- Se una sincronizzazione fallisce, il rollback preserva i dati
- Log disponibili in: `logs/educatori.log`, `logs/pazienti.log`, `logs/direttori.log`

### Password:
- Password sono ancora in chiaro (come per gli altri ruoli)
- Aggiornamenti password sincronizzano automaticamente in registrazioni

---

## 📞 Supporto

Per domande o problemi durante l'implementazione:
1. Verificare che i file siano stati uploadati correttamente
2. Controllare i log per errori (es: `logs/educatori.log`)
3. Verificare che la tabella `direttori` sia stata creata (per direttori/casemanager)
4. Controllare i permessi database su Aruba (utente SQL: Sql1073852)

---

**Data Report**: 2025-11-03
**Stato**: ✅ COMPLETATO E PRONTO PER DEPLOYMENT
