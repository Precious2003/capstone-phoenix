# PowerShell script to install Sysmon on Windows (run as Administrator)
# Usage: . .\install_sysmon.ps1

param(
    [string]$SysmonPath = "C:\Temp",
    [string]$ConfigURL = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
)

Write-Host "=== Sysmon Installation Script ===" -ForegroundColor Cyan

# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor Red
    exit 1
}

# Create temp directory if it doesn't exist
if (!(Test-Path $SysmonPath)) {
    New-Item -ItemType Directory -Path $SysmonPath | Out-Null
    Write-Host "Created directory: $SysmonPath" -ForegroundColor Green
}

# Download Sysmon if not present
$sysmonExe = "$SysmonPath\sysmon.exe"
$sysmonConfig = "$SysmonPath\sysmonconfig.xml"

if (!(Test-Path $sysmonExe)) {
    Write-Host "Downloading Sysmon..." -ForegroundColor Yellow
    # NOTE: Update URL to match current Sysinternals download mirror
    Write-Host "Manual download required from: https://docs.microsoft.com/sysinternals/downloads/sysmon" -ForegroundColor Yellow
    exit 1
}

# Download Sysmon config
if (!(Test-Path $sysmonConfig)) {
    Write-Host "Downloading Sysmon config from SwiftOnSecurity..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $ConfigURL -OutFile $sysmonConfig
        Write-Host "Downloaded config: $sysmonConfig" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download config. Using default minimal config." -ForegroundColor Yellow
    }
}

# Install Sysmon
Write-Host "Installing Sysmon..." -ForegroundColor Yellow
if (Test-Path $sysmonConfig) {
    & $sysmonExe -accepteula -i $sysmonConfig
} else {
    & $sysmonExe -accepteula -i
}

Get-Service Sysmon | Start-Service
Write-Host "Sysmon service started" -ForegroundColor Green

# Verify installation
Write-Host "`nVerifying Sysmon installation..." -ForegroundColor Cyan
$events = Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5 2>/dev/null
if ($events) {
    Write-Host "SUCCESS: Sysmon is logging events" -ForegroundColor Green
    Write-Host "Sample events:" -ForegroundColor Cyan
    $events | Format-Table -Property TimeCreated, Id, Message | head -5
} else {
    Write-Host "WARNING: No Sysmon events found yet. Wait 30 seconds and try again." -ForegroundColor Yellow
}
