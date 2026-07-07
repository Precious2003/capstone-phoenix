#!/usr/bin/env bash
# Zeek startup and verification script for Linux endpoint

set -euo pipefail

echo "=== Zeek Installation and Startup ==="

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: This script must be run as root (use: sudo ./zeek_setup.sh)"
  exit 1
fi

# Check if Zeek is installed
if ! command -v zeek &>/dev/null; then
  echo "Zeek not found. Installing..."
  apt-get update
  apt-get install -y zeek
fi

echo "Enabling Zeek systemd service..."
systemctl daemon-reload
systemctl enable zeek

echo "Starting Zeek service..."
systemctl start zeek

echo "Waiting 5 seconds for service to stabilize..."
sleep 5

echo "Checking Zeek service status..."
if systemctl is-active --quiet zeek; then
  echo "✓ Zeek service is RUNNING"
else
  echo "✗ Zeek service failed to start"
  systemctl status zeek
  exit 1
fi

echo ""
echo "Verifying Zeek logs are being written..."
ZEEK_LOG_DIR="/opt/zeek/logs/current"
if [ -d "$ZEEK_LOG_DIR" ]; then
  log_count=$(ls -1 "$ZEEK_LOG_DIR"/*.log 2>/dev/null | wc -l)
  echo "✓ Found $log_count log files in $ZEEK_LOG_DIR"
  ls -lh "$ZEEK_LOG_DIR"
else
  echo "✗ Zeek log directory not found: $ZEEK_LOG_DIR"
  exit 1
fi

echo ""
echo "Sample Zeek logs:"
for logfile in "$ZEEK_LOG_DIR"/*.log; do
  if [ -f "$logfile" ]; then
    count=$(wc -l < "$logfile")
    echo "  $(basename "$logfile"): $count lines"
  fi
done

echo ""
echo "✓ Zeek setup complete! Logs are being written to: $ZEEK_LOG_DIR"
echo "To tail logs in real-time: tail -f $ZEEK_LOG_DIR/conn.log"
