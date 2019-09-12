# ------------------------------------------------------------------------------
# Properties parsing function
# ------------------------------------------------------------------------------
function Read-Properties {
  <#
    .SYNOPSIS
    Parse properties file

    .DESCRIPTION
    Parse properties file to generate configuration variables

    .PARAMETER Path
    The patch parameter corresponds to the path to the property file to read.

    .PARAMETER Section
    [Switch] The Section parameter indicates if properties should be grouped depending on
     existing sections in the file.

    .OUTPUTS
    [System.Collections.Specialized.OrderedDictionary] Read-Properties returns an
    ordered hash table containing the content of the property file.

    .EXAMPLE
    Read-Properties -Path ".\conf\default.ini" -Section

    In this example, Read-Properties will parse the default.ini file contained
    in the .\conf directory and generate an ordered hashtable containing the
    key-values pairs.
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
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Define if section headers should be used to group properties or be ignored"
      )]
    [Switch]
    $Section
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Instantiate variables
    $Properties = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
    $Sections   = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
    $Header     = $null
    $errors     = 0
  }
  Process {
    # Check that the file exists
    if (Test-Path -Path $Path) {
      $ListOfProperties = Get-Content -Path $Path
      $LineNumber = 0
      # Read the property file line by line
      foreach ($Property in $ListOfProperties) {
        $LineNumber += 1
        # If properties have to be grouped by section
        if ($Section) {
          # If end of file and section is open
          if ($LineNumber -eq $ListOfProperties.Count -And $Header) {
            if ($Property[0] -ne "#" -And $Property[0] -ne ";" -And $Property -ne "") {
              $Property = Read-Property -Property $Property
              if ($Property.Count -gt 0) {
                $Sections.Add($Property.Key, $Property.Value)
              } else {
                Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $Path"
              }
            }
            $Clone = Copy-OrderedHashtable -Hashtable $Sections -Deep
            $Properties.Add($Header, $Clone)
          } elseif ($Property[0] -eq "[") {
            # If previous section exists add it to the property list
            if ($Header) {
              $Clone = Copy-OrderedHashtable -Hashtable $Sections -Deep
              $Properties.Add($Header, $Clone)
            }
            # Create new property group
            $Header = $Property.Substring(1, $Property.Length - 2)
            $Sections.Clear()
          } elseif ($Header -And $Property[0] -ne "#" -And $Property[0] -ne ";" -And $Property -ne "") {
            $Property = Read-Property -Property $Property
            if ($Property.Count -gt 0) {
              $Sections.Add($Property.Key, $Property.Value)
            } else {
              Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $Path"
            }
          }
        } else {
          # Ignore comments, sections, and blank lines
          if ($Property[0] -ne "#" -And $Property[0] -ne ";" -And $Property[0] -ne "[" -And $Property -ne "") {
            $Property = Read-Property -Property $Property
            if ($Property.Count -gt 0) {
              try {
                $Properties.Add($Property.Key, $Property.Value)
              } catch {
                Write-Log -Type "WARN" -Object "Two distinct definitions of the property $($Property.Key) have been found in the configuration file"
                $Errors += 1
              }
            } else {
              Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $Path"
            }
          }
        }
      }
    } else {
      # Alert that configuration file does not exist at specified location
      Write-Log -Type "ERROR" -Message "Path not found $Path" -ErrorCode 1
    }
    if ($Errors -gt 0) {
      Write-Log -Type "ERROR" -Object "Unable to proceed. Resolve the issues in $Path" -ErrorCode 1
    }
    return $Properties
  }
}
