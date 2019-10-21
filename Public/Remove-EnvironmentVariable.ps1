function Remove-EnvironmentVariable {
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
      Mandatory   = $false,
      HelpMessage = "Scope of the environment variable"
    )]
    [ValidateSet ("Machine", "Process", "User")]
    [String]
    $Scope = "Machine",
    [Parameter (
      HelpMessage = "Confirmation prompt"
    )]
    [Switch]
    $Confirm
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Check if variable is defined
    if (Test-EnvironmentVariable -Variable $Name -Scope $Scope) {
      if ($Confirm) {
        $Confirmation = Confirm-Prompt -Prompt "Do you want to remove the environment variable $Name?"
      }
      if ((-Not $Confirm) -Or $Confirmation) {
        Write-Log -Type "INFO" -Object "Removing $Name environment variable in $Scope scope"
        [Environment]::SetEnvironmentVariable($Name, "", $Scope)
      } else {
        Write-Log -Type "WARN" -Object "Removal of environment variable cancelled by the user"
      }
    } else {
      Write-Log -Type "WARN" -Object "$Name environment variable is not defined in $Scope scope"
    }
  }
}
