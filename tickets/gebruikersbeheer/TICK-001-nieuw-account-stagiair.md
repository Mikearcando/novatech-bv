# TICK-001 — Nieuw account aanmaken voor stagiair

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Gebruikersbeheer              |
| Prioriteit        | Hoog                          |
| Moeilijkheidsgraad| ★☆☆ (beginner)               |
| Toegewezen aan    | [student naam]                |
| Status            | Open                          |
| Aangemaakt        | [datum]                       |
| SLA               | Vandaag oplossen              |

---

## Probleemomschrijving

HR meldt via e-mail:

> "Beste IT-afdeling, Lena Visser begint maandag als stagiair bij onze IT Operations afdeling.
> Zij heeft toegang nodig tot het domein en het OpenStack dashboard.
> Haar manager is Tim Bakker. Zij wordt ingedeeld bij Team Cloud-Alpha.
> Graag zo snel mogelijk regelen. Met vriendelijke groet, HR afdeling TechNova"

---

## Wat moet er gebeuren

1. AD-account aanmaken voor Lena Visser
   - Gebruikersnaam: `lvisser` (als die al bestaat: `l.visser`)
   - OU: `OU=Studenten > Klas-1B`
   - Wachtwoord: `Student2024!`
   - Account inschakelen
2. Toevoegen aan groep `Team-Cloud-Alpha`
3. Toevoegen aan groep `GRP-CloudUsers`
4. OpenStack account aanmaken voor `lvisser` in project `team-cloud-alpha`

---

## Verwachte analyse

- Controleer of gebruikersnaam `lvisser` al bestaat: `Get-ADUser -Filter "SamAccountName -eq 'lvisser'"`
- Bepaal de juiste OU op basis van klas en team
- Controleer na aanmaken of account actief is
- Controleer of groepslidmaatschappen kloppen

---

## Oplossing

```powershell
# Op DC01 uitvoeren:

# 1. Controleer of naam al bestaat
Get-ADUser -Filter "SamAccountName -eq 'lvisser'"

# 2. Account aanmaken
New-ADUser `
    -Name "Lena Visser" `
    -GivenName "Lena" `
    -Surname "Visser" `
    -SamAccountName "lvisser" `
    -UserPrincipalName "lvisser@technova.local" `
    -Path "OU=Klas-1B,OU=Studenten,OU=Gebruikers,OU=TechNova,DC=technova,DC=local" `
    -AccountPassword (ConvertTo-SecureString "Student2024!" -AsPlainText -Force) `
    -Enabled $true

# 3. Groepen toevoegen
Add-ADGroupMember -Identity "Team-Cloud-Alpha" -Members "lvisser"
Add-ADGroupMember -Identity "GRP-CloudUsers"   -Members "lvisser"

# 4. Verificatie
Get-ADUser -Identity "lvisser" -Properties MemberOf | Select Name, Enabled
Get-ADPrincipalGroupMembership -Identity "lvisser" | Select Name
```

```bash
# OpenStack account aanmaken (op DevStack als admin):
source /opt/stack/devstack/openrc admin admin
openstack user create --password "Student2024!" --enable lvisser
openstack role add --project team-cloud-alpha --user lvisser member
```

---

## Verificatie

- [ ] Account bestaat in ADUC
- [ ] Account is ingeschakeld (groen icoontje)
- [ ] Lid van `Team-Cloud-Alpha`
- [ ] Lid van `GRP-CloudUsers`
- [ ] Kan inloggen op Horizon met `lvisser / Student2024!`

---

## Leerdoel

- AD gebruikersbeheer: aanmaken, groepen, OU-structuur
- Verband tussen AD-account en OpenStack-account
- Onboarding procedure begrijpen
