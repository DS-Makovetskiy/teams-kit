@echo off
::chcp 1251 >nul
chcp 65001 >nul

:: Задаем переменные
set "SITE_STATUS="
set "FILE_STATUS="
set "ONL_SIZE_KB=-"
set "LOC_SIZE_KB=-"
set "DISABLED_SITE="
set "DISABLED_FILE="
set "SITE_URL=https://go.microsoft.com/fwlink/?linkid=2196106"
set "TEAMS_STATUS_FILE=%~dp0scripts\teams_status.txt"
set "LOCAL_FILE=%~dp0teams\MSTeams-x64.msix"
set "CHECK_SCRIPT=%~dp0scripts\CheckTeams.ps1"
set "INSTALL_SCRIPT=%~dp0\scripts\InstallTeamsAllUsers.ps1"
set "UNINSTALL_CLASSIC_SCRIPT=%~dp0\scripts\UninstallClassicTeams.ps1"
set "UNINSTALL_NEW_SCRIPT=%~dp0\scripts\UninstallNewTeams.ps1"

:: Определяем цвета
set "COLOR_GRAY=[90m"
set "COLOR_GREEN=[32m"
set "COLOR_RED=[31m"
set "COLOR_RESET=[0m"

:: Запускаем PowerShell-скрипт и проверяем, есть ли админ-права
powershell -NoProfile -ExecutionPolicy Bypass -File "%CHECK_SCRIPT%" || (
    echo.
    echo %COLOR_RED%[Ошибка]%COLOR_RESET% Запустите этот скрипт от имени администратора!
    echo.
    pause
    exit /b
)

:: # Проверка установленных версий MS Teams
:check_teams
cls

:: ## Запуск скрипта по проверке установленных версий MS Teams
echo Проверка установленных версий MS Teams...

powershell -NoProfile -ExecutionPolicy Bypass -File %CHECK_SCRIPT%
set /p TEAMS_STATUS=<"%TEAMS_STATUS_FILE%"
del "%TEAMS_STATUS_FILE%"

:: ## Проверка доступности сайта
echo Проверка доступности сайта для скачивания MS Teams...

curl -s --head %SITE_URL% | findstr /R "200 | 302" >nul
if %errorlevel%==0 (
    set "SITE_STATUS=Доступен"
	:: ### Получаем размер файла с оф. сайта
	for /f %%A in ('powershell -Command "try { (Invoke-WebRequest -Uri '%SITE_URL%' -Method Head).Headers['Content-Length'] } catch { 'error' }"') do set "online_size=%%A"
) else (
    set "SITE_STATUS=Не доступен"
)

:: ## Проверка наличия локальной версии файла в папке "teams"
echo Проверка доступности локального файла MS Teams...

if exist "%LOCAL_FILE%" (
    set "FILE_STATUS=Доступен"
	:: ### Получаем размер локального файла
	for /f %%A in ('wmic datafile where "name='%LOCAL_FILE:\=\\%'" get FileSize ^| findstr [0-9]') do set "local_size=%%A"
) else (
    set "FILE_STATUS=Файл не найден"
)

:: ## Рассчитываем размер в KB
if defined online_size set /a ONL_SIZE_KB=%online_size%/1024
if defined local_size set /a LOC_SIZE_KB=%local_size%/1024

:: ## Определение статусов сайта и локального файла, выделение цветом
if "%SITE_STATUS%"=="Доступен" (
    set "display_site_status=%COLOR_GREEN%%SITE_STATUS%%COLOR_RESET% [%ONL_SIZE_KB% KB]"
) else (
    set "display_site_status=%COLOR_RED%%SITE_STATUS%%COLOR_RESET% [%ONL_SIZE_KB% KB]"
)

if "%FILE_STATUS%"=="Доступен" (
    set "display_file_status=%COLOR_GREEN%%FILE_STATUS%%COLOR_RESET% [%LOC_SIZE_KB% KB]"
) else (
    set "display_file_status=%COLOR_RED%%FILE_STATUS%%COLOR_RESET% [%LOC_SIZE_KB% KB]"
)

:: ## Определяем доступность пунктов
if not "%SITE_STATUS%"=="Доступен" (
    set "DISABLED_SITE=%COLOR_GRAY%"
) else (
    set "DISABLED_SITE="
)

if not "%FILE_STATUS%"=="Доступен" (
    set "DISABLED_FILE=%COLOR_GRAY%"
) else (
    set "DISABLED_FILE="
)
cls

:: ## В зависимости от статуса Teams выводим меню
if "%TEAMS_STATUS%"=="Not found" (
    goto install_menu
) else (
    goto remove_menu
)
:: # Проверка установленных версий Teams


:: # Установка Teams
:install_menu

:: ## Вывод статусов
echo Статус сайта: %display_site_status%
echo Статус файла: %display_file_status%

:: ## Вывод меню с учетом недоступных пунктов
echo.
echo Microsoft Teams не установлен.
echo.
echo 1. %DISABLED_SITE%Скачать новую версию MS Teams%COLOR_RESET%
echo 2. %DISABLED_FILE%Установить локальную версию%COLOR_RESET%
echo 3. Повторить проверку
echo 4. Выход
echo.

:: ## Запрос выбора
set /p choice=Введите номер пункта: 

:: ## Обрабатываем выбор
if "%choice%"=="1" if "%SITE_STATUS%"=="Доступен" (goto download_file)
if "%choice%"=="2" if "%FILE_STATUS%"=="Доступен" (goto install_teams)
if "%choice%"=="3" (goto check_teams)
if "%choice%"=="4" (exit)

cls
goto install_menu
:: # Установка Teams


:: # Удаление Teams
:remove_menu

:: ## Вывод статусов
echo Статус сайта: %display_site_status%
echo Статус файла: %display_file_status%

echo.
echo Microsoft Teams установлен.
echo %TEAMS_STATUS%
echo.
echo Выберите действие:
echo 1. Удалить Classic Teams [Microsoft Teams]
echo 2. Удалить New Teams     [MS Teams]
echo 3. Повторить проверку
echo 4. Выход
echo.

set /p choice=Введите номер пункта: 

if "%choice%"=="1" goto remove_classic_teams
if "%choice%"=="2" goto remove_new_teams
if "%choice%"=="3" goto check_teams
if "%choice%"=="4" exit

cls
goto remove_menu
:: # Удаление Teams


:: # Скачивание файла
:download_file
if not exist "%~dp0teams" (
    mkdir "%~dp0teams"
)

echo.
echo Загружаем новую версию Teams...

powershell -Command "Start-BitsTransfer -Source '%SITE_URL%' -Destination '%LOCAL_FILE%'"

if exist "%LOCAL_FILE%" (
    echo Файл загружен успешно.
    echo Выполняется установка...
    goto install_teams
) else (
    echo Ошибка загрузки файла.
	pause
    exit /b
)

:: # Установка Teams
:install_teams
cls
echo Выполняется установка MS Teams...
powershell -ExecutionPolicy Bypass -NoProfile -File %INSTALL_SCRIPT%
echo Установка успешно завершена.
echo.
pause
exit /b

:: # Удаление Classic Teams
:remove_classic_teams
cls
echo Выполняется удаление Classic Teams...
powershell -ExecutionPolicy Bypass -NoProfile -File %UNINSTALL_CLASSIC_SCRIPT%
echo.
echo Удаление Classic Teams успешно завершено.
echo.
pause
goto check_teams

:: # Удаление New Teams
:remove_new_teams
cls
echo Выполняется удаление New Teams...
powershell -ExecutionPolicy Bypass -NoProfile -File %UNINSTALL_NEW_SCRIPT%
echo.
echo Удаление New Teams успешно завершено.
echo.
pause
goto check_teams