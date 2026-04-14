# TICK-005 — DNS naam wordt niet opgelost

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Netwerkproblemen              |
| Prioriteit        | Middel                        |
| Moeilijkheidsgraad| ★★☆ (gemiddeld)              |
| Status            | Open                          |
| SLA               | Vandaag                       |

---

## Probleemomschrijving

Medewerker Emma van Dam rapporteert:

> "Ik kan geen verbinding maken met dc01.technova.local. Als ik ping 192.168.100.11
> doe dan werkt het prima, maar ping dc01.technova.local geeft 'Ping request could
> not find host dc01.technova.local'. Andere collega's hebben dit probleem niet."

---

## Verwachte analyse

Het probleem is DNS-specifiek (IP werkt, naam niet). Mogelijke oorzaken:
1. DNS server incorrect geconfigureerd op dit werkstation
2. DNS cache bevat een fout record
3. DNS suffix niet geconfigureerd
4. DNS service op DC01 is gestopt (onwaarschijnlijk want anderen hebben geen problemen)

Start met de client, dan pas de server.

---

## Diagnosestappen

```powershell
# Stap 1: IP configuratie bekijken op de probleemclient
ipconfig /all
# Controleer: DNS Servers → moet 192.168.100.11 zijn

# Stap 2: DNS cache controleren
ipconfig /displaydns | findstr /i "technova"

# Stap 3: Naam direct via specifieke DNS server bevragen
nslookup dc01.technova.local 192.168.100.11
# Als dit WEL werkt: probleem zit in DNS-instelling op client
# Als dit NIET werkt: probleem zit in DNS server of record

# Stap 4: DNS cache leegmaken op client
ipconfig /flushdns
ipconfig /registerdns

# Stap 5: Opnieuw proberen
ping dc01.technova.local
```

---

## Oplossing

```powershell
# Als DNS server verkeerd geconfigureerd op client:
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" `
    -ServerAddresses "192.168.100.11","8.8.8.8"

# DNS suffix instellen (zorg dat technova.local automatisch wordt toegevoegd):
Set-DnsClient -InterfaceAlias "Ethernet" `
    -ConnectionSpecificSuffix "technova.local"

# DNS cache leegmaken:
ipconfig /flushdns

# Verificatie:
Resolve-DnsName -Name "dc01.technova.local"
Resolve-DnsName -Name "horizon.technova.local"
Resolve-DnsName -Name "devstack01.technova.local"
```

---

## Verificatie

- [ ] `ipconfig /all` toont `192.168.100.11` als DNS server
- [ ] `ping dc01.technova.local` werkt
- [ ] `ping horizon.technova.local` werkt
- [ ] `nslookup devstack01.technova.local` geeft correct IP

---

## Leerdoel

- DNS troubleshooting: client vs. server probleem identificeren
- ipconfig commando's voor netwerk diagnose
- DNS cache en de impact ervan op naamresolutie
- Verschil tussen direct IP-bereikbaarheid en DNS-resolutie
