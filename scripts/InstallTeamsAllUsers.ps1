$PackagePath = "..\teams\MSTeams-x64.msix"

Add-AppxProvisionedPackage -Online -PackagePath $PackagePath -SkipLicense
