#!/usr/bin/env bash
set -e

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

PORT="${1:-47474}"  # Port to remove from firewall (default: 47474)
DELETE_DATA="${2:-false}"  # Set to 'true' to delete /var/lib/grafana and /etc/grafana

echo "⚠️  Uninstalling Grafana and cleaning up..."

# 1. Stop and disable service
echo "=> Stopping grafana-server..."
sudo systemctl stop grafana-server || true
sudo systemctl disable grafana-server || true

# 2. Remove Grafana package
echo "=> Removing Grafana package..."
sudo dnf remove -y grafana grafana-enterprise || true

# 3. Remove Grafana repo
echo "=> Removing Grafana repo..."
sudo rm -f /etc/yum.repos.d/grafana.repo

# 4. Remove firewall rule
bolt-cli firewall --action=delete --port="$PORT"


# 5. Optional: Remove data/config
if [[ "$DELETE_DATA" == "true" ]]; then
  echo "=> Removing Grafana data and configuration..."
  sudo rm -rf /var/lib/grafana /etc/grafana /var/log/grafana
else
  echo "✅ Keeping Grafana data and config (run with 'true' to remove)"
fi

echo "✅ Grafana has been uninstalled."