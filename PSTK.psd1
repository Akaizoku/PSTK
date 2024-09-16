#
# Module manifest for module 'PSTK'
#
# Generated by: Florian Carrier
#
# Generated on: 16/09/2024
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSTK.psm1'

# Version number of this module.
ModuleVersion = '1.2.6'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '065d3e48-45c0-4b6b-9052-b92fe22b4e51'

# Author of this module
Author = 'Florian Carrier'

# Company or vendor of this module
CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = '(c) 2019-2024 Florian Carrier. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Collection of useful functions and procedures for PowerShell scripting'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Compare-Hashtable', 'Compare-Properties', 'Compare-Version', 
               'Complete-RelativePath', 'Confirm-Prompt', 'Convert-FileEncoding', 
               'ConvertTo-JavaProperty', 'ConvertTo-NaturalSort', 'ConvertTo-PDF', 
               'ConvertTo-RegularExpression', 'Copy-Object', 'Copy-OrderedHashtable', 
               'Expand-CompressedFile', 'Find-Key', 'Format-String', 
               'Get-CallerPreference', 'Get-EnvironmentVariable', 'Get-HTTPStatus', 
               'Get-KeyValue', 'Get-Object', 'Get-Path', 'Get-Properties', 'Get-URI', 
               'Import-CSVProperties', 'Import-Function', 'Import-Properties', 
               'Invoke-OracleCmd', 'New-DynamicParameter', 'New-ProcessObject', 
               'New-RandomPassword', 'New-SelfContainedPackage', 'Out-Hashtable', 
               'Ping-Host', 'Protect-WindowsCmdValue', 'Remove-EnvironmentVariable', 
               'Remove-Object', 'Rename-NumberedFile', 'Resolve-Array', 
               'Resolve-Boolean', 'Resolve-Tags', 'Resolve-URI', 'Select-XMLNode', 
               'Set-EnvironmentVariable', 'Set-RelativePath', 'Set-Tags', 
               'Show-EnvironmentVariables', 'Start-Script', 'Stop-AllTranscripts', 
               'Stop-Script', 'Sync-EnvironmentVariable', 'Test-EnvironmentVariable', 
               'Test-HTTPStatus', 'Test-Object', 'Test-OracleConnection', 
               'Test-Service', 'Test-SQLConnection', 'Update-File', 
               'Update-ProcessObject', 'Wait-WebResource', 'Write-Checksum', 
               'Write-ErrorLog', 'Write-InsertOrUpdate', 'Write-Log'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'PowerShell','PS','PoSh','Tool','ToolKit','Utility'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/Akaizoku/PSTK/blob/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/Akaizoku/PSTK'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'https://github.com/Akaizoku/PSTK/blob/main/CHANGELOG.md'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/Akaizoku/PSTK/blob/main/README.md'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

