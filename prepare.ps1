Import-Module `
    -Name PackageManagement `
;
Install-PackageProvider `
    -Name NuGet `
    -Force `
;
Register-PackageSource `
    -Name NuGet `
    -ProviderName NuGet `
    -Location 'http://packages.nuget.org/api/v2/' `
    -Trusted `
    -Force `
;
Install-PackageProvider `
    -Name Chocolatey `
    -Force `
;
Import-PackageProvider `
    -Name Chocolatey `
    -Force `
;
Install-Package `
    -Name Chocolatey `
    -Source chocolatey `
    -Force `
;

Install-Package `
    -Name 'GnuWin32.Bin' `
    -MinimumVersion '0.6.3' `
    -Verbose `
    -Force `
;
Install-Package `
    -Name 'python' `
    -MinimumVersion '3.5' `
    -Verbose `
    -Force `
;
Install-Package `
    -Name 'fontforge' `
    -MinimumVersion '2015.08.24.20150930' `
    -Verbose `
    -Force `
;
Install-Package `
    -Name 'miktex' `
    -MinimumVersion '2.9' `
    -Verbose `
    -Force `
;
Install-Package `
    -Name 'WiX' `
    -MinimumVersion '4.0' `
    -Source NuGet `
    -Verbose `
    -Force `
;
Install-Package `
    -Name 'cygwin' `
    -Source chocolatey `
    -Verbose `
    -Force `
;
Install-Package `
    -Name 'cyg-get' `
    -Source chocolatey `
    -Verbose `
    -Force `
;

#Invoke-Expression "$env:ChocolateyPath\lib\chocolatey.$((Get-Package -Name 'chocolatey').Version)\tools\chocolateyInstall\choco install cygwin -y -force";

#Invoke-Expression "$env:ChocolateyPath\lib\cyg-get.$((Get-Package -Name 'cyg-get').Version)\tools\cyg-get.ps1 ttfautohint"

