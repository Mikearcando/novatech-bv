#!/usr/bin/env bash
# =============================================================================
# create-openstack-users.sh
# TechNova BV — OpenStack gebruikers, projecten en rollen aanmaken
#
# Gebruik:
#   source /opt/stack/devstack/openrc admin admin
#   chmod +x create-openstack-users.sh
#   ./create-openstack-users.sh
#
# Vereiste: DevStack moet draaien, openrc geladen zijn als admin
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC}   $1"; }
warn() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
err()  { echo -e "${RED}[ERR]${NC}  $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }

# ─── Configuratie ─────────────────────────────────────────────────────────────
PASSWORD="Student2024!"
DOMAIN="default"
OUTPUT_CSV="/opt/stack/openstack-accounts.csv"

# ─── OpenStack CLI beschikbaar? ───────────────────────────────────────────────
if ! command -v openstack &>/dev/null; then
    err "OpenStack CLI niet gevonden. Is DevStack actief en openrc geladen?"
    exit 1
fi

# Controleer admin token
if ! openstack token issue &>/dev/null; then
    err "Niet geauthenticeerd. Voer eerst uit:"
    err "  source /opt/stack/devstack/openrc admin admin"
    exit 1
fi

info "OpenStack gebruikers aanmaken voor TechNova BV"
info "Wachtwoord voor alle studenten: $PASSWORD"
echo ""

# ─── Projecten/Teams aanmaken ─────────────────────────────────────────────────
info "=== Projecten aanmaken ==="
declare -A TEAMS=(
    ["team-infra-alpha"]="TechNova Scrum Team Infrastructure Alpha"
    ["team-infra-beta"]="TechNova Scrum Team Infrastructure Beta"
    ["team-cloud-alpha"]="TechNova Scrum Team Cloud Alpha"
    ["team-cloud-beta"]="TechNova Scrum Team Cloud Beta"
    ["team-ops-alpha"]="TechNova Scrum Team Operations Alpha"
    ["team-ops-beta"]="TechNova Scrum Team Operations Beta"
    ["team-support"]="TechNova Scrum Team Support"
    ["team-security"]="TechNova Scrum Team Security"
    ["team-devops"]="TechNova Scrum Team DevOps"
    ["team-docenten"]="TechNova Docentomgeving"
)

for project in "${!TEAMS[@]}"; do
    desc="${TEAMS[$project]}"
    if openstack project show "$project" &>/dev/null; then
        warn "Project '$project' bestaat al"
    else
        openstack project create \
            --domain "$DOMAIN" \
            --description "$desc" \
            --enable \
            "$project"
        log "Project aangemaakt: $project"
    fi
done

# ─── Quota instellen per team (beperken zodat resources eerlijk verdeeld zijn)
info ""
info "=== Quota instellen per team ==="
for project in "${!TEAMS[@]}"; do
    PROJECT_ID=$(openstack project show -f value -c id "$project" 2>/dev/null || echo "")
    if [[ -n "$PROJECT_ID" ]]; then
        # Compute quota
        openstack quota set \
            --instances 5 \
            --cores 10 \
            --ram 10240 \
            "$project" 2>/dev/null || true
        # Volume quota
        openstack quota set \
            --volumes 10 \
            --gigabytes 100 \
            "$project" 2>/dev/null || true
        log "Quota ingesteld voor: $project (max 5 instances, 10 cores, 10GB RAM)"
    fi
done

# ─── Studentgebruikers aanmaken ───────────────────────────────────────────────
info ""
info "=== Studentgebruikers aanmaken ==="

# Studenten per team: username;project
declare -a STUDENTEN=(
    "jjansen;team-infra-alpha"
    "ldevries;team-infra-alpha"
    "abouali;team-infra-alpha"
    "msantos;team-infra-alpha"
    "tbakker;team-infra-alpha"
    "fyilmaz;team-infra-beta"
    "rsharma;team-infra-beta"
    "sbakker;team-infra-beta"
    "lvisser;team-infra-beta"
    "nmeijer;team-infra-beta"
    "evandam;team-cloud-alpha"
    "lhendriks;team-cloud-alpha"
    "ykoster;team-cloud-alpha"
    "dsmit;team-cloud-alpha"
    "jlaan;team-cloud-alpha"
    "fdeboer;team-cloud-beta"
    "nbrouwer;team-cloud-beta"
    "svanberg;team-cloud-beta"
    "ipeters;team-cloud-beta"
    "mtimmerman;team-cloud-beta"
    "sarslan;team-ops-alpha"
    "bosei;team-ops-alpha"
    "mwillems;team-ops-alpha"
    "jclaes;team-ops-alpha"
    "hnakamura;team-ops-alpha"
    "rdeclercq;team-ops-beta"
    "ifernandez;team-ops-beta"
    "tvandenb;team-ops-beta"
    "agoossens;team-ops-beta"
    "wmartens;team-ops-beta"
    "kpeeters;team-support"
    "bjanssen;team-support"
    "nleemans;team-support"
    "dwouters;team-support"
    "lvandenberghe;team-support"
    "rdesmet;team-security"
    "adubois;team-security"
    "mlambert;team-security"
    "esimon;team-security"
    "brenard;team-security"
    "nhoffman;team-devops"
    "lbecker;team-devops"
    "jweber;team-devops"
    "smuller;team-devops"
    "fschneider;team-devops"
)

# CSV header
echo "Gebruikersnaam;Project;Wachtwoord;URL" > "$OUTPUT_CSV"

for entry in "${STUDENTEN[@]}"; do
    USERNAME="${entry%;*}"
    PROJECT="${entry#*;}"

    if openstack user show "$USERNAME" &>/dev/null; then
        warn "Gebruiker '$USERNAME' bestaat al"
    else
        openstack user create \
            --domain "$DOMAIN" \
            --password "$PASSWORD" \
            --description "TechNova student" \
            --enable \
            "$USERNAME"
        log "Gebruiker aangemaakt: $USERNAME → $PROJECT"
    fi

    # Koppel aan project met 'member' rol
    if ! openstack role assignment list \
            --user "$USERNAME" --project "$PROJECT" \
            --role member &>/dev/null; then
        openstack role add \
            --project "$PROJECT" \
            --user "$USERNAME" \
            member 2>/dev/null || true
    fi

    # Schrijf naar CSV
    echo "$USERNAME;$PROJECT;$PASSWORD;http://192.168.100.20/dashboard" >> "$OUTPUT_CSV"
done

# ─── Docent admin account ─────────────────────────────────────────────────────
info ""
info "=== Docentaccount instellen ==="
if ! openstack user show "docent" &>/dev/null; then
    openstack user create \
        --domain "$DOMAIN" \
        --password "Docent2024!" \
        --description "TechNova docent — beheerderstoegang" \
        --enable \
        "docent"
    openstack role add --project "team-docenten" --user "docent" admin
    openstack role add --project "admin" --user "docent" admin 2>/dev/null || true
    log "Docentaccount aangemaakt (docent / Docent2024!)"
fi

# ─── Standaard image uploaden ─────────────────────────────────────────────────
info ""
info "=== Controleer beschikbare images ==="
IMAGE_COUNT=$(openstack image list --format value -c Name | wc -l)
info "Beschikbare images: $IMAGE_COUNT"
if [[ $IMAGE_COUNT -eq 0 ]]; then
    warn "Geen images gevonden. Upload handmatig een Ubuntu of CirrOS image:"
    warn "  openstack image create 'Ubuntu 22.04' --disk-format qcow2 --container-format bare --public --file /pad/naar/ubuntu.qcow2"
fi

# ─── Flavors aanmaken ─────────────────────────────────────────────────────────
info ""
info "=== Standaard flavors aanmaken ==="
declare -A FLAVORS=(
    # Naam | vCPU | RAM (MB) | Disk (GB)
    ["tn.tiny"]="1 512 10"
    ["tn.small"]="1 1024 20"
    ["tn.medium"]="2 2048 40"
    ["tn.large"]="4 4096 80"
)

for flavor_name in "${!FLAVORS[@]}"; do
    read -r vcpus ram disk <<< "${FLAVORS[$flavor_name]}"
    if openstack flavor show "$flavor_name" &>/dev/null; then
        warn "Flavor '$flavor_name' bestaat al"
    else
        openstack flavor create \
            --vcpus "$vcpus" \
            --ram "$ram" \
            --disk "$disk" \
            --public \
            "$flavor_name"
        log "Flavor: $flavor_name (${vcpus} vCPU, ${ram}MB RAM, ${disk}GB disk)"
    fi
done

# ─── Samenvatting ─────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}  OpenStack inrichting KLAAR${NC}"
echo -e "${CYAN}══════════════════════════════════════════${NC}"
info "Accountoverzicht opgeslagen in: $OUTPUT_CSV"
info "Horizon URL: http://192.168.100.20/dashboard"
info "Docent login: docent / Docent2024!"
info "Student login: [gebruikersnaam] / Student2024!"
echo ""
openstack project list --format table 2>/dev/null | head -20
