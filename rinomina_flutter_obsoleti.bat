@echo off
REM ============================================
REM Script per rinominare file Flutter obsoleti
REM Aggiunge underscore _ davanti al nome
REM ============================================

echo.
echo ========================================
echo RINOMINA FILE FLUTTER OBSOLETI
echo ========================================
echo.
echo Questo script rinomina:
echo - pubspec.yaml       --^> _pubspec.yaml
echo - pubspec.lock       --^> _pubspec.lock
echo - lib/               --^> _lib/
echo - .dart_tool/        --^> _.dart_tool/
echo - analysis_options.yaml --^> _analysis_options.yaml
echo.
echo Cartella: C:\MAMP\htdocs\Assistivetech\training_cognitivo
echo.
pause

cd "C:\MAMP\htdocs\Assistivetech\training_cognitivo"

echo.
echo === RINOMINO FILE PUBSPEC.YAML ===
for /r %%f in (pubspec.yaml) do (
    if exist "%%f" (
        echo Rinomino: %%~dpf%%~nf%%~xf
        ren "%%f" "_pubspec.yaml"
    )
)

echo.
echo === RINOMINO FILE PUBSPEC.LOCK ===
for /r %%f in (pubspec.lock) do (
    if exist "%%f" (
        echo Rinomino: %%~dpf%%~nf%%~xf
        ren "%%f" "_pubspec.lock"
    )
)

echo.
echo === RINOMINO FILE ANALYSIS_OPTIONS.YAML ===
for /r %%f in (analysis_options.yaml) do (
    if exist "%%f" (
        echo Rinomino: %%~dpf%%~nf%%~xf
        ren "%%f" "_analysis_options.yaml"
    )
)

echo.
echo === RINOMINO CARTELLE LIB ===
for /d /r %%d in (lib) do (
    if exist "%%d" (
        echo Rinomino cartella: %%d
        ren "%%d" "_lib"
    )
)

echo.
echo === RINOMINO CARTELLE .DART_TOOL ===
for /d /r %%d in (.dart_tool) do (
    if exist "%%d" (
        echo Rinomino cartella: %%d
        ren "%%d" "_.dart_tool"
    )
)

echo.
echo ========================================
echo COMPLETATO!
echo ========================================
echo.
echo Verifica che tutto funzioni, poi puoi eliminare manualmente:
echo - Tutti i file che iniziano con underscore _
echo - Tutte le cartelle che iniziano con underscore _
echo.
pause
