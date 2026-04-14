#Requires -Modules ActiveDirectory
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Maakt alle studentaccounts aan voor TechNova BV (45 studenten).

.DESCRIPTION
    Leest studenten uit een CSV-bestand, maakt accounts aan in de
    juiste OU, voegt ze toe aan de teamgroep en de algemene
    studentengroep. Genereert ook een overzichtsbestand met
    inloggegevens voor de docent.

.PARAMETER CsvPath
    Pad naar het CSV-bestand met studenten.
    Kolommen: Voornaam;Achternaam;Klas;Team

.PARAMETER DefaultPassword
    Standaardwachtwoord. Student moet dit wijzigen bij eerste login
    als -ForcePasswordChange gebruikt wordt.

.PARAMETER ForcePasswordChange
    Als $true moet de student het wachtwoord wijzigen bij eerste login.
    Zet op $false voor de leeromgeving zodat students niet vergeten.

.EXAMPLE
    .\New-TechNovaStudents.ps1 -CsvPath ".\studenten.csv"
    .\New-TechNovaStudents.ps1 -CsvPath ".\studenten.csv" -ForcePasswordChange $false

.NOTES
    Uitvoeren als Domain Admin op DC01.
    Voer EERST New-OUStructure.ps1 en New-ADGroups.ps1 uit.
#>

param(
    [string]$CsvPath            = ".\studenten.csv",
    [string]$DefaultPassword    = "Student2024!",
    [bool]  $ForcePasswordChange = $false,
    [string]$OutputCsv          = "C:\Logs\AD-Setup\student-accounts-$(Get-Date -Format 'yyyyMMdd').csv"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Domain  = "DC=technova,DC=local"
$LogFile = "C:\Logs\AD-Setup\studenten-$(Get-Date -Format 'yyyyMMdd-HHmm').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$Level] $Message"
    Write-Host $line -ForegroundColor $(switch ($Level) {
        "OK"    { "Green"  }; "SKIP" { "Yellow" }; "WARN" { "Magenta" }
        "ERROR" { "Red"    }; default { "White" }
    })
    $line | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# Log/output directories aanmaken
foreach ($dir in @((Split-Path $LogFile -Parent), (Split-Path $OutputCsv -Parent))) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

# ─── Validaties ──────────────────────────────────────────────────────────────
if (-not (Test-Path $CsvPath)) {
    Write-Log "CSV-bestand niet gevonden: $CsvPath" "ERROR"
    exit 1
}

$securePassword = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force
$aangemaakt = 0
$overgeslagen = 0
$fouten = 0
$outputData = [System.Collections.Generic.List[PSObject]]::new()

Write-Log "=== Studentaccounts aanmaken TechNova BV ==="
Write-Log "CSV: $CsvPath"
Write-Log "Wachtwoord wijzigen bij login: $ForcePasswordChange"

$studenten = Import-Csv -Path $CsvPath -Delimiter ";" -Encoding UTF8

foreach ($s in $studenten) {
    # Gebruikersnaam genereren: voornaam + eerste letter achternaam + eventueel getal bij duplicaat
    $baseName = ($s.Voornaam.ToLower().Trim() -replace '[^a-z0-9]', '') +
                ($s.Achternaam.ToLower().Trim() -replace '[^a-z0-9]', '')[0]
    $username = $baseName

    # Uniekheid waarborgen
    $counter = 1
    while (Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue) {
        $username = "$baseName$counter"
        $counter++
    }

    $displayName  = "$($s.Voornaam.Trim()) $($s.Achternaam.Trim())"
    $upn          = "$username@technova.local"
    $klas         = $s.Klas.Trim()
    $team         = $s.Team.Trim()

    # OU bepalen
    $ouPath = "OU=$klas,OU=Studenten,OU=Gebruikers,OU=TechNova,$Domain"
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'" -ErrorAction SilentlyContinue)) {
        # Fallback naar hoofd Studenten OU als klas-OU niet bestaat
        $ouPath = "OU=Studenten,OU=Gebruikers,OU=TechNova,$Domain"
        Write-Log "WARN: Klas-OU '$klas' niet gevonden, fallback naar Studenten OU" "WARN"
    }

    try {
        New-ADUser `
            -Name              $displayName `
            -GivenName         $s.Voornaam.Trim() `
            -Surname           $s.Achternaam.Trim() `
            -SamAccountName    $username `
            -UserPrincipalName $upn `
            -Path              $ouPath `
            -AccountPassword   $securePassword `
            -Enabled           $true `
            -PasswordNeverExpires (-not $ForcePasswordChange) `
            -ChangePasswordAtLogon $ForcePasswordChange `
            -Description       "Student | Klas: $klas | Team: $team" `
            -Department        "IT Operations" `
            -Company           "TechNova BV" `
            -Title             "Junior Systeembeheerder (Student)"

        # Toevoegen aan teamgroep
        $teamGroup = "Team-$team"
        if (Get-ADGroup -Filter "Name -eq '$teamGroup'" -ErrorAction SilentlyContinue) {
            Add-ADGroupMember -Identity $teamGroup -Members $username
        } else {
            Write-Log "WARN: Teamgroep '$teamGroup' niet gevonden" "WARN"
        }

        # Toevoegen aan algemene studentengroep
        Add-ADGroupMember -Identity "DL-AlleStudenten" -Members $username -ErrorAction SilentlyContinue

        Write-Log "OK: $username ($displayName) | Klas: $klas | Team: $team" "OK"
        $aangemaakt++

        $outputData.Add([PSCustomObject]@{
            Gebruikersnaam = $username
            Volledige_Naam = $displayName
            UPN            = $upn
            Klas           = $klas
            Team           = $team
            Wachtwoord     = $DefaultPassword
            OU             = $ouPath
        })
    }
    catch {
        Write-Log "ERROR bij '$displayName': $($_.Exception.Message)" "ERROR"
        $fouten++
    }
}

# ─── Output CSV voor docent ───────────────────────────────────────────────────
if ($outputData.Count -gt 0) {
    $outputData | Export-Csv -Path $OutputCsv -Delimiter ";" -Encoding UTF8 -NoTypeInformation
    Write-Log "Accountoverzicht opgeslagen: $OutputCsv"
}

# ─── Samenvatting ────────────────────────────────────────────────────────────
Write-Log "=== Samenvatting ==="
Write-Log "Aangemaakt  : $aangemaakt"
Write-Log "Overgeslagen: $overgeslagen"
Write-Log "Fouten      : $fouten"
Write-Log "Logbestand  : $LogFile"
Write-Log "Accountlijst: $OutputCsv"

if ($fouten -gt 0) {
    Write-Host "`nLET OP: $fouten fout(en) opgetreden. Controleer: $LogFile" -ForegroundColor Red
}
