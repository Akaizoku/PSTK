function Resolve-URI {
  <#
    .SYNOPSIS
    Resolve URI

    .DESCRIPTION
    Parse a unform resource identifier (URI) and resolve restricted and reserved characters

    .PARAMETER URI
    The URI parameter corresponds to the uniform resource identifier to resolve.

    .INPUTS
    System.String. You can pipe the uniform resource identifier to Resolve-URI.

    .OUTPUTS
    System.String. Resolve-URI returns the encoded uniform resource identifier.

    File name:      Resolve-URI.ps1
    Author:         Florian Carrier
    Creation date:  2018-12-12
    Last modified:  2020-01-16

    .LINK
    https://en.wikipedia.org/wiki/Uniform_Resource_Identifier

    .LINK
    https://en.wikipedia.org/wiki/Percent-encoding
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "URI to resolve",
      ValueFromPipeline               = $true,
      ValueFromPipelineByPropertyName = $true
    )]
    [String]
    $URI,
    [Parameter (
      HelpMessage = "Switch to limit parsing to restricted characters"
    )]
    [Switch]
    $RestrictedOnly
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # List of restricted characters
    $RestrictedCharacters = [Ordered]@{
      "\" = '/'
      "%" = '%25'
    }
    # List of reserved characters
    $ReservedCharacters = [Ordered]@{
      " " = '%20'
      "," = '%2C'
      ";" = '%3B'
      ":" = '%3A'
      "!" = '%21'
      "?" = '%3F'
      "'" = '%27'
      "(" = '%28'
      ")" = '%29'
      "[" = '%5B'
      "]" = '%5D'
      "@" = '%40'
      "*" = '%2A'
      "/" = '%2F'
      "&" = '%26'
      "#" = '%23'
      "+" = '%2B'
      "=" = '%3D'
      "$" = '%24'
    }
  }
  Process {
    # Encode restricted characters
    foreach ($RestrictedCharacter in $RestrictedCharacters.GetEnumerator()) {
      $URI = $URI.Replace($RestrictedCharacter.Key, $RestrictedCharacter.Value)
    }
    # Encode reserved characters
    if (-Not $RestrictedOnly) {
      foreach ($ReservedCharacter in $ReservedCharacters.GetEnumerator()) {
        $URI = $URI.Replace($ReservedCharacter.Key, $ReservedCharacter.Value)
      }
    }
    # Return encoded URI
    return $URI
  }
}
