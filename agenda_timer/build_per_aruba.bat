@echo off
REM Script per preparare build Agenda Timer per Aruba
REM Esegui questo script quando sei pronto per aggiornare l'app su Aruba

echo ========================================
echo PREPARAZIONE BUILD PER ARUBA
echo ========================================
echo.

echo [1/4] Pulizia build precedente...
if exist build\web rmdir /s /q build\web

echo [2/4] Modifica temporanea web/index.html...
powershell -Command "(Get-Content web\index.html) -replace '\$FLUTTER_BASE_HREF', '/agenda_timer/' | Set-Content web\index.html"

echo [3/4] Build Flutter per produzione...
call flutter build web --release
if %errorlevel% neq 0 (
    echo ERRORE: Build Flutter fallito!
    powershell -Command "(Get-Content web\index.html) -replace '/agenda_timer/', '\$FLUTTER_BASE_HREF' | Set-Content web\index.html"
    pause
    exit /b 1
)

echo [4/4] Copia file nella root...
xcopy /E /Y /Q build\web\* .

echo.
echo [RIPRISTINO] Ripristino web/index.html originale...
powershell -Command "(Get-Content web\index.html) -replace '/agenda_timer/', '\$FLUTTER_BASE_HREF' | Set-Content web\index.html"

echo.
echo ========================================
echo BUILD COMPLETATO CON SUCCESSO!
echo ========================================
echo.
echo File pronti per upload FTP su Aruba:
echo - Host: ftp.assistivetech.it
echo - User: 7985805@aruba.it
echo - Cartella destinazione: /agenda_timer/
echo.
echo IMPORTANTE: Carica tutti i file mantenendo la struttura:
echo   - index.html
echo   - manifest.json
echo   - .htaccess
echo   - flutter*.js
echo   - main.dart.js
echo   - assets/
echo   - canvaskit/
echo   - icons/
echo   - api/
echo.
pause
