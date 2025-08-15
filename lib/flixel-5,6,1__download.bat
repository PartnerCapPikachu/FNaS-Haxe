@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"
cd ..

REM --- Variables ---
set LIB_NAME=flixel
set LIB_VERSION=5,6,1
set LIB_ZIP=lib\%LIB_NAME%-%LIB_VERSION%.zip

REM Get HAXELIB_DIR (location of installed libs)
for /f "delims=" %%D in ('haxelib config') do set HAXELIB_DIR=%%D

set INSTALLED_LIB_DIR=%HAXELIB_DIR%\%LIB_NAME%\%LIB_VERSION%
set BACKUP_LIB_DIR=%HAXELIB_DIR%\%LIB_NAME%\%LIB_VERSION%-backup

REM --- Backup existing flixel version ---
if exist "%INSTALLED_LIB_DIR%" (
    echo Found installed %LIB_NAME% version %LIB_VERSION%.
    echo Backing up existing version...

    if exist "%BACKUP_LIB_DIR%" (
        echo Backup folder exists, deleting old backup...
        rmdir /s /q "%BACKUP_LIB_DIR%"
    )

    xcopy /E /I /Y "%INSTALLED_LIB_DIR%" "%BACKUP_LIB_DIR%" >nul
    echo Backup created at "%BACKUP_LIB_DIR%"
) else (
    echo No existing %LIB_NAME% %LIB_VERSION% installation found.
)

REM --- Check if zip exists ---
if not exist "%LIB_ZIP%" (
    echo ERROR: Zip file "%LIB_ZIP%" not found!
    echo Aborting.
    pause
    exit /b 1
)

REM --- Install from zip directly ---
echo Installing %LIB_NAME% version %LIB_VERSION% from "%LIB_ZIP%"...
haxelib install "%LIB_ZIP%"

pause