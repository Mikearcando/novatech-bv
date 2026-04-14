# IP-adresplan — TechNova BV Leeromgeving

## Netwerk: 192.168.100.0/24

| IP-adres           | Hostnaam                    | Rol                         | MAC/NIC  |
|--------------------|-----------------------------|-----------------------------|----------|
| 192.168.100.1      | [schoolgateway]             | Standaardgateway / router   | —        |
| 192.168.100.10     | proxmox.technova.local      | Proxmox VE hypervisor       | vmbr0    |
| 192.168.100.11     | dc01.technova.local         | Domain Controller, DNS, DHCP| Ethernet |
| 192.168.100.20     | devstack01.technova.local   | OpenStack all-in-one        | ens18    |
| 192.168.100.30     | jump01.technova.local       | Optionele jump server       | —        |
| 192.168.100.50-99  | [gereserveerd]              | Toekomstige servers         | —        |
| 192.168.100.100-127| [DHCP pool — werkstations]  | Student PC's                | DHCP     |
| 192.168.100.128-191| [Floating IPs OpenStack]    | VM's in OpenStack (extern)  | Neutron  |
| 192.168.100.192-254| [gereserveerd]              | Toekomst / beheer           | —        |
| 192.168.100.255    | [broadcast]                 | —                           | —        |

---

## Subnetdetails

| Parameter        | Waarde              |
|------------------|---------------------|
| Netwerk          | 192.168.100.0       |
| Subnetmasker     | 255.255.255.0 (/24) |
| Gateway          | 192.168.100.1       |
| DNS Server 1     | 192.168.100.11 (DC01)|
| DNS Server 2     | 8.8.8.8 (fallback)  |
| DHCP range       | 192.168.100.100 - 192.168.100.127 |
| Floating IP range| 192.168.100.128 - 192.168.100.191 |

---

## OpenStack interne netwerken

| Netwerk             | Subnet         | Team              | Gateway    |
|---------------------|----------------|-------------------|------------|
| team-infra-alpha-net| 10.20.1.0/24   | Team Infra Alpha  | 10.20.1.1  |
| team-infra-beta-net | 10.20.2.0/24   | Team Infra Beta   | 10.20.2.1  |
| team-cloud-alpha-net| 10.20.3.0/24   | Team Cloud Alpha  | 10.20.3.1  |
| team-cloud-beta-net | 10.20.4.0/24   | Team Cloud Beta   | 10.20.4.1  |
| team-ops-alpha-net  | 10.20.5.0/24   | Team Ops Alpha    | 10.20.5.1  |
| team-ops-beta-net   | 10.20.6.0/24   | Team Ops Beta     | 10.20.6.1  |
| team-support-net    | 10.20.7.0/24   | Team Support      | 10.20.7.1  |
| team-security-net   | 10.20.8.0/24   | Team Security     | 10.20.8.1  |
| team-devops-net     | 10.20.9.0/24   | Team DevOps       | 10.20.9.1  |
| DevStack fixed range| 10.11.12.0/24  | Intern (DevStack) | 10.11.12.1 |

---

## DNS Records samenvatting

| Naam                          | Type  | Waarde            |
|-------------------------------|-------|-------------------|
| proxmox.technova.local        | A     | 192.168.100.10    |
| dc01.technova.local           | A     | 192.168.100.11    |
| devstack01.technova.local     | A     | 192.168.100.20    |
| horizon.technova.local        | CNAME | devstack01        |
| openstack.technova.local      | CNAME | devstack01        |
| jump01.technova.local         | A     | 192.168.100.30    |

---

## Wijzigingslog

| Datum | Wijziging | Door wie |
|-------|-----------|----------|
|       |           |          |
