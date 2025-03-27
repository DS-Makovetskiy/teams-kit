# Завершение всех процессов Teams
Get-Process -Name Teams -ErrorAction SilentlyContinue | Stop-Process -Force

# Получаем список всех пакетов, связанных с Microsoft Teams, для всех пользователей
$teamsPackages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*MSTeams*" }

# Удаляем каждый найденный пакет
foreach ($package in $teamsPackages) {
    Remove-AppxPackage -Package $package.PackageFullName -AllUsers
}
