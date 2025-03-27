# $PackagePath = "$PSScriptRoot\..\teams\MSTeams-x64.msix"

# Add-AppxProvisionedPackage -Online -PackagePath $PackagePath -SkipLicense


$PackagePath = "$PSScriptRoot\..\teams\MSTeams-x64.msix"

Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command `"Add-AppxProvisionedPackage -Online -PackagePath '$PackagePath' -SkipLicense`"" -NoNewWindow -Wait
