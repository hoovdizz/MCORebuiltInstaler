#requires -version 5.1
$ErrorActionPreference = 'Stop'
$Host.UI.RawUI.WindowTitle = 'Motor City Online Rebuilt Uninstaller v0.9'

$ReceiptRoot = Join-Path $env:ProgramData 'MCO-Rebuilt-Installer'
$ReceiptPath = Join-Path $ReceiptRoot 'install.json'


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

function Assert-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'This uninstaller must run as Administrator.'
    }
}

function Remove-RegistryTree32 {
    param([string]$SubKey)

    $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
        [Microsoft.Win32.RegistryHive]::LocalMachine,
        [Microsoft.Win32.RegistryView]::Registry32
    )

    try {
        $base.DeleteSubKeyTree($SubKey, $false)
    }
    catch {}
    finally {
        $base.Close()
    }
}

function Remove-RegistryTree64 {
    param([string]$SubKey)

    $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
        [Microsoft.Win32.RegistryHive]::LocalMachine,
        [Microsoft.Win32.RegistryView]::Registry64
    )

    try {
        $base.DeleteSubKeyTree($SubKey, $false)
    }
    catch {}
    finally {
        $base.Close()
    }
}

function Remove-NovaEAComIfOwned {
    $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
        [Microsoft.Win32.RegistryHive]::LocalMachine,
        [Microsoft.Win32.RegistryView]::Registry32
    )

    try {
        $key = $base.OpenSubKey('SOFTWARE\EACom\AuthAuth', $true)
        if (-not $key) { return }

        $server = [string]$key.GetValue('AuthLoginServer', '')
        if ($server -ieq 'auth.novaserv.cc') {
            $key.Close()
            $base.DeleteSubKeyTree('SOFTWARE\EACom\AuthAuth', $false)
            Write-Host 'Removed NovaServ EACom\AuthAuth registry.'
        }
        else {
            $key.Close()
            Write-Host 'EACom\AuthAuth was left in place because it no longer points to auth.novaserv.cc.'
        }
    }
    finally {
        $base.Close()
    }
}


function Remove-AppCompatLayer {
    param([string]$ExePath)

    if ([string]::IsNullOrWhiteSpace($ExePath)) {
        return
    }

    $subKey = 'Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers'

    try {
        $cu = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($subKey, $true)
        if ($cu) {
            try { $cu.DeleteValue($ExePath, $false) } finally { $cu.Close() }
        }
    } catch {}

    try {
        $lm = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($subKey, $true)
        if ($lm) {
            try { $lm.DeleteValue($ExePath, $false) } finally { $lm.Close() }
        }
    } catch {}
}

function Remove-CertificateByThumbprint {
    param([string]$Thumbprint)

    if ([string]::IsNullOrWhiteSpace($Thumbprint)) {
        return
    }

    $Thumbprint = $Thumbprint.Replace(' ','').ToUpperInvariant()

    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store(
        'Root',
        [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
    )

    try {
        $store.Open(
            [System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite
        )

        $matches = @(
            $store.Certificates |
            Where-Object {
                $_.Thumbprint.Replace(' ','').ToUpperInvariant() -eq $Thumbprint
            }
        )

        foreach ($cert in $matches) {
            Write-Host "Removing certificate from Local Computer -> Trusted Root Certification Authorities:"
            Write-Host "  Subject: $($cert.Subject)"
            Write-Host "  Thumbprint: $Thumbprint"
            $store.Remove($cert)
        }
    }
    finally {
        $store.Close()
    }
}

try {
    Assert-Admin
    $Root = Split-Path -Parent $MyInvocation.MyCommand.Path
    Set-MCOConsoleIcon -IconPath (Join-Path $Root 'mcity.ico')
    Clear-Host

    Write-Host 'Motor City Online - Rebuilt Uninstaller v0.9' -ForegroundColor Cyan
    Write-Host '===========================================' -ForegroundColor Cyan
    Write-Host ''

    $receipt = $null
    if (Test-Path -LiteralPath $ReceiptPath -PathType Leaf) {
        try {
            $receipt = Get-Content -LiteralPath $ReceiptPath -Raw | ConvertFrom-Json
        }
        catch {}
    }

    $defaultInstall = if ($receipt -and $receipt.InstallDir) {
        [string]$receipt.InstallDir
    }
    else {
        Join-Path ${env:ProgramFiles(x86)} 'EA Games\Motor City Online'
    }

    Write-Host "Detected installation folder:"
    Write-Host "  $defaultInstall"
    Write-Host ''
    $answer = Read-Host 'Remove this MCO installation? [y/N]'
    if ($answer -notmatch '^[Yy]') {
        Write-Host 'Uninstall cancelled.'
        exit 0
    }

    Write-Host ''
    Write-Host '[1/6] Removing MCO/NovaServ-specific registry...' -ForegroundColor Green

    Remove-RegistryTree32 'SOFTWARE\Electronic Arts\Motor City'
    Remove-RegistryTree32 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\mcity.exe'
    Remove-RegistryTree64 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\mcity.exe'
    Remove-NovaEAComIfOwned

    # The captured HKCU EA/3DSetup registry and DAO/Jet registrations are
    # deliberately left in place because they are shared compatibility data
    # and may be used by other legacy EA applications.

    Write-Host '[2/6] Removing the installed server certificate...' -ForegroundColor Green
    $thumb = $null

    if ($receipt -and $receipt.CertThumbprint) {
        $thumb = [string]$receipt.CertThumbprint
    }
    else {
        # Exact thumbprint of the server.crt packaged with v0.9.
        $thumb = 'FF230DB6F36F18B85D5998D6647C3588812CA3F5'
    }

    Remove-CertificateByThumbprint -Thumbprint $thumb

    Write-Host '[3/6] Removing shortcuts...' -ForegroundColor Green

    $desktopShortcut = Join-Path ([Environment]::GetFolderPath('CommonDesktopDirectory')) 'Motor City Online.lnk'
    Remove-Item -LiteralPath $desktopShortcut -Force -ErrorAction SilentlyContinue

    $programFolder = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'EA Games\Motor City Online'
    Remove-Item -LiteralPath $programFolder -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host '[4/6] Removing Windows compatibility settings...' -ForegroundColor Green

    $mcityPath = if ($receipt -and $receipt.MCityPath) {
        [string]$receipt.MCityPath
    } else {
        Join-Path $defaultInstall 'mcity.exe'
    }

    $launcherPath = if ($receipt -and $receipt.LauncherPath) {
        [string]$receipt.LauncherPath
    } else {
        Join-Path $defaultInstall 'mco-launcher.exe'
    }

    Remove-AppCompatLayer -ExePath $mcityPath
    Remove-AppCompatLayer -ExePath $launcherPath

    Write-Host '[5/6] Removing Motor City Online application files...' -ForegroundColor Green

    if (Test-Path -LiteralPath $defaultInstall -PathType Container) {
        Remove-Item -LiteralPath $defaultInstall -Recurse -Force
    }

    Write-Host '[6/6] Removing installer receipt...' -ForegroundColor Green
    Remove-Item -LiteralPath $ReceiptPath -Force -ErrorAction SilentlyContinue

    if (Test-Path -LiteralPath $ReceiptRoot -PathType Container) {
        $remaining = Get-ChildItem -LiteralPath $ReceiptRoot -Force -ErrorAction SilentlyContinue |
                     Select-Object -First 1
        if (-not $remaining) {
            Remove-Item -LiteralPath $ReceiptRoot -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host ''
    Write-Host 'MCO UNINSTALL COMPLETE' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Removed:' -ForegroundColor Green
    Write-Host '  - Motor City Online application directory'
    Write-Host '  - MCO machine registry'
    Write-Host '  - NovaServ EACom AuthAuth registry when owned by this install'
    Write-Host '  - mcity.exe App Paths'
    Write-Host '  - Desktop/Start Menu shortcuts'
    Write-Host '  - Windows 7 / Run-as-admin compatibility entries for mcity.exe and mco-launcher.exe'
    Write-Host '  - Exact MCO server certificate from LocalMachine\Root'
    Write-Host ''
    Write-Host 'Intentionally retained:' -ForegroundColor Yellow
    Write-Host '  - DAO 3.51 / Jet 3.5 shared DLLs'
    Write-Host '  - DAO / Jet shared registry'
    Write-Host '  - Captured EA 3DSetup compatibility database'
    Write-Host ''
    [void](Read-Host 'Press ENTER to close')
}
catch {
    Write-Host ''
    Write-Host 'MCO UNINSTALL FAILED' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ''
    [void](Read-Host 'Press ENTER to close')
    exit 1
}
