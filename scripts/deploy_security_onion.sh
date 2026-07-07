#!/usr/bin/env bash
# Minimal guidance script — run interactively on Security Onion VM
set -euo pipefail

echo "Ensure you have Security Onion ISO or OVA available."
# installation is interactive — provide the typical commands for reference
cat <<'EOF'
# On the Security Onion VM (Ubuntu based):
# 1. Boot installer/VM image
# 2. After initial setup run:
sudo so-install
# 3. Verify status:
sudo so-status
EOF

echo "See docs/README_LAB.md for architecture and next steps."