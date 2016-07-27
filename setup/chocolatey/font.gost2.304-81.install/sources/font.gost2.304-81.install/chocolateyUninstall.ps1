﻿Uninstall-ChocolateyPackage `
    -packageName $env:chocolateyPackageName `
    -installerType msi `
    -silentArgs "$( ( Get-Item -Path ( Join-Path -Path ( Split-Path -Parent $PSCommandPath ) -ChildPath '*.msi' ) )[0].FullName ) /quiet /qn  /norestart" `
    -file ( ( Get-Item -Path ( Join-Path -Path ( Split-Path -Parent $PSCommandPath ) -ChildPath '*.msi' ) )[0].FullName ) `
    -validExitCodes @(0, 3010, 1641) `
;
