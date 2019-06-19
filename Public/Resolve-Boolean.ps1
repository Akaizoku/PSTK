function Resolve-Boolean {
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Boolean values"
    )]
    [String]
    $Boolean,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Hashtable containing the values"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $Hashtable
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Instantiate variables
    $BooleanValues = Resolve-Array -Array $Boolean -Delimiter ","
  }
  Process {
    # Loop through values
    foreach ($BooleanValue in $BooleanValues) {
      if (($Hashtable.$BooleanValue -eq $true) -Or ($Hashtable.$BooleanValue -eq 1)) {
        $Hashtable.$BooleanValue = $true
      } elseif (($Hashtable.$BooleanValue -eq $false) -Or ($Hashtable.$BooleanValue -eq 0)) {
        $Hashtable.$BooleanValue = $false
      } else {
        Write-Log -Type "WARN" -Object "$($Hashtable.$BooleanValue) could not be parsed as a boolean"
      }
    }
    return $Hashtable
  }
}
