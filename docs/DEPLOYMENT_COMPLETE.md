# SOC Homelab — Complete Deployment & Reference Guide

## Quick Start (3 Steps)

```bash
# Step 1: Read the deployment guide
cat docs/DEPLOYMENT_GUIDE.md

# Step 2: Launch VMs (see Option A/B/C below)
# Option A (Local): cd vagrant && vagrant up
# Option B (AWS): cd infra/terraform/aws && terraform apply
# Option C (Docker): cd docker && docker-compose up -d

# Step 3: Run verification
bash scripts/verify_lab.sh
```

---

## Project Structure

```
capstone-phoenix/
├── docs/
│   ├── DEPLOYMENT_GUIDE.md          # Step-by-step setup guide (THIS FILE)
│   ├── README_LAB.md                # Lab architecture overview
│   ├── RUNBOOK_LAB.md               # Runbook with deployment options
│   ├── TierRoles.md                 # SOC analyst tier roles & responsibilities
│   ├── Alert_Triage.csv             # Sample alert triage log
│   ├── Escalation_Report.md         # Escalation template
│   ├── SOC_TriageReport.md          # Lab report template
│   ├── AI_prompt_examples.md        # ChatGPT prompts for log analysis
│   ├── SOC_TierFlow.mmd             # Mermaid diagram (workflow)
│   ├── Deliverables_Checklist.md    # Submission checklist
│   └── EVIDENCE/                    # Screenshots & exported logs
├── scripts/
│   ├── deploy_security_onion.sh     # SO deployment guidance
│   ├── install_sysmon.ps1           # Windows Sysmon install (PowerShell)
│   ├── install_sysmon.md            # Sysmon install notes
│   ├── install_wazuh_agent.sh       # Linux Wazuh agent setup
│   ├── install_zeek.sh              # Zeek installation script
│   ├── zeek_setup.sh                # Zeek startup & verification
│   ├── verify_lab.sh                # Comprehensive lab verification checklist
│   └── csv_to_xlsx.py               # Convert Alert_Triage.csv to Excel
├── vagrant/
│   └── Vagrantfile                  # Local VM provisioning (VirtualBox)
├── docker/
│   └── docker-compose.yml           # Lightweight Docker stack
├── infra/terraform/
│   ├── aws/
│   │   ├── main.tf                  # AWS resources skeleton
│   │   ├── variables.tf             # Variable definitions
│   │   └── outputs.tf               # Output values
│   ├── README_VARS.md               # Terraform variable guide
│   └── [existing k3s/Kubernetes modules]
├── ansible/
│   ├── site_vagrant.yml             # Vagrant provisioning playbook
│   ├── inventory_vagrant.ini        # Vagrant inventory
│   └── [existing k3s/Kubernetes roles]
├── kibana/
│   └── tasking_dashboard.json       # Sample Kibana dashboard
├── sysmon/
│   └── sample-sysmon-config.xml     # Sysmon config example
└── README.md                         # Main project README
```

---

## Deployment Options

### Option A: Local Lab (Vagrant + VirtualBox)

**Best for:** Learning, offline work, constrained resources

**Requirements:**
- VirtualBox or VMware Fusion
- Vagrant
- 16+ GB RAM on host

**Steps:**
```bash
cd vagrant
vagrant up
vagrant ssh securityonion
# Run SO install: sudo so-install
```

### Option B: AWS Cloud Lab (Terraform + Ansible)

**Best for:** Production-grade testing, scalability, persistent infrastructure

**Requirements:**
- AWS account + CLI credentials
- Terraform
- Ansible

**Steps:**
```bash
cd infra/terraform/aws
terraform init
terraform apply
# Wait for instances → run Ansible playbook
ansible-playbook -i /tmp/inventory.ini ansible/site.yml
```

### Option C: Docker Stack (Learning/quick test)

**Best for:** Quick prototyping, lightweight demo

**Limitations:** Security Onion not supported in containers

**Steps:**
```bash
cd docker
docker-compose up -d
# Access Kibana: http://localhost:5601
```

---

## Detailed Deployment Steps

### Step 1: Launch Security Onion VM

**File:** `docs/DEPLOYMENT_GUIDE.md` → Section "STEP 1"

Before:
- [ ] Download SO ISO/OVA
- [ ] Allocate 8–12 GB RAM, 4 vCPU
- [ ] Plan network interfaces (mgmt + sniffing)

During:
- [ ] Boot SO VM
- [ ] Select deployment mode: **EVAL** (for lab environments)
- [ ] Configure management and sniffing interfaces
- [ ] Complete installation

After:
```bash
ssh -u sslconfig@<SO-IP>
sudo so-status  # Verify all services RUNNING
```

### Step 2: Install Sysmon on Windows

**File:** `docs/DEPLOYMENT_GUIDE.md` → Section "STEP 2"

From Windows (as Administrator):
```powershell
# Download Sysmon from Sysinternals
# Download config from SwiftOnSecurity
# Then run:
.\install_sysmon.ps1

# Verify:
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" | Select -First 10
```

Or use provided script:
```powershell
# Run as Administrator
. .\scripts\install_sysmon.ps1
```

### Step 3: Enable Zeek on Linux

**File:** `docs/DEPLOYMENT_GUIDE.md` → Section "STEP 3"

From Linux endpoint (with sudo):
```bash
# Option 1: Manual commands
sudo systemctl daemon-reload
sudo systemctl enable zeek
sudo systemctl start zeek

# Option 2: Use provided script
sudo bash scripts/zeek_setup.sh
```

Verify:
```bash
sudo systemctl status zeek
ls /opt/zeek/logs/current/conn.log
```

### Step 4: Verify Logs on Security Onion

**File:** `docs/DEPLOYMENT_GUIDE.md` → Section "STEP 4"

From SO host:
```bash
# Check Zeek logs
ls -l /nsm/bro/logs/current/
# or
ls -l /nsm/zeek/logs/current/

# Check SO service logs
ls -l /opt/so/log/

# Run comprehensive verification
bash scripts/verify_lab.sh
```

---

## Alert Triage Workflow

### Example: Analyzing a DNS Alert

1. **Tier-1 Alert Triage** (5–10 min)
   - Alert: "Multiple DNS requests to unusual domain"
   - Action: Check `Alert_Triage.csv` for similar alerts
   - Decision: Domain appears in whitelist → False Positive → Close

2. **Tier-2 Investigation** (if escalated, 30–120 min)
   - Gather Sysmon + Zeek logs
   - Correlate process execution with DNS queries
   - Check threat intelligence (VirusTotal, AlienVault)
   - Determine if truly suspicious

3. **Tier-3 Threat Hunting** (if confirmed malicious, ongoing)
   - Create detection rule (YARA/Snort)
   - Hunt for similar patterns in historical logs
   - Update playbooks

---

## Key Files & Their Purposes

| File | Purpose | Owner |
|------|---------|-------|
| `DEPLOYMENT_GUIDE.md` | Step-by-step setup walkthrough | SOC Lead |
| `TierRoles.md` | Analyst responsibilities & escalation | SOC Manager |
| `Alert_Triage.csv` | Sample alert with Tier-1 decisions | Analyst |
| `Escalation_Report.md` | Template for Tier-1→Tier-2 handoff | Analyst |
| `SOC_TriageReport.md` | Final investigation summary | Tier-2/3 |
| `scripts/verify_lab.sh` | Automated health check | DevOps |

---

## Troubleshooting

### Issue: Zeek logs not appearing in Kibana

**Solution:**
1. Check Zeek service: `sudo systemctl status zeek`
2. Verify logs written: `ls /nsm/zeek/logs/current/`
3. Check Logstash/Filebeat: `sudo so-status | grep -i logstash`
4. Restart pipeline: `sudo so-restart`

### Issue: Sysmon not logging events

**Solution:**
1. Check event viewer: `Get-WinEvent -LogName Microsoft-Windows-Sysmon/Operational`
2. Verify service running: `Get-Service Sysmon | Start-Service`
3. Check config: `Get-Content C:\ProgramData\Sysmon\sysmon-config.xml`
4. Reinstall if needed: `sysmon -accepteula -i sysmonconfig.xml`

### Issue: Kibana cannot connect to Elasticsearch

**Solution:**
1. Check ES listening: `curl http://localhost:9200`
2. Check heap: `sudo so-status | grep -i elasticsearch`
3. Increase heap (SO): `sudo so-manage config`
4. Restart: `sudo so-restart`

---

## Quick Commands Reference

### Security Onion
```bash
sudo so-status              # Check all services
sudo so-restart             # Restart all services
sudo so-manage config       # Configure SO
ls /nsm/bro/logs/current    # View Zeek logs
tail -f /opt/so/log/*.log   # Watch SO logs
```

### Sysmon (Windows)
```powershell
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational"
Get-Service Sysmon
sysmon -accepteula -u      # Uninstall Sysmon
```

### Zeek (Linux)
```bash
sudo systemctl status zeek
sudo systemctl restart zeek
tail -f /opt/zeek/logs/current/conn.log
zeek -eval 'print "test"'  # Test Zeek
```

### Kibana
```
Access: https://<SO-IP>
Create Index Pattern: Discover → Create Index Pattern
Query: Analyze network events in Kibana console
```

---

## Next Steps

1. **Generate Test Traffic** to populate logs:
   ```bash
   # On Windows VM
   curl https://google.com
   powershell -command "Get-Process"
   
   # On Linux VM
   curl https://google.com
   nslookup example.com
   ```

2. **Check Kibana** for ingested events (refresh every 30 sec)

3. **Create Dashboards** using Kibana visualizations

4. **Run Alert Triage Exercises** using `Alert_Triage.csv` template

5. **Complete SOC Triage Report** (`SOC_TriageReport.md`)

---

## Deliverables Checklist

- [ ] `SOC_TierFlow.mmd` (Mermaid diagram)
- [ ] `TierRoles.md` (analyst tier guide)
- [ ] `DEPLOYMENT_GUIDE.md` (this walkthrough)
- [ ] `Alert_Triage.csv` (sample alert log)
- [ ] `Escalation_Report.md` (template)
- [ ] `SOC_TriageReport.md` (lab report)
- [ ] Screenshots in `docs/EVIDENCE/`
- [ ] Final ZIP package ready for submission

---

## Additional Resources

- **Security Onion:** https://securityonion.net
- **Zeek:** https://zeek.org
- **Sysmon:** https://learn.microsoft.com/sysinternals/downloads/sysmon
- **Wazuh:** https://wazuh.com
- **Kibana:** https://www.elastic.co/kibana
- **NIST Incident Response:** https://nvlpubs.nist.gov/nistpubs/specialpublications/nist.sp.800-61r3.pdf

---

## Support

For issues or questions, consult:
1. `docs/DEPLOYMENT_GUIDE.md` (Troubleshooting section)
2. Official documentation links above
3. Lab community forums or Slack channels
