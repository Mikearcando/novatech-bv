# TICK-016 — Incidentrapport schrijven na storing

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Documentatie                  |
| Prioriteit        | Middel                        |
| Moeilijkheidsgraad| ★★☆ (gemiddeld)              |
| Status            | Open                          |
| SLA               | Morgen ochtend                |

---

## Probleemomschrijving

> "Gisteren is het Horizon dashboard 45 minuten onbereikbaar geweest (09:30-10:15).
> Dit heeft impact gehad op alle 45 studenten. Management wil een incidentrapport
> met tijdlijn, oorzaak, en verbetermaatregelen. Lever dit op vóór morgen 09:00."

---

## Template voor het incidentrapport

Gebruik onderstaande structuur en vul alle secties in. Fictief uitwerken is OK.

```markdown
# Incidentrapport — [Incident naam]

## Incidentgegevens
| Veld            | Waarde              |
|-----------------|---------------------|
| Incident ID     | INC-2025-001        |
| Datum           | [datum]             |
| Tijd start      | 09:30               |
| Tijd opgelost   | 10:15               |
| Duur storing    | 45 minuten          |
| Ernst           | Hoog (alle gebruikers getroffen) |
| Gerapporteerd door | [naam]           |
| Opgelost door   | [naam]              |

## Samenvatting
[Één of twee zinnen: wat is er gebeurd en wat was de impact?]

## Tijdlijn
| Tijd  | Actie / Bevinding                          |
|-------|--------------------------------------------|
| 09:30 | Eerste melding ontvangen van student       |
| 09:35 | Begin diagnose: ping test → VM bereikbaar  |
| 09:40 | Apache2 gestopt gevonden                   |
| 09:42 | Apache2 herstart: `sudo systemctl restart apache2` |
| 09:43 | Horizon bereikbaar — melding naar studenten|
| 10:15 | Incident gesloten na verificatie           |

## Oorzaak
[Wat was de technische oorzaak? Wees specifiek.]

## Oplossing
[Welke stappen zijn uitgevoerd om het op te lossen?]

## Impact
- Aantal getroffen gebruikers: 45
- Getroffen systemen: Horizon dashboard, OpenStack API
- Niet getroffen: Active Directory, DNS, RDP toegang

## Verbetermaatregelen
| Maatregel                           | Verantwoordelijke | Deadline |
|-------------------------------------|-------------------|----------|
| Apache2 instellen op autostart      | [naam]            | [datum]  |
| Dagelijkse monitoring toevoegen     | [naam]            | [datum]  |

## Goedkeuring
| Rol             | Naam          | Datum    |
|-----------------|---------------|----------|
| Opgesteld door  | [naam]        | [datum]  |
| Gereviewed door | [docent naam] | [datum]  |
```

---

## Beoordelingscriteria

- Tijdlijn is volledig en logisch
- Oorzaak is technisch correct beschreven
- Verbetermaatregelen zijn concreet en uitvoerbaar
- Taalgebruik is professioneel
- Document is opgemaakt in Markdown

---

## Leerdoel

- Incidentrapportage schrijven (standaard in IT-beheer)
- Tijdlijn reconstrueren
- Root cause analysis (wat was de echte oorzaak?)
- Verbetermaatregelen formuleren
