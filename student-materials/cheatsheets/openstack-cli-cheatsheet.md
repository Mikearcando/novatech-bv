# OpenStack CLI Cheatsheet
## TechNova BV | Gebruik via SSH op devstack01

---

## Verbinding maken & authenticeren

```bash
# SSH naar DevStack (als stack gebruiker):
ssh stack@192.168.100.20

# Authenticeren als admin (verplicht vóór CLI gebruik):
source /opt/stack/devstack/openrc admin admin

# Authenticeren als student (jouw eigen account):
# Maak een openrc bestand aan voor jouw account:
cat > ~/mijn-openrc.sh << 'EOF'
export OS_AUTH_URL=http://192.168.100.20/identity
export OS_PROJECT_NAME="team-infra-alpha"   # jouw teamnaam
export OS_USERNAME="jjansen"                 # jouw gebruikersnaam
export OS_PASSWORD="Student2024!"
export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_DOMAIN_NAME="Default"
export OS_IDENTITY_API_VERSION=3
EOF

source ~/mijn-openrc.sh

# Token testen (werkt authenticatie?):
openstack token issue
```

---

## INSTANCES (VM's)

```bash
# Lijst van VM's
openstack server list
openstack server list --all-projects    # Admin: alle teams

# VM aanmaken
openstack server create \
    --flavor tn.small \
    --image "Ubuntu 22.04" \
    --network "team-infra-net" \
    --security-group default \
    mijn-vm

# VM details bekijken
openstack server show mijn-vm

# VM starten / stoppen / herstarten
openstack server start   mijn-vm
openstack server stop    mijn-vm
openstack server reboot  mijn-vm

# VM verwijderen
openstack server delete mijn-vm

# Console openen (VNC URL ophalen)
openstack console url show mijn-vm

# VM log bekijken (handig bij crash)
openstack console log show mijn-vm
```

---

## IMAGES

```bash
# Beschikbare images
openstack image list

# Image details
openstack image show "Ubuntu 22.04"

# Image uploaden (admin)
openstack image create "Ubuntu 22.04" \
    --disk-format qcow2 \
    --container-format bare \
    --public \
    --file /pad/naar/ubuntu-22.04-server-cloudimg-amd64.img

# Snapshot maken van draaiende VM
openstack server image create --name "mijn-backup" mijn-vm
```

---

## FLAVORS (VM types)

```bash
# Alle flavors
openstack flavor list

# Details
openstack flavor show tn.small

# Aanmaken (admin only)
openstack flavor create \
    --vcpus 2 \
    --ram 2048 \
    --disk 40 \
    --public \
    tn.medium
```

---

## NETWERKEN

```bash
# Netwerken
openstack network list
openstack network show team-infra-net

# Netwerk aanmaken
openstack network create \
    --description "Team Infra intern netwerk" \
    team-infra-net

# Subnet aanmaken
openstack subnet create \
    --network team-infra-net \
    --subnet-range 10.20.1.0/24 \
    --dns-nameserver 192.168.100.11 \
    --allocation-pool start=10.20.1.10,end=10.20.1.254 \
    team-infra-subnet

# Router aanmaken
openstack router create team-infra-router

# Router koppelen aan extern netwerk (gateway)
openstack router set \
    --external-gateway public \
    team-infra-router

# Intern subnet aan router koppelen
openstack router add subnet team-infra-router team-infra-subnet
```

---

## FLOATING IPs

```bash
# Beschikbare floating IPs
openstack floating ip list

# Nieuw floating IP aanmaken (uit public pool)
openstack floating ip create public

# Floating IP koppelen aan VM
openstack server add floating ip mijn-vm 192.168.100.140

# Floating IP loskoppelen
openstack server remove floating ip mijn-vm 192.168.100.140

# Floating IP verwijderen
openstack floating ip delete 192.168.100.140
```

---

## SECURITY GROUPS (Firewall)

```bash
# Overzicht
openstack security group list

# Regels bekijken
openstack security group rule list default

# Regel toevoegen: SSH (poort 22) toestaan
openstack security group rule create \
    --protocol tcp \
    --dst-port 22 \
    --remote-ip 0.0.0.0/0 \
    default

# Regel toevoegen: Ping (ICMP) toestaan
openstack security group rule create \
    --protocol icmp \
    default

# HTTP toestaan
openstack security group rule create \
    --protocol tcp \
    --dst-port 80 \
    default

# Regel verwijderen
openstack security group rule delete <rule-id>
```

---

## GEBRUIKERS & PROJECTEN (admin)

```bash
# Gebruikers
openstack user list
openstack user show jjansen
openstack user create --password "Student2024!" --enable nieuw-student
openstack user set --password "Nieuw2024!" jjansen

# Projecten
openstack project list
openstack project show team-infra-alpha

# Gebruiker aan project koppelen
openstack role add --project team-infra-alpha --user jjansen member

# Quota bekijken
openstack quota show team-infra-alpha
```

---

## SERVICES CONTROLEREN (admin)

```bash
openstack service list                   # Alle services
openstack compute service list           # Nova compute
openstack network agent list             # Neutron agents

# Als een service down is:
sudo systemctl status devstack@n-api     # Nova API
sudo systemctl status devstack@q-svc     # Neutron
sudo systemctl status apache2            # Horizon
```

---

## VEELGEBRUIKTE COMBINATIES

```bash
# Welke VMs gebruik ik?
openstack server list --format table

# IP van mijn VM opvragen
openstack server show mijn-vm -f value -c addresses

# Hoeveel resources heb ik nog?
openstack limits show --absolute

# Alle running VMs met status
openstack server list --status ACTIVE
openstack server list --status ERROR    # VMs met fout
```
