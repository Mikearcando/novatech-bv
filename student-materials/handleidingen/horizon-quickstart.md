# OpenStack Horizon Quickstart — TechNova BV
## Voor junior systeembeheerders (leerjaar 1 & 2)

---

## Inloggen op Horizon

1. Open een webbrowser (Chrome of Firefox aanbevolen)
2. Ga naar: `http://192.168.100.20/dashboard`
3. Vul in:
   - **Domain:** `default`
   - **User Name:** jouw gebruikersnaam (bv. `jjansen`)
   - **Password:** `Student2024!`
4. Klik **Sign In**

Je zit nu in het dashboard van jouw team-project.

---

## Het dashboard begrijpen

```
Linkerbalk (menu):
├── Project                 ← jouw team-project
│   ├── Compute
│   │   ├── Overview        ← hoeveel resources gebruik je?
│   │   ├── Instances       ← jouw VM's
│   │   ├── Images          ← beschikbare OS-images
│   │   └── Key Pairs       ← SSH sleutels
│   └── Network
│       ├── Network Topology← visueel netwerkschema
│       ├── Networks        ← jouw netwerken
│       ├── Routers         ← verbinding intern↔extern
│       └── Security Groups ← firewall regels
└── Identity
    ├── Projects            ← projectoverzicht (admin only)
    └── Users               ← gebruikersbeheer (admin only)
```

---

## VM aanmaken (Instance)

### Stap 1: Navigeer naar Instances
- Klik in het linkermenu op **Project** → **Compute** → **Instances**
- Klik rechtsboven op **Launch Instance**

### Stap 2: Details invullen

**Tabblad Details:**
| Veld             | Waarde                                    |
|------------------|-------------------------------------------|
| Instance Name    | bv. `webserver-team1`                     |
| Description      | Kort beschrijf waarvoor deze VM dient     |
| Availability Zone| `nova`                                    |
| Count            | 1                                         |

**Tabblad Source:**
| Veld                   | Waarde                          |
|------------------------|---------------------------------|
| Select Boot Source     | Image                           |
| Create New Volume      | No (voor snelheid)              |
| Allocated image        | Klik op ↑ bij het gewenste image (bv. Ubuntu 22.04 of CirrOS) |

**Tabblad Flavor:**
- Klik op ↑ bij de gewenste flavor:
  - `tn.tiny` — 1 vCPU, 512MB RAM, 10GB schijf (voor testen)
  - `tn.small` — 1 vCPU, 1GB RAM, 20GB schijf (voor opdrachten)
  - `tn.medium` — 2 vCPU, 2GB RAM, 40GB schijf (voor productie)

**Tabblad Networks:**
- Klik op ↑ bij jouw teamnetwerk (bv. `team-infra-net`)
- Als er geen teamnetwerk is: gebruik `private`

**Tabblad Security Groups:**
- Klik op ↑ bij `default` (SSH en ping toegestaan)

### Stap 3: VM starten
- Klik op **Launch Instance** (rechtsboven)
- De VM verschijnt in de lijst met status `Spawning` → na ~1 min `Active`

---

## Verbinden met een VM

### Via VNC Console (browser)
1. Klik op de naam van je VM in de lijst
2. Klik op tabblad **Console**
3. Klik op **Click here to show only console**
4. Je ziet de terminal van de VM in je browser

### Via SSH (met floating IP)

Je hebt een **floating IP** nodig voor SSH vanuit buiten OpenStack.

**Floating IP associëren:**
1. Ga naar **Project** → **Compute** → **Instances**
2. Klik op het pijltje (▼) naast **Create Snapshot** bij jouw VM
3. Klik **Associate Floating IP**
4. Klik op **+** om een floating IP toe te wijzen
5. Klik **Associate**

Nu kan je SSH-en:
```bash
ssh ubuntu@<floating-ip>         # Ubuntu images
ssh cirros@<floating-ip>         # CirrOS (wachtwoord: cubswin:))
```

---

## VM beheer

### VM stoppen
1. Instances → klik op ▼ naast jouw VM
2. Klik **Shut Off Instance** → **Shut Off Instance**

### VM starten
1. Instances → klik op ▼ → **Start Instance**

### VM verwijderen (permanent!)
1. Instances → selecteer de VM (vinkje links)
2. Klik **Delete Instances** (rood) → bevestig
3. **Let op:** verwijderde VM's zijn weg. Maak eerst een snapshot als je hem misschien nodig hebt.

### Snapshot van VM maken
1. Instances → klik op ▼ → **Create Snapshot**
2. Geef een naam op (bv. `webserver-backup-14april`)
3. Snapshot verschijnt onder **Compute** → **Images**

---

## Netwerk aanmaken (opdracht)

1. Ga naar **Project** → **Network** → **Networks**
2. Klik **Create Network**

**Tabblad Network:**
- Network Name: `team-[jouw team]-net`
- Enable Admin State: aangevinkt
- Create Subnet: aangevinkt

**Tabblad Subnet:**
- Subnet Name: `team-[jouw team]-subnet`
- Network Address: bv. `10.20.1.0/24` (uniek per team!)
- IP Version: IPv4
- Gateway IP: `10.20.1.1`

**Tabblad Subnet Details:**
- Enable DHCP: aangevinkt
- DNS Name Servers: `192.168.100.11` (DC01)

3. Klik **Create**

---

## Security Group aanpassen

1. Ga naar **Project** → **Network** → **Security Groups**
2. Klik **Manage Rules** naast `default`
3. Klik **Add Rule**
4. Voorbeeld: SSH toestaan:
   - Rule: `SSH`
   - Remote: `CIDR`
   - CIDR: `0.0.0.0/0` (overal vandaan, voor test)
5. Klik **Add**

---

## Veelgemaakte fouten

| Fout                                 | Oorzaak                          | Oplossing                                     |
|--------------------------------------|----------------------------------|-----------------------------------------------|
| "No valid host was found"            | Te weinig resources              | Kies kleinere flavor (`tn.tiny`)              |
| VM staat op ERROR                    | Probleem bij aanmaken            | Verwijder VM en probeer opnieuw               |
| Kan niet SSH-en naar VM              | Geen floating IP of security group blokkeert | Floating IP associëren, SSH rule toevoegen |
| Inloggen op Horizon mislukt          | Verkeerd wachtwoord of domein   | Controleer: domein = `default`                |
| VM aanmaken knop grijs               | Te weinig quota                 | Verwijder niet-gebruikte VM's eerst           |
| Netwerk niet zichtbaar bij VM aanmaken | Netwerk niet in jouw project  | Maak netwerk aan in jouw project              |
