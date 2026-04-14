# GPO Overzicht — TechNova BV

## GPO 1: GPO-Wachtwoordbeleid

**Koppeling:** Domein technova.local  
**Doel:** Basisbeveiligingsbeleid voor alle accounts

### Instellingen
```
Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy

Enforce password history:       3 passwords remembered
Maximum password age:           0 (never expires — voor leeromgeving)
Minimum password age:           0 days
Minimum password length:        8 characters
Password must meet complexity:  Enabled
Store passwords using reversible encryption: Disabled
```

### Account Lockout (bewust NIET ingesteld voor onderwijs)
```
Account lockout threshold:      0 (uitgeschakeld)
# Reden: studenten vergrendelen hun account te makkelijk bij typefouten
# Docent handmatig ontgrendelen kost te veel tijd
```

---

## GPO 2: GPO-Student-Basisprofiel

**Koppeling:** OU=Studenten  
**Doel:** Standaard werkomgeving voor studenten, geen onnodige afleiding

### Bureaubladachtergrond instellen
```
User Configuration > Administrative Templates > Desktop > Desktop

Desktop Wallpaper: Enabled
  Wallpaper Name:  \\DC01\SYSVOL\technova.local\wallpaper\technova-bg.jpg
  Wallpaper Style: Fill
```

### Configuratiescherm beperken
```
User Configuration > Administrative Templates > Control Panel

Prohibit access to Control Panel and PC settings: Enabled
```

### Taakbeheer uitschakelen (optioneel, streng)
```
User Configuration > Administrative Templates > System > Ctrl+Alt+Del Options

Remove Task Manager: Disabled
# Aanbeveling: laat dit AAN, studenten moeten leren met services te werken
```

---

## GPO 3: GPO-Schermvergrendeling

**Koppeling:** OU=TechNova  
**Doel:** Automatische vergrendeling bij inactiviteit

### Instellingen
```
Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options

Interactive logon: Machine inactivity limit: 1800 seconds (30 minuten)

User Configuration > Administrative Templates > Control Panel > Personalization

Enable screen saver:         Enabled
Screen saver timeout:        1800 seconds
Force specific screen saver: Enabled
  screensaver: scrnsave.scr (leeg scherm)
Password protect screen saver: Enabled
```

---

## GPO 4: GPO-RDP-Instellingen

**Koppeling:** OU=Servers  
**Doel:** Remote Desktop correct instellen

### Instellingen
```
Computer Configuration > Administrative Templates > Windows Components > Remote Desktop Services

Allow users to connect remotely using Remote Desktop Services: Enabled
Set time limit for active but idle Remote Desktop Services sessions: 2 hours
Terminate session when time limits are reached: Enabled
```

---

## GPO 5: GPO-Docenten-Uitgebreid

**Koppeling:** OU=Docenten  
**Doel:** Geen beperkingen voor docenten

### Instellingen
```
User Configuration > Administrative Templates > Control Panel
  Prohibit access to Control Panel: Disabled

User Configuration > Administrative Templates > System
  Prevent access to registry editing tools: Disabled
  Prevent access to the command prompt: Disabled
```

---

## GPO aanmaken — PowerShell commando's

```powershell
# GPO aanmaken
New-GPO -Name "GPO-Student-Basisprofiel" -Comment "Standaard profiel voor studenten TechNova"

# GPO koppelen aan OU
New-GPLink -Name "GPO-Student-Basisprofiel" `
    -Target "OU=Studenten,OU=Gebruikers,OU=TechNova,DC=technova,DC=local" `
    -LinkEnabled Yes

# GPO-instellingen bekijken (HTML rapport)
Get-GPOReport -Name "GPO-Student-Basisprofiel" -ReportType HTML -Path "C:\Temp\gpo-rapport.html"

# Alle GPO's en hun koppelingen tonen
Get-GPO -All | Select-Object DisplayName, GpoStatus | Format-Table -AutoSize

# GPO geforceerd toepassen op client (als student klaagt over instelling)
gpupdate /force
```

## Troubleshooting GPO

| Probleem                           | Diagnose                     | Oplossing                                   |
|------------------------------------|------------------------------|---------------------------------------------|
| GPO werkt niet op gebruiker        | `gpresult /r`                | Controleer koppeling, OU-locatie gebruiker  |
| Instelling niet toegepast          | `gpresult /h C:\Temp\gpo.html` | Open HTML, zoek conflicterende GPO       |
| GPO werkt op computer maar niet user | Security filtering?         | Controleer ACL op GPO object               |
| Gewenste GPO overschreven          | Hogere prioriteit GPO        | GPO volgorde aanpassen in GPMC             |
