function Test-Object {
  <#
    .SYNOPSIS
    Wrapper for Test-Path

    .DESCRIPTION
    Wrapper function for Test-Path to catch access permission issues

    .INPUTS Path
    The path parameter corresponds to the path to the object to test

    .INPUTS NotFound
    The not found flag reverse the valid outcome of the test to allow for negative testing
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the object"
    )]
    [ValidateNotNUllOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      HelpMessage = "Reverse valid outcome of the test"
    )]
    [Switch]
    $NotFound
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Test path
    try {
      $Outcome = Test-Path -Path $Path -ErrorAction "Stop"
    } catch [System.UnauthorizedAccessException] {
      if (-Not $Error[0].Exception) {
        $ErrorMessage = "Access is denied ($Path)"
      } else {
        $ErrorMessage = $Error[0].Exception
      }
      Write-Log -Type "DEBUG" -Object $ErrorMessage
      $Outcome = $true
    }
    # Output test result
    if ($PSBoundParameters.ContainsKey("NotFound")) {
      return (-Not $Outcome)
    } else {
      return $Outcome
    }
  }
}
