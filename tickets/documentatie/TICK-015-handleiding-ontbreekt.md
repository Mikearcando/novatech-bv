# TICK-015 — Documentatie ontbreekt voor nieuwe medewerker onboarding

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Documentatie                  |
| Prioriteit        | Laag                          |
| Moeilijkheidsgraad| ★★☆ (gemiddeld)              |
| Status            | Open                          |
| SLA               | Einde sprint                  |

---

## Probleemomschrijving

> "We hebben geen standaard onboarding handleiding voor nieuwe medewerkers.
> Elke keer als er iemand nieuw begint, moet iemand handmatig uitleggen hoe alles werkt.
> Dit kost veel tijd. Maak een duidelijke handleiding die een nieuwe medewerker
> zelfstandig kan volgen om zijn/haar omgeving in te richten."
> — Projectleider / CTO

---

## Wat er opgeleverd moet worden

Een Markdown-document (`onboarding-nieuwe-medewerker.md`) met:
1. Welkom bij TechNova BV — korte introductie
2. Hoe inloggen op Windows (domeinnaam, wachtwoord)
3. Hoe verbinden met de serveromgeving (RDP naar DC01)
4. Hoe inloggen op het OpenStack dashboard (Horizon URL, credentials)
5. Overzicht van de tools die beschikbaar zijn
6. De 5 belangrijkste regels voor systeembeheer bij TechNova
7. Contactpersonen bij vragen

---

## Richtlijnen voor het schrijven

- Schrijf voor iemand die ICT kent maar jouw omgeving nog nooit heeft gezien
- Gebruik stap-voor-stap instructies met nummering
- Voeg concrete voorbeelden toe (echte IP-adressen, echte namen)
- Gebruik korte zinnen
- Voeg een "veelgestelde vragen" sectie toe

---

## Voorbeeld structuur

```markdown
# Onboarding Handleiding — TechNova BV

## 1. Welkom
...

## 2. Inloggen op Windows
Server: 192.168.100.11
Domein: TECHNOVA
Gebruikersnaam: [jouw gebruikersnaam]
Wachtwoord: Student2024!

Stap 1: Open Remote Desktop Connection (Start → Zoek op 'mstsc')
Stap 2: ...

## 3. OpenStack Dashboard
URL: http://192.168.100.20/dashboard
...
```

---

## Verificatie

- [ ] Document aanwezig in `docs/handleidingen/`
- [ ] Alle 7 onderdelen aanwezig
- [ ] Getest door een andere student: "Kun jij zonder hulp inloggen met deze handleiding?"
- [ ] Geen spelfouten
- [ ] Opgeleverd in Markdown formaat

---

## Leerdoel

- Technisch schrijven voor collega's
- Kennisoverdracht: kennis vastleggen zodat anderen het kunnen gebruiken
- Handleiding testen door peer review
