#requires -version 5.1
$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'MCO Database Runtime Repair v0.9'
$Script:LogPath = $null
$Script:DataRoot = Join-Path $env:ProgramData 'MCO New Age Install'
$Script:LogRoot = Join-Path $Script:DataRoot 'Logs'

# Embedded Jet 3.5 registry. No external Registry folder is required.
$Script:EmbeddedReg_Jet35 = @'
//5XAGkAbgBkAG8AdwBzACAAUgBlAGcAaQBzAHQAcgB5ACAARQBkAGkAdABvAHIAIABWAGUAcgBzAGkAbwBuACAANQAuADAAMAANAAoADQAKAFsASABLAEUA
WQBfAEwATwBDAEEATABfAE0AQQBDAEgASQBOAEUAXABTAE8ARgBUAFcAQQBSAEUAXABXAE8AVwA2ADQAMwAyAE4AbwBkAGUAXABNAGkAYwByAG8AcwBvAGYA
dABcAEoAZQB0AFwAMwAuADUAXQANAAoADQAKAFsASABLAEUAWQBfAEwATwBDAEEATABfAE0AQQBDAEgASQBOAEUAXABTAE8ARgBUAFcAQQBSAEUAXABXAE8A
VwA2ADQAMwAyAE4AbwBkAGUAXABNAGkAYwByAG8AcwBvAGYAdABcAEoAZQB0AFwAMwAuADUAXABFAG4AZwBpAG4AZQBzAF0ADQAKACIAUwB5AHMAdABlAG0A
RABCACIAPQAiAHMAeQBzAHQAZQBtAC4AbQBkAGIAIgANAAoAIgBDAG8AbQBwAGEAYwB0AEIAeQBQAEsAZQB5ACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAA
MAAwADEADQAKAA0ACgBbAEgASwBFAFkAXwBMAE8AQwBBAEwAXwBNAEEAQwBIAEkATgBFAFwAUwBPAEYAVABXAEEAUgBFAFwAVwBPAFcANgA0ADMAMgBOAG8A
ZABlAFwATQBpAGMAcgBvAHMAbwBmAHQAXABKAGUAdABcADMALgA1AFwARQBuAGcAaQBuAGUAcwBcAEoAZQB0ACAAMgAuAHgAXQANAAoAIgB3AGkAbgAzADIA
IgA9ACIAQwA6AFwAXABXAGkAbgBkAG8AdwBzAFwAXABzAHkAcwB0AGUAbQAzADIAXABcAG0AcwByAGQAMgB4ADMANQAuAGQAbABsACIADQAKACIAUgBlAGEA
ZABBAGgAZQBhAGQAUABhAGcAZQBzACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAwADgADQAKACIATQBhAHgAQgB1AGYAZgBlAHIAUwBpAHoAZQAiAD0A
ZAB3AG8AcgBkADoAMAAwADAAMAAwADIAMAAwAA0ACgAiAEwAbwBjAGsAUgBlAHQAcgB5ACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAxADQADQAKACIA
QwBvAG0AbQBpAHQATABvAGMAawBSAGUAdAByAHkAIgA9AGQAdwBvAHIAZAA6ADAAMAAwADAAMAAwADEANAANAAoAIgBQAGEAZwBlAFQAaQBtAGUAbwB1AHQA
IgA9AGQAdwBvAHIAZAA6ADAAMAAwADAAMAAwADAANQANAAoAIgBMAG8AYwBrAGUAZABQAGEAZwBlAFQAaQBtAGUAbwB1AHQAIgA9AGQAdwBvAHIAZAA6ADAA
MAAwADAAMAAwADAANQANAAoAIgBDAHUAcgBzAG8AcgBUAGkAbQBlAG8AdQB0ACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAwADUADQAKACIASQBkAGwA
ZQBGAHIAZQBxAHUAZQBuAGMAeQAiAD0AZAB3AG8AcgBkADoAMAAwADAAMAAwADAAMABhAA0ACgAiAEYAbwByAGMAZQBPAFMARgBsAHUAcwBoACIAPQBkAHcA
bwByAGQAOgAwADAAMAAwADAAMAAwADAADQAKAA0ACgBbAEgASwBFAFkAXwBMAE8AQwBBAEwAXwBNAEEAQwBIAEkATgBFAFwAUwBPAEYAVABXAEEAUgBFAFwA
VwBPAFcANgA0ADMAMgBOAG8AZABlAFwATQBpAGMAcgBvAHMAbwBmAHQAXABKAGUAdABcADMALgA1AFwARQBuAGcAaQBuAGUAcwBcAEoAZQB0ACAAMwAuADUA
XQANAAoAIgBQAGEAZwBlAFQAaQBtAGUAbwB1AHQAIgA9AGQAdwBvAHIAZAA6ADAAMAAwADAAMQAzADgAOAANAAoAIgBMAG8AYwBrAFIAZQB0AHIAeQAiAD0A
ZAB3AG8AcgBkADoAMAAwADAAMAAwADAAMQA0AA0ACgAiAE0AYQB4AEIAdQBmAGYAZQByAFMAaQB6AGUAIgA9AGQAdwBvAHIAZAA6ADAAMAAwADAAMAAwADAA
MAANAAoAIgBUAGgAcgBlAGEAZABzACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAwADMADQAKACIARQB4AGMAbAB1AHMAaQB2AGUAQQBzAHkAbgBjAEQA
ZQBsAGEAeQAiAD0AZAB3AG8AcgBkADoAMAAwADAAMAAwADcAZAAwAA0ACgAiAFMAaABhAHIAZQBkAEEAcwB5AG4AYwBEAGUAbABhAHkAIgA9AGQAdwBvAHIA
ZAA6ADAAMAAwADAAMAAwADMAMgANAAoAIgBGAGwAdQBzAGgAVAByAGEAbgBzAGEAYwB0AGkAbwBuAFQAaQBtAGUAbwB1AHQAIgA9AGQAdwBvAHIAZAA6ADAA
MAAwADAAMAAxAGYANAANAAoAIgBNAGEAeABMAG8AYwBrAHMAUABlAHIARgBpAGwAZQAiAD0AZAB3AG8AcgBkADoAMAAwADAAMAAyADUAMQBjAA0ACgAiAEwA
bwBjAGsARABlAGwAYQB5ACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAA2ADQADQAKACIAUgBlAGMAeQBjAGwAZQBMAFYAcwAiAD0AZAB3AG8AcgBkADoA
MAAwADAAMAAwADAAMAAwAA0ACgAiAFUAcwBlAHIAQwBvAG0AbQBpAHQAUwB5AG4AYwAiAD0AIgB5AGUAcwAiAA0ACgAiAEkAbQBwAGwAaQBjAGkAdABDAG8A
bQBtAGkAdABTAHkAbgBjACIAPQAiAG4AbwAiAA0ACgANAAoAWwBIAEsARQBZAF8ATABPAEMAQQBMAF8ATQBBAEMASABJAE4ARQBcAFMATwBGAFQAVwBBAFIA
RQBcAFcATwBXADYANAAzADIATgBvAGQAZQBcAE0AaQBjAHIAbwBzAG8AZgB0AFwASgBlAHQAXAAzAC4ANQBcAEUAbgBnAGkAbgBlAHMAXABPAEQAQgBDAF0A
DQAKACIAVAByAGEAYwBlAE8ARABCAEMAQQBQAEkAIgA9AGQAdwBvAHIAZAA6ADAAMAAwADAAMAAwADAAMAANAAoAIgBEAGkAcwBhAGIAbABlAEEAcwB5AG4A
YwAiAD0AZAB3AG8AcgBkADoAMAAwADAAMAAwADAAMAAxAA0ACgAiAFQAcgBhAGMAZQBTAFEATABNAG8AZABlACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAA
MAAwADAADQAKACIAUQB1AGUAcgB5AFQAaQBtAGUAbwB1AHQAIgA9AGQAdwBvAHIAZAA6ADAAMAAwADAAMAAwADMAYwANAAoAIgBMAG8AZwBpAG4AVABpAG0A
ZQBvAHUAdAAiAD0AZAB3AG8AcgBkADoAMAAwADAAMAAwADAAMQA0AA0ACgAiAEMAbwBuAG4AZQBjAHQAaQBvAG4AVABpAG0AZQBvAHUAdAAiAD0AZAB3AG8A
cgBkADoAMAAwADAAMAAwADIANQA4AA0ACgAiAFQAcgB5AEoAZQB0AEEAdQB0AGgAIgA9AGQAdwBvAHIAZAA6ADAAMAAwADAAMAAwADAAMQANAAoAIgBGAGEA
dABCAGwAYQBzAHQAUgBvAHcAcwAiAD0AZAB3AG8AcgBkADoAZgBmAGYAZgBmAGYAZgBmAA0ACgAiAEYAYQB0AEIAbABhAHMAdABUAGkAbQBlAG8AdQB0ACIA
PQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAwADMADQAKACIAQQBzAHkAbgBjAFIAZQB0AHIAeQBJAG4AdABlAHIAdgBhAGwAIgA9AGQAdwBvAHIAZAA6ADAA
MAAwADAAMAAxAGYANAANAAoAIgBBAHQAdABhAGMAaABDAGEAcwBlAFMAZQBuAHMAaQB0AGkAdgBlACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAwADAA
DQAKACIARgBhAHMAdABSAGUAcQB1AGUAcgB5ACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAwADAADQAKACIATwBEAEIAQwBJAFMAQQBNAEEAdAB0AGEA
YwBoACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAwADAADQAKACIAUAByAGUAcABhAHIAZQBkAEkAbgBzAGUAcgB0ACIAPQBkAHcAbwByAGQAOgAwADAA
MAAwADAAMAAwADAADQAKACIAUAByAGUAcABhAHIAZQBkAFUAcABkAGEAdABlACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAwADAADQAKACIAUwBuAGEA
cABzAGgAbwB0AE8AbgBsAHkAIgA9AGQAdwBvAHIAZAA6ADAAMAAwADAAMAAwADAAMAANAAoAIgBBAHQAdABhAGMAaABhAGIAbABlAE8AYgBqAGUAYwB0AHMA
IgA9ACIAJwBUAEEAQgBMAEUAJwAsACcAVgBJAEUAVwAnACwAJwBTAFkAUwBUAEUATQAgAFQAQQBCAEwARQAnACwAJwBBAEwASQBBAFMAJwAsACcAUwBZAE4A
TwBOAFkATQAnACIADQAKAA0ACgBbAEgASwBFAFkAXwBMAE8AQwBBAEwAXwBNAEEAQwBIAEkATgBFAFwAUwBPAEYAVABXAEEAUgBFAFwAVwBPAFcANgA0ADMA
MgBOAG8AZABlAFwATQBpAGMAcgBvAHMAbwBmAHQAXABKAGUAdABcADMALgA1AFwASQBTAEEATQAgAEYAbwByAG0AYQB0AHMAXQANAAoADQAKAFsASABLAEUA
WQBfAEwATwBDAEEATABfAE0AQQBDAEgASQBOAEUAXABTAE8ARgBUAFcAQQBSAEUAXABXAE8AVwA2ADQAMwAyAE4AbwBkAGUAXABNAGkAYwByAG8AcwBvAGYA
dABcAEoAZQB0AFwAMwAuADUAXABJAFMAQQBNACAARgBvAHIAbQBhAHQAcwBcAEoAZQB0ACAAMgAuAHgAXQANAAoAIgBFAG4AZwBpAG4AZQAiAD0AIgBKAGUA
dAAgADIALgB4ACIADQAKACIATwBuAGUAVABhAGIAbABlAFAAZQByAEYAaQBsAGUAIgA9AGgAZQB4ADoAMAAwAA0ACgAiAEkAbgBkAGUAeABEAGkAYQBsAG8A
ZwAiAD0AaABlAHgAOgAwADAADQAKACIAQwByAGUAYQB0AGUARABCAE8AbgBFAHgAcABvAHIAdAAiAD0AaABlAHgAOgAwADAADQAKACIASQBzAGEAbQBUAHkA
cABlACIAPQBkAHcAbwByAGQAOgAwADAAMAAwADAAMAAwADAADQAKAA0ACgA=
'@



function Set-MCOConsoleIcon {
    param([Parameter(Mandatory)][string]$IconPath)

    if (-not (Test-Path -LiteralPath $IconPath -PathType Leaf)) {
        return
    }

    try {
        if (-not ('MCONativeConsoleIcon' -as [type])) {
            Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class MCONativeConsoleIcon
{
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr LoadImage(
        IntPtr hInst,
        string lpszName,
        uint uType,
        int cxDesired,
        int cyDesired,
        uint fuLoad
    );

    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(
        IntPtr hWnd,
        uint Msg,
        IntPtr wParam,
        IntPtr lParam
    );
}
"@
        }

        $IMAGE_ICON = 1
        $LR_LOADFROMFILE = 0x10
        $LR_DEFAULTSIZE = 0x40
        $WM_SETICON = 0x80
        $ICON_SMALL = [IntPtr]0
        $ICON_BIG = [IntPtr]1

        $hwnd = [MCONativeConsoleIcon]::GetConsoleWindow()
        $hIcon = [MCONativeConsoleIcon]::LoadImage(
            [IntPtr]::Zero,
            $IconPath,
            $IMAGE_ICON,
            0,
            0,
            ($LR_LOADFROMFILE -bor $LR_DEFAULTSIZE)
        )

        if ($hwnd -ne [IntPtr]::Zero -and $hIcon -ne [IntPtr]::Zero) {
            [void][MCONativeConsoleIcon]::SendMessage($hwnd, $WM_SETICON, $ICON_SMALL, $hIcon)
            [void][MCONativeConsoleIcon]::SendMessage($hwnd, $WM_SETICON, $ICON_BIG, $hIcon)
        }
    }
    catch {
        # Cosmetic only. Never fail installation because the console icon could not be set.
    }
}

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Write-Host $line
    if ($Script:LogPath) {
        Add-Content -LiteralPath $Script:LogPath -Value $line -Encoding UTF8
    }
}

function Assert-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'This repair must run as Administrator.'
    }
}

function Import-EmbeddedReg {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Base64Data
    )

    $tempReg = Join-Path $env:TEMP ("MCO-{0}-{1}.reg" -f $Name, [guid]::NewGuid().ToString('N'))

    try {
        $clean = ($Base64Data -replace '\s','')
        [IO.File]::WriteAllBytes($tempReg, [Convert]::FromBase64String($clean))

        Write-Log "Importing embedded registry payload: $Name"
        & reg.exe import "$tempReg" | Out-Null

        if ($LASTEXITCODE -ne 0) {
            throw "reg.exe failed importing embedded registry '$Name' with exit code $LASTEXITCODE."
        }
    }
    finally {
        Remove-Item -LiteralPath $tempReg -Force -ErrorAction SilentlyContinue
    }
}


function Get-FileVersionSafe {
    param([string]$Path)
    try {
        $raw = (Get-Item -LiteralPath $Path).VersionInfo.FileVersion
        if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
        $m = [regex]::Match($raw, '\d+(?:\.\d+){1,3}')
        if ($m.Success) { return [version]$m.Value }
    } catch {}
    return $null
}

function Install-MCOLegacyFile {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination,
        [switch]$AllowVersionUpgrade
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
        throw "Required database dependency is missing from the installer payload: $Source"
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Destination) -Force | Out-Null

    if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
        Write-Log "Installed database dependency: $Destination"
        return
    }

    $srcHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
    $dstHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash
    if ($srcHash -eq $dstHash) {
        Write-Log "Database dependency already matches reference: $Destination"
        return
    }

    if ($AllowVersionUpgrade) {
        $srcVer = Get-FileVersionSafe $Source
        $dstVer = Get-FileVersionSafe $Destination

        if ($srcVer -and $dstVer -and $dstVer -lt $srcVer) {
            $backup = "$Destination.mco-pre-v05.bak"
            if (-not (Test-Path -LiteralPath $backup)) {
                Copy-Item -LiteralPath $Destination -Destination $backup -Force
            }
            Copy-Item -LiteralPath $Source -Destination $Destination -Force
            Write-Log "Upgraded legacy database dependency $Destination from $dstVer to $srcVer (backup: $backup)"
            return
        }
    }

    Write-Log "Existing shared component differs and was retained: $Destination"
}

function Register-MCODatabaseDll {
    param([Parameter(Mandatory)][string]$DllPath)

    if (-not (Test-Path -LiteralPath $DllPath -PathType Leaf)) {
        throw "Cannot register missing DLL: $DllPath"
    }

    $regsvr32 = Join-Path $env:WINDIR 'SysWOW64\regsvr32.exe'
    if (-not (Test-Path -LiteralPath $regsvr32 -PathType Leaf)) {
        throw "32-bit regsvr32.exe was not found: $regsvr32"
    }

    Write-Log "Registering 32-bit database DLL: $DllPath"
    $p = Start-Process -FilePath $regsvr32 -ArgumentList @('/s', "`"$DllPath`"") -Wait -PassThru
    if ($p.ExitCode -ne 0) {
        throw "32-bit regsvr32 failed for '$DllPath' with exit code $($p.ExitCode)."
    }
}

function Import-WorkingJet35Registry {
    param([string]$Root)
    Write-Log 'Importing embedded working-reference Jet 3.5 registry settings.'
    Import-EmbeddedReg -Name 'Jet35-HKLM' -Base64Data $Script:EmbeddedReg_Jet35
}

function Install-MCODatabaseRuntime {
    param([Parameter(Mandatory)][string]$Root)

    $daoSrc = Join-Path $Root 'Payload\Legacy\DAO'
    $jetSrc = Join-Path $Root 'Payload\Legacy\Jet35'

    $daoDst = Join-Path ${env:ProgramFiles(x86)} 'Common Files\Microsoft Shared\DAO'
    $syswow = Join-Path $env:WINDIR 'SysWOW64'

    # Exact files observed on the WORKING Windows 10 reference machine.
    Install-MCOLegacyFile (Join-Path $daoSrc 'dao350.dll') (Join-Path $daoDst 'dao350.dll') -AllowVersionUpgrade
    Install-MCOLegacyFile (Join-Path $daoSrc 'dao2535.tlb') (Join-Path $daoDst 'dao2535.tlb')

    foreach ($name in @(
        'MSJET35.DLL',
        'MSRD2X35.DLL',
        'MSJTER35.DLL',
        'MSJINT35.DLL',
        'MSREPL35.DLL'
    )) {
        Install-MCOLegacyFile (Join-Path $jetSrc $name) (Join-Path $syswow $name) -AllowVersionUpgrade
    }

    # These are shared runtime/expression components. Install only when absent;
    # do not replace a different existing Windows/application version.
    foreach ($name in @(
        'VBAJET32.DLL',
        'EXPSRV.DLL',
        'MSVCRT40.DLL'
    )) {
        Install-MCOLegacyFile (Join-Path $jetSrc $name) (Join-Path $syswow $name)
    }

    Import-WorkingJet35Registry -Root $Root

    # These are the three captured DLLs that export DllRegisterServer.
    # Use the 32-bit regsvr32 because MCO is a 32-bit application.
    Register-MCODatabaseDll (Join-Path $daoDst 'dao350.dll')
    Register-MCODatabaseDll (Join-Path $syswow 'MSJET35.DLL')
    Register-MCODatabaseDll (Join-Path $syswow 'MSRD2X35.DLL')

    Test-MCODatabaseRuntime
}

function Test-MCODatabaseRuntime {
    $reg32 = Join-Path $env:WINDIR 'SysWOW64\reg.exe'
    if (-not (Test-Path -LiteralPath $reg32 -PathType Leaf)) {
        throw "32-bit reg.exe not found: $reg32"
    }

    $checks = @(
        @('HKCR\DAO.DBEngine.35', 'DAO.DBEngine.35'),
        @('HKCR\CLSID\{00000010-0000-0010-8000-00AA006D2EA4}', 'DAO 3.51 DBEngine CLSID'),
        @('HKLM\SOFTWARE\Microsoft\Jet\3.5', 'Jet 3.5 registry')
    )

    foreach ($check in $checks) {
        & $reg32 query $check[0] *> $null
        if ($LASTEXITCODE -ne 0) {
            throw "Database runtime verification failed: $($check[1]) was not visible to the 32-bit registry view."
        }
        Write-Log "Verified 32-bit registry: $($check[1])"
    }

    $required = @(
        (Join-Path ${env:ProgramFiles(x86)} 'Common Files\Microsoft Shared\DAO\dao350.dll'),
        (Join-Path $env:WINDIR 'SysWOW64\MSJET35.DLL'),
        (Join-Path $env:WINDIR 'SysWOW64\MSRD2X35.DLL'),
        (Join-Path $env:WINDIR 'SysWOW64\MSJTER35.DLL'),
        (Join-Path $env:WINDIR 'SysWOW64\MSJINT35.DLL')
    )

    foreach ($file in $required) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            throw "Database runtime verification failed: missing $file"
        }
    }

    Write-Log 'DAO 3.51 / Jet 3.5 runtime verification PASSED.'
}

try {
    Assert-Admin
    $Root = Split-Path -Parent $MyInvocation.MyCommand.Path
    New-Item -ItemType Directory -Path $Script:LogRoot -Force | Out-Null
    $Script:LogPath = Join-Path $Script:LogRoot ("Repair-MCO-Database-v0.9-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

    Set-MCOConsoleIcon -IconPath (Join-Path $Root 'mcity.ico')

    Clear-Host
    Write-Host 'MCO Database Runtime Repair v0.9' -ForegroundColor Cyan
    Write-Host '================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'This repair DOES NOT reinstall MCO and DOES NOT run any old installer EXE.' -ForegroundColor Green
    Write-Host 'It installs/registers the DAO 3.51 / Jet 3.5 runtime captured from the working PC.' -ForegroundColor Green
    Write-Host ''

    Install-MCODatabaseRuntime -Root $Root

    Write-Host ''
    Write-Host 'DATABASE RUNTIME REPAIR COMPLETE' -ForegroundColor Cyan
    Write-Host 'DAO 3.51 / Jet 3.5 files and 32-bit registration verified.' -ForegroundColor Green
    Write-Host ''
    Write-Host 'Now launch Motor City Online again and test whether the database error is gone.' -ForegroundColor Yellow
    Write-Host "Log: $Script:LogPath" -ForegroundColor DarkGray
    Write-Host ''
    [void](Read-Host 'Press ENTER to close')
}
catch {
    Write-Host ''
    Write-Host 'DATABASE REPAIR FAILED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($Script:LogPath) {
        try { Add-Content -LiteralPath $Script:LogPath -Value $_.Exception.ToString() -Encoding UTF8 } catch {}
    }
    Write-Host ''
    [void](Read-Host 'Press ENTER to close')
    exit 1
}
