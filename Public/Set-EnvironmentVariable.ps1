function Set-EnvironmentVariable {
  <#
    .SYNOPSIS
    Set environment variable

    .DESCRIPTION
    Set the value of the environment variable

    .PARAMETER Name
    The name parameter corresponds to the name of the environment variable.

    .PARAMETER Value
    The value parameter corresponds to the value to assign to the environment variable.

    .PARAMETER Scope
    The optional scope parameter corresponds to the scope in which the environment variable is defined.

    .NOTES
    File name:      Set-EnvironmentVariable.ps1
    Author:         Florian Carrier
    Creation date:  2019-01-22
    Last modified:  2019-12-13
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
