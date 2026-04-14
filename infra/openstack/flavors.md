# OpenStack Flavors — TechNova BV

## Overzicht standaard flavors

Flavors bepalen hoeveel CPU, RAM en schijfruimte een VM krijgt.
Studenten kiezen bij het aanmaken van een VM een flavor.

| Naam       | vCPU | RAM    | Disk  | Gebruik                             |
|------------|------|--------|-------|-------------------------------------|
| tn.tiny    | 1    | 512 MB | 10 GB | Testen, CirrOS testimage            |
| tn.small   | 1    | 1 GB   | 20 GB | Ubuntu minimaal, simpele taken      |
| tn.medium  | 2    | 2 GB   | 40 GB | Webserver, applicatieserver         |
| tn.large   | 4    | 4 GB   | 80 GB | Zwaardere werklasten (beheer door docent) |

## Aanmaken via CLI

```bash
# Aanmaken van tn.tiny
openstack flavor create \
  --vcpus 1 \
  --ram 512 \
  --disk 10 \
  --public \
  tn.tiny

# Aanmaken van tn.small
openstack flavor create \
  --vcpus 1 \
  --ram 1024 \
  --disk 20 \
  --public \
  tn.small

# Aanmaken van tn.medium
openstack flavor create \
  --vcpus 2 \
  --ram 2048 \
  --disk 40 \
  --public \
  tn.medium

# Aanmaken van tn.large (docent only)
openstack flavor create \
  --vcpus 4 \
  --ram 4096 \
  --disk 80 \
  --private \
  tn.large
```

## Quota per team (ingesteld bij setup)

| Resource    | Maximum per team | Reden                                   |
|-------------|------------------|-----------------------------------------|
| Instances   | 5                | Voorkomt resource uitputting            |
| vCPU's      | 10               | Max 10 cores per team                   |
| RAM         | 10 GB            | Gelijkmatige verdeling                  |
| Volumes     | 10               | Beperkte opslag                         |
| Disk totaal | 100 GB           | Totale schijfruimte per team            |

## Controleer quota via CLI

```bash
# Quota voor een specifiek project bekijken
openstack quota show team-cloud-alpha

# Huidig gebruik bekijken
openstack limits show --absolute --project team-cloud-alpha
```
