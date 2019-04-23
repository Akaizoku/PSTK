function Get-EnvironmentVariable {
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
    $Value = [Environment]::GetEnvironmentVariable($Variable, $Scope)
    if ($Value) {
      Write-Log -Type "DEBUG" -Message "$Scope`t$Variable=$Value"
    }
    # If variable does not exists, the value will be null
    return $Value
  }
}
