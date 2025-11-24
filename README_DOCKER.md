# 🐳 Test Locale con Docker - AssistiveTech.it

## Prerequisiti

- **Docker Desktop** installato: https://www.docker.com/products/docker-desktop/
  ```bash
  # Verifica installazione
  docker --version
  docker-compose --version
  ```

## 🚀 Avvio Rapido

### 1. Avvia i container
```bash
# Dalla root del progetto
docker-compose up -d

# Verifica container attivi
docker ps
```

### 2. Accedi ai servizi

| Servizio | URL | Credenziali |
|----------|-----|-------------|
| **Sito Web** | http://localhost:8080 | - |
| **Training Cognitivo** | http://localhost:8080/training_cognitivo/ | - |
| **App Scrivi Parole** | http://localhost:8080/training_cognitivo/scrivi/scrivi_parole/ | - |
| **phpMyAdmin** | http://localhost:8081 | root / root |
| **MySQL diretto** | localhost:3306 | assistivetech / assistivetech123 |

### 3. Setup Database

#### Opzione A: Via phpMyAdmin (http://localhost:8081)
1. Login con `root` / `root`
2. Seleziona database `assistivetech_local`
3. Vai su tab **SQL**
4. Esegui in ordine:
   ```sql
   -- 1. Schema base (se non auto-importato)
   -- Copia contenuto da: api/create_database.sql

   -- 2. Script categoria Scrivi
   -- Copia contenuto da: api/insert_scrivi_categoria_esercizio.sql
   ```

#### Opzione B: Via terminale
```bash
# Entra nel container MySQL
docker exec -it assistivetech_db mysql -uroot -proot assistivetech_local

# Poi esegui query SQL manualmente
```

### 4. Modifica Config PHP per Docker

Crea file `api/config_docker.php`:
```php
<?php
$host = 'db';  // Nome servizio Docker
$username = 'assistivetech';
$password = 'assistivetech123';
$database = 'assistivetech_local';
?>
```

Nei file API (es: `api_categorie_esercizi.php`), sostituisci temporaneamente:
```php
// Da:
$host = '31.11.39.242';
$username = 'Sql1073852';
// ...

// A:
require_once 'config_docker.php';
```

## 🧪 Test Funzionalità

### Test 1: Homepage
```
http://localhost:8080/
```
Verifica: Homepage carica correttamente

### Test 2: Training Cognitivo
```
http://localhost:8080/training_cognitivo/
```
Verifica:
- Sidebar categorie carica
- Categoria "Scrivi" appare
- Clic su "Scrivi" → mostra esercizio

### Test 3: App Flutter PWA
```
http://localhost:8080/training_cognitivo/scrivi/scrivi_parole/
```
Verifica:
- App Flutter carica
- Toggle 2/3 sillabe funziona
- Inserimento sillabe area maestra
- Clic sillabe area alunno
- Ricerca ARASAAC (richiede internet)
- TTS funziona

## 🛑 Stop e Pulizia

```bash
# Ferma container (dati DB preservati)
docker-compose down

# Ferma e rimuovi tutto (incluso DB)
docker-compose down -v

# Riavvia dopo modifiche
docker-compose restart

# Vedi log real-time
docker-compose logs -f

# Vedi log solo web server
docker-compose logs -f web
```

## 🔧 Troubleshooting

### Problema: Porta 8080 già in uso
```bash
# Modifica docker-compose.yml:
# web -> ports: "8082:80"  # Cambia 8080 in 8082
```

### Problema: MySQL non si avvia
```bash
# Rimuovi volume e ricrea
docker-compose down -v
docker-compose up -d
```

### Problema: Permission denied sui file
```bash
# Entra nel container web
docker exec -it assistivetech_web bash

# Dai permessi
chmod -R 755 /var/www/html
chown -R www-data:www-data /var/www/html
```

### Problema: API non risponde
```bash
# Verifica log web server
docker-compose logs web

# Verifica container PHP ha estensione PDO MySQL
docker exec assistivetech_web php -m | grep pdo
```

Se manca PDO, aggiungi al `docker-compose.yml` sotto `web`:
```yaml
web:
  build:
    context: .
    dockerfile: Dockerfile
```

E crea `Dockerfile`:
```dockerfile
FROM php:8.2-apache
RUN docker-php-ext-install pdo pdo_mysql
RUN a2enmod rewrite
```

## 📊 Vantaggi Docker

- ✅ **Isolamento completo**: Non inquina il sistema
- ✅ **Reset rapido**: `docker-compose down -v` cancella tutto
- ✅ **Portabile**: Stessa config su tutti i computer
- ✅ **Veloce**: Avvio in secondi
- ✅ **Professionale**: Simula ambiente produzione

## 🌐 URLs Finali Locali

| Risorsa | URL Locale (Docker) | URL Produzione |
|---------|---------------------|----------------|
| Homepage | http://localhost:8080/ | https://assistivetech.it/ |
| Training | http://localhost:8080/training_cognitivo/ | https://assistivetech.it/training_cognitivo/ |
| Categoria Scrivi | http://localhost:8080/training_cognitivo/scrivi/ | https://assistivetech.it/training_cognitivo/scrivi/ |
| App Scrivi Parole | http://localhost:8080/training_cognitivo/scrivi/scrivi_parole/ | https://assistivetech.it/training_cognitivo/scrivi/scrivi_parole/ |
| phpMyAdmin | http://localhost:8081 | http://mysql.aruba.it |

---

**Pronto per il test! 🚀**
