# TICK-014 — VM in OpenStack heeft geen internettoegang

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Cloudproblemen / Netwerk      |
| Prioriteit        | Middel                        |
| Moeilijkheidsgraad| ★★★ (gevorderd)              |
| Status            | Open                          |
| SLA               | Morgen                        |

---

## Probleemomschrijving

> "Onze VM (app-server-01) draait prima en is pingbaar via floating IP.
> Maar vanuit de VM zelf kunnen we `apt update` niet uitvoeren:
> 'Temporary failure in name resolution' en `ping 8.8.8.8` geeft timeout.
> De VM heeft interne IP 10.20.3.14."

---

## Verwachte analyse

VM kan niet naar buiten communiceren. Controleer in volgorde:
1. Heeft de VM een IP? (intern werkt het, dus ja)
2. Is er een router met gateway naar extern netwerk?
3. Staat de DNS correct ingesteld in het subnet?
4. Blokkeert een security group het uitgaand verkeer?

---

## Diagnosestappen

```bash
# Stap 1: Vanuit de VM (via console):
ip addr show        # IP aanwezig?
ip route show       # Is er een default route?
# Moet zoiets zijn: default via 10.20.3.1 dev eth0

ping 10.20.3.1      # Kan de VM de gateway pingen?
ping 8.8.8.8        # Kan de VM internet bereiken?
nslookup google.com # Werkt DNS?

# Stap 2: Router controleren (in Horizon of CLI)
```

```bash
# Via OpenStack CLI als admin:
source /opt/stack/devstack/openrc admin admin

# Router bekijken
openstack router list
openstack router show team-cloud-alpha-router

# Heeft de router een externe gateway (naar 'public')?
openstack router show team-cloud-alpha-router | grep external_gateway

# Subnet gekoppeld aan router?
openstack router show team-cloud-alpha-router | grep -A10 interfaces
```

---

## Oplossing

```bash
# Als router geen externe gateway heeft:
openstack router set \
    --external-gateway public \
    team-cloud-alpha-router

# Als subnet niet gekoppeld is aan router:
openstack router add subnet team-cloud-alpha-router team-cloud-alpha-subnet

# DNS instellen in subnet (als DNS ontbreekt):
openstack subnet set \
    --dns-nameserver 192.168.100.11 \
    --dns-nameserver 8.8.8.8 \
    team-cloud-alpha-subnet

# Security group: zorg dat uitgaand verkeer is toegestaan
# Default security group laat normaal alles uitgaand toe, maar controleer:
openstack security group rule list default | grep egress
# Moet regels tonen die 'egress' zijn (uitgaand)
```

---

## Verificatie

```bash
# Vanuit de VM:
ping 8.8.8.8           # Internet bereikbaar?
nslookup google.com    # DNS werkt?
curl http://example.com # HTTP werkend?
```

---

## Leerdoel

- OpenStack netwerkarchitectuur: intern netwerk, router, extern netwerk
- NAT/routing concepten in de cloud
- DNS-configuratie in subnets
- Methodisch netwerk troubleshoot: VM → router → extern
