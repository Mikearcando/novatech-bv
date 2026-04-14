# Active Directory Opdrachten — TechNova BV
## Leerjaar 1 & 2 | Sprint 1

Alle opdrachten voer je uit in de TechNova leeromgeving.
Verbind eerst via RDP met DC01 (`192.168.100.11`).
**Documenteer elke stap die je uitvoert in een ticketformulier.**

---

## Opdracht A01 — Nieuwe medewerker aanmaken ★☆☆

**Context:**  
HR heeft gemeld dat Nadia Boussaid morgen begint als junior medewerker bij de IT afdeling. Ze heeft een account nodig.

**Jouw taak:**
1. Maak een AD-account aan voor Nadia Boussaid in de OU `Studenten > Klas-1A`
2. Gebruikersnaam: `nboussaid`
3. Wachtwoord: `Student2024!`
4. Voeg haar toe aan de groep `Team-Infra-Alpha`
5. Voeg haar toe aan de groep `GRP-CloudUsers`

**Verificatie:**  
Controleer via ADUC dat het account bestaat, actief is en lid is van beide groepen.

**Documenteer:**  
Noteer welke stappen je hebt uitgevoerd en de PowerShell-commando's die je gebruikte.

---

## Opdracht A02 — Medewerker in dienst gewijzigd ★☆☆

**Context:**  
Medewerker Tim Bakker is gepromoveerd. Hij gaat nu als beheerder werken en heeft andere groepsrechten nodig.

**Jouw taak:**
1. Verwijder Tim Bakker (`tbakker`) uit de groep `Team-Infra-Alpha`
2. Voeg hem toe aan de groep `GRP-ServerAdmins`
3. Wijzig zijn functietitel in AD: `Title` → `Systeembeheerder`
4. Wijzig zijn afdeling: `Department` → `IT Beheer`

**PowerShell commando voor functietitel:**
```powershell
Set-ADUser -Identity "tbakker" -Title "Systeembeheerder" -Department "IT Beheer"
```

**Verificatie:**  
Open ADUC → zoek tbakker → tabblad General en Organization.

---

## Opdracht A03 — Medewerker uit dienst ★☆☆

**Context:**  
Jens de Boer (gebruikersnaam: `jdeboer`) heeft TechNova verlaten. Beveiligingsbeleid schrijft voor: account direct uitschakelen en verplaatsen.

**Jouw taak:**
1. Schakel het account van `jdeboer` uit
2. Verplaats het account naar `OU=Uitgeschakeld`
3. Noteer de datum van uitschakeling in de account-beschrijving (Description)

**Commando:**
```powershell
# Stap 1: Uitschakelen
Disable-ADAccount -Identity "jdeboer"

# Stap 2: Beschrijving bijwerken
Set-ADUser -Identity "jdeboer" -Description "Uitgeschakeld op $(Get-Date -Format 'dd-MM-yyyy') — medewerker vertrokken"

# Stap 3: Verplaatsen
# Gebruik ADUC (rechtsklik → Move) of zoek eerst de DN op:
Get-ADUser -Identity "jdeboer" | Select DistinguishedName
```

---

## Opdracht A04 — Bulk gebruikers aanmaken vanuit CSV ★★★

**Context:**  
HR levert een CSV aan met 5 nieuwe studenten die beginnen volgende week.

**Jouw taak:**
1. Maak een CSV-bestand `nieuw-studenten.csv` aan met de volgende 5 personen:

```csv
Voornaam;Achternaam;Klas;Team
Emma;Visser;Klas-1A;Cloud-Alpha
Lucas;Smits;Klas-1A;Cloud-Alpha
Nour;El Amrani;Klas-1B;Infra-Beta
Pieter;Hermans;Klas-1B;Cloud-Beta
Zoe;Vandenberghe;Klas-2A;Ops-Alpha
```

2. Schrijf of gebruik een PowerShell-script om alle 5 accounts aan te maken
3. Voeg alle 5 toe aan de groep `DL-AlleStudenten`
4. Controleer of alle accounts actief zijn

**Aandachtspunt:** Genereer de gebruikersnaam als eerste letter voornaam + achternaam (bv. `evisser`).

---

## Opdracht A05 — OU aanmaken voor nieuw project ★★☆

**Context:**  
TechNova start een nieuw project: "CloudMigration". Er moet een aparte OU komen voor de projectmedewerkers.

**Jouw taak:**
1. Maak een nieuwe OU aan: `OU=CloudMigration` onder `OU=Teams,OU=TechNova`
2. Maak een beveiligingsgroep aan: `Team-CloudMigration` in de nieuwe OU
3. Voeg 3 bestaande studenten toe aan deze groep (kies zelf)
4. Maak een nieuw account aan in deze OU voor een fictieve projectleider

**Commando's:**
```powershell
# OU aanmaken
New-ADOrganizationalUnit -Name "CloudMigration" `
    -Path "OU=TechNova,DC=technova,DC=local"

# Groep aanmaken
New-ADGroup -Name "Team-CloudMigration" `
    -GroupScope Global -GroupCategory Security `
    -Path "OU=CloudMigration,OU=TechNova,DC=technova,DC=local"
```

---

## Opdracht A06 — GPO verkennen ★★☆

**Context:**  
Een nieuwe medewerker vraagt: "Waarom kan ik geen programma's installeren?" Jij moet uitleggen welk beleid dit regelt.

**Jouw taak:**
1. Open de **Group Policy Management Console (GPMC)** op DC01
   - Server Manager → Tools → Group Policy Management
2. Navigeer naar `Forest > Domains > technova.local`
3. Bekijk welke GPO's er zijn
4. Zoek de GPO die softwareinstallatie beperkt (of beschrijf welke GPO dit ZOU moeten doen)
5. Schrijf een document met:
   - Naam van de GPO
   - Aan welke OU gekoppeld
   - Welke instelling precies actief is
   - Hoe je kunt controleren of de GPO actief is op een gebruiker

**Tip:** Gebruik op de client: `gpresult /r` of `gpresult /h C:\Temp\gpo-rapport.html`

---

## Opdracht A07 — GPO aanmaken voor bureaubladachtergrond ★★★

**Context:**  
De directie van TechNova wil dat alle studenten hetzelfde bureaubladachtergrond hebben met het TechNova logo.

**Jouw taak:**
1. Maak een nieuw afbeeldingsbestand aan (kopieer een willekeurig plaatje naar `\\DC01\SYSVOL\technova.local\scripts\bg.jpg`)
2. Maak een nieuwe GPO aan: `GPO-TechNova-Achtergrond`
3. Configureer de GPO:
   - User Configuration → Administrative Templates → Desktop → Desktop
   - Wallpaper Name: het pad naar je afbeelding
   - Wallpaper Style: Fill
4. Koppel de GPO aan `OU=Studenten`
5. Test door opnieuw in te loggen als een student
6. Gebruik `gpupdate /force` als de GPO niet direct werkt

---

## Documentatievereiste

Elke opdracht lever je op met:
- [ ] Naam van de opdracht
- [ ] Welke stappen je hebt uitgevoerd (in eigen woorden)
- [ ] De PowerShell-commando's die je hebt gebruikt
- [ ] Hoe je hebt geverifieerd dat het werkt
- [ ] Wat je moeilijk vond en hoe je het opgelost hebt
