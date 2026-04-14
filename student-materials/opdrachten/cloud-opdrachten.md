# OpenStack Cloud Opdrachten — TechNova BV
## Leerjaar 1 & 2 | Sprint 1 & 2

Open de Horizon-handleiding erbij: `student-materials/handleidingen/horizon-quickstart.md`
Inloggen op Horizon: `http://192.168.100.20/dashboard` — jouw gebruikersnaam / `Student2024!`

---

## Opdracht C01 — VM aanmaken via Horizon ★☆☆

**Context:**  
Klant vraagt om een Ubuntu testserver op te zetten voor hun ontwikkelteam.

**Jouw taak:**
1. Log in op Horizon met jouw account
2. Ga naar **Project → Compute → Instances → Launch Instance**
3. Maak een VM aan met:
   - Naam: `dev-server-[jouwinitialen]`
   - Image: `CirrOS` (klein testimage, snel)
   - Flavor: `tn.tiny`
   - Network: jouw teamnetwerk of `private`
4. Wacht tot de VM status `Active` heeft
5. Open de console via **Console** tabblad
6. Log in op de VM (gebruiker: `cirros`, wachtwoord: `cubswin:)`)
7. Voer uit: `hostname` en `ip addr`
8. Schrijf op wat je ziet

**Leerdoel:** VM lifecycle begrijpen, Horizon navigeren.

---

## Opdracht C02 — Teamnetwerk aanmaken ★★☆

**Context:**  
Elk team heeft een eigen geïsoleerd netwerk nodig voor hun VM's.

**Jouw taak:**
1. Ga naar **Project → Network → Networks**
2. Maak een netwerk aan:
   - Naam: `team-[jouwteam]-net`
   - Subnet naam: `team-[jouwteam]-subnet`
   - Subnet range: `10.20.[teamnummer].0/24`
   - DNS: `192.168.100.11`
   - DHCP: aan
3. Maak een **router** aan:
   - Naam: `team-[jouwteam]-router`
   - External network: `public`
4. Koppel jouw subnet aan de router:
   - Router → tabblad **Interfaces** → **Add Interface** → kies jouw subnet
5. Maak een VM aan in jouw nieuwe netwerk en controleer dat hij een IP krijgt

**Teamnummers:**
| Team           | Subnet         |
|----------------|----------------|
| Team-Infra-Alpha | 10.20.1.0/24 |
| Team-Infra-Beta  | 10.20.2.0/24 |
| Team-Cloud-Alpha | 10.20.3.0/24 |
| Team-Cloud-Beta  | 10.20.4.0/24 |
| Team-Ops-Alpha   | 10.20.5.0/24 |
| Team-Ops-Beta    | 10.20.6.0/24 |
| Team-Support     | 10.20.7.0/24 |
| Team-Security    | 10.20.8.0/24 |
| Team-DevOps      | 10.20.9.0/24 |

---

## Opdracht C03 — Floating IP associëren ★★☆

**Context:**  
Je wilt je VM bereiken vanaf een andere computer in het netwerk via SSH.

**Jouw taak:**
1. Zorg dat je een VM hebt die draait (uit C01 of C02)
2. Ga naar **Project → Network → Floating IPs**
3. Klik **Allocate IP to Project** → Pool: `public` → **Allocate IP**
4. Associeer het IP aan jouw VM
5. Controleer via ping: open een terminal of PowerShell
   ```
   ping <jouw-floating-ip>
   ```
6. Als ping werkt: maak verbinding via SSH (via DevStack console):
   ```bash
   ssh cirros@<jouw-floating-ip>
   # Wachtwoord: cubswin:)
   ```

**Documenteer:** Welk floating IP heeft jouw VM gekregen? Werkt de verbinding?

---

## Opdracht C04 — Security Group aanpassen ★★☆

**Context:**  
Klant meldt: "We kunnen niet pingen naar onze VM". Jij gaat dit oplossen.

**Jouw taak:**
1. Ga naar **Project → Network → Security Groups**
2. Klik op **Manage Rules** bij `default`
3. Controleer welke regels er zijn. Ontbreekt ICMP?
4. Voeg een regel toe voor ICMP (ping):
   - Rule: `All ICMP`
   - Direction: `Ingress`
   - Remote: `CIDR` → `0.0.0.0/0`
5. Voeg ook SSH toe als die er niet is:
   - Rule: `SSH`
   - Remote: `CIDR` → `0.0.0.0/0`
6. Test: ping en SSH naar jouw VM

---

## Opdracht C05 — Snapshot maken en herstellen ★★★

**Context:**  
Vóór een risicovolle update wil de klant een backup van de VM.

**Jouw taak:**
1. Maak een draaiende VM met een kleine wijziging (maak een bestand aan):
   ```bash
   # Via VM console:
   touch /home/cirros/mijn-testbestand.txt
   echo "Dit is mijn testbestand" > /home/cirros/mijn-testbestand.txt
   ```
2. Maak een snapshot:
   - Instances → Actie-menu (▼) → **Create Snapshot**
   - Naam: `vm-backup-[datum]`
3. Verwijder het bestand in de VM:
   ```bash
   rm /home/cirros/mijn-testbestand.txt
   ```
4. Herstel de VM via de snapshot:
   - Ga naar **Compute → Images**
   - Zoek jouw snapshot op → **Launch** → gebruik snapshot als boot source
5. Controleer in de nieuwe VM of het bestand er weer is

**Documenteer:** Wat is het verschil tussen een snapshot en een backup?

---

## Opdracht C06 — VM sizing begrijpen ★★☆

**Context:**  
Je moet uitleggen aan een klant welke VM-grootte hij nodig heeft.

**Jouw taak:**
1. Bekijk alle beschikbare flavors:
   - Horizon: **Project → Compute → Instances → Launch Instance → Flavor**
   - Of CLI: `openstack flavor list`
2. Maak een tabel in jouw documentatie met alle flavors en hun specificaties
3. Beantwoord de volgende klantvragen schriftelijk:
   - "Ik wil een webserver draaien die 50 gelijktijdige gebruikers aankan"
   - "Ik wil een kleine database voor 10 gebruikers"
   - "Ik wil snel even iets testen, zo klein mogelijk"
4. Motiveer je antwoorden

---

## Opdracht C07 — Quota en resource management ★★★

**Context:**  
Het Cloud team merkt dat de server trager wordt. Jij onderzoekt het resource gebruik.

**Jouw taak:**
1. Ga naar **Project → Compute → Overview**
2. Bekijk hoeveel resources jouw team heeft gebruikt
3. Noteer:
   - Instanties: X van max Y gebruikt
   - vCPU's: X van max Y
   - RAM: X van max Y GB
4. Verwijder VM's die niet meer nodig zijn
5. Controleer opnieuw en schrijf op wat er is vrijgekomen
6. Schrijf een aanbeveling: "Wanneer moet je VM's verwijderen?"

---

## Documentatievereiste

Per opdracht lever je op:
- [ ] Naam van de opdracht
- [ ] Stappen die je hebt uitgevoerd
- [ ] Screenshot van de werkende oplossing (of beschrijving)
- [ ] Antwoord op de verificatievraag
- [ ] Eventuele problemen en hoe je die hebt opgelost
