SOC Homelab Runbook — Options & Steps

Overview
This runbook provides step-by-step guidance to deploy the lab using three options: Vagrant (local VMs), Terraform+Ansible (AWS), and Docker (lightweight). Choose one based on available resources.

Option A — Vagrant (Local VirtualBox)
1. Prerequisites: VirtualBox, Vagrant
2. Start VMs:

```bash
cd vagrant
vagrant up
```

3. SSH into Security Onion VM:

```bash
vagrant ssh securityonion
sudo so-install
sudo so-status
```

4. On Windows VM import Sysmon and Wazuh agent, follow `scripts/install_sysmon.md`.

Option B — Terraform + Ansible (AWS)
1. Prerequisites: AWS CLI configured, Terraform, Ansible
2. Initialize terraform:

```bash
cd infra/terraform/aws
terraform init
terraform apply -auto-approve
```

3. After instances are provisioned, generate `/tmp/inventory.ini` pointing to instances and run Ansible playbook:

```bash
ansible-playbook -i /tmp/inventory.ini ansible/site.yml --private-key /path/to/key.pem
```

4. Follow Security Onion installation on the securityonion host.

Option C — Docker (Quick test)
1. Start stack (note: Security Onion not supported in container):

```bash
cd docker
docker-compose up -d
```

2. Access Kibana at `http://localhost:5601` and configure index patterns.

Common Post-Deployment Checks
- Security Onion: `sudo so-status`
- Wazuh agent: `systemctl status wazuh-agent`
- Zeek logs: `ls /opt/zeek/logs/current/` (or `./zeek-logs` in docker)
- Kibana: import `kibana/tasking_dashboard.json`

Artifacts and Deliverables
- Place screenshots and exported dashboards into `docs/evidence/`.
- Fill `docs/Alert_Triage.csv` and export to `Alert_Triage.xlsx` if desired.
