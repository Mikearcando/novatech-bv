# TICK-010 — Medewerker kan gedeelde map niet openen

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Rechtenproblemen              |
| Prioriteit        | Middel                        |
| Moeilijkheidsgraad| ★★☆ (gemiddeld)              |
| Status            | Open                          |
| SLA               | Vandaag                       |

---

## Probleomschrijving

> "Als ik via Windows Verkenner probeer te openen: \\DC01\Projecten krijg ik
> de fout 'Access Denied. You don't have permission to access this resource.'
> Mijn collega Lena (lvisser) kan die map wel openen. Wij zitten in hetzelfde team."
> — Nour El Amrani (nelam)

---

## Verwachte analyse

Toegangsproblemen op gedeelde mappen hebben twee lagen:
1. **Share permissions** (wie mag de netwerkshare zien)
2. **NTFS permissions** (wie mag het bestand/map op schijf lezen/schrijven)

Beide moeten correct zijn. Controleer ook groepslidmaatschap.

---

## Diagnosestappen

```powershell
# Stap 1: Controleer of share bestaat
Get-SmbShare -Name "Projecten" -ErrorAction SilentlyContinue

# Stap 2: Share permissions bekijken
Get-SmbShareAccess -Name "Projecten"

# Stap 3: NTFS rechten bekijken op de map
$pad = "C:\Shares\Projecten"  # pas aan naar werkelijk pad
Get-Acl -Path $pad | Format-List

# Overzichtelijker:
(Get-Acl -Path $pad).Access |
    Select-Object IdentityReference, FileSystemRights, AccessControlType |
    Format-Table -AutoSize

# Stap 4: Groepslidmaatschap nelam controleren
Get-ADPrincipalGroupMembership -Identity "nelam" | Select-Object Name

# Stap 5: Controleer of GRP-FileShare-Lezen rechten heeft op de map
# Welke groepen hebben toegang?
(Get-Acl -Path $pad).Access |
    Where-Object { $_.IdentityReference -like "*GRP*" -or $_.IdentityReference -like "*Team*" }
```

---

## Oplossing

```powershell
# Stap 1: Voeg nelam toe aan de toegangsgroep
Add-ADGroupMember -Identity "GRP-FileShare-Lezen" -Members "nelam"

# Als de groep zelf geen toegang heeft tot de map:
# NTFS rechten instellen voor GRP-FileShare-Lezen:
$pad = "C:\Shares\Projecten"
$acl = Get-Acl -Path $pad

$regel = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "TECHNOVA\GRP-FileShare-Lezen",
    "Read",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.AddAccessRule($regel)
Set-Acl -Path $pad -AclObject $acl

# Share permissions controleren en aanpassen indien nodig:
Grant-SmbShareAccess -Name "Projecten" `
    -AccountName "TECHNOVA\GRP-FileShare-Lezen" `
    -AccessRight Read -Force
```

---

## Verificatie

- [ ] `nelam` is lid van `GRP-FileShare-Lezen`
- [ ] `Get-Acl` toont leesrechten voor de groep
- [ ] `nelam` kan `\\DC01\Projecten` openen
- [ ] `nelam` kan bestaande bestanden lezen maar niet verwijderen (alleen Read)

---

## Leerdoel

- NTFS vs. Share permissions onderscheid
- Groepsgebaseerd toegangsbeheer (RBAC principe)
- Get-Acl / Set-Acl gebruiken
- Debugging: welke laag blokkeert?
