# TICK-009 — Medewerker heeft te veel rechten — beveiligingsaudit

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Rechtenproblemen              |
| Prioriteit        | Hoog — beveiligingskwestie    |
| Moeilijkheidsgraad| ★★☆ (gemiddeld)              |
| Status            | Open                          |
| SLA               | Vandaag                       |

---

## Probleemomschrijving

Beveiligingsaudit heeft een probleem gevonden:

> "Tijdens onze maandelijkse beveiligingsaudit is gebleken dat student-account
> 'dwouters' lid is van de groep 'Domain Admins'. Dit is onjuist: studenten
> mogen geen domeinbeheerder zijn. Hoe dit is ontstaan is onbekend.
> Corrigeer dit direct. Documenteer ook welke andere rechten dit account heeft."

---

## Achtergrond

**Least Privilege Principe:** Gebruikers mogen alleen de rechten hebben die ze nodig hebben voor hun functie. Teveel rechten = groter beveiligingsrisico.

Een studentaccount hoort lid te zijn van:
- Zijn/haar team-groep (bv. `Team-Support`)
- `DL-AlleStudenten`
- Eventueel `GRP-CloudUsers`

Een studentaccount hoort NIET lid te zijn van:
- `Domain Admins`
- `Schema Admins`
- `Enterprise Admins`
- `Administrators` (lokaal)

---

## Diagnosestappen

```powershell
# Stap 1: Alle groepen van dwouters opvragen
Get-ADPrincipalGroupMembership -Identity "dwouters" |
    Select-Object Name, GroupScope, GroupCategory |
    Sort-Object Name

# Stap 2: Wie is lid van Domain Admins?
Get-ADGroupMember -Identity "Domain Admins" |
    Select-Object Name, SamAccountName, ObjectClass

# Stap 3: Controleer ook andere gevaarlijke groepen
$gevaardlijkeGroepen = @("Domain Admins","Schema Admins","Enterprise Admins","Administrators","Backup Operators")
foreach ($groep in $gevaardlijkeGroepen) {
    $leden = Get-ADGroupMember -Identity $groep -ErrorAction SilentlyContinue |
        Where-Object { $_.SamAccountName -like "*student*" -or $_.SamAccountName -match "^[a-z]" }
    if ($leden) {
        Write-Host "WAARSCHUWING: Studentaccounts in '$groep':" -ForegroundColor Red
        $leden | Select-Object Name, SamAccountName
    }
}
```

---

## Oplossing

```powershell
# Verwijder dwouters uit Domain Admins
Remove-ADGroupMember -Identity "Domain Admins" -Members "dwouters" -Confirm:$false

# Verificeer
Get-ADPrincipalGroupMembership -Identity "dwouters" | Select-Object Name

# Controleer of Domain Admins nu correct is
Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name, SamAccountName

# Zorg dat het account de juiste groepen WEL heeft
Add-ADGroupMember -Identity "Team-Support"       -Members "dwouters" -ErrorAction SilentlyContinue
Add-ADGroupMember -Identity "DL-AlleStudenten"   -Members "dwouters" -ErrorAction SilentlyContinue
```

---

## Rapportage

Schrijf een incidentrapport met:
- Wanneer het ontdekt is
- Hoe het waarschijnlijk is ontstaan
- Welke actie is uitgevoerd
- Wie de actie heeft uitgevoerd
- Hoe het voorkomen kan worden (aanbeveling)

---

## Verificatie

- [ ] `dwouters` is NIET meer in `Domain Admins`
- [ ] `dwouters` is wel in de juiste studentgroepen
- [ ] Geen andere studentaccounts in `Domain Admins`
- [ ] Incidentrapport geschreven

---

## Leerdoel

- Least privilege principe toepassen
- Beveiligingsaudit uitvoeren
- AD groepslidmaatschappen beoordelen
- Incidentrapportage schrijven
