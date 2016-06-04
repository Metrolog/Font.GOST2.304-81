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

Write-Information 'Preparing NuGet packages provider and sources...';
$null = Install-PackageProvider -Name NuGet -Force;
$null = Import-PackageProvider -Name NuGet -Force;
if ( (Get-PackageSource -ProviderName NuGet).count -eq 0 ) {
    Register-PackageSource `
        -Name NuGet `
        -ProviderName NuGet `
        -Location 'http://packages.nuget.org/api/v2/' `
        -Trusted `
        -OutVariable $null `
    ;
};

Write-Information 'Preparing Chocolatey packages provider and sources...';
$null = Install-PackageProvider -Name Chocolatey -Force;
$null = Import-PackageProvider -Name Chocolatey -Force;
if ( (Get-PackageSource -ProviderName Chocolatey).count -eq 0 ) {
    $null = Register-PackageSource `
        -Name chocolatey `
        -ProviderName Chocolatey `
        -Location 'http://chocolatey.org/api/v2/' `
        -Trusted `
    ;
};
$ToPath += "$env:ChocolateyPath\bin";

Write-Information 'Install Chocolatey command line package manager...';
if ($PSCmdLet.ShouldProcess('Chocolatey command line package manager', 'Установить')) {
    $env:chocolateyUseWindowsCompression = 'true';
    $env:chocolateyVersion = '0.9.10-beta-20160531';
    Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 | Invoke-Expression;
};

Write-Information 'Install CygWin tools...';
if ($PSCmdLet.ShouldProcess('make', 'Установить модуль CygWin')) {
    choco install make --source cygwin;
};
if ($PSCmdLet.ShouldProcess('mkdir', 'Установить модуль CygWin')) {
    choco install mkdir --source cygwin;
};
if ($PSCmdLet.ShouldProcess('zip', 'Установить модуль CygWin')) {
    choco install zip --source cygwin;
};
if ($PSCmdLet.ShouldProcess('touch', 'Установить модуль CygWin')) {
    choco install touch --source cygwin;
};
if ($PSCmdLet.ShouldProcess('ttfautohint', 'Установить модуль CygWin')) {
    choco install ttfautohint --source cygwin;
};

if ( (Get-Package -Name Git -ErrorAction SilentlyContinue).count -eq 0 ) {
    Write-Information 'Preparing git...';
    $null = Install-Package -Name 'git' -MinimumVersion '2.8';
};

Write-Information 'Preparing FontForge...';
$null = Install-Package -Name 'fontforge' -MinimumVersion '2015.08.24.20150930';
$ToPath += "${env:ProgramFiles(x86)}\FontForgeBuilds\bin";

Write-Information 'Preparing MikTeX...';
$null = Install-Package -Name 'miktex' -MinimumVersion '2.9';
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
    -Force `
;
$WixVersion = ( Get-Package -Name WiX -ProviderName NuGet ).Version;
$env:WIXDIR = "$env:ProgramFiles\NuGet\Packages\WiX.$WixVersion\tools\";
if ($PSCmdLet.ShouldProcess('WIXDIR', 'Установить переменную окружения')) {
    [System.Environment]::SetEnvironmentVariable( 'WIXDIR', $env:WIXDIR, [System.EnvironmentVariableTarget]::Machine );
};
$ToPath += $env:WIXDIR;

Write-Information 'Preparing ActivePerl...';
$null = Install-Package -Name 'ActivePerl';

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
$null = Install-Package -Name 'GitVersion.Portable';

if ( $GUI ) {
    Write-Information 'Preparing SourceTree...';
    $null = Install-Package -Name 'SourceTree';
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
