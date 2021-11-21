# PowerShell Tool Kit

PowerShell Tool Kit (PSTK) is a library containing a collection of useful PowerShell functions and procedures.

## Usage

### Installation

There are two methods of setting up the PowerShell Tool Kit module on your system:

1. Download the PSTK module from the [GitHub repository](https://github.com/Akaizoku/PSTK);
1. Install the PSTK module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSTK).

```powershell
Install-Module -Name "PSTK" -Repository "PSGallery"
```

### Import

```powershell
Import-Module -Name "PSTK"
```

### List available functions

```powershell
Get-Command -Module "PSTK"
```

| CommandType | Name                        | Version | Source |
| ----------- | --------------------------- | ------: | ------ |
| Function    | Compare-Hashtable           |   1.2.5 | PSTK   |
| Function    | Compare-Properties          |   1.2.5 | PSTK   |
| Function    | Compare-Version             |   1.2.5 | PSTK   |
| Function    | Complete-RelativePath       |   1.2.5 | PSTK   |
| Function    | Confirm-Prompt              |   1.2.5 | PSTK   |
| Function    | Convert-FileEncoding        |   1.2.5 | PSTK   |
| Function    | ConvertTo-JavaProperty      |   1.2.5 | PSTK   |
| Function    | ConvertTo-NaturalSort       |   1.2.5 | PSTK   |
| Function    | ConvertTo-PDF               |   1.2.5 | PSTK   |
| Function    | ConvertTo-RegularExpression |   1.2.5 | PSTK   |
| Function    | Copy-Object                 |   1.2.5 | PSTK   |
| Function    | Copy-OrderedHashtable       |   1.2.5 | PSTK   |
| Function    | Expand-CompressedFile       |   1.2.5 | PSTK   |
| Function    | Find-Key                    |   1.2.5 | PSTK   |
| Function    | Format-String               |   1.2.5 | PSTK   |
| Function    | Get-CallerPreference        |   1.2.5 | PSTK   |
| Function    | Get-EnvironmentVariable     |   1.2.5 | PSTK   |
| Function    | Get-HTTPStatus              |   1.2.5 | PSTK   |
| Function    | Get-KeyValue                |   1.2.5 | PSTK   |
| Function    | Get-Object                  |   1.2.5 | PSTK   |
| Function    | Get-Path                    |   1.2.5 | PSTK   |
| Function    | Get-Properties              |   1.2.5 | PSTK   |
| Function    | Get-URI                     |   1.2.5 | PSTK   |
| Function    | Import-CSVProperties        |   1.2.5 | PSTK   |
| Function    | Import-Function             |   1.2.5 | PSTK   |
| Function    | Import-Properties           |   1.2.5 | PSTK   |
| Function    | Invoke-OracleCmd            |   1.2.5 | PSTK   |
| Function    | New-DynamicParameter        |   1.2.5 | PSTK   |
| Function    | New-RandomPassword          |   1.2.5 | PSTK   |
| Function    | New-SelfContainedPackage    |   1.2.5 | PSTK   |
| Function    | Out-Hashtable               |   1.2.5 | PSTK   |
| Function    | Protect-WindowsCmdValue     |   1.2.5 | PSTK   |
| Function    | Remove-EnvironmentVariable  |   1.2.5 | PSTK   |
| Function    | Remove-Object               |   1.2.5 | PSTK   |
| Function    | Rename-NumberedFile         |   1.2.5 | PSTK   |
| Function    | Resolve-Array               |   1.2.5 | PSTK   |
| Function    | Resolve-Boolean             |   1.2.5 | PSTK   |
| Function    | Resolve-Tags                |   1.2.5 | PSTK   |
| Function    | Resolve-URI                 |   1.2.5 | PSTK   |
| Function    | Select-XMLNode              |   1.2.5 | PSTK   |
| Function    | Set-EnvironmentVariable     |   1.2.5 | PSTK   |
| Function    | Set-RelativePath            |   1.2.5 | PSTK   |
| Function    | Set-Tags                    |   1.2.5 | PSTK   |
| Function    | Start-Script                |   1.2.5 | PSTK   |
| Function    | Stop-AllTranscripts         |   1.2.5 | PSTK   |
| Function    | Stop-Script                 |   1.2.5 | PSTK   |
| Function    | Sync-EnvironmentVariable    |   1.2.5 | PSTK   |
| Function    | Test-EnvironmentVariable    |   1.2.5 | PSTK   |
| Function    | Test-HTTPStatus             |   1.2.5 | PSTK   |
| Function    | Test-Object                 |   1.2.5 | PSTK   |
| Function    | Test-OracleConnection       |   1.2.5 | PSTK   |
| Function    | Test-Service                |   1.2.5 | PSTK   |
| Function    | Test-SQLConnection          |   1.2.5 | PSTK   |
| Function    | Update-File                 |   1.2.5 | PSTK   |
| Function    | Wait-WebResource            |   1.2.5 | PSTK   |
| Function    | Write-Checksum              |   1.2.5 | PSTK   |
| Function    | Write-ErrorLog              |   1.2.5 | PSTK   |
| Function    | Write-InsertOrUpdate        |   1.2.5 | PSTK   |
| Function    | Write-Log                   |   1.2.5 | PSTK   |

## Dependencies

The `Test-SQLConnection` function requires the `SQLServer` module, or the deprecated `SQLPS` one.

## Roadmap

- [ ] Extend help locales
- [ ] Use [Pester](https://github.com/pester/Pester)
- [ ] Use [AppVeyor](https://www.appveyor.com/)
