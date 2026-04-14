# TICK-006 — Client krijgt geen IP-adres van DHCP

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Netwerkproblemen              |
| Prioriteit        | Middel                        |
| Moeilijkheidsgraad| ★★☆ (gemiddeld)              |
| Status            | Open                          |
| SLA               | Vandaag                       |

---

## Probleemomschrijving

Nieuwe werkplek (PC-STUDENT-42) wordt aangemeld in het netwerk maar krijgt geen werkend IP-adres:

> "De nieuwe PC krijgt het IP-adres 169.254.45.123. Internet werkt niet en ik kan
> geen netwerkschijven koppelen. Andere PC's werken gewoon."

**Uitleg 169.254.x.x:** Dit is een APIPA-adres (Automatic Private IP Addressing). Windows wijst dit zelf toe als DHCP niet bereikbaar is.

---

## Verwachte analyse

1. Controleer of de DHCP service actief is op DC01
2. Controleer of de DHCP scope voldoende IPs heeft
3. Controleer de fysieke verbinding (kabel, switch)
4. Controleer of de DHCP-service de juiste scope bedient

---

## Diagnosestappen

```powershell
# ── Op de probleem-client ─────────────────────────────────────────────────────
# Huidig IP bekijken
ipconfig /all

# DHCP lease vernieuwen
ipconfig /release
ipconfig /renew

# Als /renew mislukt: foutmelding noteert
```

```powershell
# ── Op DC01 (DHCP server) ──────────────────────────────────────────────────────
# DHCP service status
Get-Service -Name DHCPServer | Select-Object Status, StartType

# DHCP scopes bekijken
Get-DhcpServerv4Scope

# Beschikbare IPs in scope
Get-DhcpServerv4ScopeStatistics
# Let op: 'Free' moet meer dan 0 zijn!

# Actieve leases bekijken
Get-DhcpServerv4Lease -ScopeId "192.168.100.0"

# DHCP server log bekijken
Get-EventLog -LogName System -Source "Microsoft-Windows-DHCP-Server" -Newest 20
```

---

## Oplossing

```powershell
# Als DHCP service gestopt is:
Start-Service -Name DHCPServer
Set-Service  -Name DHCPServer -StartupType Automatic

# Als scope vol is (geen vrije IPs):
# Optie A: Bestaande verlopen leases opruimen
Remove-DhcpServerv4Lease -ScopeId "192.168.100.0" -ClientId [mac-adres]

# Optie B: Scope uitbreiden (als adresruimte dat toelaat)
Set-DhcpServerv4Scope -ScopeId "192.168.100.0" `
    -EndRange "192.168.100.200"  # Was misschien .150

# Op client na fix:
ipconfig /release
ipconfig /renew
ipconfig /all
# Nu moet 192.168.100.x verschijnen
```

---

## Verificatie

- [ ] `ipconfig /all` toont IP in bereik `192.168.100.x`
- [ ] Subnetmasker: `255.255.255.0`
- [ ] Gateway: `192.168.100.1`
- [ ] DNS server: `192.168.100.11`
- [ ] Ping naar DC01 (`192.168.100.11`) werkt
- [ ] DHCP lease zichtbaar op DC01: `Get-DhcpServerv4Lease`

---

## Leerdoel

- APIPA-adressen herkennen en betekenis begrijpen
- DHCP service beheer op Windows Server
- DHCP troubleshooting: lease/renew, scope capacity
- Verschil client-kant vs. server-kant problemen
