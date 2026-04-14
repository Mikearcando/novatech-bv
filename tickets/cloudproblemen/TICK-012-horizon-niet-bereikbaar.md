# TICK-012 — Horizon dashboard niet bereikbaar

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Cloudproblemen                |
| Prioriteit        | Kritiek                       |
| Moeilijkheidsgraad| ★★☆ (gemiddeld)              |
| Status            | Open                          |
| SLA               | Direct                        |

---

## Probleemomschrijving

Alle studenten melden gelijktijdig:

> "http://192.168.100.20/dashboard geeft een fout. Browser zegt:
> 'This site can't be reached — ERR_CONNECTION_REFUSED' of
> 'This page isn't working — 192.168.100.20 didn't send any data'"

---

## Verwachte analyse

Horizon draait via Apache2. Als de webpagina niet laadt:
1. Apache2 service is gestopt
2. DevStack VM is niet bereikbaar (ping test)
3. DevStack VM is herstart en services zijn niet terug opgestart

---

## Diagnosestappen

```bash
# Stap 1: Is de VM bereikbaar?
# Via Windows of Linux client:
ping 192.168.100.20

# Als ping werkt: VM is aan maar web service is down
# Als ping niet werkt: VM is uit of onbereikbaar

# Stap 2: SSH naar DevStack (als ping werkt)
ssh stack@192.168.100.20

# Stap 3: Apache2 status controleren
sudo systemctl status apache2

# Stap 4: OpenStack services controleren
source /opt/stack/devstack/openrc admin admin
openstack service list

# Stap 5: Poort 80 check (vanuit DevStack zelf)
curl -I http://localhost/dashboard
```

---

## Oplossing

```bash
# Scenario A: Apache2 gestopt
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2

# Test:
curl -s -o /dev/null -w "%{http_code}" http://localhost/dashboard
# Moet 200 of 302 teruggeven

# Scenario B: DevStack herstart vereist (services allemaal down)
/usr/local/bin/devstack-restart
# Wacht 5-15 minuten

# Scenario C: VM is uitgeschakeld
# Ga naar Proxmox UI: https://192.168.100.10:8006
# Selecteer devstack01 → Start
# Wacht tot VM opgestart is, dan:
ssh stack@192.168.100.20
/usr/local/bin/devstack-restart
```

---

## Communicatie naar gebruikers

Zodra je weet wat er aan de hand is, communiceer dit:

> "Het Horizon dashboard is tijdelijk niet bereikbaar. We werken aan een oplossing.
> Verwachte hersteltijd: [X] minuten. Ga alvast verder met documentatietaken."

---

## Verificatie

- [ ] `http://192.168.100.20/dashboard` laadt de inlogpagina
- [ ] Inloggen als `admin / TechNova2024!` werkt
- [ ] Studenten kunnen inloggen met hun eigen account
- [ ] VM's zijn zichtbaar in de instances lijst

---

## Leerdoel

- Webservice troubleshooting (Apache2)
- Prioriteitsafweging: kritieke service, snel communiceren
- Verschil VM-beschikbaarheid vs. service-beschikbaarheid
- DevStack lifecycle begrijpen
