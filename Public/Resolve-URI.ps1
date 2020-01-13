function Resolve-URI {
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "URI to resolve"
    )]
    [String]
    $URI
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # List of restricted characters
    $RestrictedCharacters = [Ordered]@{
      "\" = '/'
      " " = '%20'
    }
  }
  Process {
    # Encode URI
    foreach ($RestrictedCharacter in $RestrictedCharacters.GetEnumerator()) {
      $URI = $URI.Replace($RestrictedCharacter.Key, $RestrictedCharacter.Value)
    }
    # Return encoded URI
    return $URI
  }
}
