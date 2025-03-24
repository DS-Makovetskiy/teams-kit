$result =   Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Teams*" | ForEach-Object {
                "$($_.DisplayName) ($($_.Version))"
            }

# $result | Write-Output

# Проверяем, есть ли результат, и записываем его в файл
$filepath = "$PSScriptRoot\teams_status.txt"  # Записываем файл в ту же папку, где .ps1

if ($result) {
    $result | Out-File -Encoding utf8 teams_status.txt
} else {
    "Not found" | Out-File -Encoding utf8 teams_status.txt
}