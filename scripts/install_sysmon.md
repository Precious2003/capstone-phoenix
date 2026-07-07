Sysmon (Windows) — Install notes

1. Download Sysmon from Microsoft Sysinternals: https://learn.microsoft.com/sysinternals/downloads/sysmon
2. Download SwiftOnSecurity Sysmon config: https://github.com/SwiftOnSecurity/sysmon-config
3. Copy `sysmonconfig.xml` to the Windows VM and install:

```powershell
# Run as Administrator
.
sysmon -accepteula -i sysmonconfig.xml
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" | Select -First 10
```

4. Install and configure Wazuh agent for Windows to forward logs to the Wazuh manager (if using Wazuh integrated into SO). See Wazuh docs for Windows agent installer.