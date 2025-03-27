# Проверяем, запущен ли PowerShell с правами администратора
$adminCheck = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$adminRole = [System.Security.Principal.WindowsPrincipal]::new($adminCheck)
$admin = $adminRole.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $admin) {
    exit 1
}

# Определяем путь к временному файлу
$filepath = "$PSScriptRoot\teams_status.txt"
$results = @()

# Получение версии New Teams
$newTeams = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Teams*" | ForEach-Object {
    "$($_.DisplayName) ($($_.Version))"
}
if ($newTeams) {
    $results += $newTeams
}

# Получение версии Classic Teams
$classicTeamsPath = "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe"
if (Test-Path $classicTeamsPath) {
    $classicVersion = (Get-Item $classicTeamsPath).VersionInfo.FileVersion
    $results += "Teams Classic ($classicVersion)"
}

# Сохранение в файл
if ($results.Count -eq 0) {
    "Not found" | Out-File -FilePath $filepath -Encoding utf8
} else {
    $results | Out-File -FilePath $filepath -Encoding utf8
}

# # Определяем путь к временному файлу
# $filepath = "$PSScriptRoot\teams_status.txt"

# # Если файл существует, удаляем его
# if (Test-Path $filepath) {
#     Remove-Item -Path $filepath -Force
# }

# $result =   Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Teams*" | ForEach-Object {
#                 "$($_.DisplayName) ($($_.Version))"
#             }

# # Проверяем, есть ли результат, и записываем его в файл
# if ($result) {
#     $result | Out-File -Encoding utf8 -FilePath $filepath
# } else {
#     "Not found" | Out-File -Encoding utf8 -FilePath $filepath
# }