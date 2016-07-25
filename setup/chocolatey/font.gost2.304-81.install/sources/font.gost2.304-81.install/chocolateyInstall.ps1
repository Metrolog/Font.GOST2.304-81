Install-ChocolateyPackage `
    -packageName '{{PackageName}}' `
    -installerType msi `
    -silentArgs "/qn /norestart /l*v `"$env:TEMP\chocolatey\{{PackageName}}.{{PackageVersion}}\MsiInstall.log`"" `
    -url "https://github.com/Metrolog/Font.GOST2.304-81/releases/download/v{{PackageVersion}}/GOST2.304-81.msi" `
    -validExitCodes = @(0, 3010, 1641) `
;
