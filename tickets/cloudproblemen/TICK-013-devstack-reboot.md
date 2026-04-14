# TICK-013 — Alle OpenStack services neer na reboot DevStack VM

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Cloudproblemen                |
| Prioriteit        | Kritiek                       |
| Moeilijkheidsgraad| ★★★ (gevorderd)              |
| Status            | Open                          |
| SLA               | Direct                        |

---

## Probleemomschrijving

DevStack VM is herstart (gepland of ongepland). Na herstart:

> "Horizon laadt niet. OpenStack CLI geeft foutmeldingen.
> `openstack service list` geeft: 'Failed to discover available identity versions'
> De DevStack VM is wel bereikbaar via SSH en ping."

---

## Achtergrond

DevStack is een **ontwikkelomgeving**, niet een productiesysteem. Na een reboot starten de OpenStack services NIET automatisch op. Dit is normaal gedrag. Je moet `rejoin-stack.sh` uitvoeren om ze te herstarten.

---

## Diagnosestappen

```bash
ssh stack@192.168.100.20

# Stap 1: Services check
systemctl is-active apache2 || echo "Apache2 DOWN"
systemctl is-active memcached || echo "Memcached DOWN"

# Stap 2: Screen sessies (DevStack draait normaal in screen)
screen -ls
# Als er geen sessies zijn: DevStack is niet actief

# Stap 3: Keystone check
curl -s http://localhost/identity/ | python3 -m json.tool || echo "Keystone reageert niet"

# Stap 4: Logs bekijken
ls -la /opt/stack/logs/
# Zijn er recente logs?
```

---

## Oplossing

```bash
# Als stack gebruiker:
sudo -u stack bash   # Schakel naar stack user als je root/andere gebruiker bent

cd /opt/stack/devstack

# Methode 1: rejoin-stack.sh (aanbevolen, behoudt bestaande configuratie)
./rejoin-stack.sh

# Wacht 5-15 minuten. Log output controleren.
# Succes = geen rode ERROR regels aan het einde

# Als rejoin-stack.sh mislukt, verifieer eerst:
cat /opt/stack/devstack/local.conf   # Bestaat nog?
ls /opt/stack/devstack/              # Is devstack map intact?

# Methode 2 (als rejoin helemaal mislukt): Proxmox snapshot herstellen
# Ga naar Proxmox UI → devstack01 → Snapshots → devstack-clean → Rollback
# Na rollback:
ssh stack@192.168.100.20
cd /opt/stack/devstack && ./rejoin-stack.sh
```

---

## Verificatie na herstel

```bash
source /opt/stack/devstack/openrc admin admin

# Services check:
openstack service list
openstack compute service list
openstack network agent list

# Horizon bereikbaar:
curl -s -o /dev/null -w "HTTP status: %{http_code}" http://localhost/dashboard
```

---

## Preventie

Zet in je kalender: na elke geplande reboot van DevStack → `rejoin-stack.sh` uitvoeren.
Maak na elke succesvolle herstart een nieuwe Proxmox snapshot.

---

## Leerdoel

- DevStack lifecycle begrip: start, reboot, herstel
- Verschil productie OpenStack vs. DevStack begrijpen
- Screen sessies bekijken
- Incident prioriteit: kritiek, snel handelen, communiceren
