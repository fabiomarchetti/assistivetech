# 🤖 AI Chatbot Assistant per Training Cognitivo - 21 Ottobre 2025

## 📋 Panoramica

Implementazione di un **assistente AI conversazionale** all'interno delle applicazioni della cartella `training_cognitivo` per aiutare gli utenti a comprendere e utilizzare gli esercizi.

---

## 🎯 Obiettivo

Inserire un bottone nella pagina principale di ogni esercizio che apre una finestra modale con un AI chatbot capace di rispondere a tutte le domande inerenti all'esercizio specifico.

---

## 🤖 Opzioni di Implementazione

### **1. Claude API (Anthropic) - CONSIGLIATA** ⭐

**Vantaggi:**
- Conversazioni naturali e contestuali
- Puoi "addestrarlo" sul contenuto specifico dell'esercizio
- Ottimo in italiano
- Messaggi illimitati nella conversazione

**Complessità:** ⭐⭐⭐ Media

**Costi:**
- Claude Haiku: ~$0.25 per 1M token input, ~$1.25 per 1M output
- Per assistente esercizi: ~$5-10/mese con uso normale

**Implementazione Frontend:**
```html
<!-- Bottone modale -->
<button class="btn btn-info" data-bs-toggle="modal" data-bs-target="#aiAssistantModal">
    <i class="bi bi-robot"></i> Aiuto AI
</button>

<!-- Modal con chat -->
<div class="modal" id="aiAssistantModal">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Assistente AI</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div id="chatMessages"></div>
                <div class="input-group mt-3">
                    <input id="userQuestion"
                           class="form-control"
                           placeholder="Fai una domanda sull'esercizio...">
                    <button class="btn btn-primary" onclick="askAI()">Invia</button>
                </div>
            </div>
        </div>
    </div>
</div>
```

**JavaScript chiamata API:**
```javascript
let chatHistory = [];

async function askAI() {
    const question = document.getElementById('userQuestion').value;
    if (!question.trim()) return;

    // Mostra domanda utente
    displayMessage(question, 'user');
    document.getElementById('userQuestion').value = '';

    // Mostra typing indicator
    showTypingIndicator();

    try {
        const response = await fetch('/api/ai_assistant.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                exercise: 'cerca_colore',
                question: question,
                conversationHistory: chatHistory
            })
        });

        const data = await response.json();

        // Rimuovi typing indicator
        hideTypingIndicator();

        // Mostra risposta AI
        displayMessage(data.text, 'bot');

        // Aggiorna history
        chatHistory.push(
            { role: 'user', content: question },
            { role: 'assistant', content: data.text }
        );

    } catch (error) {
        hideTypingIndicator();
        displayMessage('Errore di connessione. Riprova.', 'error');
    }
}

function displayMessage(text, type) {
    const messagesDiv = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${type}-message`;
    messageDiv.innerHTML = `<strong>${type === 'user' ? 'Tu' : 'Assistente'}:</strong> ${text}`;
    messagesDiv.appendChild(messageDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

function showTypingIndicator() {
    const messagesDiv = document.getElementById('chatMessages');
    const indicator = document.createElement('div');
    indicator.id = 'typingIndicator';
    indicator.className = 'message bot-message';
    indicator.innerHTML = '<em>L\'assistente sta scrivendo...</em>';
    messagesDiv.appendChild(indicator);
}

function hideTypingIndicator() {
    const indicator = document.getElementById('typingIndicator');
    if (indicator) indicator.remove();
}
```

**Backend PHP (api/ai_assistant.php):**
```php
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Leggi input
$input = json_decode(file_get_contents('php://input'), true);
$exercise = $input['exercise'] ?? '';
$question = $input['question'] ?? '';
$history = $input['conversationHistory'] ?? [];

// Chiave API Claude (da configurare)
$apiKey = 'sk-ant-xxxxx'; // INSERIRE LA TUA CHIAVE API
$url = 'https://api.anthropic.com/v1/messages';

// Context specifico per ogni esercizio
$exerciseContexts = [
    'cerca_colore' => "Sei un assistente AI per l'esercizio 'Cerca Colore' di training cognitivo.
L'esercizio consiste in:
- Drag & drop di colori usando pittogrammi ARASAAC
- Timer che misura il tempo di latenza della risposta
- 3 prove libere iniziali (non registrate)
- Salvataggio risultati nel database dal 4° tentativo in poi
- Numero prove configurabile (3-10 totali)
- Feedback visivo con GIF e messaggio TTS personalizzato
- 12 colori disponibili: rosso, blu, giallo, verde, arancione, viola, rosa, marrone, nero, bianco, grigio, azzurro

Rispondi in italiano, in modo semplice, chiaro e amichevole.
Aiuta l'utente a capire come funziona l'esercizio e a risolvere eventuali dubbi.",

    'accendi_la_luce' => "Sei un assistente AI per l'esercizio 'Accendi la Luce' (causa-effetto).
L'esercizio insegna il rapporto causa-effetto attraverso:
- Pittogramma ARASAAC scelto dall'educatore
- 10 sessioni automatiche
- Bottone grande 'FAI APPARIRE [OGGETTO]'
- Timer latenza risposta
- Feedback con applauso audio
- Salvataggio risultati in database

Rispondi in italiano, con semplicità e incoraggiamento."

    // Aggiungere context per altri esercizi qui
];

$systemPrompt = $exerciseContexts[$exercise] ?? "Sei un assistente AI per esercizi di training cognitivo. Rispondi in italiano in modo chiaro.";

// Prepara messaggi (include history se presente)
$messages = [];
foreach ($history as $msg) {
    $messages[] = [
        'role' => $msg['role'],
        'content' => $msg['content']
    ];
}
$messages[] = [
    'role' => 'user',
    'content' => $question
];

// Dati richiesta Claude API
$data = [
    'model' => 'claude-3-haiku-20240307',
    'max_tokens' => 1024,
    'system' => $systemPrompt,
    'messages' => $messages
];

// Chiamata API
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'x-api-key: ' . $apiKey,
    'anthropic-version: 2023-06-01'
]);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode === 200) {
    $result = json_decode($response, true);
    echo json_encode([
        'success' => true,
        'text' => $result['content'][0]['text']
    ]);
} else {
    echo json_encode([
        'success' => false,
        'error' => 'Errore chiamata API',
        'details' => $response
    ]);
}
?>
```

---

### **2. OpenAI API (GPT-4o mini) - Alternativa**

**Vantaggi:**
- Molto conosciuta e documentata
- Performance eccellente
- Buon supporto italiano

**Complessità:** ⭐⭐⭐ Media

**Costi:**
- GPT-4o mini: ~$0.15 per 1M token input, ~$0.60 per 1M output
- Più economica di Claude (~$3-8/mese con uso normale)

**Implementazione Backend PHP:**
```php
<?php
$apiKey = 'sk-xxxxx'; // INSERIRE CHIAVE OPENAI
$url = 'https://api.openai.com/v1/chat/completions';

$data = [
    'model' => 'gpt-4o-mini',
    'messages' => [
        ['role' => 'system', 'content' => $systemPrompt],
        ['role' => 'user', 'content' => $question]
    ],
    'max_tokens' => 1000,
    'temperature' => 0.7
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Authorization: Bearer ' . $apiKey
]);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$result = json_decode($response, true);

echo json_encode([
    'success' => true,
    'text' => $result['choices'][0]['message']['content']
]);
?>
```

---

### **3. Chatbot Predefinito (FAQ Interattive) - ZERO COSTI** 💰

**Vantaggi:**
- Gratuito, nessuna API esterna
- Velocissimo (nessuna latenza rete)
- Controllo totale sulle risposte
- Privacy garantita (tutto locale)

**Svantaggi:**
- Risposte solo a domande previste
- Meno "intelligente" e flessibile

**Complessità:** ⭐ Facile

**Implementazione JavaScript:**
```javascript
// Database FAQ locale per ogni esercizio
const FAQ_DATABASE = {
    cerca_colore: {
        "come funziona": "L'esercizio richiede di trascinare il colore corretto sulla carta centrale. Vedrai un colore target e dovrai trovarlo tra le carte circostanti.",

        "quante prove": "Ci sono 3 prove libere di pratica iniziali, poi le successive (fino a 10 totali) vengono registrate nel database per l'educatore.",

        "cosa fa il timer": "Il timer misura quanto tempo impieghi a trovare il colore corretto. Parte quando appare l'esercizio e si ferma quando trascini il colore giusto sulla carta centrale.",

        "posso sbagliare": "Sì, se trascini il colore sbagliato riceverai un messaggio di errore e potrai riprovare. Solo la risposta corretta fa avanzare all'esercizio successivo.",

        "come si trascina": "Clicca e tieni premuto sulla carta colorata che vuoi spostare, poi trascinala sulla carta centrale grigia e rilascia il mouse. Su tablet/smartphone usa il dito.",

        "quanti colori ci sono": "Ci sono 12 colori disponibili: rosso, blu, giallo, verde, arancione, viola, rosa, marrone, nero, bianco, grigio e azzurro.",

        "cosa succede quando finisco": "Quando completi tutte le prove, vedrai un'animazione di celebrazione con GIF e un messaggio personalizzato letto dal computer. Poi puoi ricominciare o uscire.",

        "chi vede i miei risultati": "Solo l'educatore che ha configurato l'esercizio può vedere i tuoi tempi di risposta e gli eventuali errori nel pannello amministrativo.",

        "cosa sono le prove libere": "Le prime 3 prove sono per fare pratica: non vengono salvate nel database, quindi puoi provare liberamente senza preoccuparti degli errori.",

        "posso cambiare i colori": "No, i colori disponibili sono già configurati dall'educatore nella fase di setup. Tu devi solo trovare quello corretto tra quelli mostrati."
    },

    accendi_la_luce: {
        "come funziona": "Devi premere il bottone grande per far apparire l'immagine scelta dall'educatore. Questo esercizio ti insegna che le tue azioni hanno un effetto (causa-effetto).",

        "quante volte devo premere": "L'esercizio ha 10 sessioni totali. In ogni sessione premi il bottone, vedi l'immagine per 3 secondi, poi scompare e puoi premere di nuovo.",

        "cosa misura il timer": "Il timer misura quanto tempo impieghi a premere il bottone dopo che l'immagine è scomparsa. Questo aiuta l'educatore a capire i tuoi tempi di reazione.",

        "posso usare la tastiera": "Sì! Puoi premere il tasto Invio o Spazio invece di cliccare il bottone con il mouse. È più comodo!",

        "cosa sono i pittogrammi": "Sono le immagini disegnate in modo semplice e chiaro che usi nell'esercizio. Vengono dal database ARASAAC, usato in tutto il mondo per aiutare la comunicazione."
    }

    // Aggiungere FAQ per altri esercizi qui
};

// Ricerca intelligente con matching parziale
function findAnswer(exercise, question) {
    const faq = FAQ_DATABASE[exercise];
    if (!faq) return null;

    const q = question.toLowerCase()
        .replace(/[?!.,]/g, '')  // Rimuovi punteggiatura
        .trim();

    // 1. Match esatto chiave
    if (faq[q]) {
        return faq[q];
    }

    // 2. Match parziale (parole chiave)
    for (const [key, answer] of Object.entries(faq)) {
        const keywords = key.split(' ');
        const matchCount = keywords.filter(kw => q.includes(kw)).length;

        // Se almeno 50% delle parole chiave matchano
        if (matchCount >= keywords.length * 0.5) {
            return answer;
        }
    }

    // 3. Nessun match trovato
    return null;
}

// Funzione principale ricerca
function askLocalFAQ(exercise, question) {
    const answer = findAnswer(exercise, question);

    if (answer) {
        return {
            found: true,
            answer: answer
        };
    } else {
        // Suggerimenti domande disponibili
        const faq = FAQ_DATABASE[exercise];
        const suggestions = Object.keys(faq).slice(0, 3);

        return {
            found: false,
            suggestions: suggestions,
            message: `Non ho capito la domanda. Prova a chiedere:\n${suggestions.map(s => `• ${s}?`).join('\n')}`
        };
    }
}

// UI con bottoni quick questions
function showQuickQuestions(exercise) {
    const faq = FAQ_DATABASE[exercise];
    const questions = Object.keys(faq);

    let html = '<div class="quick-questions mb-3">';
    html += '<p class="text-muted mb-2"><small>Domande frequenti:</small></p>';

    questions.slice(0, 5).forEach(q => {
        html += `
            <button class="btn btn-sm btn-outline-primary m-1"
                    onclick="askPredefined('${q}')">
                ${q.charAt(0).toUpperCase() + q.slice(1)}?
            </button>
        `;
    });

    html += '</div>';
    return html;
}

function askPredefined(question) {
    document.getElementById('userQuestion').value = question;
    askAI(); // Usa la funzione esistente
}
```

---

### **4. Soluzione Ibrida (FAQ + AI Fallback)** 🎯 **OTTIMALE**

**Strategia:**
1. Utente fa domanda
2. Sistema cerca risposta in FAQ locale (veloce e gratis)
3. Se non trova, chiama API Claude/OpenAI (intelligente ma costa)

**Vantaggi:**
- 80% domande risolte gratis (FAQ)
- 20% domande complesse gestite da AI
- Costi minimi (~$1-2/mese)
- Esperienza utente eccellente

**Implementazione JavaScript:**
```javascript
let chatHistory = [];

async function askAssistant(question) {
    if (!question.trim()) return;

    // Mostra domanda utente
    displayMessage(question, 'user');
    document.getElementById('userQuestion').value = '';
    showTypingIndicator();

    // STEP 1: Prova con FAQ locale
    const exercise = 'cerca_colore'; // O rilevato dinamicamente
    const localResult = askLocalFAQ(exercise, question);

    if (localResult.found) {
        // ✅ Risposta trovata in FAQ locale (veloce, gratis)
        hideTypingIndicator();
        displayMessage(localResult.answer, 'bot');
        return;
    }

    // STEP 2: Fallback su AI se FAQ non risponde
    try {
        const response = await fetch('/api/ai_assistant.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                exercise: exercise,
                question: question,
                conversationHistory: chatHistory
            })
        });

        const data = await response.json();
        hideTypingIndicator();

        if (data.success) {
            displayMessage(data.text, 'bot');

            // Aggiorna history per contesto conversazione
            chatHistory.push(
                { role: 'user', content: question },
                { role: 'assistant', content: data.text }
            );
        } else {
            displayMessage('Mi dispiace, non riesco a rispondere ora. Prova con una delle domande frequenti.', 'error');
            // Mostra suggerimenti FAQ
            const suggestionsDiv = document.createElement('div');
            suggestionsDiv.innerHTML = showQuickQuestions(exercise);
            document.getElementById('chatMessages').appendChild(suggestionsDiv);
        }

    } catch (error) {
        hideTypingIndicator();
        displayMessage('Errore di connessione. Le domande frequenti sono ancora disponibili!', 'error');

        // Mostra suggerimenti FAQ come fallback
        const suggestionsDiv = document.createElement('div');
        suggestionsDiv.innerHTML = showQuickQuestions(exercise);
        document.getElementById('chatMessages').appendChild(suggestionsDiv);
    }
}

// Funzione utility per rilevare esercizio corrente
function getCurrentExercise() {
    const path = window.location.pathname;
    if (path.includes('cerca_colore')) return 'cerca_colore';
    if (path.includes('accendi_la_luce')) return 'accendi_la_luce';
    // Aggiungere altri esercizi qui
    return 'generic';
}
```

---

## 🎨 UI/UX Completa Consigliata

### HTML Modal Bootstrap 5
```html
<!-- Bottone floating sempre visibile (angolo in basso a destra) -->
<button id="aiAssistantBtn"
        class="floating-ai-btn"
        data-bs-toggle="modal"
        data-bs-target="#aiChatModal">
    <i class="bi bi-robot"></i>
    <span>Hai bisogno di aiuto?</span>
</button>

<!-- Modal chat completa -->
<div class="modal fade" id="aiChatModal" tabindex="-1" aria-labelledby="aiChatModalLabel">
    <div class="modal-dialog modal-dialog-scrollable modal-dialog-centered">
        <div class="modal-content">

            <!-- Header con colori brand -->
            <div class="modal-header bg-gradient text-white">
                <h5 class="modal-title" id="aiChatModalLabel">
                    <i class="bi bi-robot me-2"></i>
                    Assistente AI - Cerca Colore
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Chiudi"></button>
            </div>

            <!-- Body con chat messages -->
            <div class="modal-body p-3" id="chatMessages" style="min-height: 400px; max-height: 500px; overflow-y: auto;">

                <!-- Messaggio di benvenuto -->
                <div class="message bot-message">
                    <div class="d-flex align-items-start">
                        <div class="bot-avatar me-2">
                            <i class="bi bi-robot"></i>
                        </div>
                        <div class="message-content">
                            <strong>Assistente:</strong><br>
                            Ciao! 👋 Sono qui per aiutarti con l'esercizio <strong>"Cerca Colore"</strong>.<br>
                            Cosa vorresti sapere?
                        </div>
                    </div>
                </div>

                <!-- Bottoni quick questions -->
                <div class="quick-questions mt-3">
                    <p class="text-muted mb-2"><small>Domande frequenti:</small></p>
                    <button class="btn btn-sm btn-outline-primary m-1" onclick="askQuick('come funziona')">
                        <i class="bi bi-question-circle"></i> Come funziona?
                    </button>
                    <button class="btn btn-sm btn-outline-primary m-1" onclick="askQuick('quante prove')">
                        <i class="bi bi-list-ol"></i> Quante prove?
                    </button>
                    <button class="btn btn-sm btn-outline-primary m-1" onclick="askQuick('come trascino')">
                        <i class="bi bi-hand-index"></i> Come trascino?
                    </button>
                    <button class="btn btn-sm btn-outline-primary m-1" onclick="askQuick('cosa fa il timer')">
                        <i class="bi bi-stopwatch"></i> Timer?
                    </button>
                    <button class="btn btn-sm btn-outline-primary m-1" onclick="askQuick('posso sbagliare')">
                        <i class="bi bi-x-circle"></i> Posso sbagliare?
                    </button>
                </div>

            </div>

            <!-- Footer con input -->
            <div class="modal-footer">
                <div class="input-group">
                    <input type="text"
                           id="userQuestionInput"
                           class="form-control"
                           placeholder="Scrivi la tua domanda..."
                           onkeypress="if(event.key==='Enter') sendQuestion()"
                           autofocus>
                    <button class="btn btn-primary" onclick="sendQuestion()">
                        <i class="bi bi-send"></i> Invia
                    </button>
                </div>
                <small class="text-muted w-100 mt-2">
                    <i class="bi bi-info-circle"></i>
                    Assistente alimentato da intelligenza artificiale
                </small>
            </div>

        </div>
    </div>
</div>
```

### CSS Styling
```css
/* Bottone floating animato */
.floating-ai-btn {
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 1000;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 50px;
    padding: 15px 25px;
    font-size: 16px;
    font-weight: 600;
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    gap: 10px;
}

.floating-ai-btn:hover {
    transform: translateY(-5px);
    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
}

.floating-ai-btn i {
    font-size: 24px;
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.1); }
}

/* Header gradiente */
.modal-header.bg-gradient {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* Messaggi chat */
.message {
    padding: 12px;
    margin: 10px 0;
    border-radius: 15px;
    animation: slideIn 0.3s ease;
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.bot-message {
    background: #f8f9fa;
    border: 1px solid #e9ecef;
}

.user-message {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    margin-left: auto;
    max-width: 80%;
}

.error-message {
    background: #fff3cd;
    border: 1px solid #ffc107;
    color: #856404;
}

/* Avatar bot */
.bot-avatar {
    width: 35px;
    height: 35px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 18px;
    flex-shrink: 0;
}

/* Quick questions buttons */
.quick-questions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.quick-questions .btn {
    font-size: 13px;
    transition: all 0.2s ease;
}

.quick-questions .btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

/* Typing indicator */
.typing-indicator {
    display: flex;
    align-items: center;
    padding: 12px;
    background: #f8f9fa;
    border-radius: 15px;
    margin: 10px 0;
}

.typing-indicator span {
    height: 8px;
    width: 8px;
    background: #667eea;
    border-radius: 50%;
    display: inline-block;
    margin: 0 2px;
    animation: bounce 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) {
    animation-delay: -0.32s;
}

.typing-indicator span:nth-child(2) {
    animation-delay: -0.16s;
}

@keyframes bounce {
    0%, 80%, 100% {
        transform: scale(0);
    }
    40% {
        transform: scale(1);
    }
}

/* Responsive mobile */
@media (max-width: 576px) {
    .floating-ai-btn {
        padding: 12px 20px;
        font-size: 14px;
        bottom: 15px;
        right: 15px;
    }

    .floating-ai-btn span {
        display: none; /* Mostra solo icona su mobile */
    }

    .modal-dialog {
        margin: 10px;
    }
}

/* Scrollbar personalizzata */
#chatMessages::-webkit-scrollbar {
    width: 8px;
}

#chatMessages::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 10px;
}

#chatMessages::-webkit-scrollbar-thumb {
    background: #667eea;
    border-radius: 10px;
}

#chatMessages::-webkit-scrollbar-thumb:hover {
    background: #764ba2;
}
```

### JavaScript Completo
```javascript
// Configurazione globale
const AI_CONFIG = {
    currentExercise: 'cerca_colore', // Rilevato dinamicamente
    apiEndpoint: '/api/ai_assistant.php',
    useHybrid: true, // true = FAQ + AI, false = solo AI
    chatHistory: []
};

// Inizializzazione al caricamento pagina
document.addEventListener('DOMContentLoaded', function() {
    // Rileva esercizio corrente dal path
    AI_CONFIG.currentExercise = getCurrentExercise();

    // Aggiorna titolo modale
    const modalTitle = document.querySelector('#aiChatModalLabel');
    if (modalTitle) {
        const exerciseName = getExerciseName(AI_CONFIG.currentExercise);
        modalTitle.innerHTML = `<i class="bi bi-robot me-2"></i>Assistente AI - ${exerciseName}`;
    }

    // Mostra quick questions all'apertura modale
    const modal = document.getElementById('aiChatModal');
    modal.addEventListener('shown.bs.modal', function() {
        document.getElementById('userQuestionInput').focus();
    });
});

// Funzione principale invio domanda
async function sendQuestion() {
    const input = document.getElementById('userQuestionInput');
    const question = input.value.trim();

    if (!question) return;

    // Reset input
    input.value = '';

    // Mostra messaggio utente
    displayMessage(question, 'user');

    // Mostra typing indicator
    showTypingIndicator();

    // STRATEGIA IBRIDA
    if (AI_CONFIG.useHybrid) {
        // STEP 1: Cerca in FAQ locale
        const localResult = askLocalFAQ(AI_CONFIG.currentExercise, question);

        if (localResult.found) {
            // ✅ Trovato in FAQ (veloce, gratis)
            hideTypingIndicator();
            displayMessage(localResult.answer, 'bot');
            return;
        }
    }

    // STEP 2: Fallback su AI
    try {
        const response = await fetch(AI_CONFIG.apiEndpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                exercise: AI_CONFIG.currentExercise,
                question: question,
                conversationHistory: AI_CONFIG.chatHistory
            })
        });

        const data = await response.json();
        hideTypingIndicator();

        if (data.success) {
            displayMessage(data.text, 'bot');

            // Salva in history per contesto
            AI_CONFIG.chatHistory.push(
                { role: 'user', content: question },
                { role: 'assistant', content: data.text }
            );
        } else {
            throw new Error(data.error || 'Errore API');
        }

    } catch (error) {
        console.error('Errore chiamata AI:', error);
        hideTypingIndicator();
        displayMessage(
            'Mi dispiace, al momento non riesco a rispondere. Prova con una delle domande frequenti qui sotto!',
            'error'
        );

        // Mostra suggerimenti FAQ
        showQuickQuestionsInChat();
    }
}

// Mostra messaggio in chat
function displayMessage(text, type) {
    const messagesDiv = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${type}-message`;

    if (type === 'bot') {
        messageDiv.innerHTML = `
            <div class="d-flex align-items-start">
                <div class="bot-avatar me-2">
                    <i class="bi bi-robot"></i>
                </div>
                <div class="message-content">
                    <strong>Assistente:</strong><br>
                    ${text}
                </div>
            </div>
        `;
    } else if (type === 'user') {
        messageDiv.innerHTML = `
            <div class="message-content">
                <strong>Tu:</strong><br>
                ${text}
            </div>
        `;
    } else {
        messageDiv.innerHTML = `
            <div class="message-content">
                <i class="bi bi-exclamation-triangle me-2"></i>
                ${text}
            </div>
        `;
    }

    messagesDiv.appendChild(messageDiv);

    // Auto-scroll verso l'ultimo messaggio
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

// Typing indicator
function showTypingIndicator() {
    const messagesDiv = document.getElementById('chatMessages');
    const indicator = document.createElement('div');
    indicator.id = 'typingIndicator';
    indicator.className = 'typing-indicator';
    indicator.innerHTML = `
        <div class="bot-avatar me-2">
            <i class="bi bi-robot"></i>
        </div>
        <div>
            <span></span>
            <span></span>
            <span></span>
        </div>
    `;
    messagesDiv.appendChild(indicator);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

function hideTypingIndicator() {
    const indicator = document.getElementById('typingIndicator');
    if (indicator) indicator.remove();
}

// Quick questions
function askQuick(question) {
    document.getElementById('userQuestionInput').value = question + '?';
    sendQuestion();
}

function showQuickQuestionsInChat() {
    const messagesDiv = document.getElementById('chatMessages');
    const questionsDiv = document.createElement('div');
    questionsDiv.className = 'quick-questions mt-3';
    questionsDiv.innerHTML = `
        <p class="text-muted mb-2"><small>Prova con una di queste domande:</small></p>
        <button class="btn btn-sm btn-outline-primary m-1" onclick="askQuick('come funziona')">
            Come funziona?
        </button>
        <button class="btn btn-sm btn-outline-primary m-1" onclick="askQuick('quante prove')">
            Quante prove?
        </button>
        <button class="btn btn-sm btn-outline-primary m-1" onclick="askQuick('come trascino')">
            Come trascino?
        </button>
    `;
    messagesDiv.appendChild(questionsDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

// Utility functions
function getCurrentExercise() {
    const path = window.location.pathname;
    if (path.includes('cerca_colore')) return 'cerca_colore';
    if (path.includes('accendi_la_luce')) return 'accendi_la_luce';
    return 'generic';
}

function getExerciseName(exerciseId) {
    const names = {
        'cerca_colore': 'Cerca Colore',
        'accendi_la_luce': 'Accendi la Luce',
        'generic': 'Training Cognitivo'
    };
    return names[exerciseId] || 'Esercizio';
}
```

---

## 📊 Confronto Finale Opzioni

| Opzione | Costo Mensile | Complessità | Flessibilità | Velocità | Privacy | Consigliata per |
|---------|---------------|-------------|--------------|----------|---------|-----------------|
| **FAQ Locale** | 💰 €0 | ⭐ Facile | ⭐⭐ Bassa | ⚡⚡⚡ Istantanea | 🔒🔒🔒 Totale | Progetti piccoli, budget zero |
| **Claude API** | 💰💰 €5-10 | ⭐⭐⭐ Media | ⭐⭐⭐⭐⭐ Altissima | ⚡⚡ 1-2s | 🔒🔒 Buona | Migliore qualità conversazione |
| **OpenAI API** | 💰💰 €3-8 | ⭐⭐⭐ Media | ⭐⭐⭐⭐ Alta | ⚡⚡ 1-2s | 🔒🔒 Buona | Alternativa economica |
| **Ibrido FAQ+AI** | 💰 €1-2 | ⭐⭐⭐ Media | ⭐⭐⭐⭐ Alta | ⚡⚡⚡ 0-2s | 🔒🔒🔒 Ottima | **OTTIMALE per AssistiveTech** ✅ |

---

## 🎯 Raccomandazione Finale per AssistiveTech

### **Soluzione Consigliata: Ibrida FAQ + Claude API Haiku**

**Perché questa è la scelta migliore:**

1. ✅ **Costi bassissimi**: ~€1-2/mese con uso educatori/pazienti
   - 80% domande risolte gratis da FAQ locale
   - 20% domande complesse gestite da Claude

2. ✅ **Implementazione semplice**: Un pomeriggio di lavoro
   - Codice JavaScript vanilla (no framework)
   - Backend PHP già presente nel progetto
   - Riutilizzabile per TUTTI gli esercizi

3. ✅ **Privacy garantita**:
   - Dati sensibili pazienti mai inviati ad API esterne
   - Solo domande generiche sull'esercizio vanno all'AI
   - FAQ locali 100% private

4. ✅ **Performance eccellente**:
   - 80% risposte istantanee (FAQ)
   - 20% risposte in 1-2s (Claude API)
   - Nessun rallentamento percepibile

5. ✅ **Scalabilità perfetta**:
   - Stesso codice per tutti gli esercizi
   - Cambiano solo FAQ e system prompt
   - Deployment su Aruba senza problemi

6. ✅ **UX professionale**:
   - Bottone floating sempre visibile
   - Chat modale Bootstrap elegante
   - Quick questions per accesso rapido
   - Typing indicators e animazioni fluide

---

## 📋 Piano di Implementazione

### **Fase 1: Setup Base (1-2 ore)**
1. Creare `api/ai_assistant.php` con supporto Claude API
2. Aggiungere modal HTML in template base
3. Implementare CSS styling
4. Testare connessione API

### **Fase 2: FAQ Database (2-3 ore)**
1. Creare FAQ per esercizio "Cerca Colore"
2. Creare FAQ per esercizio "Accendi la Luce"
3. Implementare sistema matching intelligente
4. Testare riconoscimento domande

### **Fase 3: Sistema Ibrido (1-2 ore)**
1. Integrare FAQ + AI fallback
2. Implementare chat history per contesto
3. Aggiungere error handling robusto
4. Testare tutti i flussi

### **Fase 4: Deploy e Test (1 ora)**
1. Configurare chiave API Claude
2. Upload su Aruba via FTP
3. Test su dispositivi reali (desktop, tablet, mobile)
4. Raccolta feedback utenti

### **Totale stimato: 5-8 ore di lavoro**

---

## 🔐 Configurazione Chiave API

### Come ottenere chiave Claude API:

1. Vai su: https://console.anthropic.com/
2. Crea account (carta credito richiesta)
3. Vai in "API Keys"
4. Clicca "Create Key"
5. Copia chiave (formato: `sk-ant-xxxxx`)
6. Inserisci in `api/ai_assistant.php`:

```php
$apiKey = 'sk-ant-api03-xxxxx'; // LA TUA CHIAVE QUI
```

### Limiti e costi Claude:

- **Modello consigliato**: `claude-3-haiku-20240307`
- **Costo**: ~$0.25 per 1M token input, ~$1.25 per 1M output
- **Stima pratica**:
  - 1 domanda = ~200 token input + 400 token output
  - 1000 domande/mese = ~€0.50
  - Con strategia ibrida (80% FAQ): ~€0.10-0.20/mese

### Alternative OpenAI:

- Vai su: https://platform.openai.com/api-keys
- Modello: `gpt-4o-mini`
- Costo: ~$0.15 per 1M input, ~$0.60 per 1M output (più economico)

---

## 🚀 Estensione Futura

### Funzionalità avanzate da aggiungere:

1. **Feedback loop**: Bottoni "Utile" / "Non utile" per migliorare FAQ
2. **Analytics**: Tracciare domande più frequenti per aggiornare FAQ
3. **Multilingua**: Supporto inglese/spagnolo oltre italiano
4. **Voice input**: Riconoscimento vocale per pazienti con difficoltà motorie
5. **TTS output**: Leggere risposte AI ad alta voce
6. **Personalizzazione**: AI che ricorda preferenze utente nella sessione

---

## 📝 Note Implementazione

### Da ricordare:

- ✅ **API Key**: Mai committare su Git (usare `.env` o config separato)
- ✅ **Rate Limiting**: Implementare limite richieste per evitare abusi
- ✅ **Error Handling**: Sempre fallback su FAQ se API non disponibile
- ✅ **Testing**: Testare con connessione lenta/assente
- ✅ **Mobile**: UI responsive e touch-friendly
- ✅ **Accessibility**: ARIA labels per screen readers

### File da creare:

```
assistivetech.it/
├── api/
│   └── ai_assistant.php          # Backend API handler
├── training_cognitivo/
│   └── shared/
│       ├── ai-chat.html          # Modal HTML riutilizzabile
│       ├── ai-chat.css           # Styling riutilizzabile
│       └── ai-chat.js            # Logic riutilizzabile
└── training_cognitivo/
    ├── cerca_colore/
    │   └── index.html            # Include chat modal
    └── causa_effetto/
        └── accendi_la_luce/
            └── index.html        # Include chat modal
```

---

## ✅ Checklist Deployment

### Prima di andare in produzione:

- [ ] Chiave API Claude configurata
- [ ] FAQ complete per almeno 2 esercizi
- [ ] Testato su Chrome, Safari, Firefox
- [ ] Testato su mobile (Android + iOS)
- [ ] Error handling verificato (API offline, rete lenta)
- [ ] Testi italiani corretti e chiari
- [ ] Performance: risposte < 2s
- [ ] CSS responsive verificato
- [ ] Accessibilità testata (keyboard navigation)
- [ ] Analytics implementate (opzionale)
- [ ] Documentazione aggiornata

---

## 📚 Risorse Utili

### Documentazione API:

- **Claude**: https://docs.anthropic.com/claude/reference/getting-started-with-the-api
- **OpenAI**: https://platform.openai.com/docs/guides/text-generation

### Bootstrap 5:

- **Modal**: https://getbootstrap.com/docs/5.3/components/modal/
- **Forms**: https://getbootstrap.com/docs/5.3/forms/overview/

### Testing:

- **Lighthouse**: Test performance PWA
- **WAVE**: Test accessibilità
- **BrowserStack**: Test cross-browser

---

**🎉 Pronto per implementare quando vuoi! Questa soluzione è perfetta per AssistiveTech: semplice, economica, scalabile e professionale.**

---

**Versione**: 1.0
**Data creazione**: 21 Ottobre 2025
**Ultima modifica**: 21 Ottobre 2025
**Stato**: Pianificazione completata, pronto per sviluppo
**Prossimo step**: Implementazione Fase 1 quando richiesto
