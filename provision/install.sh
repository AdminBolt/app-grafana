#!/usr/bin/env bash
set -e

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Variables
EDITION="${1:-oss}"        # 'oss' or 'enterprise'
PORT="${2:-47474}"          # Default port
REPO_URL="https://rpm.grafana.com"
GPG_KEY_URL="${REPO_URL}/gpg.key"
REPO_PATH="/etc/yum.repos.d/grafana.repo"

echo "Installing Grafana ($EDITION) on port $PORT..."

# 1. Import GPG key
echo "=> Importing GPG key..."
sudo rpm --import "$GPG_KEY_URL"

# 2. Create Grafana repo
echo "=> Creating repo file at $REPO_PATH..."
sudo tee "$REPO_PATH" > /dev/null <<EOF
[grafana]
name=grafana
baseurl=$REPO_URL
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=$GPG_KEY_URL
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

# 3. Install Grafana
PKG="grafana"
[[ "$EDITION" == "enterprise" ]] && PKG="grafana-enterprise"
echo "=> Installing $PKG..."
sudo dnf install -y "$PKG"

# 4. Modify port in grafana.ini
echo "=> Updating Grafana port to $PORT in grafana.ini..."
rm -f /etc/grafana/grafana.ini  # Remove existing config to avoid conflicts
cp /usr/local/bolt/plugins/grafana/config/grafana.ini /etc/grafana/grafana.ini

# 5. Open port in firewall
bolt-cli firewall --action=allow --port="$PORT"

# 6. Enable and start Grafana
echo "=> Enabling and starting grafana-server..."
sudo systemctl daemon-reload
sudo systemctl enable --now grafana-server

# 7. Show status
echo "=> Grafana is running on port $PORT:"
sudo systemctl status grafana-server --no-pager