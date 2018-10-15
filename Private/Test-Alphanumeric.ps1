# ------------------------------------------------------------------------------
# Test alphanumeric chain
# ------------------------------------------------------------------------------
function Test-Alphanumeric {
  <#
    .SYNOPSIS
    Check the format of an alphanumeric chain of characters

    .DESCRIPTION
    Test the format of an alphanumeric chain of characters to see if it can be
    incremented or decremented easily.

    .PARAMETER Alphanumeric
    The alphanumeric parameter corresponds to the chain of characters to offset.

    .INPUTS
    None.

    .OUTPUTS
    [System.Integer] Test-Alphanumeric returns the type of format that the alpha
    numeric chain of characters if using.

    .EXAMPLE
    Test-Alphanumeric -Alphanumeric "a1"

    .NOTES
    Types of format allowed and corresponding regular expressions (0 is invalid):
    1. ^\d+$
    2. ^\d+\D+$
    3. ^\D+\d+$
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
    $Alphanumeric
  )
  Begin {
    # Declare valid formats
    $Number = [RegEx]::New('^\d+$')
    $NumStr = [RegEx]::New('^\d+\D+$')
    $StrNum = [RegEx]::New('^\D+\d+$')
  }
  Process {
    # Test and return format
    if ($Alphanumeric -match $Number) {
      return 1
    } elseif ($Alphanumeric -match $NumStr) {
      return 2
    } elseif ($Alphanumeric -match $StrNum) {
      return 3
    } else {
      return 0
    }
  }
}
