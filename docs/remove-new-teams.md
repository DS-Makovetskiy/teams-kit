# <center>[Удаление нового клиента Teams](https://learn.microsoft.com/en-us/microsoftteams/teams-client-uninstall)  </center>  

## Удаление New Teams для всех пользователей  

Чтобы удалить новую Teams с компьютеров всех пользователей, используйте следующую команду PowerShell:
```PowerShell
Remove-AppxPackage
```

Командлет PowerShell для удаления новых teams от всех пользователей на всех компьютерах:
```PowerShell
Get-AppxPackage *MSTeams* -AllUsers |Remove-AppxPackage -AllUsers
```

Командлет PowerShell для отдельного пользователя без прав администратора:
```PowerShell
Get-AppxPackage *MSTeams*|Remove-AppxPackage
```

Команда для удаления teams на уровне компьютера: teamsbootstrapper.exe -x -m


