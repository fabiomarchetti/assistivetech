@echo off
REM ============================================
REM Script per VERIFICARE file rinominati
REM ============================================

echo.
echo ========================================
echo VERIFICA FILE RINOMINATI
echo ========================================
echo.

cd "C:\MAMP\htdocs\Assistivetech\training_cognitivo"

echo.
echo === FILE _PUBSPEC.YAML TROVATI ===
for /r %%f in (_pubspec.yaml) do (
    if exist "%%f" echo - %%f
)

echo.
echo === FILE _PUBSPEC.LOCK TROVATI ===
for /r %%f in (_pubspec.lock) do (
    if exist "%%f" echo - %%f
)

echo.
echo === CARTELLE _LIB TROVATE ===
for /d /r %%d in (_lib) do (
    if exist "%%d" echo - %%d
)

echo.
echo === CARTELLE _.DART_TOOL TROVATE ===
for /d /r %%d in (_.dart_tool) do (
    if exist "%%d" echo - %%d
)

echo.
echo ========================================
echo VERIFICA COMPLETATA
echo ========================================
echo.
pause
