# Installatie Handleiding — TechNova Leeromgeving
## Docentversie | Vertrouwelijk

---

## Overzicht

Deze handleiding leidt je stap voor stap door de volledige installatie van de TechNova leeromgeving. Plan hier minimaal **één volledige werkdag** voor. Doe dit vóór de start van de sprint.

**Installatievolgorde (verplicht):**

```
Stap 1  → Proxmox installeren en configureren
Stap 2  → DC01 VM aanmaken en Windows Server installeren
Stap 3  → Active Directory inrichten op DC01
Stap 4  → DNS records toevoegen
Stap 5  → Proxmox snapshot DC01 (dc01-clean)
Stap 6  → DevStack VM aanmaken en Ubuntu installeren
Stap 7  → Ubuntu voorbereiden (prepare-ubuntu.sh)
Stap 8  → DevStack installeren (stack.sh)
Stap 9  → Proxmox snapshot DevStack (devstack-clean)
Stap 10 → Gebruikers aanmaken (AD + OpenStack)
Stap 11 → Testplan uitvoeren
Stap 12 → Studentmaterialen klaarzetten
```

**Schatting tijdsduur per stap:**

| Stap | Tijdsduur    |
|------|--------------|
| 1    | 30 min       |
| 2-4  | 60-90 min    |
| 5    | 5 min        |
| 6-7  | 30 min       |
| 8    | 45-75 min    |
| 9    | 5 min        |
| 10   | 20 min       |
| 11   | 30 min       |
| 12   | 15 min       |

---

## Stap 1 — Proxmox VE installeren

### 1.1 ISO downloaden en USB aanmaken

1. Download Proxmox VE 8.x ISO van https://www.proxmox.com/downloads
2. Flash naar USB met Rufus (Windows) of Balena Etcher
3. Boot van USB op de server

### 1.2 Installatie doorlopen

Kies tijdens installatie:
- **Target disk:** jouw snelste schijf (NVMe/SSD)
- **Country:** Netherlands
- **Timezone:** Europe/Amsterdam
- **Keyboard:** Dutch (of US als je dat gewend bent)
- **Hostname:** `proxmox01.technova.local`
- **IP:** `192.168.100.10/24`
- **Gateway:** `192.168.100.1`
- **DNS:** `8.8.8.8` (tijdelijk, later DC01)
- **Root password:** stel een sterk wachtwoord in

### 1.3 Eerste configuratie na installatie

SSH in op Proxmox of gebruik de console:

```bash
# Enterprise repo uitschakelen (geen licentie nodig)
echo "# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise" \
    > /etc/apt/sources.list.d/pve-enterprise.list

# No-subscription repo toevoegen
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" \
    >> /etc/apt/sources.list.d/pve-no-subscription.list

# Ceph enterprise repo uitschakelen
echo "# deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise" \
    > /etc/apt/sources.list.d/ceph.list

# Systeem bijwerken
apt update && apt full-upgrade -y

# Herstart
reboot
```

### 1.4 Nested virtualisatie inschakelen

```bash
# Voor Intel CPU (meest voorkomend):
echo "options kvm-intel nested=Y" > /etc/modprobe.d/kvm-intel.conf
update-initramfs -u -k all
reboot

# Na herstart controleren:
cat /sys/module/kvm_intel/parameters/nested
# Moet 'Y' zijn
```

---

## Stap 2 — DC01 aanmaken in Proxmox

### 2.1 Windows Server 2022 ISO uploaden

1. Open Proxmox Web UI: `https://192.168.100.10:8006`
2. Klik op `local` → `ISO Images` → `Upload`
3. Upload Windows Server 2022 Evaluation ISO
   - Download van: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022

### 2.2 VM aanmaken

1. Klik op `Create VM`

| Parameter         | Waarde                      |
|-------------------|-----------------------------|
| VM ID             | 100                         |
| Name              | DC01                        |
| ISO               | Windows Server 2022 ISO     |
| Guest OS          | Windows                     |
| System            | UEFI, Machine: q35          |
| SCSI Controller   | VirtIO SCSI                 |
| Disk              | 60 GB, SSD emulation aan    |
| CPU               | 2 cores, type: host         |
| RAM               | 4096 MB                     |
| NIC               | VirtIO, bridge: vmbr0       |

2. Start de VM na aanmaken
3. Open console → installeer Windows Server 2022 Standard (Desktop Experience)

### 2.3 Windows eerste configuratie

Na installatie in de VM:

```powershell
# Computernaam instellen
Rename-Computer -NewName "DC01" -Restart
```

Na herstart:

```powershell
# Statisch IP instellen
New-NetIPAddress -InterfaceAlias "Ethernet" `
    -IPAddress 192.168.100.11 `
    -PrefixLength 24 `
    -DefaultGateway 192.168.100.1

Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
    -ServerAddresses "192.168.100.11","8.8.8.8"
```

---

## Stap 3 — Active Directory installeren

```powershell
# AD DS rol installeren
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Domein aanmaken
Install-ADDSForest `
    -DomainName "technova.local" `
    -DomainNetbiosName "TECHNOVA" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -SafeModeAdministratorPassword (
        ConvertTo-SecureString "Admin2024!" -AsPlainText -Force
    ) `
    -InstallDns `
    -Force

# Server herstart automatisch
```

Na herstart inloggen als `TECHNOVA\Administrator`:

```powershell
# OU structuur aanmaken (script uit repo)
Set-Location "C:\Scripts"
.\New-OUStructure.ps1

# Groepen aanmaken
.\New-ADGroups.ps1

# Studenten aanmaken (kopieer studenten.csv naar C:\Scripts)
.\New-TechNovaStudents.ps1 -CsvPath "C:\Scripts\studenten.csv"
```

---

## Stap 4 — DNS records toevoegen

```powershell
# DNS records voor DevStack en Proxmox
Add-DnsServerResourceRecordA -ZoneName "technova.local" `
    -Name "devstack01" -IPv4Address "192.168.100.20"

Add-DnsServerResourceRecordA -ZoneName "technova.local" `
    -Name "proxmox" -IPv4Address "192.168.100.10"

Add-DnsServerResourceRecordCName -ZoneName "technova.local" `
    -Name "horizon" -HostNameAlias "devstack01.technova.local."

# Controleren
Resolve-DnsName -Name "devstack01.technova.local"
```

---

## Stap 5 — Snapshot DC01

In Proxmox UI:
1. Selecteer VM 100 (DC01)
2. Klik `Snapshots` → `Take Snapshot`
3. Naam: `dc01-clean`
4. Beschrijving: `DC01 volledig ingericht na Sprint 1 voorbereiding`

---

## Stap 6 — DevStack VM aanmaken

Zelfde proces als DC01, maar:

| Parameter       | Waarde                     |
|-----------------|----------------------------|
| VM ID           | 101                        |
| Name            | devstack01                 |
| ISO             | Ubuntu 22.04 Server ISO    |
| Guest OS        | Linux / Ubuntu             |
| CPU             | 4 cores, type: **host** (verplicht voor nested virt!) |
| RAM             | 12288 MB (12 GB minimum)   |
| Disk            | 120 GB, SSD emulation aan  |
| NIC             | VirtIO, bridge: vmbr0      |

**Belangrijk:** Stel CPU type in op `host` voor nested virtualisatie. Dit is verplicht voor DevStack.

### Ubuntu installatie opties

```
Language: English
Update installer: Skip
Network: ens18 configured (DHCP tijdelijk, later statisch)
Storage: Custom — gebruik de volle 120 GB schijf
Profile:
  Name: stack
  Server name: devstack01
  Username: stack
  Password: [onthoud dit]
SSH: Install OpenSSH Server — JA
Snaps: Geen
```

---

## Stap 7 — Ubuntu voorbereiden

SSH in op devstack01 (`192.168.100.20` of via DHCP-adres):

```bash
ssh stack@<ip-van-ubuntu>

# Statisch IP instellen
sudo nano /etc/netplan/00-installer-config.yaml
# Kopieer inhoud van scripts/linux/netplan-config.yaml
# Pas ens18 aan naar jouw interface (check: ip link show)

sudo netplan apply

# Prepare script uploaden en uitvoeren
# Optie 1: kopieer via SCP
scp scripts/linux/prepare-ubuntu.sh stack@192.168.100.20:~/

# Optie 2: tekst kopiëren en plakken in nano
nano ~/prepare-ubuntu.sh

# Uitvoeren
chmod +x ~/prepare-ubuntu.sh
sudo ~/prepare-ubuntu.sh
```

Na het script: **herstart de server.**

---

## Stap 8 — DevStack installeren

```bash
ssh stack@192.168.100.20

# local.conf aanmaken
cp /pad/naar/infra/openstack/local.conf /opt/stack/devstack/local.conf
# OF handmatig aanmaken:
nano /opt/stack/devstack/local.conf

# Installatie starten
cd /opt/stack/devstack
./stack.sh
```

**Dit duurt 30-75 minuten.** Laat het runnen. Kijk mee in de terminal.

Succes ziet er zo uit aan het einde:
```
This is your host IP address: 192.168.100.20
Horizon is now available at http://192.168.100.20/dashboard
Keystone is serving at http://192.168.100.20/identity/
The default users are: admin and demo
The password: TechNova2024!
```

---

## Stap 9 — Snapshot DevStack

```bash
# Op Proxmox host:
qm snapshot 101 "devstack-clean" --description "DevStack na succesvolle installatie"
```

**Dit snapshot is je reddingslijn.** Bewaar het altijd.

---

## Stap 10 — OpenStack gebruikers aanmaken

```bash
ssh stack@192.168.100.20

# OpenRC laden
source /opt/stack/devstack/openrc admin admin

# OpenStack inrichting script uitvoeren
chmod +x ~/create-openstack-users.sh
# Of vanuit het repo:
chmod +x scripts/openstack/create-openstack-users.sh
./scripts/openstack/create-openstack-users.sh
```

---

## Stap 11 — Testplan

Voer alle checks uit voordat studenten beginnen:

```powershell
# Op DC01:
.\Get-ADHealthCheck.ps1
```

```bash
# Op DevStack:
source /opt/stack/devstack/openrc admin admin
./scripts/openstack/check-openstack-health.sh
```

**Handmatige verificaties:**
- [ ] Open browser → `http://192.168.100.20/dashboard` → inloggen als `admin / TechNova2024!`
- [ ] Maak een testvm aan via Horizon → start succesvol
- [ ] Log in als `jjansen / Student2024!` op Horizon → zie eigen project
- [ ] Log in op DC01 via RDP als `TECHNOVA\jjansen / Student2024!` → werkt
- [ ] Ping van DC01 naar devstack01: `ping 192.168.100.20` → succes
- [ ] nslookup horizon.technova.local → resolveert naar 192.168.100.20

---

## Stap 12 — Studentmaterialen klaarzetten

1. Print of deel de [Studentenhandleiding](studentenhandleiding.md)
2. Maak een gedeelde map of Teams/Classroom aan met:
   - Studentenhandleiding
   - Cheatsheets
   - Ticketlijst voor sprint 1
   - Sprint backlog template
3. Schrijf op het bord (of zet in Teams):
   - Horizon URL: `http://192.168.100.20/dashboard`
   - Wachtwoord: `Student2024!`
   - Scrum board locatie
