# Определяем путь к файлу (он будет в той же папке, что и .ps1)
$filepath = "$PSScriptRoot\teams_status.txt"

# Если файл существует, удаляем его
if (Test-Path $filepath) {
    Remove-Item -Path $filepath -Force
}

$result =   Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Teams*" | ForEach-Object {
                "$($_.DisplayName) ($($_.Version))"
            }

# $result | Write-Output
# Проверяем, есть ли результат, и записываем его в файл
if ($result) {
    $result | Out-File -Encoding utf8 -FilePath $filepath
} else {
    "Not found" | Out-File -Encoding utf8 -FilePath $filepath
}