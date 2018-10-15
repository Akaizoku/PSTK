# ------------------------------------------------------------------------------
# Increment/decrement alphanumeric string
# ------------------------------------------------------------------------------
function Add-Offset {
  <#
    .SYNOPSIS
    Adds an offset to an alphanumeric chain of characters

    .DESCRIPTION
    Adds an offset to the integer part of an alphanumeric chain of characters.

    .PARAMETER Alphanumeric
    The alphanumeric parameter corresponds to the chain of characters to offset.

    .PARAMETER Offset
    The offset parameter corresponds to the integer by which the alphanumeric
    chain of characters should be offset.

    .INPUTS
    None.

    .OUTPUTS
    System.String. Add-Offset returns an alphanumeric chain of character.

    .EXAMPLE
    Add-Offset -Alphanumeric "a1" -Offset 2

    .NOTES
    The alphanumeric chain of characters has to match the following regular ex-
    pressions:
    - ^\d+$
    - ^\d+\D+$
    - ^\D+\d+$
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Alphanumeric chain of character"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Alphanumeric,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Offset"
    )]
    [ValidateNotNullOrEmpty ()]
    [Int]
    $Offset
  )
  try {
    # Check character chain format
    $Format = Test-Alphanumeric -Alphanumeric $Alphanumeric
    if ($Format -ne 0) {
      # Increment/decrement value
      if ($Format -eq 1) {
        $NewAlphanumeric = [Long]$Alphanumeric + $Offset
      } else {
        $Integer  = $Alphanumeric -replace ('\D+', "")
        $String   = $Alphanumeric -replace ('\d+', "")
        [Long]$Integer += $Offset
        if ($Format -eq 2) {
          $NewAlphanumeric = "$Integer$String"
        } elseif ($Format -eq 3) {
          $NewAlphanumeric = "$String$Integer"
        }
      }
    } else {
      Write-Log -Type "WARN" -Message "The alphanumeric chain of character (""$Alphanumeric"") does not have a correct format."
      return $Alphanumeric
    }
  } catch [System.Management.Automation.RuntimeException] {
    Write-Log -Type "ERROR" -Message "The numeric value is too large (greater than $([Long]::MaxValue))."
  }
  return $NewAlphanumeric
}
