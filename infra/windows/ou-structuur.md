# Active Directory OU-structuur — TechNova BV

## Volledige OU-boom

```
DC=technova,DC=local
└── OU=TechNova
    ├── OU=Gebruikers
    │   ├── OU=Studenten
    │   │   ├── OU=Klas-1A        (15 studenten)
    │   │   ├── OU=Klas-1B        (15 studenten)
    │   │   └── OU=Klas-2A        (15 studenten)
    │   ├── OU=Docenten           (docent accounts)
    │   ├── OU=Medewerkers        (fictieve TechNova medewerkers)
    │   └── OU=Uitgeschakeld      (verlopen / vertrokken accounts)
    ├── OU=Groepen
    │   ├── OU=Scrum-Teams        (1 groep per team)
    │   ├── OU=Toegang            (resource toegangsgroepen)
    │   └── OU=Rollen             (rolgebaseerde groepen)
    ├── OU=Computers
    │   ├── OU=Werkstations
    │   └── OU=Laptops
    ├── OU=Servers                (DC01, devstack01 computerobjecten)
    └── OU=Serviceaccounts        (serviceaccounts voor applicaties)
```

## Groepen overzicht

### Scrum-Teams (OU=Scrum-Teams)
| Groepnaam          | Type     | Leden (indicatief) |
|--------------------|----------|--------------------|
| Team-Infra-Alpha   | Security | 5 studenten        |
| Team-Infra-Beta    | Security | 5 studenten        |
| Team-Cloud-Alpha   | Security | 5 studenten        |
| Team-Cloud-Beta    | Security | 5 studenten        |
| Team-Ops-Alpha     | Security | 5 studenten        |
| Team-Ops-Beta      | Security | 5 studenten        |
| Team-Support       | Security | 5 studenten        |
| Team-Security      | Security | 5 studenten        |
| Team-DevOps        | Security | 5 studenten        |

### Toegangsgroepen (OU=Toegang)
| Groepnaam              | Doel                                      |
|------------------------|-------------------------------------------|
| GRP-CloudUsers         | Toegang Horizon dashboard                 |
| GRP-ServerAdmins       | Beheerdersrechten Windows Servers         |
| GRP-FileShare-Lezen    | Leestoegang gedeelde mappen               |
| GRP-FileShare-Schrijven| Schrijftoegang gedeelde mappen            |
| GRP-RDP-Users          | Remote Desktop toegang                    |
| GRP-Docenten           | Docentenrechten (uitgebreid)              |

## GPO-koppelingen

| GPO-naam                      | Gekoppeld aan              | Instelling                            |
|-------------------------------|----------------------------|---------------------------------------|
| GPO-Student-Basisprofiel      | OU=Studenten               | Standaard bureaubladachtergrond, geen controlpanel |
| GPO-Wachtwoordbeleid          | OU=TechNova (domein niveau)| Min 8 tekens, complexiteit aan        |
| GPO-Schermvergrendeling       | OU=TechNova                | Vergrendeling na 30 minuten inactiviteit |
| GPO-Software-Restricties      | OU=Studenten               | Geen executable installatie           |
| GPO-Docenten-Uitgebreid       | OU=Docenten                | Geen restricties                      |

## Account instellingen studenten

| Instelling               | Waarde                   | Reden                              |
|--------------------------|--------------------------|------------------------------------|
| Wachtwoord verloopt      | Nooit                    | Omgeving werkt zonder verloopdatum |
| Account vergrendeling    | Uitgeschakeld            | Voorkomt lockout bij typefouten    |
| Wachtwoord wijzigen      | Niet verplicht           | Vereenvoudigt beheer omgeving      |
| Inloguren                | Geen beperking           | Flexibele lestijden                |
| Inloggen op             | Alleen domeincomputers   | Standaard domeinbeleid             |

## Standaard wachtwoorden

| Account type    | Wachtwoord     | Wijzigen?  |
|-----------------|----------------|------------|
| Studenten       | Student2024!   | Nee        |
| Docent          | Docent2024!    | Aanbevolen |
| Administrator   | Admin2024!     | Ja, direct |
| Serviceaccounts | Service2024!   | Nee        |

**Beveiligingsnoot:** Dit zijn onderwijswachtwoorden voor een afgesloten leeromgeving.
Gebruik NOOIT deze wachtwoorden in productieomgevingen.
