# Beheerplan — TechNova Leeromgeving
## Docentversie | Dagelijks gebruik

---

## Dagelijkse routine (vóór de les)

**Tijdsduur: ~10 minuten**

### 1. DC01 controleren

```powershell
# Open PowerShell op je eigen PC of via RDP op DC01
# RSAT vereist op docentwerkstation

# Snelle check:
Test-NetConnection -ComputerName "192.168.100.11" -Port 389  # LDAP
Test-NetConnection -ComputerName "192.168.100.11" -Port 3389 # RDP

# Uitgebreide health check (uitvoeren op DC01):
# \\DC01\C$\Scripts\Get-ADHealthCheck.ps1
```

### 2. DevStack controleren

```bash
ssh stack@192.168.100.20

source /opt/stack/devstack/openrc admin admin
openstack service list --format value -c State | grep -c "up"
# Moet minimaal 5 zijn

# Als services down zijn:
/usr/local/bin/devstack-restart
```

### 3. Horizon testen

Open browser: `http://192.168.100.20/dashboard`
- Inloggen als `admin / TechNova2024!`
- Controleer of projecten zichtbaar zijn
- Controleer of er geen VM's met status `ERROR` zijn

### 4. Geblokkeerde accounts checken

```powershell
# Op DC01 of met RSAT:
Search-ADAccount -LockedOut -SearchBase "OU=Studenten,OU=Gebruikers,OU=TechNova,DC=technova,DC=local" |
    Select-Object Name, SamAccountName |
    Format-Table -AutoSize
```

---

## Wekelijkse routine

### Maandagsmorgen (begin week)

```bash
# Snapshot DC01 en DevStack
qm snapshot 100 "dc01-week$(date +%V)" --description "DC01 begin week $(date +%V)"
qm snapshot 101 "devstack-week$(date +%V)" --description "DevStack begin week $(date +%V)"

# Schijfruimte controleren op Proxmox host
df -h
pvesm status
```

### Vrijdagmiddag (einde week)

```bash
# Oude snapshots opruimen (bewaar laatste 3)
qm listsnapshot 101
# Verwijder snapshots ouder dan 3 weken:
# qm delsnapshot 101 [naam]
```

---

## Procedures bij veelvoorkomende problemen

### Probleem: DevStack reageert niet / Horizon onbereikbaar

```bash
ssh stack@192.168.100.20

# 1. Check Apache2
sudo systemctl status apache2
sudo systemctl restart apache2

# 2. Check OpenStack services
source /opt/stack/devstack/openrc admin admin
openstack service list

# 3. Als services down zijn, herstart DevStack
/usr/local/bin/devstack-restart

# 4. Als herstart niet werkt, herstel snapshot
# (Op Proxmox host:)
qm rollback 101 devstack-clean
```

### Probleem: DC01 start niet / AD niet bereikbaar

```bash
# Proxmox console openen:
# Proxmox UI → DC01 → Console

# Als Windows niet opstart:
qm rollback 100 dc01-clean
```

### Probleem: Student account geblokkeerd

```powershell
# Op DC01 of via RSAT:
Unlock-ADAccount -Identity "gebruikersnaam"
# Of gebruik het script:
.\Reset-StudentPasswords.ps1 -Modus Enkeling -Gebruikersnaam "gebruikersnaam"
```

### Probleem: Student kan niet inloggen op Horizon

```bash
# Controleer of account bestaat in OpenStack:
source /opt/stack/devstack/openrc admin admin
openstack user show gebruikersnaam

# Wachtwoord resetten:
openstack user set --password "Student2024!" gebruikersnaam

# Controleer projectkoppeling:
openstack role assignment list --user gebruikersnaam
```

### Probleem: VM student staat op ERROR

```bash
source /opt/stack/devstack/openrc admin admin

# VM status bekijken:
openstack server show vm-naam

# Nova logs:
sudo tail -100 /opt/stack/logs/n-cpu.log | grep ERROR

# Als VM corrupt is, verwijder en maak opnieuw:
openstack server delete vm-naam
```

### Probleem: Schijfruimte vol op DevStack

```bash
# Controleer:
df -h /opt/stack

# Stale VM's verwijderen:
openstack server list --all-projects
openstack server delete [vm-namen]

# Stale images verwijderen:
openstack image list
openstack image delete [image-naam]

# DevStack logs opruimen:
find /opt/stack/logs -name "*.log" -mtime +3 -delete
```

---

## Accounts overzicht

| Account               | Systeem     | Gebruikersnaam  | Wachtwoord    |
|-----------------------|-------------|-----------------|---------------|
| Proxmox root          | Proxmox     | root            | [jouw keuze]  |
| Windows Administrator | DC01 / AD   | Administrator   | Admin2024!    |
| OpenStack admin       | OpenStack   | admin           | TechNova2024! |
| DevStack SSH          | Ubuntu      | stack           | [jouw keuze]  |
| Docent AD             | AD          | docent          | Docent2024!   |
| Docent OpenStack      | OpenStack   | docent          | Docent2024!   |
| Studenten (allen)     | AD + OS     | [zie accountlijst] | Student2024! |

**Bewaar wachtwoorden veilig. Niet in dit document opslaan in productie.**

---

## Noodprocedure: Hele omgeving herstel

Als alles kapot is:

1. **Proxmox UI openen:** `https://192.168.100.10:8006`
2. **DC01 herstellen:**
   - DC01 → Snapshots → `dc01-clean` → Rollback
3. **DevStack herstellen:**
   - devstack01 → Snapshots → `devstack-clean` → Rollback
4. **Beide VMs starten**
5. **DevStack herstarten na rollback:**
   ```bash
   ssh stack@192.168.100.20
   /usr/local/bin/devstack-restart
   ```
6. **Controleer beide health checks**
7. **Studenten informeren:** "5 minuten, systeem wordt hersteld"

**Tijdsduur noodherstel:** 10-20 minuten

---

## Fallback scenario: omgeving volledig down

Als de infrastructuur niet te herstellen is binnen 10 minuten, schakel over naar **Papieren Sprint**:

- Studenten werken met papieren tickets
- Documentatietaken: infrastructuurbeschrijving schrijven, diagrammen tekenen
- PowerShell oefeningen op eigen PC (RSAT als lab, mock-AD)
- Scrum ceremonies gewoon doorgaan
- Beoordelaar observeert samenwerking en probleemanalyse

Materiaal voor papieren sprint ligt klaar in `teacher-materials/fallback-lesplan.md`.
