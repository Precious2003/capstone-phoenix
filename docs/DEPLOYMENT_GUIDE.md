#!/bin/bash
# SOC Lab Deployment — Step-by-Step Runbook

set -euo pipefail

echo "=== SOC Homelab Deployment Checklist ==="
echo ""
echo "This runbook guides you through launching and configuring the SOC lab."
echo "Estimated time: 30–45 minutes"
echo ""

# ============================================================================
# STEP 1: Launch Security Onion VM in Evaluation Mode
# ============================================================================

cat <<'EOF'
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: Launch Security Onion VM in Evaluation Mode             │
└─────────────────────────────────────────────────────────────────┘

BEFORE YOU START:
- Download Security Onion ISO or OVA from: https://github.com/Security-Onion-Solutions/securityonion
- Open your virtualization manager (VirtualBox, VMware Fusion, etc.)
- Allocate 8–12 GB RAM and 4 vCPUs for the SO VM

DURING INSTALLATION:
1. Boot the Security Onion ISO or start the OVA
2. Complete the initial networking setup (hostname, IP address)
3. When prompted for deployment mode, select: EVAL (Evaluation mode)
   - EVAL mode is for small lab environments (<= 50 GB/day)
4. Configure network interfaces:
   - Management interface: for SSH/web console access (static IP recommended)
   - Sniffing interface: for network traffic capture (can be DHCP or static)
5. Complete the installation and reboot

AFTER BOOT-UP:
- Security Onion will run: sudo so-setup
- Follow the interactive setup wizard
- Note the URLs and credentials for Kibana access

To verify SO is running:
  ssh -u sslconfig@<SO-IP>
  sudo so-status

EXPECTED OUTPUT:
  All Security Onion services should show: RUNNING

✓ Once SO is running, move to STEP 2.

EOF

# ============================================================================
# STEP 2: Install Sysmon on Windows Endpoint
# ============================================================================

cat <<'EOF'
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: Install Sysmon on Windows Endpoint                      │
└─────────────────────────────────────────────────────────────────┘

PREREQUISITES:
- Windows 10/11 VM with admin access
- Network connectivity to SO VM

STEP 2.1: Download Sysmon
  1. On Windows, open PowerShell as Administrator
  2. Download Sysmon:
     https://docs.microsoft.com/sysinternals/downloads/sysmon
  3. Also download SwiftOnSecurity Sysmon config:
     https://github.com/SwiftOnSecurity/sysmon-config/releases

STEP 2.2: Install Sysmon with Configuration
  1. Copy both sysmon.exe and sysmonconfig.xml to C:\Temp\
  2. Open PowerShell as Administrator
  3. Run:
     cd C:\Temp
     .\sysmon.exe -accepteula -i sysmonconfig.xml

STEP 2.3: Verify Sysmon Installation
  1. Check Windows Event Viewer for Sysmon events:
     Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" | Select -First 10
  2. You should see event logs with:
     - EventID 1: Process Creation
     - EventID 3: Network Connection
     - EventID 7: Image Load (DLL execution)

STEP 2.4: Install Wazuh Agent (optional but recommended)
  1. Download Wazuh agent for Windows from:
     https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-windows.html
  2. Install with GUI or PowerShell
  3. Configure agent manager IP to point to SO Wazuh manager (if integrated)
  4. Start service:
     Start-Service -Name "Wazuh"

✓ Once Sysmon is logging, move to STEP 3.

EOF

# ============================================================================
# STEP 3: Enable and Start Zeek on Linux Endpoint
# ============================================================================

cat <<'EOF'
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: Enable and Start Zeek on Linux Endpoint                 │
└─────────────────────────────────────────────────────────────────┘

PREREQUISITES:
- Ubuntu/Rocky Linux VM with internet access
- Sudo privileges

STEP 3.1: Install Zeek (if not already installed)
  sudo apt-get update
  sudo apt-get install -y zeek

STEP 3.2: Enable Zeek at Boot and Start Service
  sudo systemctl daemon-reload
  sudo systemctl enable zeek
  sudo systemctl start zeek

STEP 3.3: Verify Zeek is Running
  sudo systemctl status zeek

  Expected output: active (running)

STEP 3.4: Verify Zeek Logs are Being Written
  ls -l /opt/zeek/logs/current/

  You should see:
  - conn.log (connection events)
  - dns.log (DNS queries)
  - http.log (HTTP requests)
  - ssl.log (SSL/TLS handshakes)

  To tail logs in real-time:
    tail -f /opt/zeek/logs/current/conn.log

✓ Once Zeek is logging, move to STEP 4.

EOF

# ============================================================================
# STEP 4: Verify Logs on Security Onion
# ============================================================================

cat <<'EOF'
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: Verify Logs on Security Onion                           │
└─────────────────────────────────────────────────────────────────┘

STEP 4.1: Check Zeek/Bro Logs on SO
  SSH to SO VM:
    ssh -u sslconfig@<SO-IP>

  View Zeek logs:
    ls -l /nsm/bro/logs/current/
    # or on newer SO versions:
    ls -l /nsm/zeek/logs/current/

  Expected files:
  - conn.log
  - dns.log
  - notice.log
  - http.log

STEP 4.2: Check Security Onion Service Logs
  ls -l /opt/so/log/

  View tail of logs:
    tail -f /opt/so/log/*.log

STEP 4.3: Access Kibana and Verify Ingestion
  1. Open browser: https://<SO-IP>
  2. Log in with SO admin credentials
  3. Navigate to Kibana
  4. Create index pattern for:
     - logstash-so_zeek (Zeek logs)
     - logstash-sysmon (Sysmon logs from Windows)
  5. Verify you see events from both endpoints

STEP 4.4: Generate Test Traffic to Verify Detection
  On Windows VM:
    curl https://google.com
    powershell -command "Get-Process"

  On Linux VM:
    curl https://google.com
    nslookup example.com

  Check Kibana for new events within 30 seconds.

VERIFICATION COMPLETE
If you see logs from all three components (Security Onion, Sysmon, Zeek)
appearing in Kibana, your lab is successfully configured!

✓ Lab deployment complete. Proceed to Alert Triage exercises.

EOF

echo ""
echo "Next: Run the lab verification script to check all components."
echo "Location: scripts/verify_lab.sh"
