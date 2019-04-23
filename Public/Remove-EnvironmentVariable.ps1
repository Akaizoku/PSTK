function Remove-EnvironmentVariable {
  [CmdletBinding()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Name of the environment variable"
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $Variable,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Scope of the environment variable"
    )]
    [ValidateSet ("Machine", "Process", "User")]
    [String]
    $Scope = "Machine"
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Check if variable is defined
    if (Test-EnvironmentVariable -Variable $Variable -Scope $Scope) {
      Write-Log -Type "INFO" -Message "Removing $Variable environment variable in $Scope scope"
      [Environment]::SetEnvironmentVariable($Variable, "", $Scope)
    } else {
      Write-Log -Type "WARN" -Message "$Variable environment variable is not defined in $Scope scope"
    }
  }
}
