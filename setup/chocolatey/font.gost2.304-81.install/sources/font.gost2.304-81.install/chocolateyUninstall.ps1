Uninstall-ChocolateyPackage `
    -packageName $env:chocolateyPackageName `
    -installerType msi `
    -silentArgs "$( ( Get-Item '*.msi' )[0].Name ) /qn /norestart" `
    -validExitCodes = @(0, 3010, 1641) `
;
