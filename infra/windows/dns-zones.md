# DNS Zones & Records — TechNova BV

## Zone overzicht

| Zone             | Type              | Server | Doel                          |
|------------------|-------------------|--------|-------------------------------|
| technova.local   | Primary forward   | DC01   | Interne naamresolutie         |
| 100.168.192.in-addr.arpa | Primary reverse | DC01 | Reverse lookup (IP → naam) |

## Forward Lookup Zone: technova.local

### Verplichte records (aangemaakt door AD)

| Naam                    | Type  | Waarde               | Opmerkingen              |
|-------------------------|-------|----------------------|--------------------------|
| (blank / @)             | SOA   | dc01.technova.local  | Start of Authority       |
| (blank / @)             | NS    | dc01.technova.local  | Nameserver               |
| dc01                    | A     | 192.168.100.11       | Domain Controller        |
| _msdcs                  | -     | (subzone, auto)      | AD servicelocator records|
| _sites                  | SRV   | (auto)               | AD sites                 |
| _tcp                    | SRV   | (auto)               | Kerberos, LDAP services  |
| _udp                    | SRV   | (auto)               | NTP, andere UDP services |

### Handmatig toe te voegen records

| Naam                    | Type  | Waarde               | Opmerkingen               |
|-------------------------|-------|----------------------|---------------------------|
| devstack01              | A     | 192.168.100.20       | DevStack / OpenStack node |
| horizon                 | CNAME | devstack01           | Alias voor Horizon UI     |
| openstack               | CNAME | devstack01           | Alias voor OpenStack      |
| proxmox                 | A     | 192.168.100.10       | Proxmox beheerinterface   |

### Records aanmaken via PowerShell

```powershell
# Op DC01 uitvoeren als Domain Admin

$Zone = "technova.local"
$DC01IP = "192.168.100.11"

# DevStack record
Add-DnsServerResourceRecordA -ZoneName $Zone `
    -Name "devstack01" `
    -IPv4Address "192.168.100.20" `
    -TimeToLive 01:00:00

# Horizon als CNAME
Add-DnsServerResourceRecordCName -ZoneName $Zone `
    -Name "horizon" `
    -HostNameAlias "devstack01.technova.local."

# OpenStack als CNAME
Add-DnsServerResourceRecordCName -ZoneName $Zone `
    -Name "openstack" `
    -HostNameAlias "devstack01.technova.local."

# Proxmox record
Add-DnsServerResourceRecordA -ZoneName $Zone `
    -Name "proxmox" `
    -IPv4Address "192.168.100.10"

# Alle records in zone tonen
Get-DnsServerResourceRecord -ZoneName $Zone | Sort-Object Name | Format-Table -AutoSize
```

## Reverse Lookup Zone: 100.168.192.in-addr.arpa

### Records

| IP                | PTR (naam)                      |
|-------------------|---------------------------------|
| 192.168.100.10    | proxmox.technova.local          |
| 192.168.100.11    | dc01.technova.local             |
| 192.168.100.20    | devstack01.technova.local       |

### Reverse zone aanmaken

```powershell
# Reverse lookup zone aanmaken
Add-DnsServerPrimaryZone `
    -NetworkID "192.168.100.0/24" `
    -ReplicationScope "Domain" `
    -DynamicUpdate "Secure"

# PTR records handmatig toevoegen
Add-DnsServerResourceRecordPtr -ZoneName "100.168.192.in-addr.arpa" `
    -Name "11" -PtrDomainName "dc01.technova.local."
Add-DnsServerResourceRecordPtr -ZoneName "100.168.192.in-addr.arpa" `
    -Name "20" -PtrDomainName "devstack01.technova.local."
Add-DnsServerResourceRecordPtr -ZoneName "100.168.192.in-addr.arpa" `
    -Name "10" -PtrDomainName "proxmox.technova.local."
```

## DNS Testen

```powershell
# Forward lookup
Resolve-DnsName -Name "dc01.technova.local"
Resolve-DnsName -Name "horizon.technova.local"

# Reverse lookup
Resolve-DnsName -Name "192.168.100.11" -Type PTR

# Specifieke DNS server bevragen
nslookup devstack01.technova.local 192.168.100.11

# DNS cache legen op client
ipconfig /flushdns
ipconfig /registerdns
```

## DNS Troubleshooting

| Symptoom                          | Oorzaak                        | Oplossing                              |
|-----------------------------------|--------------------------------|----------------------------------------|
| Naam resolveert niet              | Record ontbreekt               | `Add-DnsServerResourceRecordA`         |
| Verkeerd IP bij naamopzoeking     | Oud record in cache            | `ipconfig /flushdns` op client         |
| DNS service reageert niet         | DNS service gestopt            | `Start-Service DNS` op DC01            |
| Client gebruikt verkeerde DNS     | IP-configuratie client fout    | `ipconfig /all`, DNS serveradres check |
| Reverse lookup werkt niet         | Reverse zone mist              | Zone aanmaken, PTR records toevoegen   |
