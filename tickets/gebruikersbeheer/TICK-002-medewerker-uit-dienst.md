# TICK-002 — Medewerker uit dienst — account deactiveren

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Gebruikersbeheer              |
| Prioriteit        | Hoog — beveiligingsrisico     |
| Moeilijkheidsgraad| ★☆☆ (beginner)               |
| Status            | Open                          |
| SLA               | Binnen 1 uur                  |

---

## Probleemomschrijving

> "Beste IT, Medewerker Finn de Boer (fdeboer) heeft zijn ontslag ingediend en werkt
> zijn laatste dag vandaag. Zijn account moet worden uitgeschakeld zodra hij het pand
> verlaat om 17:00. Zorg er ook voor dat hij niet meer kan inloggen op de cloud-omgeving.
> — HR / Management"

---

## Wat moet er gebeuren

1. AD-account `fdeboer` uitschakelen
2. Account verplaatsen naar `OU=Uitgeschakeld`
3. Beschrijving toevoegen met datum en reden
4. OpenStack account uitschakelen
5. Actieve sessies beëindigen (indien van toepassing)

---

## Verwachte analyse

- Zoek het account op: `Get-ADUser -Identity "fdeboer"`
- Controleer huidige OU en groepslidmaatschappen
- Controleer of account actieve sessies heeft
- Neem in de beschrijving op: datum, reden, wie de actie heeft uitgevoerd

---

## Oplossing

```powershell
# Stap 1: Account opzoeken en status controleren
Get-ADUser -Identity "fdeboer" -Properties Enabled, DistinguishedName, Description

# Stap 2: Account uitschakelen
Disable-ADAccount -Identity "fdeboer"

# Stap 3: Beschrijving bijwerken
Set-ADUser -Identity "fdeboer" `
    -Description "Uitgeschakeld $(Get-Date -Format 'dd-MM-yyyy') — medewerker vertrokken. Actie: [jouw naam]"

# Stap 4: Verplaatsen naar Disabled OU
# Haal eerst de DistinguishedName op:
$dn = (Get-ADUser -Identity "fdeboer").DistinguishedName
Move-ADObject -Identity $dn `
    -TargetPath "OU=Uitgeschakeld,OU=Gebruikers,OU=TechNova,DC=technova,DC=local"

# Stap 5: Verificatie
Get-ADUser -Identity "fdeboer" -Properties Enabled, Description, DistinguishedName
```

```bash
# OpenStack account uitschakelen:
source /opt/stack/devstack/openrc admin admin
openstack user set --disable fdeboer
openstack user show fdeboer
```

---

## Verificatie

- [ ] Account `fdeboer` uitgeschakeld in ADUC (rode pijl-icoon)
- [ ] Account staat nu in `OU=Uitgeschakeld`
- [ ] Beschrijving bevat datum en reden
- [ ] Inloggen als `fdeboer` mislukt (test dit!)
- [ ] OpenStack account uitgeschakeld

---

## Leerdoel

- Offboarding procedure uitvoeren
- Beveiligingsbeleid: tijdig accounts uitschakelen
- AD accountstatus beheren
- Verband AD en OpenStack accountstatus
