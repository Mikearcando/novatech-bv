# TechNova BV — ICT Leeromgeving
## MBO ICT | Leerjaar 1 & 2 | Systeembeheer Sprint Project

---

## Wat is dit project?

Studenten werken als junior systeembeheerder bij het fictieve bedrijf **TechNova BV**.
Ze beheren een hybride IT-omgeving (Windows Active Directory + OpenStack private cloud)
en verwerken realistische tickets via de Scrum-methode.

De docent is CTO/projectleider en heeft de omgeving vooraf ingericht.
Studenten werken in teams van 5, elk met eigen rollen en verantwoordelijkheden.

---

## Snelstart Docent

### Omgeving bouwen (volgorde!)
```
1. Proxmox VE installeren op hardware
2. DC01 VM aanmaken → Windows Server 2022 installeren
3. scripts/ad/New-OUStructure.ps1 uitvoeren op DC01
4. scripts/ad/New-ADGroups.ps1 uitvoeren op DC01
5. scripts/ad/New-TechNovaStudents.ps1 uitvoeren (gebruik scripts/ad/studenten.csv)
6. devstack01 VM aanmaken → Ubuntu 22.04 installeren
7. scripts/linux/prepare-ubuntu.sh uitvoeren op devstack01
8. infra/openstack/local.conf kopiëren naar /opt/stack/devstack/
9. sudo -u stack /opt/stack/devstack/stack.sh uitvoeren
10. scripts/openstack/create-openstack-users.sh uitvoeren
11. Testplan doorlopen (teacher-materials/installatie-handleiding.md Stap 11)
```

**Gedetailleerde handleiding:** [teacher-materials/installatie-handleiding.md](teacher-materials/installatie-handleiding.md)

### Dagelijks beheer
```
- DC01 check:       scripts/ad/Get-ADHealthCheck.ps1
- OpenStack check:  scripts/openstack/check-openstack-health.sh
- DevStack herstel: scripts/openstack/restart-devstack.sh
```

---

## Snelstart Studenten

| Systeem | Verbinding | Gebruikersnaam | Wachtwoord |
|---------|-----------|----------------|------------|
| Windows (RDP) | `192.168.100.11` | `TECHNOVA\[gebruikersnaam]` | `Student2024!` |
| Horizon (browser) | `http://192.168.100.20/dashboard` | `[gebruikersnaam]` | `Student2024!` |

**Domain bij Horizon login:** `default`

Lees eerst: [student-materials/handleidingen/ad-quickstart.md](student-materials/handleidingen/ad-quickstart.md)

---

## Projectstructuur

```
technova-leeromgeving/
├── README.md                    ← Dit bestand
│
├── docs/                        ← Alle projectdocumentatie
│   ├── architectuur/
│   │   ├── component-overzicht.md
│   │   └── ip-adresplan.md
│   └── handleidingen/
│
├── infra/                       ← Infrastructuurconfiguraties
│   ├── proxmox/vm-overzicht.md
│   ├── windows/ou-structuur.md, gpo-overzicht.md, dns-zones.md
│   └── openstack/local.conf, netwerk-overzicht.md, flavors.md
│
├── scripts/                     ← Uitvoerbare scripts
│   ├── ad/                      ← PowerShell (AD beheer)
│   │   ├── New-OUStructure.ps1
│   │   ├── New-ADGroups.ps1
│   │   ├── New-TechNovaStudents.ps1  ← Gebruikt studenten.csv
│   │   ├── studenten.csv
│   │   ├── Reset-StudentPasswords.ps1
│   │   └── Get-ADHealthCheck.ps1
│   ├── openstack/               ← Bash (OpenStack beheer)
│   │   ├── create-openstack-users.sh
│   │   ├── check-openstack-health.sh
│   │   └── restart-devstack.sh
│   └── linux/                   ← Ubuntu voorbereiding
│       ├── prepare-ubuntu.sh
│       └── netplan-config.yaml
│
├── templates/                   ← Invulbare formulieren
│   ├── ticketformulier.md
│   ├── dagstartformulier.md
│   ├── reflectieformulier.md
│   ├── opleverdocument.md
│   └── sprint-backlog-template.md
│
├── student-materials/           ← Alles voor studenten
│   ├── opdrachten/
│   │   ├── ad-opdrachten.md     ← 7 AD opdrachten (A01-A07)
│   │   └── cloud-opdrachten.md  ← 7 Cloud opdrachten (C01-C07)
│   ├── handleidingen/
│   │   ├── ad-quickstart.md
│   │   └── horizon-quickstart.md
│   └── cheatsheets/
│       ├── powershell-cheatsheet.md
│       └── openstack-cli-cheatsheet.md
│
├── teacher-materials/           ← Alles voor de docent
│   ├── installatie-handleiding.md  ← LEES DIT EERST
│   ├── beheerplan.md
│   └── beoordelingsmodel.md     ← Rubric + cijferberekening
│
├── tickets/                     ← 34 uitgewerkte tickets
│   ├── overzicht-alle-tickets.md   ← START HIER
│   ├── gebruikersbeheer/        (TICK-001, 002)
│   ├── loginproblemen/          (TICK-003, 004)
│   ├── netwerkproblemen/        (TICK-005, 006)
│   ├── vm-beheer/               (TICK-007, 008)
│   ├── rechtenproblemen/        (TICK-009, 010)
│   ├── softwareproblemen/       (TICK-011)
│   ├── cloudproblemen/          (TICK-012, 013, 014)
│   └── documentatie/            (TICK-015, 016)
│
└── planning/                    ← Scrum planning
    ├── teamindeling.md
    └── sprint-01/
        ├── sprint-doel.md
        └── sprint-backlog.md
```

---

## Wachtwoorden (leeromgeving — niet gebruiken in productie!)

| Account               | Wachtwoord      |
|-----------------------|-----------------|
| Windows Administrator | Admin2024!      |
| OpenStack admin       | TechNova2024!   |
| Alle studenten        | Student2024!    |
| Docent (OS)           | Docent2024!     |

---

## Technische Keuzes

| Beslissing           | Keuze           | Reden                                    |
|----------------------|-----------------|------------------------------------------|
| Hypervisor           | Proxmox VE      | Gratis, Linux-vriendelijk, snapshots     |
| OpenStack variant    | DevStack        | Eenvoudigste installatie, all-in-one     |
| AD koppeling         | Gesimuleerd     | Echte LDAP-koppeling te complex voor niveau |
| Scrum tool           | Bestand/bord    | Laagdrempelig, geen account nodig        |

---

## Licenties en kosten

| Software          | Licentie              | Kosten  |
|-------------------|-----------------------|---------|
| Proxmox VE        | AGPLv3 (community)    | Gratis  |
| Windows Server 22 | Evaluation (180 dagen)| Gratis  |
| Ubuntu 22.04 LTS  | GPL                   | Gratis  |
| DevStack          | Apache 2.0            | Gratis  |

**Totale softwarekosten: €0**

---

## Support

Problemen met de omgeving?
1. Controleer [teacher-materials/beheerplan.md](teacher-materials/beheerplan.md)
2. Controleer de health check scripts
3. Herstel Proxmox snapshot als laatste redmiddel
