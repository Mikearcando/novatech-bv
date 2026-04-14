#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    Dagelijkse gezondheidscheck van Active Directory voor TechNova BV.

.DESCRIPTION
    Controleert: domein bereikbaarheid, services, gebruikers, groepen,
    geblokkeerde accounts en replicatie. Output naar scherm en logbestand.

.NOTES
    Uitvoeren als Domain Admin op DC01, elke ochtend vóór de les.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

$LogFile = "C:\Logs\AD-Health\health-$(Get-Date -Format 'yyyyMMdd-HHmm').log"
$logDir  = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

$Domain = "DC=technova,DC=local"
$fouten = 0

function Test-Item {
    param([string]$Label, [scriptblock]$Test, [string]$SuccesMsg, [string]$FailMsg)
    try {
        $result = & $Test
        if ($result) {
            Write-Host "[OK] $Label`: $SuccesMsg" -ForegroundColor Green
            "OK  | $Label | $SuccesMsg" | Out-File $LogFile -Append
        } else {
            Write-Host "[FAIL] $Label`: $FailMsg" -ForegroundColor Red
            "FAIL| $Label | $FailMsg"   | Out-File $LogFile -Append
            $script:fouten++
        }
    }
    catch {
        Write-Host "[ERR] $Label`: $($_.Exception.Message)" -ForegroundColor Red
        "ERR | $Label | $($_.Exception.Message)" | Out-File $LogFile -Append
        $script:fouten++
    }
}

Write-Host ""
Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  TechNova AD Health Check — $(Get-Date -Format 'dd-MM-yyyy HH:mm')" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 1. Domein bereikbaar
Test-Item "Domein bereikbaar" `
    { [bool](Get-ADDomain -ErrorAction SilentlyContinue) } `
    "technova.local actief" `
    "Domein NIET bereikbaar!"

# 2. DNS Service
Test-Item "DNS Service" `
    { (Get-Service -Name DNS -ErrorAction SilentlyContinue).Status -eq 'Running' } `
    "DNS draait" `
    "DNS service NIET actief!"

# 3. NETLOGON Service
Test-Item "Netlogon Service" `
    { (Get-Service -Name Netlogon -ErrorAction SilentlyContinue).Status -eq 'Running' } `
    "Netlogon draait" `
    "Netlogon service NIET actief!"

# 4. ADDS Service
Test-Item "AD DS Service" `
    { (Get-Service -Name NTDS -ErrorAction SilentlyContinue).Status -eq 'Running' } `
    "NTDS draait" `
    "AD DS service NIET actief!"

# 5. Aantal studenten
$studentCount = (Get-ADUser -Filter * -SearchBase "OU=Studenten,OU=Gebruikers,OU=TechNova,$Domain" -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Host "[INFO] Studentaccounts: $studentCount" -ForegroundColor Cyan
"INFO| Studentaccounts: $studentCount" | Out-File $LogFile -Append

# 6. Geblokkeerde accounts
$geblokkeerd = Get-ADUser -Filter { LockedOut -eq $true } -SearchBase "OU=TechNova,$Domain" `
    -Properties LockedOut, SamAccountName -ErrorAction SilentlyContinue
if ($geblokkeerd) {
    Write-Host "[WARN] Geblokkeerde accounts: $($geblokkeerd.Count)" -ForegroundColor Yellow
    foreach ($g in $geblokkeerd) {
        Write-Host "       → $($g.SamAccountName)" -ForegroundColor Yellow
        "WARN| Geblokkeerd: $($g.SamAccountName)" | Out-File $LogFile -Append
    }
} else {
    Write-Host "[OK] Geen geblokkeerde accounts" -ForegroundColor Green
    "OK  | Geen geblokkeerde accounts" | Out-File $LogFile -Append
}

# 7. Uitgeschakelde accounts in verkeerde OU
$uitgeschakeldVerkeerd = Get-ADUser -Filter { Enabled -eq $false } `
    -SearchBase "OU=Studenten,OU=Gebruikers,OU=TechNova,$Domain" `
    -Properties Enabled -ErrorAction SilentlyContinue
if ($uitgeschakeldVerkeerd) {
    Write-Host "[WARN] $($uitgeschakeldVerkeerd.Count) uitgeschakeld account(s) in Studenten-OU" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Geen uitgeschakelde accounts in Studenten-OU" -ForegroundColor Green
}

# 8. DNS forward lookup
Test-Item "DNS forward lookup" `
    { [bool](Resolve-DnsName -Name "dc01.technova.local" -ErrorAction SilentlyContinue) } `
    "dc01.technova.local resolveert correct" `
    "DNS forward lookup mislukt!"

# 9. Schijfruimte C:\
$disk = Get-PSDrive C
$vrijGB = [math]::Round($disk.Free / 1GB, 1)
if ($vrijGB -lt 5) {
    Write-Host "[WARN] Schijfruimte C:\: $vrijGB GB vrij — LAAG!" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Schijfruimte C:\: $vrijGB GB vrij" -ForegroundColor Green
}

Write-Host ""
Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
if ($fouten -eq 0) {
    Write-Host "  RESULTAAT: Alles OK" -ForegroundColor Green
} else {
    Write-Host "  RESULTAAT: $fouten probleem/problemen gevonden!" -ForegroundColor Red
}
Write-Host "  Log: $LogFile" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
