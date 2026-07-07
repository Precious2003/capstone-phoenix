#!/usr/bin/env bash
# SOC Lab Verification Checklist
# Run this on the Security Onion VM to verify all components

set -euo pipefail

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       SOC Lab Verification Checklist                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

PASSED=0
FAILED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_pass() {
  echo -e "${GREEN}✓ PASS${NC}: $1"
  ((PASSED++))
}

check_fail() {
  echo -e "${RED}✗ FAIL${NC}: $1"
  ((FAILED++))
}

check_warn() {
  echo -e "${YELLOW}⚠ WARN${NC}: $1"
}

# ============================================================================
# CHECK 1: Security Onion Status
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CHECK 1: Security Onion Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v so-status &>/dev/null; then
  if sudo so-status > /tmp/so_status.txt 2>&1; then
    if grep -q "RUNNING" /tmp/so_status.txt; then
      check_pass "Security Onion services are RUNNING"
    else
      check_warn "Security Onion status unknown — run: sudo so-status"
    fi
  fi
else
  check_warn "so-status command not found — may not be on SO host"
fi

# ============================================================================
# CHECK 2: Zeek/Bro Logs
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CHECK 2: Zeek/Bro Network Logs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "/nsm/zeek/logs/current" ]; then
  zeek_log_count=$(find /nsm/zeek/logs/current -name "*.log" -type f 2>/dev/null | wc -l)
  if [ "$zeek_log_count" -gt 0 ]; then
    check_pass "Found $zeek_log_count Zeek log files in /nsm/zeek/logs/current"
    echo "  Files: $(ls -1 /nsm/zeek/logs/current/*.log | head -5 | xargs -I {} basename {})"
  else
    check_warn "Zeek logs directory exists but no log files found yet"
  fi
elif [ -d "/nsm/bro/logs/current" ]; then
  bro_log_count=$(find /nsm/bro/logs/current -name "*.log" -type f 2>/dev/null | wc -l)
  if [ "$bro_log_count" -gt 0 ]; then
    check_pass "Found $bro_log_count Bro/Zeek log files in /nsm/bro/logs/current"
  else
    check_warn "Bro logs directory exists but no log files found yet"
  fi
else
  check_fail "No Zeek/Bro logs directory found (/nsm/zeek/logs/current or /nsm/bro/logs/current)"
fi

# ============================================================================
# CHECK 3: Security Onion Service Logs
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CHECK 3: Security Onion Service Logs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "/opt/so/log" ]; then
  so_log_count=$(find /opt/so/log -name "*.log" -type f 2>/dev/null | wc -l)
  if [ "$so_log_count" -gt 0 ]; then
    check_pass "Found $so_log_count SO service log files in /opt/so/log"
  else
    check_warn "SO logs directory exists but no log files found yet"
  fi
else
  check_fail "SO logs directory not found: /opt/so/log"
fi

# ============================================================================
# CHECK 4: Elasticsearch/Kibana
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CHECK 4: Elasticsearch & Kibana"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if curl -s http://localhost:9200 > /dev/null 2>&1; then
  check_pass "Elasticsearch is responding on port 9200"
else
  check_warn "Elasticsearch not responding on localhost:9200"
fi

if curl -s http://localhost:5601 > /dev/null 2>&1; then
  check_pass "Kibana is responding on port 5601"
  echo "  Access Kibana at: https://$(hostname -I | awk '{print $1}'):5601"
else
  check_warn "Kibana not responding on localhost:5601"
fi

# ============================================================================
# CHECK 5: Wazuh (if installed)
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CHECK 5: Wazuh Integration (if installed)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "/var/ossec" ]; then
  if systemctl is-active --quiet wazuh-manager; then
    check_pass "Wazuh manager is running"
  else
    check_warn "Wazuh manager not running — run: sudo systemctl start wazuh-manager"
  fi
else
  check_warn "Wazuh not installed on this SO instance"
fi

# ============================================================================
# CHECK 6: Network Interfaces
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CHECK 6: Network Interfaces"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

active_interfaces=$(ip -br link | grep -c "UP" || echo 0)
if [ "$active_interfaces" -gt 0 ]; then
  check_pass "Found $active_interfaces active network interface(s)"
  echo "  Interfaces:"
  ip -br addr | grep -E "^[^ ].*UP" | awk '{print "    " $1 ": " $3}'
else
  check_fail "No active network interfaces found"
fi

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}✓ Lab is ready for use!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Generate test traffic from Windows and Linux endpoints"
  echo "  2. Check Kibana for ingested events"
  echo "  3. Create dashboards for alert visualization"
  exit 0
else
  echo -e "${RED}✗ Lab has issues that need to be resolved${NC}"
  echo ""
  echo "Troubleshooting:"
  echo "  1. Check SO logs: sudo so-status"
  echo "  2. Check Zeek: ls /nsm/zeek/logs/current/ or ls /nsm/bro/logs/current/"
  echo "  3. Restart SO services: sudo so-restart"
  exit 1
fi
