function Test-EnvironmentVariable {
  <#
    .SYNOPSIS
    Check environment variable

    .DESCRIPTION
    Retrieve the value of an environment variable in the specified scope

    .PARAMETER Name
    The name parameter corresponds to the name of the environment variable.

    .PARAMETER Scope
    The optional scope parameter corresponds to the scope in which the environment variable is defined.

    .NOTES
    File name:      Test-EnvironmentVariable.ps1
    Author:         Florian Carrier
    Creation date:  2019-01-22
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
    # Check if variable is defined
    if ([Environment]::GetEnvironmentVariable($Name, $Scope)) {
      return $true
    } else {
      return $false
    }
  }
}
