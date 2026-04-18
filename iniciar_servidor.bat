@echo off
setlocal enabledelayedexpansion
title PerfilTopo Web — Servidor Local

:: ═══════════════════════════════════════════════════════════════
::  PerfilTopo Web — Iniciador de Servidor HTTP Local
::  Coloca este .bat en la MISMA carpeta que Perfiltopo_web.html
::  Doble clic para iniciar — cierra la ventana para detener
:: ═══════════════════════════════════════════════════════════════

echo.
echo          PefilTopo Web  —  Servidor Local        

echo.

:: ── 1. Ir a la carpeta donde está el .bat ────────────────────
cd /d "%~dp0"
echo  [DIR] %~dp0

:: ── 2. Verificar que perfil_topo.html existe ─────────────────
if not exist "perfil_topo.html" (
    echo.
    echo  [ERROR] No se encontro pefil_topo.html en esta carpeta.
    echo  Coloca el .bat en la misma carpeta que el .html
    echo.
    pause
    exit /b 1
)
echo  [OK]  perfil_topo.html encontrado

:: ── 3. Detectar Python ───────────────────────────────────────
set PYTHON_CMD=
set PYTHON_VER=

python --version >nul 2>&1
if !errorlevel! == 0 (
    set PYTHON_CMD=python
    for /f "tokens=*" %%v in ('python --version 2^>^&1') do set PYTHON_VER=%%v
    goto :python_found
)

python3 --version >nul 2>&1
if !errorlevel! == 0 (
    set PYTHON_CMD=python3
    for /f "tokens=*" %%v in ('python3 --version 2^>^&1') do set PYTHON_VER=%%v
    goto :python_found
)

:: Buscar Python en ubicaciones comunes si no está en PATH
for %%p in (
    "%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python310\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python39\python.exe"
    "C:\Python313\python.exe"
    "C:\Python312\python.exe"
    "C:\Python311\python.exe"
    "C:\Python310\python.exe"
    "C:\Program Files\Python313\python.exe"
    "C:\Program Files\Python312\python.exe"
    "C:\Program Files\Python311\python.exe"
    "C:\Program Files (x86)\Python312\python.exe"
) do (
    if exist %%p (
        set PYTHON_CMD=%%p
        for /f "tokens=*" %%v in ('%%p --version 2^>^&1') do set PYTHON_VER=%%v
        goto :python_found
    )
)

echo.
echo  [ERROR] Python no encontrado.
echo.
echo  Instala Python desde: https://www.python.org/downloads/
echo  IMPORTANTE: marca "Add Python to PATH" al instalar.
echo.
pause
exit /b 1

:python_found
echo  [OK]  %PYTHON_VER% ^(%PYTHON_CMD%^)

:: ── 4. Encontrar puerto libre 8080-8090 ──────────────────────
set PORT=8080
:buscar_puerto
netstat -an 2>nul | find ":%PORT% " >nul 2>&1
if !errorlevel! == 0 (
    echo  [INFO] Puerto %PORT% ocupado, probando %PORT%+1...
    set /a PORT=%PORT%+1
    if !PORT! GTR 8090 (
        echo  [ERROR] Todos los puertos 8080-8090 estan ocupados.
        pause
        exit /b 1
    )
    goto :buscar_puerto
)
echo  [OK]  Puerto %PORT% disponible

:: ── 5. Abrir browser tras 2s ─────────────────────────────────
set URL=http://localhost:%PORT%/perfil_topo.html
set LAUNCHER=%TEMP%\gt_launch_%RANDOM%.bat
echo @echo off > "%LAUNCHER%"
echo timeout /t 2 /nobreak ^>nul >> "%LAUNCHER%"
echo start "" "%URL%" >> "%LAUNCHER%"
start /min "" cmd /c "%LAUNCHER%"

:: ── 6. Iniciar servidor ──────────────────────────────────────
echo.
echo  ════════════════════════════════════════════════
echo   URL: %URL%
echo   Mantén esta ventana ABIERTA mientras usas la app
echo   Ctrl+C para detener el servidor
echo  ════════════════════════════════════════════════
echo.

%PYTHON_CMD% -m http.server %PORT% --bind 127.0.0.1 2>&1

:: ── 7. Al cerrar ────────────────────────────────────────────
if exist "%LAUNCHER%" del "%LAUNCHER%" >nul 2>&1
echo.
echo  Servidor detenido. Puedes cerrar esta ventana.
pause
endlocal
