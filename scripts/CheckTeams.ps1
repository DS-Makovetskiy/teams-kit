Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Teams*" | ForEach-Object {
    "$($_.DisplayName) ($($_.Version))"
}
