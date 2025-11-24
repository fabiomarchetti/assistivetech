# DOCUMENTAZIONE API DIRETTORI E CASEMANAGER

**Data**: 05/11/2025
**Versione**: 1.0
**Status**: ✅ Pronto per produzione

---

## 📋 INDICE

1. [API Direttori](#api-direttori)
2. [API CaseManager](#api-casemanager)
3. [Associazioni CaseManager-Pazienti](#associazioni-casemanager-pazienti)
4. [Pattern Implementativo](#pattern-implementativo)
5. [Error Handling](#error-handling)
6. [Logging](#logging)

---

## 🔴 API DIRETTORI

**File**: `api/api_direttori.php`

### Endpoints

#### 1. GET_ALL - Recupera tutti i direttori

**Richiesta**:
```bash
POST /api/api_direttori.php
Content-Type: application/json

{
  "action": "get_all"
}
```

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Direttori recuperati con successo",
  "data": [
    {
      "id_direttore": 1,
      "id_registrazione": 47,
      "nome": "Mario",
      "cognome": "Rossi",
      "id_sede": 1,
      "id_settore": 2,
      "id_classe": 5,
      "telefono": "0123456789",
      "email_contatto": "mario.rossi@mail.com",
      "note_direttive": "Supervisione settore Intensivi",
      "data_creazione": "05/11/2025 14:30:00",
      "stato_direttore": "attivo",
      "nome_sede": "Osimo - Sede Principale",
      "nome_settore": "Trattamenti Intensivi",
      "nome_classe": "Viola 1",
      "username_registrazione": "mario.rossi@mail.com",
      "numero_casemanager_assegnati": 3
    }
  ]
}
```

---

#### 2. CREATE - Crea nuovo direttore

**Richiesta**:
```bash
POST /api/api_direttori.php
Content-Type: application/json

{
  "action": "create",
  "nome": "Mario",
  "cognome": "Rossi",
  "username": "mario.rossi@mail.com",
  "password": "SecurePass123",
  "id_sede": 1,
  "id_settore": 2,
  "id_classe": 5,
  "telefono": "0123456789",
  "email_contatto": "mario.rossi@mail.com",
  "note_direttive": "Supervisione settore Intensivi"
}
```

**Validazioni**:
- ✅ Nome, cognome, username, password obbligatori
- ✅ Password minimo 6 caratteri
- ✅ Username univoco nel database
- ✅ Sede deve essere valida (se specificata)

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Direttore creato con successo",
  "data": null
}
```

**Errori possibili**:
```json
{
  "success": false,
  "message": "Nome, cognome, username e password sono obbligatori",
  "data": null
}
```

**Processo interno** (TRANSAZIONE ATOMICA):
1. INSERT registrazioni (ruolo='direttore')
2. GET id_registrazione (LAST_INSERT_ID)
3. INSERT direttori con id_registrazione
4. COMMIT (o ROLLBACK se fallisce)

---

#### 3. UPDATE - Aggiorna direttore esistente

**Richiesta**:
```bash
POST /api/api_direttori.php
Content-Type: application/json

{
  "action": "update",
  "id_direttore": 1,
  "nome": "Mario",
  "cognome": "Rossi",
  "username": "mario.rossi@mail.com",
  "password": "NewPassword123",
  "id_sede": 1,
  "id_settore": 2,
  "id_classe": 5,
  "telefono": "0123456789",
  "email_contatto": "mario.rossi@mail.com",
  "note_direttive": "Supervisione settore Intensivi",
  "stato_direttore": "attivo"
}
```

**Note**:
- ✅ Password opzionale (se non fornita, mantiene la precedente)
- ✅ Se username/password forniti, sincronizza anche registrazioni
- ✅ Stato: 'attivo', 'sospeso', 'inattivo'

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Direttore aggiornato con successo",
  "data": null
}
```

**Processo interno**:
1. UPDATE direttori
2. IF username/password != empty THEN:
   - GET id_registrazione dalla tabella direttori
   - UPDATE registrazioni (sincronizzazione)
3. COMMIT

---

#### 4. DELETE - Disattiva direttore (SOFT DELETE)

**Richiesta**:
```bash
POST /api/api_direttori.php
Content-Type: application/json

{
  "action": "delete",
  "id_direttore": 1
}
```

**Processo interno**:
- ❌ NON elimina fisicamente dal database
- ✅ UPDATE direttori SET stato_direttore='inattivo'
- ✅ Mantiene lo storico
- ✅ Preserva associazioni case manager

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Direttore disattivato con successo",
  "data": null
}
```

---

## 🟡 API CASEMANAGER

**File**: `api/api_casemanager.php`

### Endpoints

#### 1. GET_ALL - Recupera tutti i case manager

**Richiesta**:
```bash
POST /api/api_casemanager.php
Content-Type: application/json

{
  "action": "get_all"
}
```

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Case manager recuperati con successo",
  "data": [
    {
      "id_casemanager": 1,
      "id_registrazione": 48,
      "id_direttore": 1,
      "nome": "Anna",
      "cognome": "Bianchi",
      "id_sede": 1,
      "id_settore": 2,
      "id_classe": 5,
      "telefono": "0987654321",
      "email_contatto": "anna.bianchi@mail.com",
      "specializzazione": "Cognitivo",
      "data_creazione": "05/11/2025 14:35:00",
      "stato_casemanager": "attivo",
      "nome_sede": "Osimo - Sede Principale",
      "nome_settore": "Trattamenti Intensivi",
      "nome_classe": "Viola 1",
      "username_registrazione": "anna.bianchi@mail.com",
      "direttore_nome": "Mario Rossi",
      "numero_pazienti": 5
    }
  ]
}
```

---

#### 2. CREATE - Crea nuovo case manager

**Richiesta**:
```bash
POST /api/api_casemanager.php
Content-Type: application/json

{
  "action": "create",
  "nome": "Anna",
  "cognome": "Bianchi",
  "username": "anna.bianchi@mail.com",
  "password": "SecurePass456",
  "id_direttore": 1,
  "id_sede": 1,
  "id_settore": 2,
  "id_classe": 5,
  "telefono": "0987654321",
  "email_contatto": "anna.bianchi@mail.com",
  "specializzazione": "Cognitivo"
}
```

**Note**:
- ✅ id_direttore opzionale (NULL se non specificato)
- ✅ Se specificato, verifica che direttore sia attivo
- ✅ specializzazione è un campo descrittivo (es: "Cognitivo", "Comportamentale")

**Validazioni**:
- ✅ Nome, cognome, username, password obbligatori
- ✅ Password minimo 6 caratteri
- ✅ Username univoco
- ✅ Se id_direttore fornito, deve essere valido e attivo

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Case manager creato con successo",
  "data": null
}
```

---

#### 3. UPDATE - Aggiorna case manager

**Richiesta**:
```bash
POST /api/api_casemanager.php
Content-Type: application/json

{
  "action": "update",
  "id_casemanager": 1,
  "nome": "Anna",
  "cognome": "Bianchi",
  "username": "anna.bianchi@mail.com",
  "password": "NewPassword456",
  "id_direttore": 1,
  "id_sede": 1,
  "id_settore": 2,
  "id_classe": 5,
  "telefono": "0987654321",
  "email_contatto": "anna.bianchi@mail.com",
  "specializzazione": "Cognitivo",
  "stato_casemanager": "attivo"
}
```

**Processo interno**:
1. UPDATE casemanager
2. IF username/password != empty THEN:
   - Sincronizza registrazioni
3. COMMIT

---

#### 4. DELETE - Disattiva case manager (SOFT DELETE)

**Richiesta**:
```bash
POST /api/api_casemanager.php
Content-Type: application/json

{
  "action": "delete",
  "id_casemanager": 1
}
```

**Effetti**:
- ✅ UPDATE casemanager SET stato_casemanager='inattivo'
- ✅ Mantiene associazioni con pazienti
- ✅ Storico preservato

---

#### 5. GET_MIEI_PAZIENTI - Pazienti assegnati al case manager

**Richiesta**:
```bash
POST /api/api_casemanager.php
Content-Type: application/json

{
  "action": "get_miei_pazienti",
  "id_casemanager": 1
}
```

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Pazienti del case manager recuperati",
  "data": [
    {
      "id_paziente": 1,
      "id_registrazione": 18,
      "nome_completo": "Vincenzo Giovane",
      "username_registrazione": "vincenzo@gmail.com",
      "nome_sede": "Osimo - Sede Principale",
      "nome_settore": "Scolastico",
      "nome_classe": "Rosa",
      "data_associazione": "05/11/2025",
      "note": "Paziente segue percorso cognitivo intensivo"
    }
  ]
}
```

---

#### 6. GET_PAZIENTI_DISPONIBILI - Pazienti non ancora assegnati

**Richiesta**:
```bash
POST /api/api_casemanager.php
Content-Type: application/json

{
  "action": "get_pazienti_disponibili",
  "id_casemanager": 1
}
```

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Pazienti disponibili recuperati",
  "data": [
    {
      "id_paziente": 2,
      "id_registrazione": 19,
      "nome_completo": "Cristian Filippetti",
      "username_registrazione": "cristian@gmail.com",
      "nome_sede": "Osimo - Sede Principale",
      "nome_settore": "Adulti",
      "nome_classe": "AD1 Celeste 1"
    }
  ]
}
```

---

#### 7. ASSIGN_PAZIENTE - Assegna paziente al case manager

**Richiesta**:
```bash
POST /api/api_casemanager.php
Content-Type: application/json

{
  "action": "assign_paziente",
  "id_casemanager": 1,
  "id_paziente": 2,
  "note": "Inizio coordinamento terapeutico"
}
```

**Validazioni**:
- ✅ id_casemanager e id_paziente obbligatori
- ✅ Verifiche esistenza case manager
- ✅ Verifiche esistenza paziente
- ✅ Non consente duplicati (una sola assegnazione attiva)

**Processo interno**:
1. INSERT casemanager_pazienti (is_attiva=1, data_associazione=oggi)
2. COMMIT

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Paziente assegnato con successo",
  "data": null
}
```

**Errore - Già assegnato**:
```json
{
  "success": false,
  "message": "Paziente già assegnato a questo case manager",
  "data": null
}
```

---

#### 8. UNASSIGN_PAZIENTE - Rimuove paziente dal case manager

**Richiesta**:
```bash
POST /api/api_casemanager.php
Content-Type: application/json

{
  "action": "unassign_paziente",
  "id_casemanager": 1,
  "id_paziente": 2
}
```

**Processo interno**:
- UPDATE casemanager_pazienti SET is_attiva=0
- ✅ Soft delete (mantiene storico)
- ✅ Paziente rimane disponibile per altri case manager

**Risposta di successo** (200):
```json
{
  "success": true,
  "message": "Paziente rimosso con successo",
  "data": null
}
```

---

## 📌 ASSOCIAZIONI CASEMANAGER-PAZIENTI

### Tabella: `casemanager_pazienti`

**Struttura**:
```sql
id_associazione (PK)
├── id_casemanager (FK → casemanager)
├── id_paziente (FK → pazienti)
├── data_associazione (VARCHAR 10, formato dd/mm/yyyy)
├── is_attiva (TINYINT 1/0 - soft delete)
└── note (TEXT - note associazione)
```

**Vincoli**:
- ✅ UNIQUE (id_casemanager, id_paziente, is_attiva) - una sola assegnazione attiva
- ✅ CASCADE DELETE su casemanager
- ✅ CASCADE DELETE su pazienti

**Flussi**:

**Assegnazione nuovo paziente**:
```
1. ASSIGN_PAZIENTE
2. INSERT casemanager_pazienti (is_attiva=1)
3. Paziente visibile in GET_MIEI_PAZIENTI
```

**Cambio case manager di un paziente**:
```
1. UNASSIGN_PAZIENTE (case manager attuale)
   → UPDATE is_attiva=0 (soft delete)
2. ASSIGN_PAZIENTE (case manager nuovo)
   → INSERT con is_attiva=1
```

**Visualizzazione storico**:
```
SELECT * FROM casemanager_pazienti WHERE is_attiva=0
→ Mostra associazioni terminate
```

---

## 🔧 PATTERN IMPLEMENTATIVO

### Transazioni Atomiche

**Pattern per CREATE**:
```php
BEGIN TRANSACTION
├── 1. INSERT registrazioni
├── 2. GET id_registrazione (lastInsertId)
├── 3. INSERT direttori/casemanager (con id_registrazione)
COMMIT (o ROLLBACK su errore)
```

**Vantaggio**: Se fallisce uno, tutti tornano indietro

### Soft Delete

**Tutte le operazioni DELETE usano soft delete**:
```php
// ❌ SBAGLIATO
DELETE FROM direttori WHERE id_direttore=1;

// ✅ CORRETTO
UPDATE direttori SET stato_direttore='inattivo' WHERE id_direttore=1;
```

### Sincronizzazione Registrazioni

**Quando aggiorna nome/cognome/username/password**:
```php
// UPDATE direttori
// UPDATE registrazioni (sincronizzazione)
// IF registrazione esiste e campo != empty THEN aggiorna
```

---

## ⚠️ ERROR HANDLING

### Status Code HTTP

Tutti gli endpoint ritornano **200 OK** indipendentemente da successo/errore.

**Controllare sempre il flag `success`**:

```javascript
// Lato client
fetch('/api/api_direttori.php', {
  method: 'POST',
  body: JSON.stringify({ action: 'get_all' })
})
.then(res => res.json())
.then(data => {
  if (data.success) {
    console.log('Operazione riuscita:', data.data);
  } else {
    console.error('Errore:', data.message);
  }
});
```

### Errori comuni

| Errore | Causa | Soluzione |
|--------|-------|-----------|
| "Nome, cognome, username... obbligatori" | Campo mancante | Verificare tutti i campi |
| "La password deve avere almeno 6 caratteri" | Password troppo corta | Usare password ≥ 6 char |
| "Username già esistente" | Username non univoco | Scegliere username diverso |
| "Direttore non trovato o inattivo" | id_direttore non valido | Verificare ID o stato |
| "Database error" | Errore database | Controllare logs/direttori.log |

---

## 📊 LOGGING

### Log Direttori

**File**: `logs/direttori.log`

```
[2025-11-05 14:30:00] CREATE_DIRETTORE - Nome: Mario Rossi, Username: mario.rossi@mail.com - IP: 127.0.0.1
[2025-11-05 14:35:00] UPDATE_DIRETTORE - ID: 1, Nome: Mario Rossi - IP: 127.0.0.1
[2025-11-05 14:40:00] DELETE_DIRETTORE - ID: 1, Nome: Mario Rossi - IP: 127.0.0.1
```

### Log CaseManager

**File**: `logs/casemanager.log`

```
[2025-11-05 14:45:00] CREATE_CASEMANAGER - Nome: Anna Bianchi, Username: anna.bianchi@mail.com - IP: 127.0.0.1
[2025-11-05 14:50:00] ASSIGN_PAZIENTE - Case Manager: 1, Paziente: 1 - IP: 127.0.0.1
[2025-11-05 14:55:00] UNASSIGN_PAZIENTE - Case Manager: 1, Paziente: 1 - IP: 127.0.0.1
```

---

## ✅ CHECKLIST DEPLOYMENT

Prima di usare in produzione:

- [ ] Script SQL `create_direttori_casemanager_FIXED.sql` eseguito
- [ ] Tabelle `direttori`, `casemanager`, `casemanager_pazienti` create
- [ ] Enum `registrazioni.ruolo_registrazione` aggiornato con 'direttore' e 'casemanager'
- [ ] File `api/api_direttori.php` caricato
- [ ] File `api/api_casemanager.php` caricato
- [ ] Directory `logs/` esiste e scrivibile
- [ ] Test creazione direttore eseguito
- [ ] Test creazione case manager eseguito
- [ ] Test assegnazione paziente eseguito
- [ ] Backup database eseguito

---

## 🎯 PROSSIMI STEP

1. ✅ Integrare API nell'admin panel (HTML/JavaScript)
2. ✅ Creare dashboard per direttori
3. ✅ Creare dashboard per case manager
4. ✅ Implementare autorizzazioni (solo visualizzare propri pazienti)
5. ✅ Aggiungere controlli di sicurezza (rate limiting, CORS whitelist)

---

**Documento completato**: ✅
**Pronto per produzione**: ✅
**Testato**: ⏳ (in corso)
