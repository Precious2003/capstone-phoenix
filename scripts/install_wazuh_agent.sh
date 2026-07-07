#!/usr/bin/env bash
# Linux Wazuh agent install (example for Debian/Ubuntu)
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

# Add Wazuh repo (instructions may change — check official docs)
apt-get update
apt-get install -y wget curl apt-transport-https lsb-release gnupg2
wget -qO - https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
# Example repo line (edit release name accordingly)
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" >/etc/apt/sources.list.d/wazuh.list
apt-get update
apt-get install -y wazuh-agent
systemctl enable --now wazuh-agent

echo "Edit /var/ossec/etc/ossec.conf to point agent to manager and restart agent."