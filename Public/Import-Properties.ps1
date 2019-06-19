# ------------------------------------------------------------------------------
# Properties setting function
# ------------------------------------------------------------------------------
function Import-Properties {
  <#
    .SYNOPSIS
    Import properties from configuration files

    .DESCRIPTION
    Import properties from configuration files

    .PARAMETER Path
    The path parameter should be the name of the property file.

    .PARAMETER Custom
    The Custom parameter should be the name of the custom property file.

    .OUTPUTS
    Import-Properties returns an
    ordered hash table containing the names and values of the properties listed
    in the property files.

    .EXAMPLE
    Import-Properties -Path "\conf\default.ini" -Custom "\\shared\custom.ini"

    In this example, Import-Properties will read properties from the default.ini
    file contained in the \conf directory, then read the properties from
    in the custom.ini file contained in the \\shared directory, and override the
    default ones with the custom ones.

    .NOTES
    Import-Properties does not currently allow the use of sections to group proper-
    ties in custom files
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the property file"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Path to the custom property file"
    )]
    [String]
    $Custom,
    [Parameter (
      Position    = 3,
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
    if (Test-Path -Path $Path) {
      # Parse properties with or without section split
      $Properties = Read-Properties -Path $Path -Section:$Section
      # Check if a custom file is provided
      if ($PSBoundParameters.ContainsKey("Custom")) {
        # Make sure said file does exists
        if (Test-Path -Path $Custom) {
          # Override default properties with custom ones
          $CustomProperties = Read-Properties -Path $Custom
          foreach ($Property in $CustomProperties.Keys) {
            # Override default with custom
            if ($Properties.$Property) {
              $Properties.$Property = $CustomProperties.$Property
            } else {
              Write-Log -Type "WARN" -Object "The ""$Property"" property defined in $Custom is unknown"
            }
          }
        } else {
          Write-Log -Type "ERROR" -Object "Path not found $Custom"
          Write-Log -Type "WARN"  -Object "No custom configuration could be retrieved"
        }
      }
      # If some items are mandatory
      if ($PSBoundParameters.ContainsKey("ValidateSet")) {
        $MissingProperties = 0
        foreach ($Item in $ValidateSet) {
          # Check that the property has been defined
          if (-Not $Properties.$Item) {
            Write-Log -Type "WARN" -Object "$Item property is missing from configuration file"
            $MissingProperties += 1
          }
        }
        if ($MissingProperties -ge 1) {
          if ($MissingProperties -eq 1) { $Grammar = "property is"    }
          else                          { $Grammar = "properties are" }
          Write-Log -Type "ERROR" -Object "$MissingProperties $Grammar not defined" -ErrorCode 1
        }
      }
      return $Properties
    } else {
      Write-Log -Type "ERROR" -Object "Path not found $Path" -ErrorCode 1
    }
  }
}
