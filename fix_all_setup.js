// Script Node.js per correggere tutti i setup.html
// Applica auto-selezione sviluppatore + Anonimo

const fs = require('fs');
const path = require('path');

const setupFiles = [
    'C:\\MAMP\\htdocs\\Assistivetech\\training_cognitivo\\categorizzazione\\animali\\setup.html',
    'C:\\MAMP\\htdocs\\Assistivetech\\training_cognitivo\\categorizzazione\\frutti\\setup.html',
    'C:\\MAMP\\htdocs\\Assistivetech\\training_cognitivo\\categorizzazione\\veicoli\\setup.html',
    'C:\\MAMP\\htdocs\\Assistivetech\\training_cognitivo\\categorizzazione\\veicoli_aria\\setup.html',
    'C:\\MAMP\\htdocs\\Assistivetech\\training_cognitivo\\categorizzazione\\veicoli_mare\\setup.html',
    'C:\\MAMP\\htdocs\\Assistivetech\\training_cognitivo\\causa_effetto\\accendi_la_luce\\setup.html',
    'C:\\MAMP\\htdocs\\Assistivetech\\training_cognitivo\\scrivi\\scrivi_parole\\setup.html',
    'C:\\MAMP\\htdocs\\Assistivetech\\training_cognitivo\\trascina_immagini\\cerca_colore\\setup.html'
];

const fixedLoadUtentiFunction = `
        // Carica educatori e pazienti
        async function loadUtenti() {
            try {
                // Carica tutti gli utenti (inclusi sviluppatori per setup esercizi)
                const respEducatori = await fetch(\`\${BASE_PATH}/api/auth_registrazioni.php\`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: 'get_all' })
                });
                const dataEducatori = await respEducatori.json();

                if (!dataEducatori.success) {
                    console.error('Errore API:', dataEducatori.message);
                    return;
                }

                const selectEducatore = document.getElementById('educatore');
                const selectPaziente = document.getElementById('paziente');

                // L'API restituisce i dati in 'registrazioni'
                let utenti = dataEducatori.registrazioni || [];

                // Aggiungi manualmente lo sviluppatore (che è escluso dall'API get_all)
                const sviluppatore = {
                    nome_registrazione: 'Fabio',
                    cognome_registrazione: 'Marchetti',
                    ruolo_registrazione: 'sviluppatore',
                    username_registrazione: 'marchettisoft@gmail.com'
                };

                utenti.unshift(sviluppatore);

                // Aggiungi sviluppatore per primo e pre-selezionalo
                const optionSviluppatore = document.createElement('option');
                optionSviluppatore.value = \`\${sviluppatore.nome_registrazione} \${sviluppatore.cognome_registrazione}\`;
                optionSviluppatore.textContent = \`\${sviluppatore.nome_registrazione} \${sviluppatore.cognome_registrazione} (Sviluppatore)\`;
                optionSviluppatore.selected = true;
                selectEducatore.appendChild(optionSviluppatore);

                // Carica educatori
                const educatori = utenti.filter(u => u.ruolo_registrazione === 'educatore');

                educatori.forEach(edu => {
                    const option = document.createElement('option');
                    option.value = \`\${edu.nome_registrazione} \${edu.cognome_registrazione}\`;
                    option.textContent = \`\${edu.nome_registrazione} \${edu.cognome_registrazione}\`;
                    selectEducatore.appendChild(option);
                });

                // Aggiungi opzione Anonimo PRIMA e pre-selezionala
                const optionAnonimo = document.createElement('option');
                optionAnonimo.value = 'Anonimo';
                optionAnonimo.textContent = 'Anonimo (Test)';
                optionAnonimo.selected = true;
                selectPaziente.appendChild(optionAnonimo);

                // Carica pazienti
                const pazienti = utenti.filter(u => u.ruolo_registrazione === 'paziente');

                pazienti.forEach(paz => {
                    const option = document.createElement('option');
                    option.value = \`\${paz.nome_registrazione} \${paz.cognome_registrazione}\`;
                    option.textContent = \`\${paz.nome_registrazione} \${paz.cognome_registrazione}\`;
                    selectPaziente.appendChild(option);
                });

            } catch (error) {
                console.error('Errore caricamento utenti:', error);
            }
        }`;

console.log('🔧 Correzione setup.html - Auto-selezione Sviluppatore + Anonimo\n');

setupFiles.forEach(filePath => {
    try {
        let content = fs.readFileSync(filePath, 'utf8');

        // Trova la funzione loadUtenti esistente
        const loadUtentiRegex = /async function loadUtenti\(\) \{[\s\S]*?\n        \}/;

        if (loadUtentiRegex.test(content)) {
            content = content.replace(loadUtentiRegex, fixedLoadUtentiFunction.trim());
            fs.writeFileSync(filePath, content, 'utf8');
            console.log(\`✅ \${path.basename(path.dirname(filePath))}/setup.html\`);
        } else {
            console.log(\`⚠️  \${path.basename(path.dirname(filePath))}/setup.html - loadUtenti non trovata\`);
        }
    } catch (error) {
        console.error(\`❌ \${path.basename(path.dirname(filePath))}/setup.html - Errore: \${error.message}\`);
    }
});

console.log('\n✅ Correzione completata!');
