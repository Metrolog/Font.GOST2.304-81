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

Import-Module -Name PackageManagement;

<#
$null = Install-PackageProvider -Name NuGet -Force;
$null = Import-PackageProvider -Name NuGet -Force;
$null = Register-PackageSource `
    -Name NuGet `
    -ProviderName NuGet `
    -Location 'http://packages.nuget.org/api/v2/' `
    -Trusted `
    -Force `
;
#>

$null = Install-PackageProvider -Name Chocolatey -Force;
$null = Import-PackageProvider -Name Chocolatey -Force;
#if ( (Get-PackageSource -ProviderName Chocolatey).count -eq 0 ) {
    $null = Register-PackageSource `
        -Name chocolatey `
        -ProviderName Chocolatey `
        -Location 'http://chocolatey.org/api/v2/' `
        -Trusted `
        -Force `
    ;
#};
$ToPath += "$env:ChocolateyPath\bin";

$null = Install-Package -Name 'GitVersion.Portable' -ProviderName Chocolatey -Source chocolatey;
Write-Verbose 'Set build full version with GitVersion...';
& GitVersion /output buildserver;

if ( ( Get-Package -Name CygWin -ErrorAction SilentlyContinue ).count -eq 0 ) {
    $null = Install-Package -Name 'cygwin' -RequiredVersion '2.4.1' -ProviderName Chocolatey -Source chocolatey;
};
$env:CygWin = Get-ItemPropertyValue `
    -Path HKLM:\SOFTWARE\Cygwin\setup `
    -Name rootdir `
;
Write-Verbose "CygWin root directory: $env:CygWin";
# исправляем проблемы совместимости chocolatey, cyg-get и cygwin
If ( Test-Path "$env:CygWin\cygwinsetup.exe" ) {
    $cygwinsetup = "$env:CygWin\cygwinsetup.exe";
} ElseIf ( Test-Path "$env:CygWin\setup-x86.exe" ) {
    $cygwinsetup = "$env:CygWin\setup-x86.exe";
} ElseIf ( Test-Path "$env:ChocolateyInstall\lib\Cygwin\tools\cygwin\cygwinsetup.exe" ) {
    $cygwinsetup = "$env:ChocolateyInstall\lib\Cygwin\tools\cygwin\cygwinsetup.exe";
} Else {
    Write-Error 'I can not find CygWin setup, try to use it from PATH!!!';
};
Write-Verbose "CygWin setup: $cygwinsetup";
if ($PSCmdLet.ShouldProcess('CygWin', 'Установить переменную окружения')) {
    [System.Environment]::SetEnvironmentVariable( 'CygWin', $env:CygWin, [System.EnvironmentVariableTarget]::Machine );
};
$ToPath += "$env:CygWin\bin";

Write-Verbose 'Install CygWin tools...';
if ($PSCmdLet.ShouldProcess('make, mkdir, touch, zip, ttfautohint', 'Установить пакет CygWin')) {
    Start-Process `
        -FilePath $cygwinsetup `
        -ArgumentList '--packages make,mkdir,touch,zip,ttfautohint --quiet-mode --no-desktop --no-startmenu --upgrade-also --site http://mirrors.kernel.org/sourceware/cygwin/' `
        -Wait `
        -WindowStyle Minimized `
    ;
};

if ( (Get-Package -Name Git -ErrorAction SilentlyContinue).count -eq 0 ) {
    $null = Install-Package -Name 'git' -MinimumVersion '2.8' -ProviderName Chocolatey -Source chocolatey;
};

$null = Install-Package -Name 'fontforge' -MinimumVersion '2015.08.24.20150930' -ProviderName Chocolatey -Source chocolatey;
$ToPath += "${env:ProgramFiles(x86)}\FontForgeBuilds\bin";

$null = Install-Package -Name 'miktex' -MinimumVersion '2.9' -ProviderName Chocolatey -Source chocolatey;
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

<#
$null = Install-Package `
    -Name 'WiX' `
    -MinimumVersion '4.0' `
    -Source NuGet `
    -Force `
;
$WixVersion = ( Get-Package -Name WiX -ProviderName NuGet ).Version;
$env:WIXDIR = "$env:ProgramFiles\NuGet\Packages\WiX.$WixVersion\tools\";
if ($PSCmdLet.ShouldProcess('WIXDIR', 'Установить переменную окружения')) {
    [System.Environment]::SetEnvironmentVariable( 'WIXDIR', $env:WIXDIR, [System.EnvironmentVariableTarget]::Machine );
};
$ToPath += $env:WIXDIR;
#>

$null = Install-Package -Name 'ActivePerl' -Source chocolatey;

Write-Verbose 'Preparing ctanify and ctanupload TeX scripts...';
if ($PSCmdLet.ShouldProcess('ctanify', 'Установить сценарий TeX и необходимые для него файлы')) {
    & "ppm" install File::Copy::Recursive;
    & "$MikTexBinPath\mpm" --install=ctanify;
};
if ($PSCmdLet.ShouldProcess('ctanupload', 'Установить сценарий TeX и необходимые для него файлы')) {
    & "ppm" install HTML::FormatText;
    & "$MikTexBinPath\mpm" --install=ctanupload;
};

$null = Install-Package -Name adobereader -ProviderName Chocolatey -Source chocolatey;

if ( $GUI ) {
    $null = Install-Package -Name SourceTree -ProviderName Chocolatey -Source chocolatey;
    $null = Install-Package -Name visualstudio2015community -ProviderName Chocolatey -Source chocolatey;
    $null = Install-Package -Name notepadplusplus -ProviderName Chocolatey -Source chocolatey;
};

Write-Verbose 'Preparing PATH environment variable...';
if ($PSCmdLet.ShouldProcess('PATH', 'Установить переменную окружения')) {
    $Path = `
        ( `
            ( $env:Path -split ';' ) `
            + $ToPath `
            | Sort-Object -Unique `
        ) `
    ;
    Write-Verbose 'Path variable:';
    $Path | % { Write-Verbose "    $_" };
    $env:Path = $Path -join ';';
    [System.Environment]::SetEnvironmentVariable( 'PATH', $env:Path, [System.EnvironmentVariableTarget]::User );
};
