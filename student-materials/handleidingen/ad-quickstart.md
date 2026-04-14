# Active Directory Quickstart — TechNova BV
## Voor junior systeembeheerders (leerjaar 1 & 2)

---

## Verbinding maken met de server

### Via Remote Desktop (RDP)
1. Open **Remote Desktop Connection** (zoek op `mstsc` in Start)
2. Computer: `192.168.100.11` of `dc01.technova.local`
3. Klik op **Connect**
4. Gebruikersnaam: `TECHNOVA\jouwgebruikersnaam`
5. Wachtwoord: `Student2024!`

### Via Server Manager (als je al bent ingelogd)
- Druk op de Windows-toets → Server Manager
- Ga naar **Tools** → **Active Directory Users and Computers**

---

## Active Directory Users and Computers — basishandelingen

### Gebruiker aanmaken

1. Open **Active Directory Users and Computers (ADUC)**
2. Navigeer in het linker paneel naar de juiste OU:
   - `technova.local` → `TechNova` → `Gebruikers` → `Studenten` → `Klas-XX`
3. Rechtsklik op de OU → **New** → **User**
4. Vul in:
   - **First name:** voornaam
   - **Last name:** achternaam
   - **User logon name:** gebruikersnaam (bv. `j.jansen`)
5. Klik **Next** → vul wachtwoord in → klik **Finish**

### Gebruiker aan groep toevoegen

1. Dubbelklik op de gebruiker in ADUC
2. Ga naar tabblad **Member Of**
3. Klik **Add**
4. Typ de groepsnaam (bv. `GRP-CloudUsers`) → klik **OK** → **OK**

**Of via PowerShell:**
```powershell
Add-ADGroupMember -Identity "GRP-CloudUsers" -Members "gebruikersnaam"
```

### Wachtwoord resetten

1. Rechtsklik op de gebruiker in ADUC
2. Klik **Reset Password**
3. Vul nieuw wachtwoord in
4. Vink aan: **User must change password at next logon** (indien gewenst)
5. Klik **OK**

**Of via PowerShell:**
```powershell
Set-ADAccountPassword -Identity "gebruikersnaam" `
    -NewPassword (ConvertTo-SecureString "NieuwWachtwoord1!" -AsPlainText -Force) `
    -Reset
```

### Account uitschakelen (bij vertrokken medewerker)

1. Rechtsklik op de gebruiker in ADUC
2. Klik **Disable Account**
3. **Optioneel:** verplaats naar OU=Uitgeschakeld

**Of via PowerShell:**
```powershell
Disable-ADAccount -Identity "gebruikersnaam"
Move-ADObject -Identity "CN=Naam,OU=Studenten,...,DC=technova,DC=local" `
    -TargetPath "OU=Uitgeschakeld,OU=Gebruikers,OU=TechNova,DC=technova,DC=local"
```

### Account ontgrendelen (na te veel foutieve inlogpogingen)

```powershell
Unlock-ADAccount -Identity "gebruikersnaam"
# Controleer of ontgrendeld:
Get-ADUser -Identity "gebruikersnaam" -Properties LockedOut | Select LockedOut
```

---

## PowerShell gebruiken voor AD

### Verbinding maken met AD via PowerShell

```powershell
# PowerShell openen als beheerder op DC01
# Importeer AD module
Import-Module ActiveDirectory

# Controleer of het werkt
Get-ADDomain
```

### Gebruikersinformatie opvragen

```powershell
# Eén gebruiker opzoeken
Get-ADUser -Identity "jjansen" -Properties *

# Alle studenten opzoeken
Get-ADUser -Filter * -SearchBase "OU=Studenten,OU=Gebruikers,OU=TechNova,DC=technova,DC=local" |
    Select-Object Name, SamAccountName, Enabled |
    Format-Table -AutoSize

# Gebruiker zoeken op naam
Get-ADUser -Filter "Name -like '*Jansen*'" | Select-Object Name, SamAccountName
```

### Groepslidmaatschap controleren

```powershell
# Leden van een groep opvragen
Get-ADGroupMember -Identity "Team-Infra-Alpha" | Select-Object Name, SamAccountName

# Groepen van een gebruiker opvragen
Get-ADPrincipalGroupMembership -Identity "jjansen" | Select-Object Name
```

---

## Veelgemaakte fouten

| Fout                                   | Oorzaak                              | Oplossing                                    |
|----------------------------------------|--------------------------------------|----------------------------------------------|
| "Access is denied"                     | Geen rechten voor deze actie        | Controleer of je de juiste account gebruikt   |
| "The specified account already exists" | Gebruikersnaam al in gebruik        | Kies een andere gebruikersnaam                |
| "The object already exists"            | OU bestaat al                       | Verwijder of gebruik bestaande OU             |
| Gebruiker kan niet inloggen            | Account uitgeschakeld of geblokkeerd | Controleer status in ADUC                    |
| "Cannot find an object with identity"  | Verkeerde gebruikersnaam             | Controleer spelling met `Get-ADUser -Filter *` |

---

## Handige commando's — spiekbriefje

```powershell
# Gebruiker aanmaken
New-ADUser -Name "Jan Jansen" -SamAccountName "jjansen" -Enabled $true `
    -AccountPassword (ConvertTo-SecureString "Student2024!" -AsPlainText -Force)

# Gebruiker uitschakelen
Disable-ADAccount -Identity "gebruikersnaam"

# Gebruiker inschakelen
Enable-ADAccount -Identity "gebruikersnaam"

# Wachtwoord resetten
Set-ADAccountPassword -Identity "gebruikersnaam" -Reset `
    -NewPassword (ConvertTo-SecureString "NieuwWw1!" -AsPlainText -Force)

# Gebruiker ontgrendelen
Unlock-ADAccount -Identity "gebruikersnaam"

# Aan groep toevoegen
Add-ADGroupMember -Identity "Groepnaam" -Members "gebruikersnaam"

# Uit groep verwijderen
Remove-ADGroupMember -Identity "Groepnaam" -Members "gebruikersnaam" -Confirm:$false

# Gebruiker zoeken
Get-ADUser -Filter "SamAccountName -eq 'jjansen'"

# Alle groepsleden
Get-ADGroupMember -Identity "Groepnaam"
```
