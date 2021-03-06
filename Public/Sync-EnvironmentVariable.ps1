function Sync-EnvironmentVariable {
  <#
    .SYNOPSIS
    Reload environment variable

    .DESCRIPTION
    Force a reload of the session's environment variable

    .PARAMETER Name
    The name parameter corresponds to the name of the environment variable.

    .PARAMETER Scope
    The optional scope parameter corresponds to the scope in which the environment variable is defined.

    .NOTES
    File name:      Sync-EnvironmentVariable.ps1
    Author:         Florian Carrier
    Creation date:  2019-12-13
    Last modified:  2019-12-17
  #>
  [CmdletBinding (
    SupportsShouldProcess = $true
  )]
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
    $Scope = "Machine"
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Check if environment variable exists in specified scope
    if (Test-EnvironmentVariable -Name $Name -Scope $Scope) {
      # Reload variable value in current session
      Set-Item -Path "env:$Name" -Value (Get-EnvironmentVariable -Name $Name -Scope $Scope) -Force
      return $true
    } else {
      # If environment variable no longer exists in the specifed scope then remove it (if it exists)
      if (Get-Item -Path "env:$Name" -ErrorAction "SilentlyContinue") {
        Remove-Item -Path "env:$Name"
      }
      return $false
    }
  }
}
