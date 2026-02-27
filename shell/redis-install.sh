#!/bin/bash
set -e
VM_USER="${VM_USER:-rocky}"
LOGFILE="/home/${VM_USER}/redis-install.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "[REDIS] Configuring Redis with password..."
REDIS_CONF="/etc/redis/redis.conf"

sudo sed -i "s/^# requirepass .*/requirepass $1/" $REDIS_CONF
sudo systemctl restart redis-server
echo "[REDIS] Redis configured and restarted."
