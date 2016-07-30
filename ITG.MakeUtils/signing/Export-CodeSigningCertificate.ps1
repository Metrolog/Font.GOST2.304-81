[CmdletBinding()]
 
param (
    [String]
    $FilePath
)

$OldVerbosePreference = $VerbosePreference;
$VerbosePreference = 'SilentlyContinue';

Import-Module -Name Microsoft.PowerShell.Utility;
Import-Module -Name pki;

$VerbosePreference = $OldVerbosePreference;

Get-ChildItem -LiteralPath cert:/CurrentUser/My `
| ? { $_.EnhancedKeyUsageList | ? { $_.ObjectId -eq '1.3.6.1.5.5.7.3.3' } } `
| Sort-Object -Descending -Property NotAfter `
| Select-Object -First 1 `
| Export-Certificate -Type CERT -Force -FilePath $FilePath `
| Out-Null `
;
Write-Verbose "Code signing certificate was exported to `"$FilePath`".";
