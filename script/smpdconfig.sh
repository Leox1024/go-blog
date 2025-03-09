#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] This script must be run as root." >&2
  exit 1
fi

echo "[INFO] Updating the system..."
apt update

echo "[INFO] Installing SNMP and SNMPD..."
apt install -y snmp snmpd

if [ -f /etc/snmp/snmpd.conf ]; then
  BACKUP="/etc/snmp/snmpd.conf.backup.$(date +%F_%T)"
  echo "[INFO] Backing up existing configuration to $BACKUP"
  cp /etc/snmp/snmpd.conf "$BACKUP"
fi

echo "[INFO] Updating SNMP configuration file..."
cat > /etc/snmp/snmpd.conf <<'EOF'
sysLocation    admin
sysContact     [email protected]
sysServices    72
master  agentx
agentaddress 0.0.0.0:161,[::1]
view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.25.1
rouser authPrivUser authpriv -V systemonly
includeAllDisks 90%
includeAllInterfaces
extend temp /usr/bin/sensors
mem 90%
load    12 10 5
includeDir /etc/snmp/snmpd.conf.d
EOF

echo "[INFO] Stopping SNMP service..."
systemctl stop snmpd

USERNAME="admin"
AUTH_PASS=$(openssl rand -base64 12)
PRIV_PASS=$(openssl rand -base64 12)

if ! command -v net-snmp-create-v3-user &>/dev/null; then
  echo "[ERROR] net-snmp-create-v3-user not found." >&2
  exit 1
fi

net-snmp-create-v3-user -ro -A "$AUTH_PASS" -X "$PRIV_PASS" "$USERNAME"

echo "[INFO] Restarting SNMP service..."
systemctl start snmpd
systemctl enable snmpd

echo "SNMPv3 User: $USERNAME"
echo "Auth Password: $AUTH_PASS"
echo "Priv Password: $PRIV_PASS"
echo "[INFO] Configuration completed!"

