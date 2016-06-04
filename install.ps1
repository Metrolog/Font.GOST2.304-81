<# 
.Synopsis 
    Скрипт подготовки среды сборки и тестирования проекта GOST2-304
.Description 
    Скрипт подготовки среды сборки и тестирования проекта GOST2-304.
    Используется в том числе и для подготовки среды на серверах appveyor.
.Link 
    https://github.com/Metrolog/Font.GOST2.304-81
.Example 
    .\install.ps1 -GUI;
    Устанавливаем необходимые пакеты, в том числе - и графические среды.
#> 
[CmdletBinding(
    SupportsShouldProcess = $true
    , ConfirmImpact = 'Low'
    , HelpUri = 'https://github.com/Metrolog/Font.GOST2.304-81'
)]
 
param (
    # Ключ, определяющий необходимость установки визуальных средств.
    # По умолчанию устанавливаются только средства для командной строки.
    [Switch]
    $GUI
) 

switch ( $env:PROCESSOR_ARCHITECTURE ) {
    'amd64' { $ArchPath = 'x64'; }
    'x86'   { $ArchPath = 'x86'; }
    default { Write-Error 'Unsupported processor architecture.'}
};
$ToPath = @();

Import-Module `
    -Name PackageManagement `
;

Write-Information 'Preparing NuGet packages provider and sources...';
$null = Install-PackageProvider `
    -Name NuGet `
    -Force `
;
$null = Import-PackageProvider `
    -Name NuGet `
    -Force `
;
if ( (Get-PackageSource -ProviderName NuGet).count -eq 0 ) {
    Register-PackageSource `
        -Name NuGet `
        -ProviderName NuGet `
        -Location 'http://packages.nuget.org/api/v2/' `
        -Trusted `
        -Force `
        -OutVariable $null `
    ;
};

Write-Information 'Preparing Chocolatey packages provider and sources...';
$null = Install-PackageProvider `
    -Name Chocolatey `
    -Force `
;
$null = Import-PackageProvider `
    -Name Chocolatey `
    -Force `
;
$null = Register-PackageSource `
    -Name chocolatey `
    -ProviderName Chocolatey `
    -Location 'http://chocolatey.org/api/v2/' `
    -Trusted `
    -Force `
;
$ToPath += "$env:ChocolateyPath\bin";

if ( (Get-Package -Name Git -ErrorAction SilentlyContinue).count -eq 0 ) {
    Write-Information 'Preparing git...';
    $null = Install-Package `
        -Name 'git' `
        -MinimumVersion '2.8' `
        -Force `
    ;
};

Write-Information 'Preparing cygwin...';
$null = Install-Package `
    -Name 'cygwin' `
    -Source chocolatey `
    -RequiredVersion '2.4.1' `
    -ForceBootstrap `
    -Force `
;
$env:CygWin = Get-ItemPropertyValue `
    -Path HKLM:\SOFTWARE\Cygwin\setup `
    -Name rootdir `
;
Write-Verbose "CygWin root directory: $env:CygWin";
if ($PSCmdLet.ShouldProcess('CygWin', 'Установить переменную окружения')) {
    [System.Environment]::SetEnvironmentVariable( 'CygWin', $env:CygWin, [System.EnvironmentVariableTarget]::Machine );
};
$ToPath += "$env:CygWin\bin";

<#
$null = Install-Package `
    -Name 'cyg-get' `
    -Source chocolatey `
    -RequiredVersion '1.0.7' `
    -Force `
;
$CygGet = "$env:ChocolateyPath\lib\cyg-get.$((Get-Package -Name 'cyg-get').Version)\content\cyg-get.ps1";
if ($PSCmdLet.ShouldProcess('ttfautohint, make, zip', 'Установить пакет CygWin')) {
    & $CygGet ttfautohint, make, zip;
};
#>
$cygwinsetup = "$env:CygWin\cygwinsetup.exe"
Write-Verbose "CygWinSetup path: $cygwinsetup";
if ($PSCmdLet.ShouldProcess('ttfautohint, make, zip', 'Установить пакет CygWin')) {
    Start-Process `
        -FilePath $cygwinsetup `
        -ArgumentList '--packages ttfautohint,make,zip --quiet-mode --no-desktop --no-startmenu --upgrade-also --site http://mirrors.kernel.org/sourceware/cygwin/' `
        -Wait `
        -WindowStyle Minimized `
    ;
};

Write-Information 'Preparing FontForge...';
$null = Install-Package `
    -Name 'fontforge' `
    -MinimumVersion '2015.08.24.20150930' `
    -Force `
;
$ToPath += "${env:ProgramFiles(x86)}\FontForgeBuilds\bin";

Write-Information 'Preparing MikTeX...';
$null = Install-Package `
    -Name 'miktex' `
    -MinimumVersion '2.9' `
    -Force `
;
$MikTex = `
    Get-ChildItem `
        -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall `
    | ?{ $_.Name -like '*MiKTeX*' } `
    | Get-ItemPropertyValue `
        -Name InstallLocation `
;
$MikTexBinPath = "$MikTex\miktex\bin\$ArchPath";
Write-Verbose "MikTeX bin directory: $MikTexBinPath";
$ToPath += $MikTexBinPath;

Write-Information 'Preparing WiX...';
$null = Install-Package `
    -Name 'WiX' `
    -MinimumVersion '4.0' `
    -Source NuGet `
    -ForceBootstrap `
    -Force `
;
$WixVersion = ( Get-Package -Name WiX -ProviderName NuGet ).Version;
$env:WIXDIR = "$env:ProgramFiles\NuGet\Packages\WiX.$WixVersion\tools\";
if ($PSCmdLet.ShouldProcess('WIXDIR', 'Установить переменную окружения')) {
    [System.Environment]::SetEnvironmentVariable( 'WIXDIR', $env:WIXDIR, [System.EnvironmentVariableTarget]::Machine );
};
$ToPath += $env:WIXDIR;

Write-Information 'Preparing ActivePerl...';
$null = Install-Package `
    -Name 'ActivePerl' `
    -Force `
;

Write-Information 'Preparing ctanify and ctanupload TeX scripts...';
if ($PSCmdLet.ShouldProcess('ctanify', 'Установить сценарий TeX и необходимые для него файлы')) {
    & "ppm" install File::Copy::Recursive;
    & "$MikTexBinPath\mpm" --install=ctanify;
};
if ($PSCmdLet.ShouldProcess('ctanupload', 'Установить сценарий TeX и необходимые для него файлы')) {
    & "ppm" install HTML::FormatText;
    & "$MikTexBinPath\mpm" --install=ctanupload;
};

Write-Information 'Preparing GitVersion...';
$null = Install-Package `
    -Name 'GitVersion.Portable' `
    -Force `
;

if ( $GUI ) {
    Write-Information 'Preparing SourceTree...';
    $null = Install-Package `
        -Name 'SourceTree' `
        -Force `
    ;
};

Write-Information 'Preparing PATH environment variable...';
if ($PSCmdLet.ShouldProcess('PATH', 'Установить переменную окружения')) {
    $Path = `
        ( `
            ( $env:Path -split ';' ) `
            + $ToPath `
            | Sort-Object -Unique `
        ) `
    ;
    Write-Verbose "Path variable: $Path";
    $env:Path = $Path -join ';';
    [System.Environment]::SetEnvironmentVariable( 'PATH', $env:Path, [System.EnvironmentVariableTarget]::User );
};
