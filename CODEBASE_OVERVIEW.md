# AssistiveTech Codebase Overview

**Date**: November 3, 2025

## 1. DIRECTORY STRUCTURE

```
C:\MAMP\htdocs\Assistivetech\
├── ROOT (Main application files)
├── /api/          - CORE API endpoints
├── /admin/        - Admin panel
├── /script_sql/   - Database migrations (40+ files)
├── /logs/         - Application logs
└── [other folders]
```

## 2. CORE TABLES

**registrazioni** - Main user registry
- id_registrazione (PK)
- username (UNIQUE)
- ruolo: admin/educatore/paziente/sviluppatore
- stato_account: attivo/sospeso/eliminato

**educatori** - Educator profiles
- id_educatore (PK)
- id_registrazione (FK UNIQUE → registrazioni, CASCADE)
- stato_educatore: attivo/sospeso/in_formazione/eliminato
- Foreign keys: id_sede, id_settore, id_classe

**pazienti** - Patient profiles
- id_paziente (PK)
- id_registrazione (FK UNIQUE → registrazioni, CASCADE)
- Foreign keys: id_sede, id_settore, id_classe

**educatori_pazienti** - M:M associations
- id_educatore, id_paziente (FKs with CASCADE)
- is_attiva: soft delete flag (not hard delete)

**sedi** - Locations/branches
**settori** - Organizational sectors
**classi** - Classes within sectors

## 3. EDUCATORI MANAGEMENT

**File**: api/api_educatori.php

**Operations**:
- CREATE: POST action=create (transactional: registrazioni → educatori)
- READ: POST action=get_all (JOINs with sedi, settori, classi)
- UPDATE: POST action=update (updates both tables if password changed)
- DELETE: POST action=delete (SOFT: sets stato_educatore='eliminato')

**Log**: logs/educatori.log

## 4. PAZIENTI MANAGEMENT

**File**: api/api_pazienti.php

**Operations**:
- CREATE: POST action=create (transactional: registrazioni → pazienti, optional educator assign)
- READ: POST action=get_all (JOINs showing current educator)
- UPDATE: POST action=update (changes educator: deactivate old, activate new via is_attiva)
- DELETE: POST action=delete (HARD DELETE with cascade to registrazioni)

**Special**: Educator changes deactivate old associations (is_attiva=0) then create new ones

**Log**: logs/pazienti.log

## 5. EDUCATORI-PAZIENTI ASSOCIATIONS

**File**: api/educatori_pazienti.php

**Operations**:
- GET miei_pazienti: Patients assigned to educator
- GET pazienti_disponibili: Unassigned patients
- POST: Associate bulk patients to educator
- DELETE: Disassociate (SOFT: is_attiva=0)

## 6. REGISTRAZIONI MANAGEMENT

**File**: api/auth_registrazioni.php

**Operations**:
- CREATE: New user (hierarchy: developer > admin > educator > patient)
- READ: All users (excludes developers)
- UPDATE: User data (cannot modify developers)
- DELETE: Hard delete (cannot delete developers)
- CHANGE_PASSWORD: Update password

**Login**: auth_login.php
- Query registrazioni
- Redirect based on ruolo_registrazione

**Log Files**:
- logs/access.log (login attempts)
- logs/registrations.log (CRUD operations)

## 7. KEY FLOWS

### Create Educator + Assign Patients
1. Create educatore (registrazioni → educatori)
2. Assign patients via educatori_pazienti.php
3. Educator has "miei pazienti" list

### Create Patient + Assign to Educator
1. Create paziente (registrazioni → pazienti)
2. Optionally link to educatore via educatori_pazienti
3. Only ONE active association per patient

### Update Patient & Change Educator
1. Update pazienti table
2. Deactivate all old associations (is_attiva=0)
3. Create new association (is_attiva=1)
4. Preserves history via is_attiva flag

### Delete Patient
Hard delete with cascade:
1. Soft delete associations (is_attiva=0)
2. Delete from pazienti
3. Delete from registrazioni (cascade)

### Delete Educator
Soft delete (preserves everything):
1. Set stato_educatore = 'eliminato'
2. registrazione preserved
3. associations preserved
4. Can be restored

## 8. FILE LOCATIONS

**Configuration**:
- api/config.php (IMPORTANT: local/Aruba switch)
- api/config_local.php (optional override)

**APIs**:
- api/auth_login.php
- api/auth_registrazioni.php
- api/api_educatori.php
- api/api_pazienti.php
- api/educatori_pazienti.php

**Admin**:
- admin/index.html (184 KB)

**Database**:
- script_sql/database.sql (complete schema)
- script_sql/create_table_educatori.sql
- script_sql/create_table_pazienti.sql
- [40+ migration scripts]

**Logs**:
- logs/educatori.log
- logs/pazienti.log
- logs/access.log
- logs/registrations.log

## 9. DATABASE CREDENTIALS

**Local (MAMP)**:
- Host: localhost
- User: root
- Password: root
- Database: assistivetech_local

**Production (Aruba)**:
- Host: 31.11.39.242
- User: Sql1073852
- Password: 5k58326940
- Database: Sql1073852_1

## 10. KEY RELATIONSHIPS

- registrazioni (1) → (1) educatori [FK UNIQUE, CASCADE]
- registrazioni (1) → (1) pazienti [FK UNIQUE, CASCADE]
- educatori (M) ↔ (M) pazienti [via educatori_pazienti]
- educatori_pazienti.is_attiva: soft delete flag

## 11. SECURITY

- Developer role protected (hidden, cannot create/modify/delete)
- Role-based hierarchy (developer > admin > educator > patient)
- Operation logging for audits
- Input validation on all endpoints
- Transactional safety for multi-table ops

## 12. SPECIAL NOTES

- Dates: Italian format dd/mm/yyyy hh:mm:ss
- Soft deletes: educatori use is_attiva, pazienti use hard delete
- Associations: Only one ACTIVE educator per patient
- History: Preserved via is_attiva flag in educatori_pazienti
- Cascade: Patient deletion cascades to registrazioni

