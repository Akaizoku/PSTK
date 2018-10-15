# ------------------------------------------------------------------------------
# Properties setting function
# ------------------------------------------------------------------------------
function Get-Properties {
  <#
    .SYNOPSIS
    Get properties from configuration files

    .DESCRIPTION
    Get properties from configuration files

    .PARAMETER File
    The File parameter should be the name of the property file.

    .PARAMETER Directory
    The Directory parameter should be the path to the directory containing the
    property file.

    .PARAMETER Custom
    The Custom parameter should be the name of the custom property file.

    .PARAMETER CustomDirectory
    The CustomDirectory parameter should be the path to the directory containing
     the custom property file.

    .OUTPUTS
    System.Collections.Specialized.OrderedDictionary. Get-Properties returns an
    ordered hash table containing the names and values of the properties listed
    in the property files.

    .EXAMPLE
    Get-Properties -File "default.ini" -Directory ".\conf" -Custom "custom.ini" -CustomDirectory "\\shared"

    In this example, Get-Properties will read properties from the default.ini
    file contained in the .\conf directory, then read the properties from
    in the custom.ini file contained in the \\shared directory, and override the
    default ones with the custom ones.

    .NOTES
    Get-Properties does not currently allow the use of sections to group proper-
    ties in custom files
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property file name"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property files"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Directory,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Custom property file name"
    )]
    [String]
    $Custom,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Path to the directory containing the custom property file"
    )]
    [String]
    $CustomDirectory = $Directory,
    [Parameter (
      Position    = 5,
      Mandatory   = $false,
      HelpMessage = "Define if section headers should be used to group properties or be ignored"
      )]
    [Switch]
    $Section
  )
  # Check that specified file exists
  if (Test-Path -Path "$Directory\$File") {
    # Parse properties with or without section split
    if ($Section) {
      $Properties = Read-Properties -File $File -Directory $Directory -Section
    } else {
      $Properties = Read-Properties -File $File -Directory $Directory
    }
    # Check if a custom file is provided
    if ($Custom) {
      # Make sure said file does exists
      if (Test-Path -Path "$CustomDirectory\$Custom") {
        # Override default properties with custom ones
        $Customs = Read-Properties -File $Custom -Directory $CustomDirectory
        foreach ($Property in $Customs.Keys) {
          # Override default with custom
          if ($Properties.$Property) {
            $Properties.$Property = $Customs.$Property
          } else {
            Write-Log -Type "WARN" -Message "The ""$Property"" property defined in $Custom is unknown"
          }
        }
      } else {
        Write-Log -Type "WARN" -Message "$Custom not found in directory $CustomDirectory"
      }
    }
    return $Properties
  } else {
    Write-Log -Type "ERROR" -Message "$File not found in directory $Directory"
    Stop-Script 1
  }
}
