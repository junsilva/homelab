#!/bin/bash
# Homelab DNA Harvester v1.0
# Purpose: Capture infrastructure and application "DNA" for AI-ready documentation.

VM_NAME=$(hostname)
TIMESTAMP=$(date +%Y%m%d_%H%M)
OUT_DIR="/tmp/${VM_NAME}_blueprint_${TIMESTAMP}"
mkdir -p "$OUT_DIR"

echo "[*] Phase 1: Capturing System & Network Identity..."
{
    echo "Hostname: $(hostname)"
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
    echo "IP Addresses:"
    ip -br addr
    echo "Routing Table:"
    ip route
} > "$OUT_DIR/system_identity.txt"

echo "[*] Phase 2: Capturing Storage & Mount Logic..."
cp /etc/fstab "$OUT_DIR/fstab_entries.txt"
findmnt -n -o SOURCE,TARGET,FSTYPE,OPTIONS > "$OUT_DIR/active_mounts.txt"

echo "[*] Phase 3: Capturing Docker Orchestration..."
if command -v docker &> /dev/null; then
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" > "$OUT_DIR/docker_inventory.txt"
    # Find all compose files in the standard path
    find /srv/appdata -maxdepth 3 -name "docker-compose.yml" -exec cp --parents {} "$OUT_DIR/" \; 2>/dev/null
    # Capture .env keys (sanitized)
    find /srv/appdata -maxdepth 3 -name ".env" -exec awk -F= '{print $1 "=********"}' {} \; > "$OUT_DIR/env_templates.txt"
fi

echo "[*] Phase 4: Harvesting Application DNA (Config Files)..."
# Targeting specific extensions that contain internal logic
SEARCH_PATHS=("/srv/appdata" "/etc/samba")
EXTENSIONS=("*.conf" "*.xml" "*.json" "*.ini" "*.yaml" "*.js")

for path in "${SEARCH_PATHS[@]}"; do
    if [ -d "$path" ]; then
        for ext in "${EXTENSIONS[@]}"; do
            find "$path" -maxdepth 4 -name "$ext" -exec cp --parents {} "$OUT_DIR/" \; 2>/dev/null
        done
    fi
done

echo "[*] Phase 5: Hardware & Security Checks..."
{
    echo "iGPU Status:"
    ls -l /dev/dri 2>/dev/null || echo "No iGPU detected"
    echo "CPU Info:"
    lscpu | grep "Model name"
} > "$OUT_DIR/hardware_check.txt"

echo "[*] Packaging Blueprint..."
tar -czvf "/tmp/${VM_NAME}_dna_${TIMESTAMP}.tar.gz" -C /tmp "$(basename "$OUT_DIR")"
echo "[SUCCESS] Archive created: /tmp/${VM_NAME}_dna_${TIMESTAMP}.tar.gz"
