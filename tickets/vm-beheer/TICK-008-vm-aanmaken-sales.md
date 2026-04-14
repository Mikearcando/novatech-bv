# TICK-008 — VM aanmaken voor afdeling Sales

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | VM Beheer                     |
| Prioriteit        | Middel                        |
| Moeilijkheidsgraad| ★☆☆ (beginner)               |
| Status            | Open                          |
| SLA               | Morgen                        |

---

## Probleemomschrijving

Verzoek van afdeling Sales:

> "Wij hebben een nieuwe testserver nodig voor onze CRM applicatie.
> We willen een Ubuntu server met minimaal 2GB RAM en 2 CPU's.
> De server moet bereikbaar zijn via SSH. Jullie mogen zelf de naam bepalen.
> — Afdeling Sales, TechNova BV"

---

## Wat moet er gebeuren

1. VM aanmaken in het Sales project (of team-project als Sales project niet bestaat)
2. Specificaties: 2 vCPU, 2GB RAM → flavor `tn.medium`
3. Image: Ubuntu 22.04 (of dichtst beschikbare)
4. VM bereikbaar maken via SSH (floating IP + security group)
5. Inloggegevens documenteren voor de afdeling

---

## Uitvoering

```bash
# Via Horizon:
# 1. Login als jouw account
# 2. Project → Compute → Instances → Launch Instance
# 3. Vul in:
#    - Naam: sales-crm-server-01
#    - Source: Ubuntu 22.04
#    - Flavor: tn.medium
#    - Network: jouw teamnetwerk
#    - Security Group: default (SSH + ICMP)

# Via CLI:
source /opt/stack/devstack/openrc admin admin

openstack server create \
    --flavor tn.medium \
    --image "Ubuntu 22.04" \
    --network team-cloud-alpha \
    --security-group default \
    sales-crm-server-01

# Wacht tot status ACTIVE:
openstack server show sales-crm-server-01 | grep status

# Floating IP toewijzen:
FLOAT_IP=$(openstack floating ip create public -f value -c floating_ip_address)
openstack server add floating ip sales-crm-server-01 $FLOAT_IP

echo "Server: sales-crm-server-01"
echo "Floating IP: $FLOAT_IP"
echo "SSH: ssh ubuntu@$FLOAT_IP"
```

---

## Verificatie

- [ ] VM heeft status `ACTIVE`
- [ ] VM heeft floating IP
- [ ] Ping naar floating IP werkt
- [ ] SSH verbinding mogelijk
- [ ] Inloggegevens en IP gedocumenteerd voor Sales

---

## Leerdoel

- VM aanmaken voor een specifieke klant/afdeling
- Floating IP begrip en gebruik
- Communicatie: output documenteren voor eindgebruiker
- Verschil flavor kiezen op basis van requirement
