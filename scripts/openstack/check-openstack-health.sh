#!/usr/bin/env bash
# =============================================================================
# check-openstack-health.sh
# TechNova BV — Dagelijkse OpenStack gezondheidscheck
#
# Gebruik (als stack gebruiker):
#   source /opt/stack/devstack/openrc admin admin
#   ./check-openstack-health.sh
# =============================================================================

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

FOUTEN=0
LOG="/var/log/openstack-health-$(date +%Y%m%d).log"

ok()   { echo -e "${GREEN}[OK]${NC}   $1" | tee -a "$LOG"; }
fail() { echo -e "${RED}[FAIL]${NC} $1" | tee -a "$LOG"; ((FOUTEN++)); }
warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG"; }
info() { echo -e "${CYAN}[INFO]${NC} $1" | tee -a "$LOG"; }

echo -e "${CYAN}══════════════════════════════════════════${NC}" | tee -a "$LOG"
echo -e "${CYAN}  TechNova OpenStack Health — $(date '+%d-%m-%Y %H:%M')${NC}" | tee -a "$LOG"
echo -e "${CYAN}══════════════════════════════════════════${NC}" | tee -a "$LOG"
echo ""

# ─── 1. Apache2 (Horizon) ────────────────────────────────────────────────────
if systemctl is-active --quiet apache2; then
    ok "Apache2 (Horizon) draait"
else
    fail "Apache2 is NIET actief → start: sudo systemctl start apache2"
fi

# ─── 2. OpenStack CLI beschikbaar ────────────────────────────────────────────
if command -v openstack &>/dev/null; then
    ok "OpenStack CLI beschikbaar"
else
    fail "OpenStack CLI niet gevonden"
fi

# ─── 3. Token ophalen (Keystone) ─────────────────────────────────────────────
if openstack token issue &>/dev/null; then
    ok "Keystone: token uitgegeven (authenticatie werkt)"
else
    fail "Keystone: kan geen token ophalen — DevStack wellicht down"
fi

# ─── 4. Nova Compute service ─────────────────────────────────────────────────
NOVA_SERVICES=$(openstack compute service list --format value -c State 2>/dev/null | grep -c "up" || echo 0)
if [[ "$NOVA_SERVICES" -gt 0 ]]; then
    ok "Nova: $NOVA_SERVICES compute service(s) UP"
else
    fail "Nova: geen compute services actief"
fi

# ─── 5. Neutron netwerk agents ───────────────────────────────────────────────
NEUTRON_UP=$(openstack network agent list --format value -c Alive 2>/dev/null | grep -c "True" || echo 0)
NEUTRON_DOWN=$(openstack network agent list --format value -c Alive 2>/dev/null | grep -c "False" || echo 0)
if [[ "$NEUTRON_DOWN" -eq 0 ]]; then
    ok "Neutron: alle $NEUTRON_UP agent(s) actief"
else
    fail "Neutron: $NEUTRON_DOWN agent(s) DOWN"
fi

# ─── 6. Glance images ────────────────────────────────────────────────────────
IMAGE_COUNT=$(openstack image list --format value -c Name 2>/dev/null | wc -l)
if [[ "$IMAGE_COUNT" -gt 0 ]]; then
    ok "Glance: $IMAGE_COUNT image(s) beschikbaar"
else
    warn "Glance: geen images gevonden — studenten kunnen geen VM's aanmaken!"
fi

# ─── 7. Projecten check ──────────────────────────────────────────────────────
PROJECT_COUNT=$(openstack project list --format value -c Name 2>/dev/null | grep "^team-" | wc -l)
if [[ "$PROJECT_COUNT" -ge 9 ]]; then
    ok "Projecten: $PROJECT_COUNT team-projecten aanwezig"
else
    warn "Projecten: slechts $PROJECT_COUNT team-projecten (verwacht 9)"
fi

# ─── 8. Gebruikersaantal ─────────────────────────────────────────────────────
USER_COUNT=$(openstack user list --format value -c Name 2>/dev/null | wc -l)
info "Gebruikers: $USER_COUNT accounts aanwezig"

# ─── 9. Schijfruimte ─────────────────────────────────────────────────────────
DISK_VRIJ=$(df /opt/stack --output=avail 2>/dev/null | tail -1 | awk '{printf "%.1f", $1/1024/1024}')
DISK_NUM=$(df /opt/stack --output=avail 2>/dev/null | tail -1 | awk '{print $1}')
if [[ -n "$DISK_NUM" && "$DISK_NUM" -gt 10485760 ]]; then  # >10GB
    ok "Schijfruimte /opt/stack: ${DISK_VRIJ} GB vrij"
elif [[ -n "$DISK_NUM" && "$DISK_NUM" -gt 5242880 ]]; then  # 5-10GB
    warn "Schijfruimte /opt/stack: ${DISK_VRIJ} GB vrij — wordt krap, ruim VMs op"
else
    fail "Schijfruimte /opt/stack: ${DISK_VRIJ} GB vrij — KRITIEK, direct opruimen!"
fi

# ─── 10. RAM beschikbaar ─────────────────────────────────────────────────────
RAM_VRIJ=$(free -m | awk '/^Mem:/ {print $7}')
if [[ "$RAM_VRIJ" -gt 2048 ]]; then
    ok "RAM: ${RAM_VRIJ} MB vrij"
elif [[ "$RAM_VRIJ" -gt 512 ]]; then
    warn "RAM: ${RAM_VRIJ} MB vrij — systeem staat onder druk"
else
    fail "RAM: ${RAM_VRIJ} MB vrij — te weinig, herstart niet-gebruikte VM's"
fi

# ─── 11. VM overzicht ────────────────────────────────────────────────────────
echo ""
info "=== Actieve VM's per project ==="
for project in $(openstack project list --format value -c Name 2>/dev/null | grep "^team-"); do
    VM_COUNT=$(openstack server list --project "$project" --format value -c Name 2>/dev/null | wc -l)
    echo "    $project: $VM_COUNT VM('s)"
done

# ─── Eindresultaat ────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}══════════════════════════════════════════${NC}"
if [[ $FOUTEN -eq 0 ]]; then
    echo -e "${GREEN}  RESULTAAT: Alles OK${NC}"
else
    echo -e "${RED}  RESULTAAT: $FOUTEN probleem/problemen gevonden!${NC}"
    echo -e "${RED}  Controleer bovenstaande FAIL meldingen${NC}"
fi
echo -e "${CYAN}  Log: $LOG${NC}"
echo -e "${CYAN}══════════════════════════════════════════${NC}"

exit $FOUTEN
