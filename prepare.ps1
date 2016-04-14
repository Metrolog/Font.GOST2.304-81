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
Register-PackageSource `
    -Name chocolatey `
    -ProviderName Chocolatey `
    -Location 'http://chocolatey.org/api/v2/' `
    -Trusted `
    -Force `
;

Install-Package `
    -Name 'git' `
    -MinimumVersion '2.8' `
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
    -Name 'cygwin' `
    -Source chocolatey `
    -RequiredVersion '2.4.1' `
    -Verbose `
    -Force `
;
$env:CygWin = Get-ItemPropertyValue `
    -Path HKLM:\SOFTWARE\Cygwin\setup `
    -Name rootdir `
;
[System.Environment]::SetEnvironmentVariable( 'CygWin', $env:CygWin, [System.EnvironmentVariableTarget]::Machine );
$env:Path = ( ( $env:Path -split ';' ) + ( , "$env:CygWin\bin" ) | Sort-Object -Unique ) -join ';';
[System.Environment]::SetEnvironmentVariable( 'PATH', $env:Path, [System.EnvironmentVariableTarget]::Machine );
Install-Package `
    -Name 'cyg-get' `
    -Source chocolatey `
    -RequiredVersion '1.2.0' `
    -Verbose `
    -Force `
;
Invoke-Expression "$env:ChocolateyPath\lib\cyg-get.$((Get-Package -Name 'cyg-get').Version)\tools\cyg-get.ps1 ttfautohint";
Invoke-Expression "$env:ChocolateyPath\lib\cyg-get.$((Get-Package -Name 'cyg-get').Version)\tools\cyg-get.ps1 make";

Install-Package `
    -Name 'WiX' `
    -MinimumVersion '4.0' `
    -Source NuGet `
    -Verbose `
    -Force `
;
