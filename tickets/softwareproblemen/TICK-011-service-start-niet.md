# TICK-011 — DNS Service start niet automatisch na reboot

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Softwareproblemen             |
| Prioriteit        | Kritiek                       |
| Moeilijkheidsgraad| ★★☆ (gemiddeld)              |
| Status            | Open                          |
| SLA               | Direct                        |

---

## Probleemomschrijving

Na een geplande reboot van DC01 gisternacht:

> "Na de reboot werkt naamresolutie niet meer in het hele netwerk.
> Iedereen krijgt errors bij het inloggen. Ik heb DC01 gecheckt:
> de server is bereikbaar maar iets werkt niet.
> — Docent / Systeembeheerder"

---

## Verwachte analyse

Als DNS niet werkt na een reboot en de server wel bereikbaar is:
1. DNS service is gestopt
2. DNS service is niet ingesteld op automatisch opstarten
3. DNS service start maar crasht meteen (event log bekijken)

---

## Diagnosestappen

```powershell
# Stap 1: Services controleren op DC01
Get-Service -Name DNS | Select-Object Name, Status, StartType

# Stap 2: Event log bekijken voor DNS errors
Get-EventLog -LogName System -Source "Microsoft-Windows-DNS-Server-Service" -Newest 20

# Stap 3: AD services overall check
Get-Service -Name @("DNS","Netlogon","NTDS","kdc","W32Time") |
    Select-Object Name, Status, StartType |
    Format-Table -AutoSize

# Stap 4: Netlogon dependency op DNS
# Netlogon heeft DNS nodig — als DNS down is, is Netlogon ook down
```

---

## Oplossing

```powershell
# Stap 1: DNS service starten
Start-Service -Name DNS

# Stap 2: Automatisch opstarten instellen
Set-Service -Name DNS -StartupType Automatic

# Stap 3: Controleer alle kritieke AD services
$kritiekeDiensten = @("DNS","Netlogon","NTDS","kdc")
foreach ($dienst in $kritiekeDiensten) {
    $s = Get-Service -Name $dienst -ErrorAction SilentlyContinue
    if ($s.Status -ne "Running") {
        Start-Service -Name $dienst
        Write-Host "Gestart: $dienst" -ForegroundColor Green
    } else {
        Write-Host "Al actief: $dienst" -ForegroundColor Cyan
    }
    Set-Service -Name $dienst -StartupType Automatic
}

# Stap 4: Verificatie
Get-Service -Name @("DNS","Netlogon","NTDS") | Select-Object Name, Status, StartType
nslookup dc01.technova.local 127.0.0.1
```

---

## Verificatie

- [ ] DNS service status: `Running`
- [ ] DNS StartType: `Automatic`
- [ ] `nslookup dc01.technova.local` werkt op DC01
- [ ] Clients kunnen inloggen op het domein
- [ ] `nslookup horizon.technova.local` werkt op een client

---

## Leerdoel

- Windows services beheer: starten, stoppen, autostart
- Afhankelijkheden tussen services herkennen (DNS → Netlogon)
- Event Log analyseren bij service failures
- Impact van één service op het hele netwerk begrijpen
