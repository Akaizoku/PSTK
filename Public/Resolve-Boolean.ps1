function Resolve-Boolean {
  <#
    .SYNOPSIS
    Resolve boolean value

    .DESCRIPTION
    Parse value to return the corresponding boolean equivalent

    .PARAMETER Value
    The value parameter corresponds to the value to parse as boolean.

    .INPUTS
    System.String. You can pipe the value to Resolve-Boolean.

    .OUTPUTS
    Boolean. Resolve-Boolean returns a boolean value.

    .NOTES
    File name:      Resolve-Boolean.ps1
    Author:         Florian Carrier
    Creation date:  17/06/2019
    Last modified:  13/01/2020
    WARNING         If the specified value cannot be parsed as a boolean, Resolve-Boolean will write a warning to the host and return FALSE.
  #>
  [CmdletBinding (
    SupportsShouldProcess = $true
  )]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Boolean value to parse",
      ValueFromPipeline               = $true,
      ValueFromPipelineByPropertyName = $true
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Value
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    if (($Value -eq $true) -Or ($Value -eq 1) -Or ($Value -eq "true")) {
      return $true
    } elseif (($Value -eq $false) -Or ($Value -eq 0) -Or ($Value -eq "false")) {
      return $false
    } else {
      Write-Log -Type "WARN" -Object "$Value could not be parsed as a boolean"
      return $false
    }
  }
}
