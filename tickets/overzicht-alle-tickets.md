# Ticketoverzicht — TechNova BV Sprint 1 & 2

Alle tickets gesorteerd per categorie. Elk ticket heeft een eigen bestand.
Gebruik dit overzicht bij de sprintplanning om tickets te verdelen.

---

## Gebruikersbeheer

| Ticket | Titel                                        | Niveau | Bestand                               |
|--------|----------------------------------------------|--------|---------------------------------------|
| TICK-001 | Nieuw account aanmaken voor stagiair        | ★☆☆   | gebruikersbeheer/TICK-001-*.md        |
| TICK-002 | Medewerker uit dienst — account deactiveren | ★☆☆   | gebruikersbeheer/TICK-002-*.md        |
| TICK-017 | Naam wijzigen na huwelijk                   | ★★☆   | — zie hieronder                       |
| TICK-018 | Bulk accounts CSV import                    | ★★★   | — zie hieronder                       |
| TICK-019 | OU aanmaken voor nieuw project              | ★★☆   | — zie hieronder                       |
| TICK-020 | Groep aanmaken voor project CloudMigration  | ★★☆   | — zie hieronder                       |

## Loginproblemen

| Ticket | Titel                                        | Niveau | Bestand                               |
|--------|----------------------------------------------|--------|---------------------------------------|
| TICK-003 | Account geblokkeerd                         | ★☆☆   | loginproblemen/TICK-003-*.md          |
| TICK-004 | Horizon login mislukt                       | ★★☆   | loginproblemen/TICK-004-*.md          |
| TICK-021 | Wachtwoord vergeten                         | ★☆☆   | — zie hieronder                       |
| TICK-022 | RDP werkt niet voor nieuwe medewerker       | ★★☆   | — zie hieronder                       |

## Netwerkproblemen

| Ticket | Titel                                        | Niveau | Bestand                               |
|--------|----------------------------------------------|--------|---------------------------------------|
| TICK-005 | DNS naam niet opgelost                      | ★★☆   | netwerkproblemen/TICK-005-*.md        |
| TICK-006 | Client krijgt geen IP                       | ★★☆   | netwerkproblemen/TICK-006-*.md        |
| TICK-023 | Ping naar server mislukt                    | ★★☆   | — zie hieronder                       |
| TICK-024 | Intern OpenStack netwerk niet bereikbaar    | ★★★   | — zie hieronder                       |

## VM Beheer

| Ticket | Titel                                        | Niveau | Bestand                               |
|--------|----------------------------------------------|--------|---------------------------------------|
| TICK-007 | VM staat op ERROR                           | ★★★   | vm-beheer/TICK-007-*.md               |
| TICK-008 | VM aanmaken voor afdeling Sales             | ★☆☆   | vm-beheer/TICK-008-*.md               |
| TICK-025 | VM snapshot maken voor update               | ★★☆   | — zie hieronder                       |
| TICK-026 | VM verwijderen — verkeerde VM aangemaakt    | ★☆☆   | — zie hieronder                       |
| TICK-027 | VM meer resources geven (resize)            | ★★★   | — zie hieronder                       |

## Rechtenproblemen

| Ticket | Titel                                        | Niveau | Bestand                               |
|--------|----------------------------------------------|--------|---------------------------------------|
| TICK-009 | Te veel rechten — audit bevinding           | ★★☆   | rechtenproblemen/TICK-009-*.md        |
| TICK-010 | Map toegang geweigerd                       | ★★☆   | rechtenproblemen/TICK-010-*.md        |
| TICK-028 | GPO blokkeert USB (onterecht)               | ★★★   | — zie hieronder                       |
| TICK-029 | OpenStack gebruiker kan geen VM aanmaken    | ★★☆   | — zie hieronder                       |

## Softwareproblemen

| Ticket | Titel                                        | Niveau | Bestand                               |
|--------|----------------------------------------------|--------|---------------------------------------|
| TICK-011 | DNS service start niet na reboot            | ★★☆   | softwareproblemen/TICK-011-*.md       |
| TICK-030 | Windows Update vastgelopen                  | ★★★   | — zie hieronder                       |

## Cloudproblemen

| Ticket | Titel                                        | Niveau | Bestand                               |
|--------|----------------------------------------------|--------|---------------------------------------|
| TICK-012 | Horizon niet bereikbaar                     | ★★☆   | cloudproblemen/TICK-012-*.md          |
| TICK-013 | DevStack down na reboot                     | ★★★   | cloudproblemen/TICK-013-*.md          |
| TICK-014 | VM geen internettoegang                     | ★★★   | cloudproblemen/TICK-014-*.md          |
| TICK-031 | Image upload mislukt                        | ★★★   | — zie hieronder                       |
| TICK-032 | Security group te streng ingesteld          | ★★☆   | — zie hieronder                       |

## Documentatie

| Ticket | Titel                                        | Niveau | Bestand                               |
|--------|----------------------------------------------|--------|---------------------------------------|
| TICK-015 | Onboarding handleiding schrijven            | ★★☆   | documentatie/TICK-015-*.md            |
| TICK-016 | Incidentrapport schrijven                   | ★★☆   | documentatie/TICK-016-*.md            |
| TICK-033 | Netwerkdiagram bijwerken                    | ★☆☆   | — zie hieronder                       |
| TICK-034 | Change request schrijven                    | ★★☆   | — zie hieronder                       |

---

## Inline tickets (niet in apart bestand, direct hier beschreven)

### TICK-017 — Naam wijzigen na huwelijk ★★☆
**Omschrijving:** Sara Bakker (sbakker) is getrouwd en heet nu Sara Jansen. Wijzig displaynaam, UPN en eventueel e-mailalias.
**Commando:** `Set-ADUser -Identity "sbakker" -DisplayName "Sara Jansen" -Surname "Jansen" -UserPrincipalName "sjansen@technova.local"`
**Leerdoel:** AD attributenbeheer, UPN wijziging impact

---

### TICK-021 — Wachtwoord vergeten ★☆☆
**Omschrijving:** Medewerker belt: "Ik ben mijn wachtwoord vergeten, ik kan niet inloggen." Reset het naar standaard en zorg dat ze het bij eerste login wijzigen.
**Commando:** `Set-ADAccountPassword -Identity "gebruiker" -Reset -NewPassword (...) ; Set-ADUser -Identity "gebruiker" -ChangePasswordAtLogon $true`
**Leerdoel:** Veilige wachtwoordreset procedure

---

### TICK-022 — RDP werkt niet voor nieuwe medewerker ★★☆
**Omschrijving:** Nieuwe medewerker kan geen RDP-verbinding maken naar DC01. Anderen wel.
**Diagnose:** Controleer Remote Desktop Users groepslidmaatschap. Controleer of Remote Desktop toegang ingeschakeld is op server.
**Oplossing:** `Add-ADGroupMember -Identity "Remote Desktop Users" -Members "gebruikersnaam"`
**Leerdoel:** Remote Desktop rechten, groepenbeheer

---

### TICK-023 — Ping naar server mislukt ★★☆
**Omschrijving:** Medewerker kan DC01 niet pingen. Anderen wel.
**Diagnose:** IP correct? Firewall ICMP? Kabel/switch?
**Oplossing:** Windows Firewall ICMP toestaan: `netsh advfirewall firewall add rule name="ICMPv4" protocol=icmpv4:8,any dir=in action=allow`
**Leerdoel:** Netwerk troubleshooting layers, ICMP/firewall

---

### TICK-024 — Intern OpenStack netwerk niet bereikbaar ★★★
**Omschrijving:** VM's binnen hetzelfde team-project kunnen niet onderling communiceren.
**Diagnose:** Zitten beide VM's in hetzelfde netwerk? Security group staat ICMP toe? Neutron agent actief?
**Oplossing:** Security group ICMP toevoegen, controleer `openstack network agent list`
**Leerdoel:** OpenStack networking, security groups

---

### TICK-025 — VM snapshot maken voor update ★★☆
**Omschrijving:** Vóór een grote update wil klant een snapshot van zijn VM.
**Oplossing:** Via Horizon: Instances → Actie → Create Snapshot. Of CLI: `openstack server image create --name "backup-dd-mm" vm-naam`
**Leerdoel:** Backup strategie, VM lifecycle

---

### TICK-026 — Verkeerde VM verwijderen ★☆☆
**Omschrijving:** Student heeft per ongeluk een VM in het verkeerde project aangemaakt.
**Oplossing:** VM verwijderen, opnieuw aanmaken in juist project. Zorgvuldigheid: controleer altijd in welk project je werkt.
**Leerdoel:** Correcte werkprocedure, project-bewustzijn

---

### TICK-028 — GPO blokkeert USB (onterecht) ★★★
**Omschrijving:** Medewerkers kunnen geen USB-stick gebruiken. Dit is niet de bedoeling.
**Diagnose:** GPMC → zoek GPO met Removable Storage policy. `gpresult /h` op client.
**Oplossing:** GPO aanpassen: Computer Config → Windows Settings → Security → Removable Storage → Disabled.
**Leerdoel:** GPO troubleshooting, beleidsintentie vs. effect

---

### TICK-029 — OpenStack gebruiker kan geen VM aanmaken ★★☆
**Omschrijving:** Student krijgt "Forbidden" bij VM aanmaken.
**Diagnose:** `openstack role assignment list --user gebruiker --project project`
**Oplossing:** `openstack role add --project team-xx --user gebruiker member`
**Leerdoel:** OpenStack RBAC, rollen en rechten

---

### TICK-030 — Windows Update vastgelopen ★★★
**Omschrijving:** DC01 hangt bij Windows Update al 2 uur op 45%.
**Diagnose:** Update log: `Get-WindowsUpdateLog`. BITS service status.
**Oplossing:** `Stop-Service wuauserv,bits,cryptsvc -Force; Remove-Item C:\Windows\SoftwareDistribution -Recurse -Force; Start-Service wuauserv,bits,cryptsvc`
**Leerdoel:** Windows Update troubleshooting, service dependencies

---

### TICK-031 — Image upload mislukt ★★★
**Omschrijving:** Student probeert Ubuntu cloud image te uploaden maar krijgt fout.
**Diagnose:** Bestandsformaat correct (qcow2)? Schijfruimte voldoende? `df -h /opt/stack`
**Oplossing:** CLI upload: `openstack image create "Ubuntu 22.04" --disk-format qcow2 --container-format bare --public --file ubuntu.img`
**Leerdoel:** Glance image service, schijfruimtebeheer

---

### TICK-032 — Security group te streng ★★☆
**Omschrijving:** Niemand kan meer SSH-en naar VM's na een wijziging door een student.
**Diagnose:** `openstack security group rule list default`
**Oplossing:** SSH regel opnieuw toevoegen. Documenteer welke regels minimaal nodig zijn.
**Leerdoel:** Security group beheer, impact van wijzigingen

---

### TICK-033 — Netwerkdiagram bijwerken ★☆☆
**Omschrijving:** Diagram is verouderd. Nieuwe VM's en netwerken ontbreken.
**Oplossing:** Inventariseer: `openstack server list --all-projects`, `openstack network list`. Werk `docs/architectuur/netwerk-diagram.md` bij.
**Leerdoel:** Documentatiebeheer, netwerkinventarisatie

---

### TICK-034 — Change request schrijven ★★☆
**Omschrijving:** Je wil een wijziging doorvoeren (bv. nieuw netwerk aanmaken). Schrijf een change request.
**Vereiste velden:** Doel van de wijziging, impact, risico, rollback plan, geplande datum, goedkeuring.
**Leerdoel:** Change management, professionele IT-communicatie

---

## Verdeling tips voor docent

**Sprint 1 (beginners):** TICK-001, 002, 003, 006, 008, 015, 017, 021
**Sprint 1 (gevorderden):** TICK-004, 005, 009, 010, 011, 012, 016
**Sprint 2 (alle):** TICK-007, 013, 014, 022-034
