Uninstall-ChocolateyPackage `
    -packageName '{{PackageName}}' `
    -installerType msi `
    -silentArgs "{{PackageGUID}} /qn /norestart /l*v `"$env:TEMP\chocolatey\{{PackageName}}.{{PackageVersion}}\MsiUninstall.log`"" `
    -validExitCodes = @(0, 3010, 1641) `
;
