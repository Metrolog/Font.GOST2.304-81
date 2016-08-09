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
    , ConfirmImpact = 'Medium'
    , HelpUri = 'https://github.com/Metrolog/Font.GOST2.304-81'
)]
 
param (
    # Ключ, определяющий необходимость установки визуальных средств.
    # По умолчанию устанавливаются только средства для командной строки.
    [Switch]
    $GUI
) 

Function Execute-ExternalInstaller {
    [CmdletBinding(
        SupportsShouldProcess = $true
        , ConfirmImpact = 'Medium'
    )]
    param (
        [String]
        $LiteralPath
        ,
        [String]
        $ArgumentList
    )

    $pinfo = [System.Diagnostics.ProcessStartInfo]::new();
    $pinfo.FileName = $LiteralPath;
    $pinfo.RedirectStandardError = $true;
    $pinfo.RedirectStandardOutput = $true;
    $pinfo.UseShellExecute = $false;
    $pinfo.Arguments = $ArgumentList;
    $p = [System.Diagnostics.Process]::new();
    try {
        $p.StartInfo = $pinfo;
        $p.Start() | Out-Null;
        $p.WaitForExit();
        $LASTEXITCODE = $p.ExitCode;
        $p.StandardOutput.ReadToEnd() `
        | Write-Verbose `
        ;
        if ( $p.ExitCode -ne 0 ) {
            $p.StandardError.ReadToEnd() `
            | Write-Error `
            ;
        };
    } finally {
        $p.Close();
    };
}

switch ( $env:PROCESSOR_ARCHITECTURE ) {
    'amd64' { $ArchPath = 'x64'; }
    'x86'   { $ArchPath = 'x86'; }
    default { Write-Error 'Unsupported processor architecture.'}
};
$ToPath = @();

Import-Module -Name PackageManagement;

$null = Install-PackageProvider -Name NuGet -Force;
$null = Import-PackageProvider -Name NuGet -Force;
$null = (
    Get-PackageSource -ProviderName NuGet `
    | Set-PackageSource -Trusted `
);
$null = Install-PackageProvider -Name Chocolatey -Force;
$null = Import-PackageProvider -Name Chocolatey -Force;
$null = (
    Get-PackageSource -ProviderName Chocolatey `
    | Set-PackageSource -Trusted `
);
$null = Install-Package -Name chocolatey -MinimumVersion 0.9.10.3 -ProviderName Chocolatey;
$null = Import-PackageProvider -Name Chocolatey -Force;
$null = (
    Get-PackageSource -ProviderName Chocolatey `
    | Set-PackageSource -Trusted `
);

& choco install GitVersion.Portable --confirm --failonstderr | Out-String -Stream | Write-Verbose;
& choco install GitReleaseNotes.Portable --confirm --failonstderr | Out-String -Stream | Write-Verbose;

if ( -not ( $env:APPVEYOR -eq 'True' ) ) {
    & choco install NuGet.CommandLine --confirm --failonstderr | Out-String -Stream | Write-Verbose;
    & choco install git --confirm --failonstderr | Out-String -Stream | Write-Verbose;
    & choco install StrawberryPerl --confirm --failonstderr | Out-String -Stream | Write-Verbose;
    & choco install openssl --confirm --failonstderr | Out-String -Stream | Write-Verbose;
    & choco install windows-sdk-10 --confirm --failonstderr | Out-String -Stream | Write-Verbose;
};

& choco install cygwin --confirm --failonstderr | Out-String -Stream | Write-Verbose;
$env:CygWin = Get-ItemPropertyValue `
    -Path HKLM:\SOFTWARE\Cygwin\setup `
    -Name rootdir `
;
Write-Verbose "CygWin root directory: $env:CygWin";
$ToPath += "$env:CygWin\bin";

#& choco install make mkdir touch zip ttfautohint --source cygwin --confirm --failonstderr | Out-String -Stream | Write-Verbose;
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
    Execute-ExternalInstaller `
        -LiteralPath $cygwinsetup `
        -ArgumentList '--packages make,mkdir,touch,zip,ttfautohint --quiet-mode --no-desktop --no-startmenu --site http://mirrors.kernel.org/sourceware/cygwin/' `
    ;
};

& choco install fontforge --confirm --failonstderr | Out-String -Stream | Write-Verbose;
$ToPath += "${env:ProgramFiles(x86)}\FontForgeBuilds\bin";

if ($PSCmdLet.ShouldProcess('MikTeX', 'Установить')) {
#   $null = Install-Package -Name 'miktex' -MinimumVersion '2.9' -ProviderName Chocolatey -Source chocolatey;
    switch ( $env:PROCESSOR_ARCHITECTURE ) {
        'amd64' {
            $MiktexSetupZIP = 'miktexsetup-x64.zip';
            $MiktexSetupNET = 'setup-x64.exe';
        }
        'x86' {
            $MiktexSetupZIP = 'miktexsetup.zip';
            $MiktexSetupNET = 'setup.exe';
        }
        default { Write-Error 'Unsupported processor architecture.'}
    };
    # nearest repository selection
    if ( $env:APPVEYOR -eq 'True' ) {
        $MiktexRemoteRepositoryRoot = "http://muug.ca/mirror/ctan/systems/win32/miktex";
    } else {
        $MiktexRemoteRepositoryRoot = "http://mirror.datacenter.by/pub/mirrors/CTAN/systems/win32/miktex";
    };
    $MiktexRemoteRepository = "$MiktexRemoteRepositoryRoot/tm/packages/";
    Invoke-WebRequest -Uri "$MiktexRemoteRepositoryRoot/setup/$MiktexSetupZIP" -OutFile "$env:Temp/$MiktexSetupZIP";
    Expand-Archive -LiteralPath "$env:Temp/$MiktexSetupZIP" -DestinationPath "$env:Temp/miktex" -Force;
    $MiktexLocalRepository = "$env:Temp\miktex";
    $MiktexSetup = "$MiktexLocalRepository\miktexsetup.exe";
    & $MiktexSetup `
        --remote-package-repository="$MiktexRemoteRepository" `
        --local-package-repository="$MiktexLocalRepository" `
        --package-set=basic `
        --verbose `
        download `
    | Out-String -Stream | Write-Verbose;
    $MiktexPath = "$env:ProgramFiles\miktex";
<#
    & $MiktexSetup `
        --remote-package-repository="$MiktexRemoteRepository" `
        --local-package-repository="$MiktexLocalRepository" `
        --package-set=basic `
        --common-install="$MiktexPath" `
        --modify-path `
        --verbose `
        install `
    | Out-String -Stream | Write-Verbose;
#>
    $MiktexSetupNETTool = "$MiktexLocalRepository\setup.exe";
    Invoke-WebRequest -Uri "$MiktexRemoteRepositoryRoot/setup/$MiktexSetupNET" -OutFile "$MiktexSetupNETTool";
    & $MiktexSetupNetTool `
        --install-from-local-repository --local-package-repository="$MiktexLocalRepository" `
        --package-set=basic `
        --shared `
        --common-install="$MiktexPath" `
        --unattended `
    | Out-String | Write-Verbose;

    $MikTexBinPath = "$MiktexPath\miktex\bin\$ArchPath";
    Write-Verbose "MikTeX bin directory: $MikTexBinPath";
    $ToPath += $MikTexBinPath;

    if ($PSCmdLet.ShouldProcess('MikTeX AutoInstall option', 'Разрешить')) {
        & "$MikTexBinPath\initexmf.exe" `
            --set-config-value=[MPM]AutoInstall=1 `
            --verbose `
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

& choco install ChocolateyPackageUpdater --confirm --failonstderr | Out-String -Stream | Write-Verbose;
& choco install SignCode.Install --confirm --version 1.0.2 --failonstderr | Out-String -Stream | Write-Verbose;

if ( $GUI ) {
    $null = Install-Package -Name SourceTree -ProviderName Chocolatey;
    $null = Install-Package -Name visualstudio2015community -ProviderName Chocolatey;
    $null = Install-Package -Name notepadplusplus -ProviderName Chocolatey;
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
