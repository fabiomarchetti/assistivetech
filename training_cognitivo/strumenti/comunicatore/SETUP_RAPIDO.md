# 🚀 Setup Rapido - Comunicatore

## 🆕 NOVITÀ: Modalità HYBRID

Il Comunicatore ora funziona **anche senza database**! Puoi:
- ✅ Usare database server (come prima)
- ✅ Creare utenti locali (PWA offline completa)
- ✅ Mix di entrambi

👉 Vedi `HYBRID_MODE.md` per dettagli completi

---

## ⚡ Installazione

### Opzione A: Con Database Server (Online)

#### 1️⃣ Setup Database

Apri **phpMyAdmin** e:

```sql
-- Crea le tabelle
SOURCE api/setup_database.sql;

-- Oppure copia/incolla manualmente il contenuto del file
```

#### 2️⃣ Verifica Config

Assicurati che esista `/Assistivetech/api/config.php` con:

```php
function getDbConnection() {
    $pdo = new PDO("mysql:host=localhost;dbname=assistivetech_db;charset=utf8mb4", "root", "password");
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $pdo;
}
```

### 3️⃣ Crea Pazienti (se necessario)

Se non hai pazienti nella tabella `registrazioni`:

```sql
INSERT INTO registrazioni (username, ruolo, nome, cognome) 
VALUES 
    ('mario', 'paziente', 'Mario', 'Rossi'),
    ('luca', 'paziente', 'Luca', 'Verdi');
```

### Opzione B: Solo Locale (PWA Offline)

**Zero configurazione!** 🎉

1. Apri `http://localhost/Assistivetech/.../comunicatore/`
2. Vai in **Gestione Educatore**
3. Clicca **+ (icona persona)** accanto a "Seleziona Utente"
4. Inserisci nome: es. `"Paolo"`
5. Clicca **✓**
6. Crea pagine e aggiungi immagini
7. **Funziona senza internet!**

✅ Tutti i dati salvati in **IndexedDB** (browser locale)

**Nota**: Le immagini ARASAAC richiedono comunque internet. Usa upload personalizzato per funzionamento 100% offline.

---

### 4️⃣ Genera Icone PWA

**Opzione A - Placeholder Rapido:**

Usa questo SVG e salvalo come `assets/icons/icon-base.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="80" fill="#673AB7"/>
  <g fill="#FFFFFF">
    <rect x="100" y="100" width="120" height="120" rx="20"/>
    <rect x="292" y="100" width="120" height="120" rx="20"/>
    <rect x="100" y="292" width="120" height="120" rx="20"/>
    <rect x="292" y="292" width="120" height="120" rx="20"/>
  </g>
</svg>
```

Poi converti online su: https://cloudconvert.com/svg-to-png

**Opzione B - Usa Tool Online:**

Vai su https://www.pwabuilder.com/imageGenerator e carica un'immagine qualsiasi.

**Salva come:**
- `assets/icons/icon-192.png` (192x192px)
- `assets/icons/icon-512.png` (512x512px)

### 5️⃣ Testa l'App

1. Apri browser: `http://localhost/Assistivetech/training_cognitivo/strumenti/comunicatore/`

2. **Test Educatore:**
   - Clicca "Gestione Educatore"
   - Seleziona un paziente
   - Crea una pagina
   - Aggiungi 2-3 immagini ARASAAC
   - Prova la preview

3. **Test Paziente:**
   - Clicca "Comunicatore Paziente"
   - Seleziona utente
   - Tocca le immagini (TTS)
   - Swipe per navigare tra pagine

---

## 🔍 Checklist Veloce

- [ ] Database creato (`comunicatore_pagine`, `comunicatore_items`, `comunicatore_log`)
- [ ] API accessibili (`/api/pagine.php`, `/api/items.php`)
- [ ] File `get_pazienti.php` presente in `/Assistivetech/api/`
- [ ] Pazienti esistenti nella tabella `registrazioni`
- [ ] Icone PWA create (o placeholder)
- [ ] Browser compatibile (Chrome/Firefox/Safari recenti)
- [ ] Test educatore completato
- [ ] Test paziente completato
- [ ] Swipe funzionante
- [ ] TTS funzionante

---

## 🐛 Problemi Comuni

### Errore: "File di configurazione database non trovato"

**Soluzione:**
```bash
# Verifica che esista
ls /Assistivetech/api/config.php

# Se mancante, crealo con contenuto corretto
```

### Errore: "Nessun paziente trovato"

**Soluzione:**
```sql
-- Aggiungi pazienti manualmente
INSERT INTO registrazioni (username, ruolo) VALUES ('test', 'paziente');
```

### Immagini non appaiono

**Soluzione:**
- Verifica connessione internet (ARASAAC richiede online)
- Controlla console browser (F12) per errori
- Prova con upload personalizzato

### PWA non installabile

**Soluzione:**
- Genera icone seguendo `GENERATE_ICONS.md`
- Verifica manifest.json con DevTools (F12 > Application > Manifest)
- Usa HTTPS per test finale (non richiesto su localhost)

---

## 📱 Test PWA su Mobile

### Android:
1. Apri in Chrome mobile
2. Menu > "Aggiungi a schermata Home"
3. Icona apparirà come app nativa

### iOS:
1. Apri in Safari
2. Tap "Condividi" > "Aggiungi a Home"
3. App installata!

---

## ✅ Deployment su Server

### Upload File:
```bash
# Via FTP carica tutta la cartella:
comunicatore/ -> /httpdocs/training_cognitivo/strumenti/comunicatore/
```

### Configurazione Aruba:

Modifica `js/api-client.js` se su Aruba:

```javascript
constructor(baseUrl = '/training_cognitivo/strumenti/comunicatore/api') {
    this.baseUrl = baseUrl;
}
```

E `js/comunicatore-app.js`:

```javascript
const response = await fetch('/api/get_pazienti.php');
```

---

## 🎯 Prossimi Passi

1. ✅ Test locale completo
2. ✅ Crea icone personalizzate
3. ✅ Aggiungi contenuti (pagine + items)
4. ✅ Test su dispositivo mobile
5. ✅ Deploy su server (se necessario)
6. ✅ Forma educatori all'uso

---

## 📞 Supporto

Consulta:
- `README.md` - Guida completa
- `assets/icons/GENERATE_ICONS.md` - Dettagli icone
- Console browser (F12) - Errori JavaScript/API

**Buon lavoro con il Comunicatore!** 🎉

