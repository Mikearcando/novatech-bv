#Requires -Modules ActiveDirectory
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Maakt alle Active Directory groepen aan voor TechNova BV.

.DESCRIPTION
    Scrum-teams, toegangsgroepen, rolgroepen en distributielijsten.
    Voer dit script UIT nadat New-OUStructure.ps1 is uitgevoerd.

.NOTES
    Uitvoeren als Domain Admin op DC01.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Domain    = "DC=technova,DC=local"
$LogFile   = "C:\Logs\AD-Setup\groepen-$(Get-Date -Format 'yyyyMMdd-HHmm').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$Level] $Message"
    Write-Host $line -ForegroundColor $(switch ($Level) {
        "OK"    { "Green"  }; "SKIP" { "Yellow" }; "ERROR" { "Red" }; default { "White" }
    })
    $line | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

function New-GroupSafe {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Description   = "",
        [string]$GroupScope    = "Global",
        [string]$GroupCategory = "Security"
    )
    try {
        if (Get-ADGroup -Filter "Name -eq '$Name'" -ErrorAction SilentlyContinue) {
            Write-Log "SKIP: Groep '$Name' bestaat al" "SKIP"; return
        }
        New-ADGroup -Name $Name -SamAccountName $Name -GroupScope $GroupScope `
            -GroupCategory $GroupCategory -Path $Path -Description $Description
        Write-Log "OK: Groep '$Name' aangemaakt" "OK"
    }
    catch { Write-Log "ERROR bij '$Name': $($_.Exception.Message)" "ERROR" }
}

# Log directory
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

Write-Log "=== Groepen aanmaken TechNova BV ==="

# ─── Paden ───────────────────────────────────────────────────────────────────
$scrumPath  = "OU=Scrum-Teams,OU=Groepen,OU=TechNova,$Domain"
$toegangPath= "OU=Toegang,OU=Groepen,OU=TechNova,$Domain"
$rollenPath = "OU=Rollen,OU=Groepen,OU=TechNova,$Domain"

# ─── Scrum Teams (1 groep per team) ─────────────────────────────────────────
Write-Log "--- Scrum-teamgroepen ---"
$scrumTeams = @(
    @{ Name = "Team-Infra-Alpha";   Desc = "Scrum Team Infrastructure Alpha" },
    @{ Name = "Team-Infra-Beta";    Desc = "Scrum Team Infrastructure Beta"  },
    @{ Name = "Team-Cloud-Alpha";   Desc = "Scrum Team Cloud Alpha"          },
    @{ Name = "Team-Cloud-Beta";    Desc = "Scrum Team Cloud Beta"           },
    @{ Name = "Team-Ops-Alpha";     Desc = "Scrum Team Operations Alpha"     },
    @{ Name = "Team-Ops-Beta";      Desc = "Scrum Team Operations Beta"      },
    @{ Name = "Team-Support";       Desc = "Scrum Team Support"              },
    @{ Name = "Team-Security";      Desc = "Scrum Team Security"             },
    @{ Name = "Team-DevOps";        Desc = "Scrum Team DevOps"               }
)
foreach ($t in $scrumTeams) {
    New-GroupSafe -Name $t.Name -Path $scrumPath -Description $t.Desc
}

# ─── Toegangsgroepen ─────────────────────────────────────────────────────────
Write-Log "--- Toegangsgroepen ---"
$toegangGroepen = @(
    @{ Name = "GRP-CloudUsers";       Desc = "Toegang tot OpenStack Horizon dashboard"        },
    @{ Name = "GRP-ServerAdmins";     Desc = "Beheerdersrechten op Windows Servers"           },
    @{ Name = "GRP-FileShare-Lezen";  Desc = "Leestoegang op gedeelde mappen"                 },
    @{ Name = "GRP-FileShare-Schrijven"; Desc = "Schrijftoegang op gedeelde mappen"           },
    @{ Name = "GRP-RDP-Users";        Desc = "Remote Desktop toegang tot servers"             },
    @{ Name = "GRP-PrintUsers";       Desc = "Toegang tot netwerkprinters"                    },
    @{ Name = "GRP-VPN-Users";        Desc = "Toegang tot VPN (toekomstig)"                   },
    @{ Name = "GRP-Docenten";         Desc = "Docentaccounts met uitgebreide rechten"         }
)
foreach ($g in $toegangGroepen) {
    New-GroupSafe -Name $g.Name -Path $toegangPath -Description $g.Desc
}

# ─── Rolgroepen ──────────────────────────────────────────────────────────────
Write-Log "--- Rolgroepen ---"
$rolGroepen = @(
    @{ Name = "ROL-ScrumMaster";   Desc = "Studenten met de rol Scrum Master deze sprint"  },
    @{ Name = "ROL-ProductOwner";  Desc = "Studenten met de rol Product Owner deze sprint" },
    @{ Name = "ROL-Developer";     Desc = "Studenten met de rol Developer deze sprint"     },
    @{ Name = "ROL-Beheerder";     Desc = "Studenten met beheerdersrol (rotatie)"          }
)
foreach ($r in $rolGroepen) {
    New-GroupSafe -Name $r.Name -Path $rollenPath -Description $r.Desc
}

# ─── Distributielijsten (Mail, nice to have) ─────────────────────────────────
Write-Log "--- Distributielijsten ---"
New-GroupSafe -Name "DL-AlleStudenten"  -Path $scrumPath `
    -Description "Alle studenten TechNova leeromgeving" `
    -GroupCategory "Distribution"
New-GroupSafe -Name "DL-AlleDocenten"   -Path $scrumPath `
    -Description "Alle docenten" `
    -GroupCategory "Distribution"

Write-Log "=== Groepen aanmaken voltooid ==="
Write-Log "Totaal groepen aangemaakt (check log voor details): $LogFile"

Write-Host ""
Write-Host "Overzicht aangemaakte groepen:" -ForegroundColor Cyan
Get-ADGroup -Filter * -SearchBase "OU=Groepen,OU=TechNova,$Domain" |
    Select-Object Name, GroupScope, GroupCategory |
    Sort-Object Name |
    Format-Table -AutoSize
