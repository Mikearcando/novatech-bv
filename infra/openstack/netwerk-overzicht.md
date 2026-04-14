# OpenStack Netwerkoverzicht — TechNova BV

## Netwerktopologie

```
Internet / Schoolnetwerk
        │
        │ 192.168.100.1 (gateway)
        │
┌───────┴────────────────────────────────────┐
│           Proxmox Bridge (vmbr0)            │
│           192.168.100.0/24                  │
│                                             │
│  DC01          DevStack         Student PC  │
│  .11           .20              .30-.50     │
└───────┬────────────────────────────────────┘
        │
  ┌─────┴─────────────────────────────────┐
  │     DevStack interne netwerken        │
  │                                       │
  │  Fixed network (VM internal)          │
  │  10.11.12.0/24                        │
  │                                       │
  │  Floating IPs (extern bereikbaar)     │
  │  192.168.100.128/26                   │
  │  (.128 - .191)                        │
  └───────────────────────────────────────┘
```

## Netwerken in OpenStack

| Netwerknaam       | Type     | Subnet            | Doel                                        |
|-------------------|----------|-------------------|---------------------------------------------|
| public            | Extern   | 192.168.100.128/26| Floating IPs, extern bereikbaar             |
| private           | Intern   | 10.11.12.0/24     | VM-VM communicatie, intern                  |
| team-infra-net    | Intern   | 10.20.1.0/24      | Netwerk voor Team Infra (aangemaakt door team) |
| team-cloud-net    | Intern   | 10.20.2.0/24      | Netwerk voor Team Cloud (aangemaakt door team) |

## Floating IP bereik

| Range                  | Beschikbare IPs | Gebruik           |
|------------------------|-----------------|-------------------|
| 192.168.100.128 - .191 | 62 adressen     | Student VM's      |
| 192.168.100.192 - .254 | Gereserveerd    | Toekomstig gebruik|

## Security Groups (standaard)

### default (elk project)
| Protocol | Poort | Richting  | Doel                    |
|----------|-------|-----------|-------------------------|
| TCP      | 22    | Inkomend  | SSH toegang             |
| ICMP     | -     | Inkomend  | Ping toestaan           |
| Alle     | -     | Uitgaand  | Alle uitgaand verkeer   |

### web-servers (aanmaken als opdracht)
| Protocol | Poort | Richting | Doel           |
|----------|-------|----------|----------------|
| TCP      | 80    | Inkomend | HTTP           |
| TCP      | 443   | Inkomend | HTTPS          |

## Opdrachten voor studenten (netwerk)

1. Maak een intern netwerk aan voor je team
2. Maak een subnet aan: 10.20.X.0/24 (X = teamnummer)
3. Maak een router aan en koppel hem aan het publieke netwerk
4. Koppel je interne netwerk aan de router
5. Maak een VM aan en associeer een floating IP
6. Controleer of je de VM kunt pingen via het floating IP

## Veelgemaakte fouten

| Fout                                  | Oorzaak                           | Oplossing                              |
|---------------------------------------|-----------------------------------|----------------------------------------|
| VM heeft geen IP                      | Geen DHCP in subnet               | DHCP inschakelen bij subnet aanmaken   |
| Floating IP werkt niet               | Router niet gekoppeld             | Router gateway naar 'public' zetten    |
| VM niet pingbaar                      | Security group blokkeert ICMP     | ICMP toestaan in security group        |
| "No valid host was found"             | Te weinig compute resources       | Kies een kleinere flavor (tn.tiny)     |
| Netwerk al in gebruik door ander team | Subnet overlap                    | Gebruik uniek subnet per team          |
