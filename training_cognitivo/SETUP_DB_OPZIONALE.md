# 🗄️ Setup Database Cloud (Opzionale)

## ⚠️ Quando Serve

Il setup database è **opzionale** e serve solo se vuoi:

- Sincronizzare dati tra dispositivi diversi
- Backup cloud dei dati paziente
- Report centralizzati educatore
- Condividere configurazioni tra tablet

## ✅ Quando NON Serve

Se usi gli esercizi in modalità **standalone** (un dispositivo per paziente), il database cloud NON è necessario.

Tutti gli esercizi funzionano perfettamente con:
- IndexedDB locale (browser)
- LocalStorage
- Cache Service Worker

---

## 📊 Esercizi che NON Richiedono DB

**Tutti gli esercizi di training cognitivo** funzionano senza database:

```
✅ categorizzazione/* (6 esercizi)
✅ causa_effetto/* (1 esercizio)
✅ clicca_immagine/* (1 esercizio)
✅ scrivi/* (2 esercizi)
✅ sequenze_logiche/* (2 esercizi)
✅ test_memoria/* (1 esercizio)
✅ trascina_immagini/* (1 esercizio)
✅ memoria/* (1 esercizio)
```

**Totale: 14 esercizi** funzionano al 100% senza DB cloud.

---

## ⚙️ Comunicatore: Funzionalità con/senza DB

### Senza Database Cloud

Il **Comunicatore** funziona ma con limitazioni:

| Funzionalità | Senza DB | Con DB |
|--------------|----------|--------|
| Creare pagine | ✅ (locale) | ✅ (cloud) |
| Upload immagini | ✅ (cache) | ✅ (server) |
| Navigazione | ✅ | ✅ |
| Sintesi vocale | ✅ | ✅ |
| Salvataggio configurazioni | ✅ (IndexedDB) | ✅ (MySQL) |
| Sincronizzazione multi-device | ❌ | ✅ |
| Backup cloud | ❌ | ✅ |
| Report educatore | ❌ | ✅ |
| Log utilizzo centralizzato | ❌ | ✅ |

### Conclusione

Per **uso singolo dispositivo**, il Comunicatore funziona benissimo anche senza DB cloud.

---

## 🔧 Setup Database Cloud (Se Necessario)

Se in futuro vuoi abilitare sincronizzazione cloud:

### 1. Accedi phpMyAdmin Aruba

```
URL: https://mysql.aruba.it
User: Sql1073852
Pass: 5k58326940
Database: Sql1073852_1
```

### 2. Esegui SQL Setup Comunicatore

Solo questo file è necessario:

```sql
-- File: strumenti/comunicatore/api/setup_database.sql
```

**Contenuto SQL**:

```sql
-- Tabella Pagine
CREATE TABLE IF NOT EXISTS `comunicatore_pagine` (
  `id_pagina` int(11) NOT NULL AUTO_INCREMENT,
  `id_paziente` int(11) NOT NULL,
  `titolo` varchar(255) NOT NULL,
  `icona_url` varchar(500) DEFAULT NULL,
  `colore_sfondo` varchar(7) DEFAULT '#FFFFFF',
  `id_padre` int(11) DEFAULT NULL,
  `ordine` int(11) DEFAULT 0,
  `data_creazione` datetime DEFAULT CURRENT_TIMESTAMP,
  `data_modifica` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pagina`),
  KEY `idx_paziente` (`id_paziente`),
  KEY `idx_padre` (`id_padre`),
  FOREIGN KEY (`id_padre`) REFERENCES `comunicatore_pagine` (`id_pagina`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Items
CREATE TABLE IF NOT EXISTS `comunicatore_items` (
  `id_item` int(11) NOT NULL AUTO_INCREMENT,
  `id_pagina` int(11) NOT NULL,
  `etichetta` varchar(255) NOT NULL,
  `immagine_url` varchar(500) DEFAULT NULL,
  `testo_vocale` varchar(500) DEFAULT NULL,
  `azione_tipo` enum('parla','naviga','altro') DEFAULT 'parla',
  `azione_valore` varchar(500) DEFAULT NULL,
  `colore` varchar(7) DEFAULT '#9C27B0',
  `ordine` int(11) DEFAULT 0,
  `data_creazione` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_item`),
  KEY `idx_pagina` (`id_pagina`),
  FOREIGN KEY (`id_pagina`) REFERENCES `comunicatore_pagine` (`id_pagina`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabella Log
CREATE TABLE IF NOT EXISTS `comunicatore_log` (
  `id_log` int(11) NOT NULL AUTO_INCREMENT,
  `id_item` int(11) NOT NULL,
  `id_paziente` int(11) NOT NULL,
  `timestamp` bigint(20) NOT NULL,
  `data_utilizzo` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_log`),
  KEY `idx_item` (`id_item`),
  KEY `idx_paziente` (`id_paziente`),
  KEY `idx_timestamp` (`timestamp`),
  FOREIGN KEY (`id_item`) REFERENCES `comunicatore_items` (`id_item`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 3. Verifica Tabelle Create

```sql
SHOW TABLES LIKE 'comunicatore_%';
```

Dovresti vedere:
```
comunicatore_pagine
comunicatore_items
comunicatore_log
```

### 4. Test Connessione

Apri il comunicatore e verifica console browser:
```
✅ DB Connection OK
✅ Pagine caricate da server
```

---

## 🎯 Setup Altri Esercizi (Opzionale)

Se vuoi aggiungere funzionalità DB anche ad altri esercizi (es. salvataggio punteggi centralizzato), esegui i rispettivi SQL:

```sql
-- Esempio: Memoria Sequenze Colori
memoria/sequenze_colori/api/setup_database.sql

-- Esempio: Categorizzazione Animali
categorizzazione/animali/api/setup_database.sql
```

**Nota**: Questi SQL sono **template generici**. Adattali alle specifiche esigenze dell'esercizio se necessario.

---

## 🆘 Troubleshooting

### Errore: Foreign Key Constraint

**Sintomo**: Errore quando salvi pagina/item

**Causa**: Tabelle create in ordine errato

**Soluzione**: Esegui SQL nell'ordine corretto:
1. Prima `comunicatore_pagine`
2. Poi `comunicatore_items`
3. Infine `comunicatore_log`

### Errore: Connection Refused

**Sintomo**: App non si connette a DB

**Causa**: config.php non rileva ambiente correttamente

**Soluzione**: Verifica in `api/config.php`:

```php
$current_host = $_SERVER['HTTP_HOST'] ?? 'localhost';
echo "Host rilevato: $current_host\n"; // Debug

if (strpos($current_host, 'assistivetech.it') !== false) {
    // Produzione Aruba
    $host = '31.11.39.242';
    $username = 'Sql1073852';
    $password = '5k58326940';
    $database = 'Sql1073852_1';
} else {
    // Locale
    // ...
}
```

---

## 📊 Riepilogo

| Scenario | Setup DB | Funzionalità |
|----------|----------|--------------|
| **Test/Demo** | ❌ Non necessario | Tutto funziona in locale |
| **Uso singolo device** | ❌ Non necessario | Dati in IndexedDB locale |
| **Multi-device sync** | ✅ Necessario | Sincronizzazione cloud |
| **Report centralizzati** | ✅ Necessario | Statistiche aggregate |

**Raccomandazione**: Inizia senza DB. Aggiungi solo se serve sincronizzazione.

---

**Data**: 13/11/2024
**Sistema**: AssistiveTech Training Cognitivo
**Esercizi Standalone**: 14 (funzionano senza DB)
**Strumenti con DB**: Comunicatore (opzionale)
