function Set-RelativePath {
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of paths to resolve"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Hashtable containing the paths"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $Hashtable,
    [Parameter (
      Position    = 3,
      Mandatory   = $true,
      HelpMessage = "Root for relative paths"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Root
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    $RelativePaths = Resolve-Array -Array $Path -Delimiter ","
    foreach ($RelativePath in $RelativePaths) {
      # Write-Log -Type "DEBUG" -Object $Hashtable.$RelativePath
      $Hashtable.$RelativePath = Join-Path -Path $Root -ChildPath $Hashtable.$RelativePath
    }
    return $Hashtable
  }
}
