<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Export Database per Aruba</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 900px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #673AB7; }
        .step {
            background: #f8f9fa;
            padding: 20px;
            margin: 15px 0;
            border-left: 4px solid #673AB7;
            border-radius: 5px;
        }
        .step h3 {
            margin-top: 0;
            color: #673AB7;
        }
        .success {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .warning {
            background: #fff3cd;
            color: #856404;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .info {
            background: #cce5ff;
            color: #004085;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .btn {
            padding: 12px 24px;
            background: #673AB7;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            text-decoration: none;
            display: inline-block;
        }
        .btn:hover { background: #9C27B0; }
        code {
            background: #f8f9fa;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: monospace;
        }
        pre {
            background: #2d2d2d;
            color: #f8f8f2;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Export Database per Deploy Aruba</h1>

        <div class="info">
            <strong>📋 Questa procedura ti guida nell'export del database pronto per Aruba</strong><br>
            Segui gli step in ordine e il deploy sarà perfetto!
        </div>

        <!-- STEP 1 -->
        <div class="step">
            <h3>📥 STEP 1: Esporta Database Locale</h3>
            <ol>
                <li>Apri phpMyAdmin: <a href="http://localhost:8888/phpMyAdmin/" target="_blank">http://localhost:8888/phpMyAdmin/</a></li>
                <li>Seleziona database: <code>assistivetech_local</code></li>
                <li>Clicca tab <strong>"Esporta"</strong></li>
                <li>Metodo: <strong>Rapido</strong></li>
                <li>Formato: <strong>SQL</strong></li>
                <li>Clicca <strong>"Esegui"</strong></li>
                <li>Salva come: <code>assistivetech_export.sql</code></li>
            </ol>
            <div class="success">✅ File salvato sul tuo computer</div>
        </div>

        <!-- STEP 2 -->
        <div class="step">
            <h3>🔧 STEP 2: Prepara per Aruba</h3>
            <ol>
                <li>Apri di nuovo phpMyAdmin</li>
                <li>Seleziona database: <code>assistivetech_local</code></li>
                <li>Clicca tab <strong>"SQL"</strong></li>
                <li>Apri file: <code>prepare_for_aruba.sql</code></li>
                <li>Copia tutto il contenuto</li>
                <li>Incolla nella textarea SQL</li>
                <li>Clicca <strong>"Esegui"</strong></li>
            </ol>
            <div class="warning">
                ⚠️ <strong>ATTENZIONE</strong>: Questo modifica il database locale!<br>
                Link convertiti: <code>/Assistivetech/...</code> → <code>/...</code>
            </div>
        </div>

        <!-- STEP 3 -->
        <div class="step">
            <h3>📤 STEP 3: Ri-Esporta Database Modificato</h3>
            <ol>
                <li>Sempre in phpMyAdmin</li>
                <li>Tab <strong>"Esporta"</strong></li>
                <li>Metodo: <strong>Rapido</strong></li>
                <li>Formato: <strong>SQL</strong></li>
                <li>Clicca <strong>"Esegui"</strong></li>
                <li>Salva come: <code>assistivetech_production.sql</code></li>
            </ol>
            <div class="success">✅ Questo file è pronto per Aruba!</div>
        </div>

        <!-- STEP 4 -->
        <div class="step">
            <h3>🔄 STEP 4: Ripristina Database Locale</h3>
            <p><strong>IMPORTANTE!</strong> Ora il tuo database locale ha link senza <code>/Assistivetech/</code></p>
            <p>Per continuare a lavorare in locale, ripristina i link:</p>
            <ol>
                <li>phpMyAdmin → Database <code>assistivetech_local</code></li>
                <li>Tab <strong>"SQL"</strong></li>
                <li>Apri file: <code>fix_link_database.sql</code></li>
                <li>Copia tutto e incolla</li>
                <li>Clicca <strong>"Esegui"</strong></li>
            </ol>
            <div class="success">
                ✅ Link ripristinati: <code>/...</code> → <code>/Assistivetech/...</code><br>
                Puoi continuare a sviluppare in locale!
            </div>
        </div>

        <!-- STEP 5 -->
        <div class="step">
            <h3>☁️ STEP 5: Upload su Aruba</h3>

            <h4>5.1 - Upload File FTP</h4>
            <pre>Host: ftp.assistivetech.it
User: 7985805@aruba.it
Pass: Filohori33!
Port: 21</pre>

            <p><strong>Cartelle da uploadare:</strong></p>
            <ul>
                <li><code>training_cognitivo/</code> → <code>/training_cognitivo/</code></li>
                <li><code>api/</code> → <code>/api/</code></li>
                <li><code>admin/</code> → <code>/admin/</code></li>
                <li><code>agenda/</code> → <code>/agenda/</code></li>
                <li><code>index.html</code> → <code>/index.html</code></li>
                <li><code>login.html</code> → <code>/login.html</code></li>
                <li><code>dashboard.html</code> → <code>/dashboard.html</code></li>
                <li><code>.htaccess</code> → <code>/.htaccess</code></li>
            </ul>

            <h4>5.2 - Importa Database</h4>
            <ol>
                <li>Vai su: <a href="http://mysql.aruba.it" target="_blank">http://mysql.aruba.it</a></li>
                <li>Login:
                    <ul>
                        <li>User: <code>Sql1073852</code></li>
                        <li>Pass: <code>5k58326940</code></li>
                    </ul>
                </li>
                <li>Seleziona database: <code>Sql1073852_1</code></li>
                <li>Tab <strong>"Importa"</strong></li>
                <li>Scegli file: <code>assistivetech_production.sql</code></li>
                <li>Clicca <strong>"Esegui"</strong></li>
            </ol>

            <div class="success">
                ✅ <strong>DEPLOY COMPLETATO!</strong><br>
                Testa su: <a href="https://assistivetech.it/" target="_blank">https://assistivetech.it/</a>
            </div>
        </div>

        <hr style="margin: 40px 0; border: none; border-top: 2px solid #eee;">

        <div class="info">
            <h3>🎯 Riepilogo Veloce</h3>
            <ol>
                <li>Esporta DB locale → <code>assistivetech_export.sql</code> (backup)</li>
                <li>Esegui <code>prepare_for_aruba.sql</code> su DB locale</li>
                <li>Ri-esporta DB → <code>assistivetech_production.sql</code></li>
                <li>Esegui <code>fix_link_database.sql</code> su DB locale (ripristino)</li>
                <li>Upload FTP + Importa DB su Aruba</li>
            </ol>
        </div>

        <div class="warning">
            <strong>📌 Ricorda:</strong><br>
            • Il file <code>config.php</code> NON va modificato<br>
            • Il file <code>config.php</code> rileva automaticamente l'ambiente<br>
            • In locale lavori sempre con link <code>/Assistivetech/...</code><br>
            • Su Aruba funziona automaticamente con link <code>/...</code>
        </div>

        <a href="admin/" class="btn">⚙️ Vai al Pannello Admin</a>
        <a href="training_cognitivo/" class="btn" style="background: #6c757d;">🧠 Training Cognitivo</a>
    </div>
</body>
</html>
