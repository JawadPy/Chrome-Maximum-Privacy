# Chrome Maximum Privacy Toolkit 🔒

A PowerShell script to **disable Google Chrome telemetry, enforce privacy policies**, and **block tracking servers** via firewall rules. Designed for developers, pentesters, and privacy advocates.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Verification](#verification)
- [License](#license)

---

## Features
- **Kills Chrome/GoogleUpdate processes** before applying changes.
- **Disables telemetry** via Registry policies (Sync, Metrics, Safe Browsing).
- **Blocks Google tracking servers** (`216.58.0.0/16`) with Windows Firewall.
- **Launches Chrome** with privacy-focused command-line flags.

---

## Requirements
- Windows 10/11 (64-bit)
- PowerShell 5.1+ (run as Administrator)
- Google Chrome installed

---

## Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/chrome-hardening-toolkit.git
   cd chrome-hardening-toolkit
    ```
2. **Edit chrome_path.txt**:
   Replace the placeholder with your Chrome executable path:
   ```plaintext
   C:\path\to\chrome.exe
   ```

---
## Usage
1. **Automated** (Double-Click)
   Run Chrome.bat (auto-elevates to Admin).

2. **Manual** (PowerShell)
   1. Launch PowerShell as Administrator.

   2. Execute:
   ```powershell
   .\Harden-Chrome.ps1
   ```
---

## Verification
1. Check applied policies at `chrome://policy/`:
  1. SyncDisabled: true
  2. MetricsReportingEnabled: false

2. Confirm firewall rule:
  ```powershell
    Get-NetFirewallRule -DisplayName "Block Chrome Telemetry" | Format-Table -Property Name,Enabled,Action
  ```

---

## License
MIT. Use at your own risk. Not affiliated with Google.
