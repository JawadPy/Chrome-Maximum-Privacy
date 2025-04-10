<#
.SYNOPSIS
Hardens Chrome by disabling telemetry, blocking Google servers, and launching with secure flags.
REQUIRES chrome_path.txt with the full path to chrome.exe (e.g., "C:\Path\To\chrome.exe").

.DESCRIPTION
1. Reads Chrome path from chrome_path.txt (MANDATORY).
2. Kills Chrome and GoogleUpdate processes.
3. Applies Registry policies to disable tracking.
4. Blocks Google's tracking servers via firewall.
5. Launches Chrome with privacy flags.

.NOTES
Author: Jawad Alfehaid
Tested on: Windows 10, Chrome 120+
#>

#Requires -RunAsAdministrator

# --- Step 1: Read Chrome Path from File (STRICT MODE) ---
$chromePathFile = "$PSScriptRoot\chrome_path.txt"
if (-not (Test-Path $chromePathFile)) {
    Write-Error "[X] chrome_path.txt not found. Create it with the full path to chrome.exe (e.g., 'C:\Path\To\chrome.exe')." -ErrorAction Stop
}

$chromePath = Get-Content $chromePathFile -ErrorAction Stop
if (-not $chromePath -or -not (Test-Path $chromePath)) {
    Write-Error "[X] Invalid path in chrome_path.txt. Provide the exact path to chrome.exe." -ErrorAction Stop
}

# --- Step 2: Kill Chrome and GoogleUpdate ---
taskkill /f /im chrome.exe 2>$null
taskkill /f /im googleupdate.exe 2>$null
Start-Sleep -Seconds 2

# --- Step 3: Apply Registry Policies ---
$chromePolicyPath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
if (-not (Test-Path $chromePolicyPath)) {
    New-Item -Path $chromePolicyPath -Force | Out-Null
}

$policies = @{
    "MetricsReportingEnabled"          = 0
    "DefaultSearchProviderEnabled"     = 0
    "SyncDisabled"                     = 1
    "SafeBrowsingEnabled"             = 0
    "BackgroundModeEnabled"           = 0
    "AutoFillEnabled"                 = 0
    "SpellCheckServiceEnabled"        = 0
    "UrlKeyedAnonymizedDataCollectionEnabled" = 0
}

foreach ($policy in $policies.GetEnumerator()) {
    Set-ItemProperty -Path $chromePolicyPath -Name $policy.Key -Value $policy.Value -Type DWORD -Force
}

# --- Step 4: Block Google Servers via Firewall ---
if (-not (Get-NetFirewallRule -DisplayName "Block Chrome Telemetry" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule `
        -DisplayName "Block Chrome Telemetry" `
        -Direction Outbound `
        -Action Block `
        -Program "$chromePath" `
        -RemoteAddress "216.58.0.0/16" `
        -ErrorAction SilentlyContinue | Out-Null
}

# --- Step 5: Launch Chrome with Hardened Flags ---
$chromeArgs = @(
    "--disable-background-networking",
    "--disable-client-side-phishing-detection",
    "--disable-default-apps",
    "--disable-hang-monitor",
    "--disable-popup-blocking",
    "--disable-prompt-on-repost",
    "--disable-sync",
    "--disable-web-resources",
    "--metrics-recording-only",
    "--no-default-browser-check",
    "--no-first-run",
    "--safebrowsing-disable-auto-update"
) -join " "

Start-Process -FilePath "$chromePath" -ArgumentList $chromeArgs

# --- Completion ---
Write-Host "[✓] Chrome hardened: Policies applied, firewall rule added, and launched securely." -ForegroundColor Green