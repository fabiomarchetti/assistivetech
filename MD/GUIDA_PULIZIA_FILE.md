# 🧹 Guida Pulizia File Flutter Obsoleti

**Data**: 21 Ottobre 2025
**Obiettivo**: Rimuovere file Flutter non più necessari dopo conversione JavaScript

---

## 📋 File/Cartelle da Eliminare

### File Flutter da Rimuovere:
- ✅ `pubspec.yaml` - Configurazione dipendenze Flutter
- ✅ `pubspec.lock` - Lock file dipendenze
- ✅ `analysis_options.yaml` - Regole lint Dart

### Cartelle Flutter da Rimuovere:
- ✅ `lib/` - Codice sorgente Dart
- ✅ `.dart_tool/` - Cache tool Dart
- ✅ `web/` (SOLO se esercizio ha index.html JavaScript nella root)
- ✅ `assets/` (SOLO se vuota o inutilizzata)

### File Backup da Rimuovere (opzionale):
- ⚠️ `index_OLD_FLUTTER.html` - Backup vecchia versione

---

## 🚀 PROCEDURA SICURA

### STEP 1: Rinomina con Underscore (SICUREZZA)

**Esegui lo script batch**:
```
C:\MAMP\htdocs\Assistivetech\rinomina_flutter_obsoleti.bat
```

**Cosa fa lo script**:
1. Rinomina `pubspec.yaml` → `_pubspec.yaml`
2. Rinomina `pubspec.lock` → `_pubspec.lock`
3. Rinomina `analysis_options.yaml` → `_analysis_options.yaml`
4. Rinomina cartella `lib/` → `_lib/`
5. Rinomina cartella `.dart_tool/` → `_.dart_tool/`

**RISULTATO**: File ancora presenti ma "disabilitati" con underscore

---

### STEP 2: Test Completo Applicazione

**Test da eseguire**:

1. **Ordina Lettere** (convertito):
   ```
   http://localhost:8888/Assistivetech/training_cognitivo/sequenze_logiche/ordina_lettere/setup.html
   ```
   - ✅ Setup carica
   - ✅ Esercizio funziona
   - ✅ Database salva

2. **Cerca Colore**:
   ```
   http://localhost:8888/Assistivetech/training_cognitivo/trascina_immagini/cerca_colore/setup.html
   ```
   - ✅ Funziona normalmente

3. **Cerca Animali**:
   ```
   http://localhost:8888/Assistivetech/training_cognitivo/categorizzazione/animali/
   ```
   - ✅ Funziona normalmente

4. **Accendi la Luce**:
   ```
   http://localhost:8888/Assistivetech/training_cognitivo/causa_effetto/accendi_la_luce/
   ```
   - ✅ Funziona normalmente

**SE TUTTO FUNZIONA** → Procedi allo Step 3
**SE QUALCOSA NON FUNZIONA** → Ripristina rimuovendo underscore

---

### STEP 3: Eliminazione Manuale

**SOLO se tutti i test passano!**

#### Opzione A: Elimina via Esplora File
1. Apri Esplora File Windows
2. Naviga a `C:\MAMP\htdocs\Assistivetech\training_cognitivo`
3. Cerca (CTRL+F): `_pubspec`
4. Seleziona tutti i risultati → Elimina
5. Ripeti per: `_lib`, `_.dart_tool`, `_analysis_options`

#### Opzione B: Elimina via Comando
```batch
cd C:\MAMP\htdocs\Assistivetech\training_cognitivo

REM Elimina file
del /s /q _pubspec.yaml
del /s /q _pubspec.lock
del /s /q _analysis_options.yaml

REM Elimina cartelle
for /d /r %%d in (_lib) do rd /s /q "%%d"
for /d /r %%d in (_.dart_tool) do rd /s /q "%%d"
```

---

## 📊 Spazio Liberato (Stimato)

| Tipo File/Cartella | Quantità | Spazio |
|---------------------|----------|--------|
| `pubspec.yaml` | 8 file | ~8 KB |
| `pubspec.lock` | 8 file | ~80 KB |
| `lib/` cartelle | 8 | ~200 KB |
| `.dart_tool/` cartelle | 8 | ~500 MB (!) |
| `analysis_options.yaml` | 8 file | ~4 KB |
| **TOTALE STIMATO** | | **~500 MB** |

**Beneficio principale**: Liberare 500MB di cache `.dart_tool`

---

## 🗂️ Struttura PRIMA vs DOPO

### PRIMA (con Flutter):
```
ordina_lettere/
├── pubspec.yaml           ❌ Flutter
├── pubspec.lock           ❌ Flutter
├── analysis_options.yaml  ❌ Flutter
├── lib/                   ❌ Flutter (codice Dart)
│   └── main.dart
├── .dart_tool/            ❌ Flutter (cache 50-100MB!)
├── web/                   ❌ Flutter build
│   └── index.html
├── setup.html             ✅ JavaScript (NUOVO)
└── index.html             ✅ JavaScript (NUOVO)
```

### DOPO (solo JavaScript):
```
ordina_lettere/
├── setup.html             ✅ JavaScript
├── index.html             ✅ JavaScript
├── manifest.json          ✅ PWA
└── icons/                 ✅ PWA
    ├── icon-192.png
    └── icon-512.png
```

**Risultato**: Cartella pulita, solo file necessari!

---

## ⚠️ ATTENZIONE: Esercizi da NON Toccare

**NON eliminare file Flutter** da questi esercizi (ancora da convertire):

1. `sequenze_logiche/ordina_numeri/` - Da convertire
2. `sequenze_logiche/ordina_le_azioni_quotidiane/` - Da convertire
3. `categorizzazione/riconosci_categoria/` - Da convertire
4. `test_memoria/ricorda_sequenza/` - Da convertire
5. `scrivi_con_le_sillabe/scrivi_con_le_sillabe/` - Da convertire
6. `scrivi/scrivi_parole/` - Da convertire

**Per questi**, rinomina con underscore MA non eliminare ancora!

---

## 🔄 Ripristino di Emergenza

**Se qualcosa smette di funzionare**:

### Opzione 1: Ripristina Singolo Esercizio
```batch
cd C:\MAMP\htdocs\Assistivetech\training_cognitivo\[categoria]\[esercizio]

ren _pubspec.yaml pubspec.yaml
ren _pubspec.lock pubspec.lock
ren _lib lib
ren _.dart_tool .dart_tool
```

### Opzione 2: Ripristina Tutto
Esegui script inverso:
```batch
cd C:\MAMP\htdocs\Assistivetech\training_cognitivo

for /r %%f in (_pubspec.yaml) do ren "%%f" "pubspec.yaml"
for /r %%f in (_pubspec.lock) do ren "%%f" "pubspec.lock"
for /d /r %%d in (_lib) do ren "%%d" "lib"
for /d /r %%d in (_.dart_tool) do ren "%%d" ".dart_tool"
```

---

## ✅ Checklist Pulizia

### Pre-Pulizia:
- [ ] Backup completo cartella `training_cognitivo` (copia su disco esterno)
- [ ] Verifica che esercizi JavaScript funzionino
- [ ] Esegui script rinomina con underscore

### Test:
- [ ] Test "Ordina Lettere" (convertito)
- [ ] Test "Cerca Colore"
- [ ] Test "Cerca Animali"
- [ ] Test "Accendi la Luce"
- [ ] Nessun errore in console browser

### Post-Test (se OK):
- [ ] Elimina file `_pubspec.*`
- [ ] Elimina cartelle `_lib/`
- [ ] Elimina cartelle `_.dart_tool/`
- [ ] Verifica spazio liberato
- [ ] Re-test applicazioni

### Opzionale:
- [ ] Elimina `index_OLD_FLUTTER.html` (backup)
- [ ] Elimina cartelle `web/` Flutter (se esercizio ha index.html JavaScript)

---

## 📝 Log Eliminazioni

**Esercizi Puliti**:
- [x] `sequenze_logiche/ordina_lettere/` - Convertito JavaScript ✅

**Esercizi da Pulire Dopo Conversione**:
- [ ] `sequenze_logiche/ordina_numeri/`
- [ ] `sequenze_logiche/ordina_le_azioni_quotidiane/`
- [ ] `categorizzazione/riconosci_categoria/`
- [ ] `test_memoria/ricorda_sequenza/`
- [ ] `scrivi_con_le_sillabe/scrivi_con_le_sillabe/`
- [ ] `scrivi/scrivi_parole/`

---

## 🎯 Risultato Finale

**Obiettivo**: Cartella `training_cognitivo` pulita con solo file JavaScript necessari

**Benefici**:
- ✅ -500MB spazio disco
- ✅ Struttura file chiara
- ✅ Deploy più veloce (meno file da caricare)
- ✅ Nessuna confusione Flutter vs JavaScript

---

**IMPORTANTE**:
1. Prima RINOMINA con underscore
2. Poi TESTA tutto
3. Solo dopo ELIMINA

**NON saltare lo step di test!**

---

**Documento compilato**: 21 Ottobre 2025
**Autore**: Claude Code
**Versione**: 1.0
