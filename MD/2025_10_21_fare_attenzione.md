# ⚠️ Guida Auto-Detection BASE_PATH - 21 Ottobre 2025

## 📋 Problema Risolto

Quando si sviluppa in **locale con MAMP**, l'applicazione risiede in:
```
http://localhost/Assistivetech/
```

Ma quando si carica su **Aruba (produzione)**, l'applicazione è in root:
```
https://www.assistivetech.it/
```

Questo causava problemi di percorsi doppi come:
```
❌ https://www.assistivetech.it/Assistivetech/training_cognitivo/...
✅ https://www.assistivetech.it/training_cognitivo/...
```

---

## ✅ Soluzione: Auto-Detection BASE_PATH

### 1. Template JavaScript Standard

**Aggiungi SEMPRE questo codice all'inizio di ogni nuovo file HTML:**

```javascript
<script>
// AUTO-DETECTION BASE_PATH (locale MAMP vs produzione Aruba)
const BASE_PATH = window.location.pathname.includes('/Assistivetech/') ? '/Assistivetech' : '';

// Funzione per normalizzare i link dal database
function normalizeLink(link) {
    if (!link) return link;
    
    // Se siamo in produzione (BASE_PATH vuoto) e il link contiene /Assistivetech/
    if (BASE_PATH === '' && link.includes('/Assistivetech/')) {
        // Rimuovi /Assistivetech/ dal link
        link = link.replace(/\/Assistivetech\//g, '/');
    }
    
    return link;
}
</script>
```

### 2. Come Usare BASE_PATH

**Per chiamate API:**
```javascript
// ❌ NON usare percorsi hardcodati
const response = await fetch('../api/api_esercizi.php');

// ✅ USA sempre BASE_PATH
const response = await fetch(`${BASE_PATH}/api/api_esercizi.php`);
```

**Per link HTML:**
```javascript
// ❌ NON usare percorsi hardcodati
<a href="/Assistivetech/training_cognitivo/esercizi/">Link</a>

// ✅ USA BASE_PATH dinamico
<a href="#" onclick="window.location.href=BASE_PATH+'/training_cognitivo/esercizi/'; return false;">Link</a>
```

**Per link dal database:**
```javascript
// ❌ NON usare link direttamente
exercisesList.innerHTML = `<a href="${exercise.link}">Esercizio</a>`;

// ✅ NORMALIZZA sempre i link dal database
const normalizedLink = normalizeLink(exercise.link);
exercisesList.innerHTML = `<a href="${normalizedLink}">Esercizio</a>`;
```

---

## 📝 Template Completo per Nuovi File

### File HTML Standard (es. setup.html, index.html)

```html
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Titolo Pagina</title>
    <!-- Altri meta tags e link CSS -->
</head>
<body>
    <!-- Contenuto HTML -->
    
    <script>
        // AUTO-DETECTION BASE_PATH (locale MAMP vs produzione Aruba)
        const BASE_PATH = window.location.pathname.includes('/Assistivetech/') ? '/Assistivetech' : '';
        
        // Funzione per normalizzare i link dal database
        function normalizeLink(link) {
            if (!link) return link;
            if (BASE_PATH === '' && link.includes('/Assistivetech/')) {
                return link.replace(/\/Assistivetech\//g, '/');
            }
            return link;
        }
        
        // Esempio: Chiamata API
        async function loadData() {
            const response = await fetch(`${BASE_PATH}/api/api_esempio.php`);
            const result = await response.json();
            
            // Se il risultato contiene link dal database, normalizzali
            if (result.data && result.data.link) {
                result.data.link = normalizeLink(result.data.link);
            }
        }
        
        // Esempio: Link dinamico
        function goToPage() {
            window.location.href = BASE_PATH + '/training_cognitivo/pagina/';
        }
    </script>
</body>
</html>
```

### File con tag `<base>` (es. Flutter)

```html
<!DOCTYPE html>
<html>
<head>
    <script>
        // AUTO-DETECTION BASE_PATH per tag <base>
        const BASE_PATH = window.location.pathname.includes('/Assistivetech/') ? '/Assistivetech' : '';
        document.write('<base href="' + BASE_PATH + '/training_cognitivo/app/">');
    </script>
    <!-- Altri tags -->
</head>
<body>
    <!-- Contenuto -->
</body>
</html>
```

---

## 🎯 Checklist per Nuovi File

Prima di creare un nuovo file HTML, verifica:

- [ ] Ho aggiunto l'auto-detection `BASE_PATH`?
- [ ] Ho aggiunto la funzione `normalizeLink()`?
- [ ] Tutte le chiamate API usano `${BASE_PATH}/api/...`?
- [ ] Tutti i link interni usano `${BASE_PATH}/percorso/...`?
- [ ] I link dal database vengono normalizzati con `normalizeLink()`?
- [ ] Non ci sono percorsi hardcodati `/Assistivetech/...`?

---

## 📁 File Già Corretti

Questi file hanno già l'auto-detection implementata e **NON** devono essere modificati:

### Backend PHP
- `api/config.php` ✅

### Frontend - Pagine Master
- `training_cognitivo/index.html` ✅
- `admin/index.html` ✅

### Frontend - Setup Esercizi
- `training_cognitivo/categorizzazione/veicoli/setup.html` ✅
- `training_cognitivo/categorizzazione/animali/setup.html` ✅
- `training_cognitivo/categorizzazione/frutti/setup.html` ✅
- `training_cognitivo/categorizzazione/veicoli_aria/setup.html` ✅
- `training_cognitivo/categorizzazione/veicoli_mare/setup.html` ✅
- `training_cognitivo/causa_effetto/accendi_la_luce/setup.html` ✅
- `training_cognitivo/scrivi/scrivi_parole/setup.html` ✅

### Frontend - Index Esercizi
- `training_cognitivo/categorizzazione/veicoli/index.html` ✅
- `training_cognitivo/categorizzazione/animali/index.html` ✅
- `training_cognitivo/categorizzazione/frutti/index.html` ✅
- `training_cognitivo/categorizzazione/veicoli_aria/index.html` ✅
- `training_cognitivo/categorizzazione/veicoli_mare/index.html` ✅

### Frontend - Redirect e Altri
- `training_cognitivo/scrivi/scrivi_parole/index.html` ✅
- `training_cognitivo/scrivi_con_le_sillabe/scrivi_con_le_sillabe/index.html` ✅
- `training_cognitivo/categorizzazione/cerca_veicoli_di_terra/index.html` ✅
- `training_cognitivo/trascina_immagini/cerca_colore/setup.html` ✅ (già implementato in precedenza)

### Frontend - Pagine Risultati (Aggiornato 22/10/2025)
- `risultati/index.html` ✅
- `risultati/istogramma.html` ✅
- `risultati/trend.html` ✅
- `risultati/scatter.html` ✅
- `risultati/items.html` ✅

---

## 🚀 Best Practices

### ✅ DO (Fai Così)

1. **Usa sempre BASE_PATH per percorsi assoluti:**
   ```javascript
   const url = `${BASE_PATH}/api/endpoint.php`;
   ```

2. **Normalizza i link dal database:**
   ```javascript
   const link = normalizeLink(exercise.link);
   ```

3. **Testa in entrambi gli ambienti:**
   - Locale: `http://localhost/Assistivetech/training_cognitivo/`
   - Produzione: `https://www.assistivetech.it/training_cognitivo/`

### ❌ DON'T (Non Fare Così)

1. **Non hardcodare mai /Assistivetech/:**
   ```javascript
   // ❌ SBAGLIATO
   const url = '/Assistivetech/api/endpoint.php';
   ```

2. **Non usare percorsi relativi per API:**
   ```javascript
   // ❌ EVITA (può causare problemi)
   const url = '../api/endpoint.php';
   
   // ✅ MEGLIO
   const url = `${BASE_PATH}/api/endpoint.php`;
   ```

3. **Non dimenticare di normalizzare link dal DB:**
   ```javascript
   // ❌ SBAGLIATO
   link.href = exercise.link;
   
   // ✅ CORRETTO
   link.href = normalizeLink(exercise.link);
   ```

---

## 🔍 Come Funziona l'Auto-Detection

```javascript
// Rileva se siamo in locale o produzione
const BASE_PATH = window.location.pathname.includes('/Assistivetech/') 
    ? '/Assistivetech'  // 🏠 Locale MAMP
    : '';               // ☁️ Produzione Aruba

// ESEMPI:
// Locale:      window.location.pathname = "/Assistivetech/training_cognitivo/"
//              BASE_PATH = "/Assistivetech"

// Produzione:  window.location.pathname = "/training_cognitivo/"
//              BASE_PATH = ""
```

---

## 📊 Riepilogo Modifiche 21/10/2025

**Problema originale:**
- Link duplicati: `https://www.assistivetech.it/Assistivetech/...` → 404 Error

**Soluzione implementata:**
- Auto-detection BASE_PATH in 20+ file
- Normalizzazione automatica dei link dal database
- Compatibilità totale locale/produzione

**Risultato:**
- ✅ Locale e produzione funzionano senza modifiche
- ✅ Deployment su Aruba semplificato
- ✅ Nessun percorso hardcodato

---

## 📞 In Caso di Problemi

Se dopo aver creato un nuovo file HTML i link non funzionano:

1. **Verifica** che il file abbia l'auto-detection BASE_PATH
2. **Controlla** nella console del browser il valore di `BASE_PATH`
3. **Svuota** la cache del browser (`Ctrl+Shift+Del`)
4. **Testa** in finestra incognito/privata

---

**File creato:** 21 Ottobre 2025  
**Autore:** Kilo Code (AI Assistant)  
**Versione:** 1.0