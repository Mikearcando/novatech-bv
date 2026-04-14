# TICK-007 — VM staat op ERROR status in Horizon

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | VM Beheer / Cloudproblemen    |
| Prioriteit        | Hoog                          |
| Moeilijkheidsgraad| ★★★ (gevorderd)              |
| Status            | Open                          |
| SLA               | Vandaag                       |

---

## Probleemomschrijving

Student Daan Smit rapporteert via het ticketsysteem:

> "Ik heb gisteren een VM aangemaakt met de naam 'webserver-daan'. Na het aanmaken
> stond hij eerst op 'Spawning' en daarna op 'Error'. Ik heb hem al verwijderd en
> opnieuw aangemaakt, zelfde probleem. Andere teamleden kunnen wel VMs aanmaken.
> Flavor: tn.medium. Mijn quota lijken OK."

---

## Verwachte analyse

ERROR status bij VM aanmaken heeft meerdere oorzaken:
1. Te weinig resources op de compute node (RAM/CPU)
2. Image beschadigd of ontbrekend
3. Nova compute service heeft een probleem
4. Quota overschreden (ondanks dat gebruiker denkt van niet)
5. Netwerk niet correct geconfigureerd bij flavor

---

## Diagnosestappen

```bash
# Op DevStack VM als admin:
source /opt/stack/devstack/openrc admin admin

# 1. VM status bekijken (ook bij ERROR staat hij nog in de lijst)
openstack server list --all-projects | grep -i "daan\|error"
openstack server show webserver-daan 2>/dev/null || echo "VM al verwijderd"

# 2. Compute services controleren
openstack compute service list
# Alle services moeten 'up' zijn

# 3. Nova logs bekijken (meest informatief)
sudo tail -50 /opt/stack/logs/n-cpu.log | grep -E "ERROR|WARN|Exception"

# 4. Quota controleren voor dit project
openstack quota show team-cloud-alpha
openstack limits show --absolute --project team-cloud-alpha

# 5. Beschikbare resources op compute node
openstack hypervisor show $(openstack hypervisor list -f value -c "Hypervisor Hostname")
# Let op: vCPUs Used, Memory MB Used
```

---

## Oplossing

```bash
# Als resources uitgeput zijn:
# Verwijder VM's die niet meer nodig zijn:
openstack server list --project team-cloud-alpha
openstack server delete <vm-naam>

# Als nova compute service down is:
sudo systemctl restart devstack@n-cpu
sudo systemctl status devstack@n-cpu

# Als image beschadigd is:
openstack image list
openstack image show "Ubuntu 22.04" | grep status
# Status moet 'active' zijn

# Als quota te laag is (admin actie):
openstack quota set --instances 8 --cores 16 --ram 20480 team-cloud-alpha

# Na herstellen: VM opnieuw aanmaken
openstack server create \
    --flavor tn.small \
    --image "CirrOS" \
    --network team-cloud-net \
    test-vm-daan
```

---

## Verificatie

- [ ] Nova compute services zijn allemaal `up`
- [ ] Nieuwe VM start zonder ERROR
- [ ] VM bereikt status `ACTIVE` binnen 2 minuten
- [ ] Oorzaak gedocumenteerd in ticketformulier

---

## Leerdoel

- OpenStack ERROR status analyseren via logs
- Relatie compute resources ↔ VM aanmaken
- Nova compute service beheer
- Systematisch debuggen: resources → services → logs
