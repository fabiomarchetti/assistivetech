# 🚀 Guida Deploy su Aruba - PROCEDURA SEMPLIFICATA

## 📋 Procedura Step-by-Step (ZERO Problemi!)

### ✅ FASE 1: Preparazione Database Locale

1. **Apri phpMyAdmin locale**: `http://localhost:8888/phpMyAdmin/`

2. **Seleziona database**: `assistivetech_local`

3. **Esegui script preparazione**:
   - Clicca tab "SQL"
   - Apri file: `prepare_for_aruba.sql`
   - Copia tutto e incolla
   - Clicca "Esegui"

   ✅ **Risultato**: Link convertiti da `/Assistivetech/...` a `/...`

4. **Esporta database pulito**:
   - Tab "Esporta"
   - Metodo: Rapido
   - Formato: SQL
   - Clicca "Esegui"
   - Salva come: `assistivetech_production.sql`

---

### ✅ FASE 2: Upload FTP su Aruba

**Configurazione FTP**:
```
Host: ftp.assistivetech.it
User: 7985805@aruba.it
Pass: Filohori33!
Port: 21
```

**Cartelle da uploadare**:
```
LOCAL                           →  ARUBA (FTP)
======================================================
training_cognitivo/             →  /training_cognitivo/
api/                            →  /api/
admin/                          →  /admin/
agenda/                         →  /agenda/
index.html                      →  /index.html
login.html                      →  /login.html
dashboard.html                  →  /dashboard.html
.htaccess                       →  /.htaccess
```

⚠️ **NON uploadare**:
- `config.override.php.disabled`
- File `*.sql` (solo script, non dump)
- Cartelle di test (`test_*.html`, `test_*.php`)

---

### ✅ FASE 3: Importa Database su Aruba

1. **Apri phpMyAdmin Aruba**: http://mysql.aruba.it

2. **Login**:
   - User: `Sql1073852`
   - Pass: `5k58326940`

3. **Seleziona database**: `Sql1073852_1`

4. **Importa**:
   - Tab "Importa"
   - Scegli file: `assistivetech_production.sql`
   - Clicca "Esegui"

5. **Verifica**:
   - Tab "SQL"
   - Esegui:
   ```sql
   SELECT link FROM categorie_esercizi LIMIT 5;
   SELECT link FROM esercizi LIMIT 5;
   ```
   - I link devono iniziare con `/training_cognitivo/` (senza `/Assistivetech/`)

---

### ✅ FASE 4: Test Produzione

Apri questi URL e verifica funzionamento:

1. **Homepage**: https://assistivetech.it/
2. **Login**: https://assistivetech.it/login.html
3. **Admin**: https://assistivetech.it/admin/
4. **Training Cognitivo**: https://assistivetech.it/training_cognitivo/
5. **Categoria Test**: Clicca su una categoria e verifica che gli esercizi si aprano
6. **Esercizio Test**: Clicca su un esercizio e verifica che la pagina si carichi

✅ **Se tutto funziona → DEPLOY COMPLETATO!**

---

## 🔄 Torno a Lavorare in Locale?

Quando torni a lavorare sul tuo PC locale MAMP:

1. **Ri-esegui** `fix_link_database.sql` su database locale
2. Questo riaggiunge `/Assistivetech/` ai link
3. Continua a sviluppare normalmente

---

## 🎯 Vantaggi di Questa Procedura

✅ **ZERO modifiche manuali** ai file
✅ **ZERO problemi di path** o link rotti
✅ **Upload FTP diretto** della cartella `training_cognitivo/`
✅ **Database sincronizzato** automaticamente
✅ **Reversibile**: Puoi tornare in locale facilmente

---

## ❓ FAQ

**Q: Devo modificare file PHP prima dell'upload?**
A: NO! Il file `config.php` rileva automaticamente l'ambiente.

**Q: Cosa fa `config.php` in produzione?**
A: Automaticamente:
- Rileva host `assistivetech.it` (non `localhost`)
- Usa `BASE_PATH = ''` (nessun prefisso)
- Disabilita debug mode
- Connette al database Aruba

**Q: I link funzioneranno subito?**
A: SÌ! Perché hai preparato il database con `prepare_for_aruba.sql`

**Q: Posso creare nuove categorie/esercizi direttamente su Aruba?**
A: SÌ! Il sistema auto-genera tutto correttamente anche in produzione.

---

## 🛠️ Troubleshooting

**Problema**: Link danno 404 su Aruba
**Soluzione**: Verifica che `prepare_for_aruba.sql` sia stato eseguito

**Problema**: Errore connessione database
**Soluzione**: Verifica credenziali in `config.php` (linee 68-71)

**Problema**: File non uploadati
**Soluzione**: Controlla filtro FTP in pannello Aruba (Sicurezza → Limita accesso FTP)

---

## 📝 Checklist Finale

Prima del deploy, verifica:

- [ ] Eseguito `prepare_for_aruba.sql` su database locale
- [ ] Esportato database → `assistivetech_production.sql`
- [ ] Configurato filtro FTP in pannello Aruba
- [ ] Uploadato tutte le cartelle via FTP
- [ ] Importato database su http://mysql.aruba.it
- [ ] Testato URL produzione
- [ ] Verificato che categorie/esercizi si aprano

✅ **DEPLOY COMPLETATO CON SUCCESSO!** 🎉
