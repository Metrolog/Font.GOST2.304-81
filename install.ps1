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

Write-Information 'Install Chocolatey command line package manager...';
if ($PSCmdLet.ShouldProcess('Chocolatey command line package manager', 'Установить')) {
    $env:chocolateyUseWindowsCompression = 'true';
    $env:chocolateyVersion = '0.9.10-beta-20160531';
    Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 | Invoke-Expression;
};

Write-Information 'Preparing NuGet.CommandLine...';
if ($PSCmdLet.ShouldProcess('NuGet.CommandLine', 'Установить')) {
    choco install 'NuGet.CommandLine' --confirm;
};

Write-Information 'Preparing MikTeX...';
if ($PSCmdLet.ShouldProcess('MikTeX', 'Установить')) {
    choco install miktex --confirm;
};

Write-Information 'Preparing cygwin...';
if ($PSCmdLet.ShouldProcess('CygWin', 'Установить')) {
    choco install cygwin --version '2.4.1' --confirm;
    $env:CygWin = Get-ItemPropertyValue `
        -Path HKLM:\SOFTWARE\Cygwin\setup `
        -Name rootdir `
    ;
    # исправляем проблемы совместимости chocolatey, cyg-get и cygwin
    If ( -not ( Test-Path "$env:CygWin\cygwinsetup.exe" ) ) {
        Copy-Item `
            -LiteralPath "$env:ChocolateyInstall\lib\Cygwin\tools\cygwin\cygwinsetup.exe" `
            -Destination $env:CygWin `
            -Force `
    };
    Write-Verbose "CygWin root directory: $env:CygWin";
    if ($PSCmdLet.ShouldProcess('CygWin', 'Установить переменную окружения')) {
        [System.Environment]::SetEnvironmentVariable( 'CygWin', $env:CygWin, [System.EnvironmentVariableTarget]::Machine );
    };
    $ToPath += "$env:CygWin\bin";
};

Write-Information 'Install CygWin tools...';
if ($PSCmdLet.ShouldProcess('make', 'Установить модуль CygWin')) {
    choco install make --source cygwin --confirm;
};
if ($PSCmdLet.ShouldProcess('mkdir', 'Установить модуль CygWin')) {
    choco install mkdir --source cygwin --confirm;
};
if ($PSCmdLet.ShouldProcess('zip', 'Установить модуль CygWin')) {
    choco install zip --source cygwin --confirm;
};
if ($PSCmdLet.ShouldProcess('touch', 'Установить модуль CygWin')) {
    choco install touch --source cygwin --confirm;
};
if ($PSCmdLet.ShouldProcess('ttfautohint', 'Установить модуль CygWin')) {
    choco install ttfautohint --source cygwin --confirm;
};

Write-Information 'Preparing git...';
if ($PSCmdLet.ShouldProcess('Git', 'Установить')) {
    choco install git --confirm;
};

Write-Information 'Preparing FontForge...';
if ($PSCmdLet.ShouldProcess('FontForge', 'Установить')) {
    choco install fontforge --confirm;
    $ToPath += "${env:ProgramFiles(x86)}\FontForgeBuilds\bin";
};

Write-Information 'Preparing MikTeX...';
if ($PSCmdLet.ShouldProcess('MikTeX', 'Установить')) {
    choco install miktex --confirm;
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
};

<#
Write-Information 'Preparing WiX Toolset...';
if ($PSCmdLet.ShouldProcess('WiX', 'Установить')) {
    $WixVersion = '4.0.0.3226-pre';
    nuget install WiX -version $WixVersion -OutputDirectory "$env:ProgramFiles\NuGet\Packages";
    $env:WIXDIR = "$env:ProgramFiles\NuGet\Packages\WiX.$WixVersion\tools\";
#    $env:WIXDIR = ( Get-Location ).ToString() + "\WiX.$WixVersion\tools\";
    [System.Environment]::SetEnvironmentVariable( 'WIXDIR', $env:WIXDIR, [System.EnvironmentVariableTarget]::Machine );
    $ToPath += $env:WIXDIR;
};
#>

Write-Information 'Preparing ActivePerl...';
if ($PSCmdLet.ShouldProcess('ActivePerl', 'Установить')) {
    choco install ActivePerl --confirm;
};

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
if ($PSCmdLet.ShouldProcess('GitVersion.Portable', 'Установить')) {
    choco install 'GitVersion.Portable' --confirm;
};

if ( $GUI ) {
    Write-Information 'Preparing SourceTree...';
    if ($PSCmdLet.ShouldProcess('SourceTree', 'Установить')) {
        choco install SourceTree --confirm;
    };
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
    $Path | % { Write-Verbose "    $_" };
    $env:Path = $Path -join ';';
    [System.Environment]::SetEnvironmentVariable( 'PATH', $env:Path, [System.EnvironmentVariableTarget]::User );
};
