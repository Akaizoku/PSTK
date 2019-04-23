# ------------------------------------------------------------------------------
# Function to compare hashtables content
# ------------------------------------------------------------------------------
function Compare-Hashtable {
  <#
    .SYNOPSIS
    Compares hashtables content

    .DESCRIPTION
    Check that two given hashtables are identic.

    .PARAMETER Reference
    The Reference parameter should be the hashtable to check.

    .PARAMETER Difference
    The Difference parameter should be the hashtable against which to check the
    first one.

    .OUTPUTS
    Boolean. Compare-Hashtable returns a boolean depnding on the result of the
    comparison between the two hashtables.

    .EXAMPLE
    Compare-Hashtable -Reference $Hashtable1 -Difference $Hashtable2
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Reference hashtable"
    )]
    [ValidateNotNullOrEmpty ()]
    # [System.Collections.Specialized.OrderedDictionary]
    $Reference,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Difference hashtable"
      )]
    [ValidateNotNullOrEmpty ()]
    # [System.Collections.Specialized.OrderedDictionary]
    $Difference
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Variables
    $Check = $true
  }
  Process {
    # Check that hashtables are of the same size
    if ($Reference.Count -ne $Difference.Count) {
      $Check = $false
    } else {
      # Loop through tables
      foreach ($Key in $Reference.Keys) {
        # Check that they contain the same keys
        if ($Difference.$Key) {
          # Check that they contain the same values
          if ($Difference.$Key -ne $Reference.$Key) {
            $Check = $false
            Write-Log -Type "DEBUG" -Message "$($Difference.$Key) does not exists in reference hashtable"
            break
          }
        } else {
          $Check = $false
          Write-Log -Type "DEBUG" -Message "$Key does not exists in difference hashtable"
          break
        }
      }
    }
    return $Check
  }
}
