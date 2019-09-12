# ------------------------------------------------------------------------------
# Check service
# ------------------------------------------------------------------------------
function Test-Service {
  <#
    .SYNOPSIS
    Check if service exists

    .DESCRIPTION
    Check if a service with the provided name exists

    .PARAMETER Service
    The service parameter corresponds to the name of the service to look for

    .INPUTS
    This function accepts strings as input values from pipeline.

    .OUTPUTS
    Returns boolean value:
    - true if service exists
    - false if service is not found

    .EXAMPLE
    Test-Service -Service "WildFly"

    This example returns true if you have installed WildFly as a service.

    .NOTES
    File name:      Test-Service.ps1
    Author:         Florian Carrier
    Creation date:  22/01/2019
    Last modified:  22/01/2019
  #>
  [CmdletBinding()]
  Param (
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "Name of the service"
    )]
    [ValidateNotNullOrEmpty()]
    [Alias ("Service")]
    [String]
    $Name
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    try {
      if (Get-Service -Name $Name -ErrorAction "Stop") {
        return $true
      }
    } catch {
      return $false
    }
  }
}
