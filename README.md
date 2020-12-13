This module is automatically generated with https://github.com/hanneshayashi/crescengo and https://github.com/PowerShell/crescendo.

It is still very much experimental, but it **should** provide basic functionality for [GSM](https://github.com/hanneshayashi/gsm).

Before using the module, make sure you have installed the GSM executable to somewhere in your PATH and set up GSM with a working configuration (see https://gsm.hayashi-ke.online/setup for instructions).

You can load the module by simply invoking

```powershell
Import-Module ./GSM.psm1
```

Afterwards, you should have PowerShell-Commandlets for all [GSM commands](https://gsm.hayashi-ke.online/gsm), like

```powershell
List-GSMUsers
```

```powershell
Delete-GSMFile -FileId <FileId>
```

```powershell
SignOut-GSMUsersRecursive -OrgUnit <OrgUnit>
```

etc.

To get a list of the available commands, you can call 

```powershell
Get-Command *GSM*
```

or, to get help for a specific function:

```powershell
Get-Help Create-GSMDrives
```