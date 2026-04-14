#!/usr/bin/env bash
# =============================================================================
# restart-devstack.sh
# TechNova BV — DevStack herstarten na reboot
#
# DevStack start NIET automatisch na een VM reboot.
# Dit script herstart alle OpenStack services via rejoin-stack.sh.
#
# Gebruik:
#   sudo -u stack /usr/local/bin/devstack-restart
#   OF: sudo ./restart-devstack.sh
#
# Tijdsduur: 5-15 minuten
# =============================================================================

set -uo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

# Stack gebruiker check
if [[ "$USER" != "stack" ]]; then
    echo "Dit script herstart als stack-gebruiker..."
    exec sudo -u stack bash "$0" "$@"
fi

DEVSTACK_DIR="/opt/stack/devstack"
LOG_FILE="/opt/stack/logs/restart-$(date +%Y%m%d-%H%M%S).log"

echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "${CYAN}  TechNova — DevStack herstarten${NC}"
echo -e "${CYAN}  $(date '+%d-%m-%Y %H:%M:%S')${NC}"
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo ""

# DevStack map check
if [[ ! -d "$DEVSTACK_DIR" ]]; then
    echo -e "${RED}[FOUT] DevStack map niet gevonden: $DEVSTACK_DIR${NC}"
    echo "Oplossing: voer prepare-ubuntu.sh opnieuw uit of herstel Proxmox snapshot."
    exit 1
fi

if [[ ! -f "$DEVSTACK_DIR/rejoin-stack.sh" ]]; then
    echo -e "${RED}[FOUT] rejoin-stack.sh niet gevonden.${NC}"
    echo "DevStack is mogelijk niet correct geïnstalleerd."
    exit 1
fi

echo "Logbestand: $LOG_FILE"
echo "Herstarten... (dit duurt 5-15 minuten)"
echo ""

cd "$DEVSTACK_DIR"

# Voer rejoin uit, log naar bestand EN scherm
./rejoin-stack.sh 2>&1 | tee "$LOG_FILE"
EXITCODE=${PIPESTATUS[0]}

echo ""
if [[ $EXITCODE -eq 0 ]]; then
    echo -e "${GREEN}[OK] DevStack herstart geslaagd${NC}"
    echo ""
    echo "Services controleren..."
    source /opt/stack/devstack/openrc admin admin 2>/dev/null
    openstack service list --format table 2>/dev/null | head -20
    echo ""
    echo -e "${GREEN}Horizon dashboard: http://192.168.100.20/dashboard${NC}"
else
    echo -e "${RED}[FOUT] DevStack herstart MISLUKT (exitcode: $EXITCODE)${NC}"
    echo ""
    echo "Opties:"
    echo "  1. Controleer log: $LOG_FILE"
    echo "  2. Herstel Proxmox snapshot: 'devstack-clean'"
    echo "  3. Controleer schijfruimte: df -h"
    echo "  4. Herstart handmatig: cd /opt/stack/devstack && ./stack.sh"
fi

exit $EXITCODE
