# Proxmox VM Overzicht — TechNova BV

## VM Configuratie

| VM ID | Naam        | OS                    | vCPU | RAM    | Disk   | IP                | Rol                     |
|-------|-------------|-----------------------|------|--------|--------|-------------------|-------------------------|
| 100   | DC01        | Windows Server 2022   | 2    | 4096 MB| 60 GB  | 192.168.100.11    | Domain Controller, DNS  |
| 101   | devstack01  | Ubuntu 22.04 LTS      | 4    | 12288 MB| 120 GB | 192.168.100.20   | OpenStack all-in-one    |
| 102   | jump01      | Ubuntu 22.04 Desktop  | 2    | 4096 MB| 40 GB  | 192.168.100.30    | Optioneel: jump host    |

## Proxmox Host Vereisten

| Component | Minimum       | Aanbevolen    |
|-----------|---------------|---------------|
| CPU       | 8 cores + VT-x| 12-16 cores   |
| RAM       | 24 GB         | 32-64 GB      |
| Opslag    | 500 GB SSD    | 1 TB NVMe SSD |
| NIC       | 1 Gbps        | 2x 1 Gbps     |
| OS        | Proxmox VE 8  | Proxmox VE 8  |

## Netwerkconfiguratie in Proxmox

```
# /etc/network/interfaces op Proxmox host

auto lo
iface lo inet loopback

auto ens18
iface ens18 inet manual

# Bridge voor VM's
auto vmbr0
iface vmbr0 inet static
    address 192.168.100.10/24
    gateway 192.168.100.1
    bridge-ports ens18
    bridge-stp off
    bridge-fd 0
    dns-nameservers 192.168.100.11 8.8.8.8
    # Opmerking: pas ens18 aan naar jouw fysieke interface naam
```

## Nested Virtualisatie Inschakelen

**Vereist voor DevStack op Proxmox.**

```bash
# Op Proxmox host — voor Intel CPU:
echo "options kvm-intel nested=Y" > /etc/modprobe.d/kvm-intel.conf
modprobe -r kvm_intel && modprobe kvm_intel

# Voor AMD CPU:
echo "options kvm-amd nested=1" > /etc/modprobe.d/kvm-amd.conf
modprobe -r kvm_amd && modprobe kvm_amd

# Controleer of het werkt:
cat /sys/module/kvm_intel/parameters/nested
# Uitvoer moet zijn: Y of 1
```

**In Proxmox UI voor VM 101 (devstack01):**
1. VM stoppen
2. Hardware → Processor → Type: "host"
3. Vink aan: "Enable NUMA"
4. VM starten

## Snapshots Beheer

```bash
# Snapshot aanmaken via CLI (op Proxmox host):
qm snapshot 100 "dc01-sprint01-start" --description "DC01 snapshot begin Sprint 1"
qm snapshot 101 "devstack-clean" --description "DevStack na installatie"

# Snapshot terugzetten:
qm rollback 101 devstack-clean

# Alle snapshots van een VM:
qm listsnapshot 101
```

## Aanbevolen snapshot schema

| Moment                     | VM's        | Naam                    |
|----------------------------|-------------|-------------------------|
| Na installatie en inrichting| 100, 101   | dc01-clean / devstack-clean |
| Begin sprint 1              | 100, 101   | sprint01-start          |
| Begin sprint 2              | 100, 101   | sprint02-start          |
| Dagelijks (optioneel)       | 101        | devstack-dag-DDMMJJJJ   |

## Proxmox beheer URLs en toegang

| Dienst              | URL                           | Gebruiker |
|---------------------|-------------------------------|-----------|
| Proxmox Web UI      | https://192.168.100.10:8006   | root      |
| DC01 RDP            | 192.168.100.11:3389           | TECHNOVA\Administrator |
| DevStack SSH        | 192.168.100.20:22             | stack     |
| Horizon Dashboard   | http://192.168.100.20/dashboard | admin / TechNova2024! |
