@echo off
REM ============================================
REM Script per ELIMINARE file Flutter obsoleti
REM ATTENZIONE: Questo script ELIMINA i file!
REM Eseguire SOLO dopo aver testato tutto!
REM ============================================

echo.
echo ========================================
echo ELIMINAZIONE FILE FLUTTER OBSOLETI
echo ========================================
echo.
echo ATTENZIONE! Questo script ELIMINERA':
echo - Tutti i file _pubspec.yaml
echo - Tutti i file _pubspec.lock
echo - Tutte le cartelle _lib/
echo - Tutte le cartelle _.dart_tool/
echo - Tutti i file _analysis_options.yaml
echo.
echo Cartella: C:\MAMP\htdocs\Assistivetech\training_cognitivo
echo.
echo Spazio liberato stimato: ~500 MB
echo.
echo PREMI CTRL+C PER ANNULLARE
echo.
pause

cd "C:\MAMP\htdocs\Assistivetech\training_cognitivo"

echo.
echo === ELIMINO FILE _PUBSPEC.YAML ===
for /r %%f in (_pubspec.yaml) do (
    if exist "%%f" (
        echo Elimino: %%f
        del /q "%%f"
    )
)

echo.
echo === ELIMINO FILE _PUBSPEC.LOCK ===
for /r %%f in (_pubspec.lock) do (
    if exist "%%f" (
        echo Elimino: %%f
        del /q "%%f"
    )
)

echo.
echo === ELIMINO FILE _ANALYSIS_OPTIONS.YAML ===
for /r %%f in (_analysis_options.yaml) do (
    if exist "%%f" (
        echo Elimino: %%f
        del /q "%%f"
    )
)

echo.
echo === ELIMINO CARTELLE _LIB ===
for /d /r %%d in (_lib) do (
    if exist "%%d" (
        echo Elimino cartella: %%d
        rd /s /q "%%d"
    )
)

echo.
echo === ELIMINO CARTELLE _.DART_TOOL ===
for /d /r %%d in (_.dart_tool) do (
    if exist "%%d" (
        echo Elimino cartella: %%d
        rd /s /q "%%d"
    )
)

echo.
echo ========================================
echo ELIMINAZIONE COMPLETATA!
echo ========================================
echo.
echo Verifica che tutto funzioni ancora correttamente.
echo.
pause
