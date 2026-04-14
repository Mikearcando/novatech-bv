# TICK-004 — Gebruiker kan niet inloggen op Horizon (OpenStack)

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Loginproblemen / Cloudproblemen|
| Prioriteit        | Hoog                          |
| Moeilijkheidsgraad| ★★☆ (gemiddeld)              |
| Status            | Open                          |
| SLA               | Vandaag                       |

---

## Probleemomschrijving

Student Tim Bakker (tbakker) stuurt een mail:

> "Ik kan wel inloggen op Windows (TECHNOVA\tbakker werkt prima) maar als ik
> naar http://192.168.100.20/dashboard ga en mijn gebruikersnaam en wachtwoord
> invul, krijg ik de fout: 'Invalid credentials'. Domain staat op 'default'.
> Anderen in mijn team hebben geen problemen. Wat doe ik fout?"

---

## Verwachte analyse

Loginproblemen op Horizon hebben meerdere mogelijke oorzaken:
1. OpenStack account bestaat niet
2. Verkeerd domein ingevoerd in Horizon login
3. Account uitgeschakeld in OpenStack
4. Gebruiker zit niet in het juiste project
5. Wachtwoord niet gesynchroniseerd (AD-wachtwoord ≠ OpenStack-wachtwoord)

---

## Diagnosecommando's

```bash
# Op DevStack VM, als admin:
source /opt/stack/devstack/openrc admin admin

# 1. Bestaat het account?
openstack user show tbakker

# 2. Is het account ingeschakeld?
openstack user show tbakker -f value -c enabled
# Moet 'True' zijn

# 3. Is de gebruiker lid van een project?
openstack role assignment list --user tbakker
# Moet minstens één regel tonen

# 4. Wachtwoord resetten naar bekende waarde
openstack user set --password "Student2024!" tbakker
```

---

## Oplossing (afhankelijk van diagnose)

```bash
# Scenario A: Account bestaat niet
openstack user create \
    --domain default \
    --password "Student2024!" \
    --enable \
    tbakker
openstack role add --project team-infra-alpha --user tbakker member

# Scenario B: Account uitgeschakeld
openstack user set --enable tbakker

# Scenario C: Niet in project
openstack role add --project team-infra-alpha --user tbakker member

# Scenario D: Verkeerd wachtwoord
openstack user set --password "Student2024!" tbakker
```

---

## Oorzaak melden aan gebruiker

> "Beste Tim, je OpenStack account was niet gekoppeld aan jouw team-project.
> Ik heb je toegevoegd aan het project team-infra-alpha met de rol 'member'.
> Probeer nu opnieuw in te loggen op http://192.168.100.20/dashboard
> met gebruikersnaam: tbakker, wachtwoord: Student2024!, domain: default."

---

## Verificatie

- [ ] `openstack user show tbakker` toont `enabled: True`
- [ ] `openstack role assignment list --user tbakker` toont projectkoppeling
- [ ] Gebruiker kan inloggen op Horizon
- [ ] Gebruiker kan eigen project zien

---

## Leerdoel

- Verschil AD-authenticatie vs. OpenStack-authenticatie begrijpen
- OpenStack gebruikersbeheer via CLI
- Systematisch troubleshooten: elimineer oorzaken één voor één
