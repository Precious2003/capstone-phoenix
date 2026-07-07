#!/usr/bin/env bash
# Zeek installation quick script (Ubuntu)
set -euo pipefail

apt-get update
apt-get install -y cmake make gcc g++ flex bison libpcap-dev libssl-dev python3-dev
# For production builds follow official docs — below is a shortcut for apt package
apt-get install -y zeek

systemctl enable zeek || true
systemctl start zeek || true

echo "Zeek logs: /opt/zeek/logs/current/"