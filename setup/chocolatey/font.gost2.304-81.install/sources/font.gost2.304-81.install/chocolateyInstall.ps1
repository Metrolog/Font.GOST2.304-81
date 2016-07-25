Install-ChocolateyInstallPackage `
    -packageName $env:chocolateyPackageName `
    -installerType msi `
    -silentArgs '/qn /norestart' `
    -filePath ( ( Get-Item '*.msi' )[0].Name ) `
    -validExitCodes = @(0, 3010, 1641) `
;
