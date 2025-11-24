# 🔧 Configurazione MAMP Porta 8888

## ⚠️ Problema Identificato

La porta 80 è probabilmente occupata da un altro servizio (IIS, Apache esistente, Skype, ecc.).

## ✅ Soluzione: Usare Porta 8888

Come sul tuo altro computer, configuriamo MAMP per usare la porta **8888**.

---

## 📋 Step-by-Step

### 1️⃣ Configurare Porte MAMP

1. **Apri MAMP**
2. Clicca su **"Preferences"** (o "Preferenze")
3. Vai su tab **"Ports"**
4. Imposta:
   - **Apache Port:** `8888`
   - **MySQL Port:** `3306` (o `8889` se preferisci)
5. Clicca **"OK"**
6. Clicca **"Start Servers"**
7. Verifica che Apache e MySQL siano entrambi **verdi**

---

### 2️⃣ Verifica Porte Attive

Dopo aver avviato MAMP, la pagina start dovrebbe mostrarti:

```
Apache: Running on port 8888
MySQL: Running on port 3306 (o 8889)
```

---

### 3️⃣ Nuovi URL da Usare

Con porta 8888, tutti gli URL cambiano:

#### Frontend
- **Homepage:** http://localhost:8888/index.html
- **Login:** http://localhost:8888/login.html
- **Admin:** http://localhost:8888/admin/
- **Agenda:** http://localhost:8888/agenda/

#### Tools Diagnostica
- **Test DB:** http://localhost:8888/test_connection.php
- **Setup DB:** http://localhost:8888/setup_local_database.php
- **phpMyAdmin:** http://localhost:8888/phpMyAdmin/ (o phpMyAdmin5)

---

### 4️⃣ Test Configurazione

**Apri:** http://localhost:8888/test_connection.php

**Dovresti vedere:**
- ✅ Ambiente rilevato: LOCALE (MAMP)
- ✅ Host richiesta: localhost:8888
- ✅ Connessione al database riuscita

---

## 🎯 Nessuna Modifica al Codice Necessaria!

Il file `api/config.php` rileva automaticamente `localhost` indipendentemente dalla porta, quindi **non serve modificare nulla** nel codice PHP.

L'unica differenza è che dovrai sempre usare `:8888` negli URL del browser.

---

## 🔍 Verifica Porta 80 Occupata

Per vedere cosa occupa la porta 80 (opzionale, se sei curioso):

```cmd
# Apri Prompt dei Comandi come Amministratore
netstat -ano | findstr :80
```

Possibili colpevoli:
- IIS (Internet Information Services di Windows)
- Skype
- Altri server web installati

---

## ⚙️ Porta MySQL: 3306 vs 8889

### Quale usare?

**Consiglio:** Usa **3306** (porta standard MySQL)

**Vantaggi porta 3306:**
- ✅ Standard MySQL universale
- ✅ Compatibile con tutti i tool
- ✅ Già configurato in `config.php`

**Se usi porta 8889:**
- Devi modificare `api/config.php` linea 35 e 53:
  ```php
  $port = 8889; // Invece di 3306
  ```

---

## 📝 Checklist Finale

- [ ] MAMP configurato su porta 8888 (Apache)
- [ ] MAMP configurato su porta 3306 (MySQL)
- [ ] MAMP avviato (entrambi i server verdi)
- [ ] Test: http://localhost:8888/test_connection.php funziona
- [ ] Test: http://localhost:8888/login.html carica
- [ ] Login con credenziali sviluppatore funziona

---

## 🆘 Troubleshooting

### MAMP non parte sulla porta 8888

**Possibile causa:** Anche la 8888 è occupata

**Soluzione:**
```
1. Prova porta 8080 o 8000
2. Aggiorna gli URL di conseguenza
```

### phpMyAdmin non si trova

**Possibili URL:**
- http://localhost:8888/phpMyAdmin/
- http://localhost:8888/phpMyAdmin5/
- http://localhost:8888/MAMP/ (clicca su phpMyAdmin)

### MySQL non parte

**Causa:** Porta 3306 occupata

**Soluzione:**
```
1. Cambia porta MySQL a 8889 in MAMP
2. Aggiorna $port in config.php (linee 35 e 53)
```

---

## ✅ Risultato Atteso

Dopo la configurazione:

- ✅ MAMP funziona su porta 8888
- ✅ Nessun conflitto con altri servizi
- ✅ Applicazione accessibile su http://localhost:8888/
- ✅ Stesso setup del tuo altro computer

---

**Porta 8888 = Zero Problemi!** 🚀
