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
      HelpMessage = "List of properties to check"
    )]
    [String[]]
    $ValidateSet,
    [Parameter (
      HelpMessage = "Define if section headers should be used to group properties or be ignored"
      )]
    [Switch]
    $Section
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Check that specified file exists
    $Path = Join-Path -Path $Directory -ChildPath $File
    if (Test-Path -Path $Path) {
      # Parse properties with or without section split
      $Properties = Read-Properties -Path $Path -Section:$Section
      # Check if a custom file is provided
      if ($Custom) {
        # Make sure said file does exists
        $CustomPath = Join-Path -Path $CustomDirectory -ChildPath $Custom
        if (Test-Path -Path $CustomPath) {
          # Override default properties with custom ones
          $Customs = Read-Properties -Path $CustomPath
          foreach ($Property in $Customs.Keys) {
            # Override default with custom
            if (Find-Key -Hashtable $Properties -Key $Property) {
              $Properties.$Property = $Customs.$Property
            } else {
              Write-Log -Type "WARN" -Object "The ""$Property"" property defined in $Custom is unknown"
            }
          }
        } else {
          Write-Log -Type "WARN" -Object "$Custom not found in directory $CustomDirectory"
        }
      }
      # If some items are mandatory
      if ($PSBoundParameters.ContainsKey("ValidateSet")) {
        $MissingProperties = 0
        foreach ($Item in $ValidateSet) {
          # Check that the property has been defined
          if (-Not $Properties.$Item) {
            Write-Log -Type "WARN" -Object "$Item property is missing from $File"
            $MissingProperties += 1
          }
        }
        if ($MissingProperties -ge 1) {
          if ($MissingProperties -eq 1) { $Grammar = "property is"    }
          else                          { $Grammar = "properties are" }
          Write-Log -Type "ERROR" -Object "$MissingProperties $Grammar not defined" -ExitCode 1
        }
      }
      return $Properties
    } else {
      Write-Log -Type "ERROR" -Object "$File not found in directory $Directory" -ExitCode 1
    }
  }
}
