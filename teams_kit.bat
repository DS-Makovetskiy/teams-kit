@echo off
::chcp 1251 >nul
chcp 65001 >nul

:: Задаем переменные
set "SITE_URL=https://go.microsoft.com/fwlink/?linkid=2196106"
set "SITE_STATUS="
set "FILE_STATUS="
set "ONL_SIZE_KB=-"
set "LOC_SIZE_KB=-"
set "DISABLED_SITE="
set "DISABLED_FILE="
set "LOCAL_FILE=%~dp0teams\MSTeams-x64.msix"
set "TEAMS_STATUS_FILE=%~dp0scripts\teams_status.txt"
set "CHECK_SCRIPT=%~dp0scripts\CheckTeams.ps1"
::set "DOWNLOAD_SCRIPT=%~dp0\scripts\download.ps1"
set "INSTALL_SCRIPT=%~dp0\scripts\InstallTeamsAllUsers.ps1"
set "DOWNLOAD_PATH=%~dp0teams\MSTeams-x64.msix"

:: Определяем цвета
set "COLOR_GREEN=[32m"
set "COLOR_RED=[31m"
set "COLOR_RESET=[0m"
set "COLOR_GRAY=[90m"

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
echo 1. %DISABLED_SITE%Скачать новую версию Microsoft Teams%COLOR_RESET%
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


:: # Скачивание файла
:download_file
if not exist "%~dp0teams" (
    mkdir "%~dp0teams"
)

echo.
echo Загружаем новую версию Teams...

powershell -Command "Start-BitsTransfer -Source '%SITE_URL%' -Destination '%DOWNLOAD_PATH%'"

if exist "%DOWNLOAD_PATH%" (
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
powershell -NoProfile -ExecutionPolicy Bypass -File %INSTALL_SCRIPT%
echo.
echo Установка успешно завершена.
pause
exit /b