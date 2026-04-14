#!/usr/bin/env bash
# =============================================================================
# prepare-ubuntu.sh
# TechNova BV — Ubuntu 22.04 LTS voorbereiding voor DevStack
#
# Uitvoeren als root op een verse Ubuntu 22.04 Server installatie.
# Doel: systeem gereed maken voor DevStack installatie.
#
# Gebruik:
#   chmod +x prepare-ubuntu.sh
#   sudo ./prepare-ubuntu.sh
# =============================================================================

set -euo pipefail

# ─── Kleuren ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC}  $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERR]${NC}  $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }

# ─── Root check ───────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    err "Dit script moet als root worden uitgevoerd: sudo $0"
    exit 1
fi

# ─── Variabelen ───────────────────────────────────────────────────────────────
STACK_USER="stack"
STACK_HOME="/opt/stack"
SWAP_SIZE="4G"
SWAP_FILE="/swapfile"
HOSTNAME_NEW="devstack01"
LOG_FILE="/var/log/technova-prepare.log"

# Alles loggen
exec > >(tee -a "$LOG_FILE") 2>&1
info "Start voorbereiding — $(date '+%Y-%m-%d %H:%M:%S')"

# ─── 1. Hostnaam instellen ────────────────────────────────────────────────────
info "Stap 1: Hostnaam instellen"
hostnamectl set-hostname "$HOSTNAME_NEW"
sed -i "s/127.0.1.1.*/127.0.1.1 $HOSTNAME_NEW/" /etc/hosts
log "Hostnaam ingesteld: $HOSTNAME_NEW"

# ─── 2. Systeem bijwerken ─────────────────────────────────────────────────────
info "Stap 2: Systeem bijwerken (kan even duren)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq
log "Systeem bijgewerkt"

# ─── 3. Benodigde pakketten installeren ──────────────────────────────────────
info "Stap 3: Pakketten installeren"
apt-get install -y -qq \
    git \
    curl \
    wget \
    vim \
    htop \
    net-tools \
    iputils-ping \
    dnsutils \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    ntp \
    chrony \
    unzip \
    jq \
    screen \
    tmux \
    iptables \
    bridge-utils \
    openvswitch-switch
log "Pakketten geïnstalleerd"

# ─── 4. IPv6 uitschakelen (DevStack werkt beter zonder) ──────────────────────
info "Stap 4: IPv6 uitschakelen"
cat >> /etc/sysctl.conf << 'EOF'
# TechNova: IPv6 uitgeschakeld voor DevStack
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl -p -q
log "IPv6 uitgeschakeld"

# ─── 5. Kernel parameters voor virtualisatie ─────────────────────────────────
info "Stap 5: Kernel parameters instellen"
cat >> /etc/sysctl.conf << 'EOF'
# TechNova: Netwerk optimalisaties voor OpenStack
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p -q
log "Kernel parameters ingesteld"

# ─── 6. Swap aanmaken ────────────────────────────────────────────────────────
info "Stap 6: Swap aanmaken ($SWAP_SIZE)"
if [[ -f "$SWAP_FILE" ]]; then
    warn "Swapbestand bestaat al, overgeslagen"
else
    fallocate -l "$SWAP_SIZE" "$SWAP_FILE"
    chmod 600 "$SWAP_FILE"
    mkswap "$SWAP_FILE"
    swapon "$SWAP_FILE"
    echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
    log "Swap aangemaakt: $SWAP_SIZE"
fi

# ─── 7. Stack gebruiker aanmaken ──────────────────────────────────────────────
info "Stap 7: Stack gebruiker aanmaken"
if id "$STACK_USER" &>/dev/null; then
    warn "Gebruiker '$STACK_USER' bestaat al"
else
    useradd -s /bin/bash -d "$STACK_HOME" -m "$STACK_USER"
    log "Gebruiker '$STACK_USER' aangemaakt"
fi

# Sudo rechten zonder wachtwoord
if [[ ! -f /etc/sudoers.d/stack ]]; then
    echo "$STACK_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/stack
    chmod 0440 /etc/sudoers.d/stack
    log "Sudo rechten ingesteld voor '$STACK_USER'"
fi

# ─── 8. DevStack downloaden ───────────────────────────────────────────────────
info "Stap 8: DevStack downloaden"
DEVSTACK_DIR="$STACK_HOME/devstack"
if [[ -d "$DEVSTACK_DIR" ]]; then
    warn "DevStack map bestaat al ($DEVSTACK_DIR)"
else
    sudo -u "$STACK_USER" git clone https://opendev.org/openstack/devstack "$DEVSTACK_DIR"
    log "DevStack gecloned naar $DEVSTACK_DIR"
fi

# ─── 9. NTP/Chrony configureren ──────────────────────────────────────────────
info "Stap 9: Tijdsynchronisatie instellen"
systemctl enable chrony --quiet
systemctl restart chrony
log "Chrony actief en gesynchroniseerd"

# ─── 10. Firewall basisregels ────────────────────────────────────────────────
info "Stap 10: UFW uitschakelen (DevStack beheert eigen firewall)"
ufw disable 2>/dev/null || true
log "UFW uitgeschakeld"

# ─── 11. Geheugen verificatie ────────────────────────────────────────────────
info "Stap 11: Systeemvereisten controleren"
RAM_GB=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)
CPU_CORES=$(nproc)
DISK_FREE_GB=$(df / --output=avail | tail -1 | awk '{printf "%.0f", $1/1024/1024}')

info "RAM        : ${RAM_GB} GB $([ "$RAM_GB" -ge 8 ] && echo '✓' || echo '⚠ Minimum 8GB aanbevolen!')"
info "CPU Cores  : ${CPU_CORES} $([ "$CPU_CORES" -ge 4 ] && echo '✓' || echo '⚠ Minimum 4 cores aanbevolen!')"
info "Schijfruimte: ${DISK_FREE_GB} GB vrij $([ "$DISK_FREE_GB" -ge 50 ] && echo '✓' || echo '⚠ Minimum 50GB vrij aanbevolen!')"

# ─── 12. Restart script aanmaken ─────────────────────────────────────────────
info "Stap 12: DevStack restart script aanmaken"
cat > /usr/local/bin/devstack-restart << 'SCRIPT'
#!/bin/bash
# Herstart DevStack na een reboot van de VM
if [[ "$USER" != "stack" ]]; then
    echo "Uitvoeren als stack gebruiker..."
    exec sudo -u stack "$0" "$@"
fi
cd /opt/stack/devstack
echo "DevStack herstarten..."
./rejoin-stack.sh
SCRIPT
chmod +x /usr/local/bin/devstack-restart
log "Restart script aangemaakt: /usr/local/bin/devstack-restart"

# ─── Afsluiting ──────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Voorbereiding KLAAR${NC}"
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo ""
info "Volgende stap: maak /opt/stack/devstack/local.conf aan"
info "Zie: infra/openstack/local.conf in het projectrepo"
info "Daarna: sudo -u stack /opt/stack/devstack/stack.sh"
echo ""
info "Logbestand: $LOG_FILE"
warn "AANBEVOLEN: herstart de server nu met: sudo reboot"
