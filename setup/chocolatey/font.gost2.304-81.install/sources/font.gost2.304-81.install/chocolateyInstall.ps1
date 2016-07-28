Install-ChocolateyInstallPackage `
    -packageName $env:chocolateyPackageName `
    -installerType msi `
    -silentArgs '/quiet /qn /norestart' `
    -file ( Join-Path -Path ( Split-Path -parent $MyInvocation.MyCommand.Definition ) -ChildPath 'setup.msi' ) `
    -validExitCodes @(0, 3010, 1641) `
;
