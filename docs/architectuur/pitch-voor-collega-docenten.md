# TechNova BV Simulatie — Pitch voor collega-docenten
## Waarom dit project een waardevolle aanvulling is op ons MBO ICT curriculum

---

## Waar we nu staan

Onze studenten leren de theorie van netwerken, operating systems en virtualisatie.
Ze weten wat een hypervisor is. Ze weten wat een domein is.
Ze hebben net een Windows Server project afgerond.

Maar vraag ze: *"Maak een gebruiker aan voor een nieuwe medewerker"* — en velen weten niet
waar ze moeten beginnen. Niet omdat ze het niet geleerd hebben, maar omdat ze het
nooit écht hebben hoeven **doen**.

Dit project verandert dat.

---

## Het idee in één zin

> Studenten werken een volledige sprint lang als junior systeembeheerder bij een fictief
> ICT-bedrijf, in een echte technische omgeving, met echte tickets en echte tooling.

---

## Wat de omgeving bevat

De simulatie draait op een server die wij als docenten vooraf inrichten:

- Een **Windows Active Directory** omgeving met domein `technova.local`
- Een **OpenStack private cloud** (Horizon dashboard, VM's aanmaken, netwerken)
- **45 studentaccounts** in beide systemen — klaar voor gebruik
- **34 realistische tickets** verdeeld over 8 categorieën
- **9 Scrum-teams** van 5 studenten elk, met rolverdeling

Studenten loggen in, pakken een ticket, lossen het op, documenteren het.
Net als in een echt ICT-bedrijf.

---

## Wat studenten concreet oefenen

| Vaardigheid | Hoe |
|---|---|
| Active Directory gebruikersbeheer | Accounts aanmaken, uitschakelen, rechten toewijzen via ADUC en PowerShell |
| Probleemanalyse | Tickets zonder kant-en-klaar antwoord — zelf uitzoeken |
| Documenteren | Elk ticket vraagt een probleemomschrijving, analyse en verificatie |
| Samenwerken | Teams van 5, eigen rolverdeling, dagelijkse standup |
| Communiceren | Sprint review: live demonstratie voor de klas |
| Cloud beheer | VM's aanmaken en beheren via een webdashboard |
| Netwerk troubleshooting | DNS, DHCP, IP-problemen diagnosticeren |
| Werken met scripts | PowerShell voor AD, Bash voor Linux |

Dit zijn precies de vaardigheden die werkgevers noemen als ze zeggen:
*"MBO-studenten weten de theorie maar kunnen het niet toepassen."*

---

## Waarom dit beter werkt dan losse opdrachten

### Het probleem met traditionele ICT-opdrachten

Een opdracht als *"Maak drie gebruikers aan in AD"* leert studenten de handeling.
Het leert ze niet:
- Waarom je die gebruiker aanmaakt
- In welke OU die hoort
- Welke groep erbij hoort
- Wat je doet als het misgaat
- Hoe je het documenteert voor een collega

### De simulatie pakt dit anders aan

Een ticket in TechNova BV ziet er zo uit:

> *"HR meldt: Lena Visser begint maandag als stagiair bij IT Operations.
> Zij heeft toegang nodig tot het domein en het OpenStack dashboard.
> Zij wordt ingedeeld bij Team Cloud-Alpha. Graag zo snel mogelijk."*

Nu moeten studenten zelf nadenken:
- Welke OU? Welke groep? Welk wachtwoord?
- Hoe maak ik haar ook aan in OpenStack?
- Hoe verifieer ik dat het werkt?
- Hoe documenteer ik dit voor mijn collega?

Dat is de stap van *kennis* naar *vakmanschap*.

---

## Wat dit oplevert voor studenten

### Technisch
- Ze begrijpen hoe AD, DNS en cloud met elkaar samenhangen
- Ze kunnen zelfstandig problemen analyseren in plaats van gokken
- Ze kennen de tooling: PowerShell, OpenStack CLI, Horizon
- Ze hebben bewijs van hun werk: ingevulde ticketformulieren en handleidingen

### Professioneel
- Ze weten wat Scrum is — niet uit een boek, maar uit ervaring
- Ze hebben een sprint review gepresenteerd voor een publiek
- Ze hebben samengewerkt onder tijdsdruk met een gedeeld doel
- Ze hebben een opleverdocument geschreven

### Voor hun CV en stage
Ze kunnen straks zeggen:
*"Ik heb gewerkt in een Windows Active Directory omgeving,
gebruikersbeheer gedaan via PowerShell, en VM's beheerd via OpenStack."*

Dat is concreet. Dat is toetsbaar. Dat geeft stageaanbieders vertrouwen.

---

## Wat dit vraagt van ons als docenten

### Voorbereiding (eenmalig)
De omgeving wordt vooraf ingericht door de projectverantwoordelijke docent.
Er zijn kant-en-klare scripts voor alles:
- AD opzetten: 3 PowerShell scripts uitvoeren
- OpenStack opzetten: 1 Bash script uitvoeren
- Studenten aanmaken: 1 CSV inladen

Tijdsinvestering voorbereiding: **één dag**.

### Tijdens de sprint
De docent is aanwezig als projectleider/CTO:
- Dagstarts begeleiden (15 minuten)
- Blokkades oppakken
- Beoordelen via observatie (rubric ligt klaar)

Er is geen nieuw lesmateriaal nodig.
Er zijn geen ingewikkelde tools nodig.
Alles draait op onze eigen hardware.

### Beheerlast
Er zijn dagelijkse healthcheck-scripts die in 2 minuten laten zien of alles werkt.
Bij een storing: één commando of een Proxmox snapshot herstellen.

---

## Wat dit kost

| Post | Kosten |
|---|---|
| Software (Proxmox, Ubuntu, DevStack) | **€0** |
| Windows Server 2022 (Evaluation licentie, 180 dagen) | **€0** |
| Extra hardware (als we een bestaande server gebruiken) | **€0** |
| Voorbereiding docent (eenmalig) | ~1 dag |

Dit project is volledig uitgewerkt en klaar voor gebruik.
Alle scripts, handleidingen, tickets, templates en het beoordelingsmodel liggen er.

---

## Wat we er voor terugkrijgen

- Studenten die **aantoonbaar** zelfstandig kunnen werken in een IT-omgeving
- Een beoordelingsmoment dat **observeerbaar en reproduceerbaar** is
- Een werkwijze die aansluit op wat het **werkveld verwacht** (Scrum, tickets, documentatie)
- Materiaal dat we elk jaar kunnen **hergebruiken en uitbreiden**
- Een project dat studenten **intrinsiek motiveert** — het voelt als echt werk

---

## Aanpak: starten met één klas

We hoeven niet meteen met 45 studenten te beginnen.

**Voorstel:**
1. Pilot met één klas of één groep van 15-20 studenten
2. Evaluatie na de sprint: wat werkte, wat niet
3. Aanpassen en herhalen

De omgeving schaalt mee. Alles is modulair opgezet.

---

## Conclusie

Onze studenten verlaten school met kennis.
Dit project geeft ze ook **ervaring**.

Het verschil tussen een student die zegt *"ik weet wat Active Directory is"*
en een student die zegt *"ik heb zelfstandig gebruikersbeheer gedaan, storingen opgelost
en dat gedocumenteerd in een professionele omgeving"* — dat verschil maken wij.

Dit project is klaar. De handleiding staat er. De scripts werken.
We hoeven het alleen nog maar te starten.

---

*Vragen of interesse? Neem contact op met de projectverantwoordelijke docent.*

*Alle projectmaterialen staan in de map `sprint 9` en zijn direct bruikbaar.*
