# PowerShell Cheatsheet — Active Directory
## TechNova BV | Altijd bij de hand houden

---

## GEBRUIKERS

```powershell
# ── Aanmaken ──────────────────────────────────────────────────────────────────
New-ADUser -Name "Jan Jansen" -SamAccountName "jjansen" `
    -UserPrincipalName "jjansen@technova.local" `
    -Path "OU=Studenten,OU=Gebruikers,OU=TechNova,DC=technova,DC=local" `
    -AccountPassword (ConvertTo-SecureString "Student2024!" -AsPlainText -Force) `
    -Enabled $true

# ── Opvragen ──────────────────────────────────────────────────────────────────
Get-ADUser -Identity "jjansen"                              # Basisinfo
Get-ADUser -Identity "jjansen" -Properties *                # Alles
Get-ADUser -Filter "Name -like '*Jansen*'"                  # Zoeken op naam
Get-ADUser -Filter * -SearchBase "OU=Studenten,..."         # Alle studenten

# ── Wijzigen ──────────────────────────────────────────────────────────────────
Set-ADUser -Identity "jjansen" -DisplayName "Jan de Jansen" # Naam aanpassen
Set-ADUser -Identity "jjansen" -Department "IT Operations"  # Afdeling

# ── Wachtwoord ────────────────────────────────────────────────────────────────
Set-ADAccountPassword -Identity "jjansen" -Reset `
    -NewPassword (ConvertTo-SecureString "Nieuw2024!" -AsPlainText -Force)

# ── In/uitschakelen ───────────────────────────────────────────────────────────
Enable-ADAccount  -Identity "jjansen"
Disable-ADAccount -Identity "jjansen"
Unlock-ADAccount  -Identity "jjansen"    # Na te veel foutieve logins

# ── Verwijderen ───────────────────────────────────────────────────────────────
Remove-ADUser -Identity "jjansen" -Confirm:$false

# ── Verplaatsen (naar andere OU) ──────────────────────────────────────────────
Move-ADObject `
    -Identity "CN=Jan Jansen,OU=Studenten,...,DC=technova,DC=local" `
    -TargetPath "OU=Uitgeschakeld,OU=Gebruikers,OU=TechNova,DC=technova,DC=local"
```

---

## GROEPEN

```powershell
# ── Aanmaken ──────────────────────────────────────────────────────────────────
New-ADGroup -Name "Team-Nieuw" -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=Scrum-Teams,OU=Groepen,OU=TechNova,DC=technova,DC=local"

# ── Leden beheren ─────────────────────────────────────────────────────────────
Add-ADGroupMember    -Identity "Team-Infra-Alpha" -Members "jjansen","lvisser"
Remove-ADGroupMember -Identity "Team-Infra-Alpha" -Members "jjansen" -Confirm:$false
Get-ADGroupMember    -Identity "Team-Infra-Alpha"

# ── Groepen van gebruiker ─────────────────────────────────────────────────────
Get-ADPrincipalGroupMembership -Identity "jjansen" | Select Name

# ── Groep opvragen ────────────────────────────────────────────────────────────
Get-ADGroup -Filter "Name -like 'Team-*'"
```

---

## ORGANISATIE-UNITS (OU)

```powershell
# ── Aanmaken ──────────────────────────────────────────────────────────────────
New-ADOrganizationalUnit -Name "Nieuweafdeling" `
    -Path "OU=TechNova,DC=technova,DC=local"

# ── Opvragen ──────────────────────────────────────────────────────────────────
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=TechNova,DC=technova,DC=local"
```

---

## COMPUTERS

```powershell
Get-ADComputer -Filter *                           # Alle computers
Get-ADComputer -Identity "PC-STUDENT01"            # Eén computer
Get-ADComputer -Filter "Name -like 'DC*'"          # Servers beginnen met DC
```

---

## ACCOUNT STATUS CONTROLEREN

```powershell
# Geblokkeerde accounts
Search-ADAccount -LockedOut -SearchBase "OU=TechNova,DC=technova,DC=local"

# Uitgeschakelde accounts
Search-ADAccount -AccountDisabled -SearchBase "OU=TechNova,DC=technova,DC=local"

# Verlopen wachtwoorden
Search-ADAccount -PasswordExpired -SearchBase "OU=TechNova,DC=technova,DC=local"
```

---

## DOMEIN EN DNS

```powershell
Get-ADDomain                                        # Domeininfo
Get-ADDomainController                              # DC info
nslookup dc01.technova.local                       # DNS forward test
nslookup 192.168.100.11                            # DNS reverse test
ipconfig /flushdns                                  # DNS cache leegmaken
ipconfig /registerdns                               # DNS opnieuw registreren
```

---

## HANDIGE TRUCJES

```powershell
# Lijst exporteren naar CSV
Get-ADUser -Filter * -SearchBase "OU=Studenten,..." |
    Select Name, SamAccountName, Enabled |
    Export-Csv -Path "C:\Temp\studenten.csv" -Delimiter ";" -NoTypeInformation

# Bulk gebruikers aanmaken vanuit CSV
Import-Csv -Path "C:\Temp\nieuweusers.csv" -Delimiter ";" | ForEach-Object {
    New-ADUser -Name "$($_.Voornaam) $($_.Achternaam)" `
        -SamAccountName $_.Username -Enabled $true `
        -AccountPassword (ConvertTo-SecureString "Student2024!" -AsPlainText -Force)
}

# Script uitvoeren als beheerder (rechtermuisklik → Run as Administrator)
# OF in PowerShell:
Start-Process PowerShell -Verb RunAs
```

---

## FOUTCODES

| Foutmelding                                    | Betekenis & Oplossing                         |
|------------------------------------------------|-----------------------------------------------|
| `Access is denied`                             | Geen rechten → gebruik beheerdersaccount      |
| `The specified account already exists`         | Gebruikersnaam al in gebruik                  |
| `Cannot find an object with identity`          | Verkeerde gebruikersnaam/SamAccountName       |
| `The directory service is unavailable`         | AD service down → check DNS/DC               |
| `The password does not meet requirements`      | Wachtwoord te eenvoudig → gebruik cijfer+hoofdletter+speciaal |
