#Requires -Modules ActiveDirectory
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Reset wachtwoorden voor een of alle studenten in TechNova BV.

.DESCRIPTION
    Biedt drie modi:
    - Enkeling : Reset één student
    - Team     : Reset alle studenten in een team
    - Allemaal : Reset alle studenten

.PARAMETER Modus
    "Enkeling", "Team" of "Allemaal"

.PARAMETER Gebruikersnaam
    SamAccountName van de student (bij modus Enkeling).

.PARAMETER Team
    Teamgroepnaam, bv. "Team-Infra-Alpha" (bij modus Team).

.PARAMETER NieuwWachtwoord
    Nieuw wachtwoord. Default: Student2024!

.EXAMPLE
    .\Reset-StudentPasswords.ps1 -Modus Enkeling -Gebruikersnaam "jjansen"
    .\Reset-StudentPasswords.ps1 -Modus Team -Team "Team-Cloud-Alpha"
    .\Reset-StudentPasswords.ps1 -Modus Allemaal
#>

param(
    [ValidateSet("Enkeling","Team","Allemaal")]
    [string]$Modus           = "Enkeling",
    [string]$Gebruikersnaam  = "",
    [string]$Team            = "",
    [string]$NieuwWachtwoord = "Student2024!"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

$securePassword = ConvertTo-SecureString $NieuwWachtwoord -AsPlainText -Force
$Domain = "DC=technova,DC=local"
$gereset = 0; $fouten = 0

function Reset-Account {
    param([string]$Sam)
    try {
        Set-ADAccountPassword -Identity $Sam -NewPassword $securePassword -Reset
        Enable-ADAccount -Identity $Sam
        Unlock-ADAccount -Identity $Sam
        Write-Host "[OK] $Sam — wachtwoord gereset en account ontgrendeld" -ForegroundColor Green
        $script:gereset++
    }
    catch {
        Write-Host "[FOUT] $Sam — $($_.Exception.Message)" -ForegroundColor Red
        $script:fouten++
    }
}

switch ($Modus) {
    "Enkeling" {
        if (-not $Gebruikersnaam) { Write-Host "Geef -Gebruikersnaam op." -ForegroundColor Red; exit 1 }
        Reset-Account -Sam $Gebruikersnaam
    }
    "Team" {
        if (-not $Team) { Write-Host "Geef -Team op, bv. 'Team-Infra-Alpha'." -ForegroundColor Red; exit 1 }
        $leden = Get-ADGroupMember -Identity $Team -Recursive | Where-Object { $_.objectClass -eq 'user' }
        if (-not $leden) { Write-Host "Geen leden gevonden in '$Team'." -ForegroundColor Yellow; exit 0 }
        foreach ($lid in $leden) { Reset-Account -Sam $lid.SamAccountName }
    }
    "Allemaal" {
        $bevestig = Read-Host "Reset ALLE studentenwachtwoorden naar '$NieuwWachtwoord'? (ja/nee)"
        if ($bevestig -ne "ja") { Write-Host "Geannuleerd."; exit 0 }
        $studenten = Get-ADUser -Filter * `
            -SearchBase "OU=Studenten,OU=Gebruikers,OU=TechNova,$Domain" `
            -Properties SamAccountName
        foreach ($s in $studenten) { Reset-Account -Sam $s.SamAccountName }
    }
}

Write-Host ""
Write-Host "Gereset: $gereset | Fouten: $fouten" -ForegroundColor Cyan
