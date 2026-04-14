#Requires -Modules ActiveDirectory
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Bouwt de volledige OU-structuur voor TechNova BV in Active Directory.

.DESCRIPTION
    Dit script maakt alle Organizational Units aan die nodig zijn voor
    de TechNova leeromgeving. Voer dit script uit op DC01 als
    domeinbeheerder. Bestaande OU's worden overgeslagen.

.NOTES
    Domein     : technova.local
    Server     : DC01
    Uitvoeren  : Als Domain Admin op DC01
    Vereiste   : ActiveDirectory module (RSAT)
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─── Configuratie ────────────────────────────────────────────────────────────
$Domain    = "DC=technova,DC=local"
$LogFile   = "C:\Logs\AD-Setup\ou-structuur-$(Get-Date -Format 'yyyyMMdd-HHmm').log"

# ─── Logging ─────────────────────────────────────────────────────────────────
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Write-Host $line -ForegroundColor $(switch ($Level) {
        "OK"    { "Green"  }
        "SKIP"  { "Yellow" }
        "ERROR" { "Red"    }
        default { "White"  }
    })
    $line | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

function New-OUSafe {
    param([string]$Name, [string]$Path, [string]$Description = "")
    try {
        $existing = Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Path -SearchScope OneLevel -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Log "SKIP: OU '$Name' bestaat al in '$Path'" "SKIP"
            return
        }
        $params = @{
            Name        = $Name
            Path        = $Path
            Description = $Description
        }
        New-ADOrganizationalUnit @params
        Write-Log "OK: OU '$Name' aangemaakt in '$Path'" "OK"
    }
    catch {
        Write-Log "ERROR bij '$Name': $($_.Exception.Message)" "ERROR"
    }
}

# ─── Log directory aanmaken ──────────────────────────────────────────────────
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Write-Log "=== Start OU-structuur aanmaken voor TechNova BV ==="
Write-Log "Domein: $Domain"
Write-Log "Uitvoerder: $($env:USERNAME) op $($env:COMPUTERNAME)"

# ─── Niveau 1: Hoofd-OU ──────────────────────────────────────────────────────
New-OUSafe -Name "TechNova"   -Path $Domain -Description "Hoofd-OU voor TechNova BV"

# ─── Niveau 2: Categorieën ───────────────────────────────────────────────────
$technovaOU = "OU=TechNova,$Domain"

New-OUSafe -Name "Gebruikers"  -Path $technovaOU -Description "Alle gebruikersaccounts"
New-OUSafe -Name "Groepen"     -Path $technovaOU -Description "Alle beveiligings- en distributiegroepen"
New-OUSafe -Name "Computers"   -Path $technovaOU -Description "Werkstations in het domein"
New-OUSafe -Name "Servers"     -Path $technovaOU -Description "Servers in het domein"
New-OUSafe -Name "Serviceaccounts" -Path $technovaOU -Description "Service- en applicatieaccounts"

# ─── Niveau 3: Gebruikers-subOU's ────────────────────────────────────────────
$gebruikersOU = "OU=Gebruikers,$technovaOU"

New-OUSafe -Name "Studenten"    -Path $gebruikersOU -Description "Studentaccounts leerjaar 1 en 2"
New-OUSafe -Name "Docenten"     -Path $gebruikersOU -Description "Docentaccounts"
New-OUSafe -Name "Medewerkers"  -Path $gebruikersOU -Description "Overige medewerkers TechNova"
New-OUSafe -Name "Uitgeschakeld"-Path $gebruikersOU -Description "Verlopen of uitgeschakelde accounts"

# ─── Niveau 3: Studenten-subOU's per klas ────────────────────────────────────
$studentenOU = "OU=Studenten,$gebruikersOU"

New-OUSafe -Name "Klas-1A"  -Path $studentenOU -Description "Studenten klas 1A"
New-OUSafe -Name "Klas-1B"  -Path $studentenOU -Description "Studenten klas 1B"
New-OUSafe -Name "Klas-2A"  -Path $studentenOU -Description "Studenten klas 2A"

# ─── Niveau 3: Groepen-subOU's ───────────────────────────────────────────────
$groepenOU = "OU=Groepen,$technovaOU"

New-OUSafe -Name "Scrum-Teams"  -Path $groepenOU -Description "Groepen per Scrum-team"
New-OUSafe -Name "Toegang"      -Path $groepenOU -Description "Toegangsgroepen voor resources"
New-OUSafe -Name "Rollen"       -Path $groepenOU -Description "Rolgebaseerde groepen"

# ─── Niveau 3: Computers-subOU's ─────────────────────────────────────────────
$computersOU = "OU=Computers,$technovaOU"

New-OUSafe -Name "Werkstations" -Path $computersOU -Description "Student en docent werkstations"
New-OUSafe -Name "Laptops"      -Path $computersOU -Description "Laptops"

Write-Log "=== OU-structuur aanmaken voltooid ==="
Write-Log "Logbestand: $LogFile"
Write-Host ""
Write-Host "Overzicht aangemaakte structuur:" -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=TechNova,$Domain" |
    Select-Object Name, DistinguishedName |
    Sort-Object DistinguishedName |
    Format-Table -AutoSize
