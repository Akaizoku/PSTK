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

| CommandType | Name                  | Version | Source |
| ----------- | --------------------- | ------- | ------ |
| Function    | Compare-Hashtable     | 1.0.0   | PSTK   |
| Function    | Compare-Properties    | 1.0.0   | PSTK   |
| Function    | Complete-RelativePath | 1.0.0   | PSTK   |
| Function    | Convert-FileEncoding  | 1.0.0   | PSTK   |
| Function    | ConvertTo-NaturalSort | 1.0.0   | PSTK   |
| Function    | ConvertTo-PDF         | 1.0.0   | PSTK   |
| Function    | Copy-OrderedHashtable | 1.0.0   | PSTK   |
| Function    | Format-String         | 1.0.0   | PSTK   |
| Function    | Get-Object            | 1.0.0   | PSTK   |
| Function    | Get-Properties        | 1.0.0   | PSTK   |
| Function    | New-DynamicParameter  | 1.0.0   | PSTK   |
| Function    | Rename-NumberedFile   | 1.0.0   | PSTK   |
| Function    | Set-Tags              | 1.0.0   | PSTK   |
| Function    | Start-Script          | 1.0.0   | PSTK   |
| Function    | Stop-Script           | 1.0.0   | PSTK   |
| Function    | Test-SQLConnection    | 1.0.0   | PSTK   |
| Function    | Write-Log             | 1.0.0   | PSTK   |

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
