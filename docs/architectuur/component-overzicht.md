# Componentoverzicht — TechNova BV Leeromgeving

## Systeem op één oogopslag

```
┌─────────────────────────────────────────────────────────────────┐
│  PROXMOX VE HOST — 192.168.100.10                               │
│  CPU: 8+ cores (VT-x/AMD-V)   RAM: 32GB   Disk: 500GB+ SSD     │
│                                                                  │
│  ┌─────────────────────────┐  ┌──────────────────────────────┐  │
│  │  VM 100 — DC01          │  │  VM 101 — devstack01         │  │
│  │  Windows Server 2022    │  │  Ubuntu 22.04 LTS            │  │
│  │  2 vCPU / 4GB RAM       │  │  4 vCPU / 12GB RAM           │  │
│  │  IP: 192.168.100.11     │  │  IP: 192.168.100.20          │  │
│  │                         │  │                              │  │
│  │  ● AD DS (LDAP/Kerberos)│  │  ● Nova (Compute)            │  │
│  │  ● DNS Server           │  │  ● Neutron (Netwerk)         │  │
│  │  ● DHCP Server          │  │  ● Glance (Images)           │  │
│  │  ● Group Policy         │  │  ● Keystone (Auth)           │  │
│  │  ● File Server (shares) │  │  ● Horizon (Dashboard :80)  │  │
│  └─────────────────────────┘  └──────────────────────────────┘  │
│                                                                  │
│  ─────────────────── vmbr0 bridge ─────────────────────────     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    192.168.100.0/24
                             │
                    ┌────────┴─────────┐
                    │   Student PC's   │
                    │  192.168.100.30- │
                    │  Schoolnetwerk   │
                    └──────────────────┘
```

---

## Componentbeschrijvingen

### Proxmox VE (Hypervisor)

| Eigenschap | Waarde |
|------------|--------|
| Software | Proxmox VE 8.x (gratis) |
| Beheer URL | https://192.168.100.10:8006 |
| Rol | Host voor alle VM's, netwerk bridge, snapshot beheer |
| Credential | root / [beheerderswachtwoord] |
| Kritiek | Ja — als Proxmox down is, is alles down |

---

### DC01 — Domain Controller

| Eigenschap | Waarde |
|------------|--------|
| OS | Windows Server 2022 Standard (Evaluation) |
| IP | 192.168.100.11 |
| Domein | technova.local |
| FSMO rollen | Alle vijf op DC01 (single DC setup) |
| Services | AD DS, DNS, DHCP, File Services |
| RDP | 192.168.100.11:3389 |
| Kritiek | Ja — authenticatie, DNS, DHCP |

**FSMO rollen uitleg voor studenten:**
Flexible Single Master Operations rollen zijn speciale Active Directory rollen. In deze omgeving heeft DC01 alle rollen. In productie verdeelt men deze over meerdere DC's.

---

### devstack01 — OpenStack (All-in-one)

| Eigenschap | Waarde |
|------------|--------|
| OS | Ubuntu 22.04 LTS |
| IP | 192.168.100.20 |
| OpenStack versie | DevStack (rolling) |
| Dashboard | http://192.168.100.20/dashboard |
| SSH | stack@192.168.100.20 |
| Kritiek | Ja — alle cloud functionaliteit |

**OpenStack services op devstack01:**

| Service | Poort | Doel |
|---------|-------|------|
| Keystone | 5000 | Authenticatie en autorisatie |
| Nova API | 8774 | VM aanmaken en beheren |
| Neutron | 9696 | Netwerk beheer |
| Glance | 9292 | Image beheer |
| Horizon | 80 | Webdashboard (Apache2) |
| VNC Proxy | 6080 | Browser console voor VM's |
| MySQL | 3306 | Database (intern) |
| RabbitMQ | 5672 | Berichtenbroker (intern) |

---

## Afhankelijkheden

```
Student login Windows
    → DC01 (AD DS, Kerberos)
    → DNS (DC01)

Student login Horizon
    → DevStack (Keystone)
    → Apache2 (Horizon)
    → (GEEN koppeling met AD — aparte accounts)

VM aanmaken
    → Horizon (Apache2)
    → Nova (devstack01)
    → Glance (devstack01 — image ophalen)
    → Neutron (devstack01 — netwerk)
    → Nova VNC (devstack01 — console)

DNS resolutie (voor naam → IP)
    → DC01 DNS service
    → Primaire server: 192.168.100.11
```

---

## Single Points of Failure (SPOF)

In deze leeromgeving zijn meerdere SPOF's aanwezig. Dit is bewust voor eenvoud.

| SPOF | Risico | Mitigatie |
|------|--------|-----------|
| Proxmox host | Hele omgeving down | Wekelijkse backups, UPS aanbevolen |
| DC01 VM | Geen Windows login, geen DNS/DHCP | Proxmox snapshot, herstelplan |
| devstack01 VM | Geen cloud functionaliteit | Proxmox snapshot, rejoin-stack.sh |
| Schoolnetwerk | Geen verbinding student ↔ server | Lokale access via Proxmox console |

---

## Upgrade en vervanging

| Situatie | Actie |
|----------|-------|
| Windows Server evaluation verloopt (180 dagen) | Nieuw evaluation-sleutel activeren of nieuwe installatie |
| DevStack vastgelopen | Snapshot herstellen (`devstack-clean`) |
| Meer studenten dan 45 | Extra compute node toevoegen als extra Proxmox VM |
| Proxmox wil updaten | `apt update && apt full-upgrade` in Proxmox shell |
