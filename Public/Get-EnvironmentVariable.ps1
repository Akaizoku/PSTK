function Get-EnvironmentVariable {
  <#
    .SYNOPSIS
    Get environment variable

    .DESCRIPTION
    Retrieve the value of an environment variable in the specified scope

    .PARAMETER Name
    The name parameter corresponds to the name of the environment variable.

    .PARAMETER Scope
    The optional scope parameter corresponds to the scope in which the environment variable is defined.

    .NOTES
    File name:      Get-EnvironmentVariable.ps1
    Author:         Florian Carrier
    Creation date:  22/01/2019
    Last modified:  13/12/2019
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
    $Value = [Environment]::GetEnvironmentVariable($Name, $Scope)
    if ($Value) {
      Write-Log -Type "DEBUG" -Message "Scope=$Scope`t$Name=$Value"
    }
    # If variable does not exists, the value will be null
    return $Value
  }
}
