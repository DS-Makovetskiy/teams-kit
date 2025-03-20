@echo off
::chcp 1251 >nul
chcp 65001 >nul

:: Задаем переменные
set "SITE_URL=https://go.microsoft.com/fwlink/?linkid=2196106"
set "SITE_STATUS="
set "FILE_STATUS="
set "online_size_kb=-"
set "local_size_kb=-"
set "LOCAL_FILE=%~dp0teams\MSTeams-x64.msix"
set "DOWNLOAD_SCRIPT=%~dp0\scripts\download.ps1"
set "INSTALL_SCRIPT=%~dp0\scripts\install.ps1"
set "DOWNLOAD_PATH=%~dp0teams\MSTeams-x64.msix"
set "DEST_FOLDER=%~dp0teams"

:: Определяем цвета
set "COLOR_GREEN=[32m"
set "COLOR_RED=[31m"
set "COLOR_RESET=[0m"


:check_teams
:: Проверка установленных версий Teams
cls
echo Проверка установленных версий Microsoft Teams...

powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0check_teams.ps1" > teams_status.txt

for /f "tokens=1 delims=" %%A in (teams_status.txt) do set TEAMS_STATUS=%%A
del teams_status.txt

:: Проверка доступности сайта
curl -s --head %SITE_URL% | findstr /R "200 | 302" >nul
if %errorlevel%==0 (
    set "SITE_STATUS=Доступен"
	:: Получаем размер файла с оф. сайта
	for /f %%A in ('powershell -Command "try { (Invoke-WebRequest -Uri '%SITE_URL%' -Method Head).Headers['Content-Length'] } catch { 'error' }"') do set "online_size=%%A"
) else (
    set "SITE_STATUS=Не доступен"
)

:: Проверка наличия локальной версии файла в папке "teams"
if exist "%LOCAL_FILE%" (
    set "FILE_STATUS=Доступен"
	:: Получаем размер локального файла
	for /f %%A in ('wmic datafile where "name='%LOCAL_FILE:\=\\%'" get FileSize ^| findstr [0-9]') do set "local_size=%%A"
) else (
    set "FILE_STATUS=Файл не найден"
)

:: Рассчитываем размер в KB
if defined online_size set /a online_size_kb=%online_size%/1024
if defined local_size set /a local_size_kb=%local_size%/1024
cls

if "%TEAMS_STATUS%"=="NOT_INSTALLED" goto install_menu
if "%TEAMS_STATUS%"=="INSTALLED" goto remove_menu
:: Проверка установленных версий Teams

:install_menu
:: Вывод статусов
if "%SITE_STATUS%"=="Доступен" (
    echo Статус сайта: %COLOR_GREEN%%SITE_STATUS%%COLOR_RESET% [%online_size_kb% KB]
) else (
    echo Статус сайта: %COLOR_RED%%SITE_STATUS%%COLOR_RESET% [%online_size_kb% KB]
)

if "%FILE_STATUS%"=="Доступен" (
    echo Статус файла: %COLOR_GREEN%%FILE_STATUS%%COLOR_RESET% [%local_size_kb% KB]
) else (
    echo Статус файла: %COLOR_RED%%FILE_STATUS%%COLOR_RESET% [%local_size_kb% KB]
)
:: Вывод статусов

echo.
echo Microsoft Teams не установлен.
echo.
echo Выберите действие:
echo 1. Скачать новую версию Microsoft Teams
echo 2. Установить локальную версию
echo 3. Повторить проверку
echo 4. Выход
echo.

set /p choice=Введите номер пункта: 

::if "%choice%"=="1" goto download_file
::if "%choice%"=="2" call install_teams.bat
::if "%choice%"=="3" goto check_teams
::if "%choice%"=="4" exit

if "%choice%"=="1" (goto download_file) else (
    if "%choice%"=="2" (call install_teams.bat) else (
        if "%choice%"=="3" (goto check_teams) else (
            if "%choice%"=="4" (exit) else (
                cls
                goto install_menu
            )
        )
    )
)

goto install_menu

:remove_menu
:: Вывод статусов
if "%SITE_STATUS%"=="Доступен" (
    echo Статус сайта: %COLOR_GREEN%%SITE_STATUS%%COLOR_RESET% [%online_size_kb% KB]
) else (
    echo Статус сайта: %COLOR_RED%%SITE_STATUS%%COLOR_RESET% [%online_size_kb% KB]
)

if "%FILE_STATUS%"=="Доступен" (
    echo Статус файла: %COLOR_GREEN%%FILE_STATUS%%COLOR_RESET% [%local_size_kb% KB]
) else (
    echo Статус файла: %COLOR_RED%%FILE_STATUS%%COLOR_RESET% [%local_size_kb% KB]
)
:: Вывод статусов

echo.
echo Microsoft Teams установлен.
echo.
echo Выберите действие:
echo 1. Удалить Classic Teams
echo 2. Удалить New Teams
echo 3. Повторить проверку
echo 4. Выход
echo.

set /p choice=Введите номер пункта: 

::if "%choice%"=="1" powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0remove_classic.ps1"
::if "%choice%"=="2" powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0remove_new.ps1"
::if "%choice%"=="3" goto check_teams
::if "%choice%"=="4" exit

if "%choice%"=="1" (powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0remove_classic.ps1") else (
    if "%choice%"=="2" (powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0remove_new.ps1") else (
        if "%choice%"=="3" (goto check_teams) else (
            if "%choice%"=="4" (exit) else (
                cls
                goto remove_menu
            )
        )
    )
)

goto remove_menu


:: Скачивание файла
:download_file
echo Загружаем новую версию Teams...
powershell -Command "Start-BitsTransfer -Source '%SITE_URL%' -Destination '%DOWNLOAD_PATH%'"

if exist "%DOWNLOAD_PATH%" (
    echo Файл загружен успешно.
    goto install_teams
) else (
    echo Ошибка загрузки файла.
	pause
    exit /b
)