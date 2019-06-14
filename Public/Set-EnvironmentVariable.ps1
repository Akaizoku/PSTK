function Set-EnvironmentVariable {
  [CmdletBinding()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Name of the environment variable"
    )]
    [ValidateNotNullOrEmpty()]
    [Alias ("Variable")]
    [String]
    $Name,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Value of the environment variable"
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $Value,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Scope of the environment variable"
    )]
    [ValidateSet ("Machine", "Process", "User")]
    [String]
    $Scope = "Machine"
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Check if variable is defined
    if (Test-EnvironmentVariable -Variable $Name -Scope $Scope) {
      Write-Log -Type "WARN" -Message "Overwriting existing $Name environment variable in $Scope scope"
    }
    Write-Log -Type "DEBUG" -Message "$Scope`t$Name=$Value"
    [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
  }
}
