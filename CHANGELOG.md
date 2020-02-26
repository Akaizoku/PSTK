# Changelog
All notable changes to the [PSTK](https://github.com/Akaizoku/PSTK) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.3](https://github.com/Akaizoku/PSTK/releases/tag/1.2.3) - 2020-03-26

Oracle update

## Added
The following functions have been added:
-   ConvertTo-JavaProperty
-   Invoke-OracleCmd
-   Test-OracleConnection

### Changed
The following functions have been updated:
-   Compare-Version: Updated parsing method
-   Test-SQLConnection: Explicitly define parameters in SQL connection string
-   Resolve-URI: Added encoding for reserved characters
-   Write-Checksum: Added an exclusion parameter
-   Write-InsertOrUpdate: Added Oracle syntax

## [1.2.2](https://github.com/Akaizoku/PSTK/releases/tag/1.2.2) - 2020-01-13

Utility update

### Added
The following functions have been added:
-   Compare-Version
-   Get-URI
-   Import-Function
-   Protect-WindowsCmdValue
-   Sync-EnvironmentVariable
-   Test-HTTPStatus
-   Wait-WebResource
-   Write-Checksum
-   Write-InsertOrUpdate

### Changed
The following functions have been updated:
-   Resolve-Boolean: Redesigned to be a generic utility
-   Resolve-URI: Fixed an issue causing it to only resolve the last restricted character of the list
-   Stop-Script: Renamed error code parameter to exit code (aliases have been set for retro-compatibility)
-   Write-Log: Renamed error code parameter to exit code (aliases have been set for retro-compatibility)
-   Write-ErrorLog: Renamed error code parameter to exit code (aliases have been set for retro-compatibility)

## [1.2.1](https://github.com/Akaizoku/PSTK/releases/tag/1.2.1) - 2019-10-01

Hotfix to enable overwriting empty properties.

### Added
-   Published module to PowerShell gallery

### Changed
The following functions have been updated:
-   Get-Properties
-   Import-Properties

## [1.2.0](https://github.com/Akaizoku/PSTK/releases/tag/1.2.0) - 2019-09-12

Expansion

### Added
The following functions have been added:
-   Confirm-Prompt
-   Expand-CompressedFile
-   Find-Key
-   Get-CallerPreference
-   Get-EnvironmentVariable
-   Get-HTTPStatus
-   Get-KeyValue
-   Get-Path
-   Import-CSVProperties
-   Import-Properties
-   Out-Hashtable
-   Remove-EnvironmentVariable
-   Remove-Object
-   Resolve-Array
-   Resolve-Boolean
-   Resolve-Tags
-   Resolve-URI
-   Select-XMLNode
-   Set-EnvironmentVariable
-   Set-RelativePath
-   Test-EnvironmentVariable
-   Test-Object
-   Test-Service
-   Update-File
-   Write-ErrorLog

### Changed
The following functions have been updated:
-   Compare-Hashtable
-   Compare-Properties
-   Complete-RelativePath
-   Convert-FileEncoding
-   Get-Object
-   Test-Object
-   Test-SQLConnection
-   Write-Log

## [1.1.0](https://github.com/Akaizoku/PSTK/releases/tag/1.1.0) - 2018-10-15

Restructuring

### Added
Added about_help (GB and US)

### Changed
Updated folder structure
Updated README

### Removed
The following functions have been marked as internal and are no longer public:
-   Add-Offset
-   ConvertTo-TitleCase
-   Measure-FileProperty
-   Read-Properties
-   Read-Property
-   Show-ExceptionFullName
-   Test-Alphanumeric

## [1.0.0](https://github.com/Akaizoku/PSTK/releases/tag/1.0.0) - 2018-10-05

First stable release

### Added
Module manifest, README, LICENSE, and CHANGELOG.
