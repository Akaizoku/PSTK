# PowerShell Tool Kit

PowerShell Tool Kit (PSTK) is a library containing a useful collection of PowerShell functions and procedures.

## Usage

### Download

Download the PSTK module from the [Github repository](https://github.com/Akaizoku/PSTK) and extract it to your local PowerShell modules repository (`$env:PSModulePath`).

### Import

```powershell
Import-Module -Name PSTK
```

### List available functions

```powershell
Get-Command -Module PSTK
```

| CommandType | Name                       | Version | Source |
| ----------- | -------------------------- | ------- | ------ |
| Function    | Compare-Hashtable          | 1.2.0   | PSTK   |
| Function    | Compare-Properties         | 1.2.0   | PSTK   |
| Function    | Complete-RelativePath      | 1.2.0   | PSTK   |
| Function    | Confirm-Prompt             | 1.2.0   | PSTK   |
| Function    | Convert-FileEncoding       | 1.2.0   | PSTK   |
| Function    | ConvertTo-NaturalSort      | 1.2.0   | PSTK   |
| Function    | ConvertTo-PDF              | 1.2.0   | PSTK   |
| Function    | Copy-OrderedHashtable      | 1.2.0   | PSTK   |
| Function    | Expand-CompressedFile      | 1.2.0   | PSTK   |
| Function    | Find-Key                   | 1.2.0   | PSTK   |
| Function    | Format-String              | 1.2.0   | PSTK   |
| Function    | Get-CallerPreference       | 1.2.0   | PSTK   |
| Function    | Get-EnvironmentVariable    | 1.2.0   | PSTK   |
| Function    | Get-HTTPStatus             | 1.2.0   | PSTK   |
| Function    | Get-KeyValue               | 1.2.0   | PSTK   |
| Function    | Get-Object                 | 1.2.0   | PSTK   |
| Function    | Get-Path                   | 1.2.0   | PSTK   |
| Function    | Get-Properties             | 1.2.0   | PSTK   |
| Function    | Import-CSVProperties       | 1.2.0   | PSTK   |
| Function    | Import-Properties          | 1.2.0   | PSTK   |
| Function    | New-DynamicParameter       | 1.2.0   | PSTK   |
| Function    | Out-Hashtable              | 1.2.0   | PSTK   |
| Function    | Remove-EnvironmentVariable | 1.2.0   | PSTK   |
| Function    | Remove-Object              | 1.2.0   | PSTK   |
| Function    | Rename-NumberedFile        | 1.2.0   | PSTK   |
| Function    | Resolve-Array              | 1.2.0   | PSTK   |
| Function    | Resolve-Boolean            | 1.2.0   | PSTK   |
| Function    | Resolve-Tags               | 1.2.0   | PSTK   |
| Function    | Resolve-URI                | 1.2.0   | PSTK   |
| Function    | Select-XMLNode             | 1.2.0   | PSTK   |
| Function    | Set-EnvironmentVariable    | 1.2.0   | PSTK   |
| Function    | Set-RelativePath           | 1.2.0   | PSTK   |
| Function    | Set-Tags                   | 1.2.0   | PSTK   |
| Function    | Start-Script               | 1.2.0   | PSTK   |
| Function    | Stop-Script                | 1.2.0   | PSTK   |
| Function    | Test-EnvironmentVariable   | 1.2.0   | PSTK   |
| Function    | Test-Object                | 1.2.0   | PSTK   |
| Function    | Test-Service               | 1.2.0   | PSTK   |
| Function    | Test-SQLConnection         | 1.2.0   | PSTK   |
| Function    | Update-File                | 1.2.0   | PSTK   |
| Function    | Write-ErrorLog             | 1.2.0   | PSTK   |
| Function    | Write-Log                  | 1.2.0   | PSTK   |

## Dependencies

The `Test-SQLConnection` function requires the `SQLServer` module, or the deprecated `SQLPS` one.

## Roadmap

-   [ ] Add pipeline support
-   [ ] Use parameter sets
-   [ ] Extend help locales
-   [ ] Define test scenari
-   [ ] Define output formats
-   [ ] Use [Pester](https://github.com/pester/Pester)
-   [ ] Use [AppVeyor](https://www.appveyor.com/)
-   [ ] Publish to [PowerShell Gallery](https://www.powershellgallery.com/)
