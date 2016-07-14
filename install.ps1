﻿<# 
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
    , ConfirmImpact = 'Medium'
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

$null = Install-PackageProvider -Name Chocolatey -Force;
$null = Import-PackageProvider -Name Chocolatey -Force;
$null = Register-PackageSource `
    -Name chocolatey `
    -ProviderName Chocolatey `
    -Location 'http://chocolatey.org/api/v2/' `
    -Trusted `
    -Force `
;
$ToPath += "$env:ChocolateyPath\bin";

$null = Install-Package -Name 'GitVersion.Portable' -ProviderName Chocolatey -Source chocolatey;
$env:GitVersion = "$env:ChocolateyPath\lib\GitVersion.Portable.$(( Get-Package -Name GitVersion.Portable -ProviderName Chocolatey ).Version)\tools\GitVersion.exe";
Write-Verbose "GitVersion path: $env:GitVersion";
if ($PSCmdLet.ShouldProcess('GitVersion', 'Установить переменную окружения')) {
    [System.Environment]::SetEnvironmentVariable( 'GitVersion', $env:GitVersion, [System.EnvironmentVariableTarget]::Machine );
};

if ( -not ( $env:APPVEYOR -eq 'True' ) ) {

    $null = Install-Package -Name NuGet.CommandLine -ProviderName Chocolatey -Source chocolatey;
    $ToPath += "$env:ChocolateyPath\lib\NuGet.CommandLine.$(( Get-Package -Name NuGet.CommandLine -ProviderName Chocolatey ).Version)\tools";

    if ( -not ( Test-Path 'HKLM:\SOFTWARE\Cygwin\setup' ) ) {
        $null = Install-Package -Name 'cygwin' -ProviderName Chocolatey -Source chocolatey;
    };

    if ( ( Get-Package -Name Git -ErrorAction SilentlyContinue ).count -eq 0 ) {
        $null = Install-Package -Name 'git' -MinimumVersion '2.8' -ProviderName Chocolatey -Source chocolatey;
    };

    if ( -not ( Test-Path "$env:SystemDrive\Perl" ) ) {
        $null = Install-Package -Name StrawberryPerl -ProviderName Chocolatey -Source chocolatey;
    };

};

$env:CygWin = Get-ItemPropertyValue `
    -Path HKLM:\SOFTWARE\Cygwin\setup `
    -Name rootdir `
;
Write-Verbose "CygWin root directory: $env:CygWin";
# исправляем проблемы совместимости chocolatey, cyg-get и cygwin
If ( Test-Path "$env:CygWin\cygwinsetup.exe" ) {
    $cygwinsetup = "$env:CygWin\cygwinsetup.exe";
} ElseIf ( Test-Path "$env:CygWin\setup-x86_64.exe" ) {
    $cygwinsetup = "$env:CygWin\setup-x86_64.exe";
} ElseIf ( Test-Path "$env:CygWin\setup-x86.exe" ) {
    $cygwinsetup = "$env:CygWin\setup-x86.exe";
} ElseIf ( Test-Path "$env:ChocolateyPath\lib\Cygwin\tools\cygwin\cygwinsetup.exe" ) {
    $cygwinsetup = "$env:ChocolateyPath\lib\Cygwin\tools\cygwin\cygwinsetup.exe";
} ElseIf ( Test-Path "$env:ChocolateyPath\lib\Cygwin.$(( Get-Package -Name CygWin -ProviderName Chocolatey ).Version)\tools\cygwin\cygwinsetup.exe" ) {
    $cygwinsetup = "$env:ChocolateyPath\lib\Cygwin.$(( Get-Package -Name CygWin -ProviderName Chocolatey ).Version)\tools\cygwin\cygwinsetup.exe";
} Else {
    Write-Error 'I can not find CygWin setup!';
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

$null = Install-Package -Name 'fontforge' -MinimumVersion '2015.08.24.20150930' -ProviderName Chocolatey -Source chocolatey;
$ToPath += "${env:ProgramFiles(x86)}\FontForgeBuilds\bin";

if ($PSCmdLet.ShouldProcess('MikTeX', 'Установить')) {
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

    if ($PSCmdLet.ShouldProcess('MikTeX AutoInstall option', 'Разрешить')) {
        Set-ItemProperty `
            -Path 'HKLM:\Software\MiKTeX.org\MiKTeX\2.9\MPM' `
            -Name 'AutoInstall' `
            -Value 1 `
            -Force `
        ;
    };
    if ($PSCmdLet.ShouldProcess('MikTeX Package repository', 'Изменить')) {
        & "$MikTexBinPath\mpm" `
            --set-repository=ftp://mirror.ox.ac.uk/sites/ctan.org/systems/win32/miktex/tm/packages/ `
        | Out-String | Write-Verbose;
    };
};

Write-Verbose 'Preparing ctanify and ctanupload TeX scripts...';
Function Install-PackageMikTeX {
    <# 
    .Synopsis 
        Установка пакета в MikTeX.
    #> 
    [CmdletBinding(
        SupportsShouldProcess = $true
        , ConfirmImpact = 'Medium'
    )]
    param (
        # Пакет
        [Parameter( 
            Mandatory = $true 
            , Position = 1 
            , ValueFromPipeline = $true 
        )] 
        [System.String]
        $Name
    )
	process {
        $OldErrorActionPreference = $ErrorActionPreference;
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue;
        & "$MikTexBinPath\mpm" --verify=$Name | Out-String | Write-Verbose;
        $ErrorActionPreference = $OldErrorActionPreference;
        if ( $LASTEXITCODE -ne 0 ) {
            & "$MikTexBinPath\mpm" --install=$Name | Out-String | Write-Verbose;
        };
 	}
};
if ($PSCmdLet.ShouldProcess('ctanify', 'Установить сценарий TeX и необходимые для него файлы')) {
    & 'ppm' install File::Copy::Recursive | Out-String | Write-Verbose;
    Install-PackageMikTeX -Name ctanify;
};
if ($PSCmdLet.ShouldProcess('ctanupload', 'Установить сценарий TeX и необходимые для него файлы')) {
    & 'ppm' install HTML::FormatText | Out-String | Write-Verbose;
    Install-PackageMikTeX -Name ctanupload;
};

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
