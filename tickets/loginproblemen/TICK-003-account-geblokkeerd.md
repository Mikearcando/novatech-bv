# TICK-003 — Gebruiker kan niet inloggen — account geblokkeerd

| Veld              | Waarde                        |
|-------------------|-------------------------------|
| Categorie         | Loginproblemen                |
| Prioriteit        | Hoog                          |
| Moeilijkheidsgraad| ★☆☆ (beginner)               |
| Status            | Open                          |
| SLA               | Binnen 30 minuten             |

---

## Probleemomschrijving

Medewerker Ravi Sharma (rsharma) belt de helpdesk:

> "Ik kan niet meer inloggen op mijn Windows account. Ik had gisteren mijn wachtwoord
> fout getypt en nu krijg ik de melding 'Your account has been locked out'.
> Ik heb een vergadering over 10 minuten en moet dringend bij mijn bestanden."

---

## Verwachte analyse

1. Controleer of het account `rsharma` inderdaad geblokkeerd is
2. Controleer in het Event Log van DC01 wanneer het geblokkeerd werd en hoe vaak het wachtwoord fout was
3. Ontgrendel het account
4. Verifieer dat de gebruiker weer kan inloggen

---

## Diagnosecommando's

```powershell
# Is het account geblokkeerd?
Get-ADUser -Identity "rsharma" -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt |
    Select-Object Name, LockedOut, BadLogonCount, LastBadPasswordAttempt

# Alle geblokkeerde accounts vinden
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName

# Event Log controleren op DC01
Get-EventLog -LogName Security -InstanceId 4740 -Newest 10 |
    Where-Object {$_.Message -like "*rsharma*"} |
    Select-Object TimeGenerated, Message
```

---

## Oplossing

```powershell
# Account ontgrendelen
Unlock-ADAccount -Identity "rsharma"

# Controleer of het gelukt is:
Get-ADUser -Identity "rsharma" -Properties LockedOut | Select-Object Name, LockedOut
# LockedOut moet False zijn

# Optioneel: wachtwoord resetten als gebruiker ook wachtwoord vergeten is
Set-ADAccountPassword -Identity "rsharma" -Reset `
    -NewPassword (ConvertTo-SecureString "Student2024!" -AsPlainText -Force)
```

---

## Verificatie

- [ ] `LockedOut` is `False` in AD
- [ ] Gebruiker kan inloggen op Windows (test met de gebruiker zelf)
- [ ] Inlogtijd normaal (niet meer dan 2 pogingen)

---

## Leerdoel

- Account lockout herkennen en oplossen
- Event Log gebruiken voor diagnose
- Verschil tussen uitgeschakeld en geblokkeerd begrijpen
- Helpdesk communicatie: snel en duidelijk oplossen
