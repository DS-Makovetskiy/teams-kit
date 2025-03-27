# Проверяем, запущен ли PowerShell с правами администратора
$adminCheck = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$adminRole = [System.Security.Principal.WindowsPrincipal]::new($adminCheck)
$admin = $adminRole.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $admin) {
    exit 1
}


# Определяем путь к временному файлу
$filepath = "$PSScriptRoot\teams_status.txt"

# Если файл существует, удаляем его
if (Test-Path $filepath) {
    Remove-Item -Path $filepath -Force
}

$result =   Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Teams*" | ForEach-Object {
                "$($_.DisplayName) ($($_.Version))"
            }

# Проверяем, есть ли результат, и записываем его в файл
if ($result) {
    $result | Out-File -Encoding utf8 -FilePath $filepath
} else {
    "Not found" | Out-File -Encoding utf8 -FilePath $filepath
}