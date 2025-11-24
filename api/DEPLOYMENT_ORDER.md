# Ordine di Deployment Database - AssistiveTech.it

## 🚀 Sequenza Corretta di Esecuzione su MySQL Aruba

### **1. `cleanup_old_tables.sql`** - Pulizia Database
```sql
-- Elimina tutte le tabelle obsolete mantenendo solo 'registrazioni'
-- ATTENZIONE: Elimina definitivamente i dati esistenti!
```

### **2. `create_table_settori_classi.sql`** - Settori e Classi
```sql
-- Crea tabelle settori/classi con dati Lega del Filo d'Oro
-- Include tutti i settori: Scolare, Trattamenti Intensivi, etc.
```

### **3. `create_table_sedi.sql`** - Tabella Sedi
```sql
-- Crea tabella sedi con sede principale di default
```

### **4. `create_table_pazienti.sql`** - Tabella Pazienti
```sql
-- Crea tabella pazienti con foreign key verso sedi
```

### **5. `update_table_educatori.sql`** - Aggiorna Educatori
```sql
-- Modifica struttura educatori esistente
```

### **6. `add_id_sede_to_tables.sql`** - Foreign Key Sedi
```sql
-- Aggiunge foreign key verso tabelle sedi nelle tabelle educatori/pazienti
```

### **7. `update_educatori_pazienti_foreign_keys.sql`** - Foreign Key Settori/Classi
```sql
-- Aggiunge foreign key verso settori/classi e migra dati esistenti
```

## ❌ **Script NON Necessari:**
- ~~`insert_existing_users.sql`~~ - Non più necessario con nuova struttura

## ✅ **Risultato Finale:**
- Database pulito e riorganizzato
- Settori/classi specializzati Lega Filo d'Oro
- Foreign key corretti tra tutte le tabelle
- Dati migrati automaticamente