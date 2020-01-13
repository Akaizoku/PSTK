function Get-URI {
  <#
    .SYNOPSIS
    Construct URI

    .DESCRIPTION
    Generate a Uniform Resource Identifier (URI) from its elements

    .NOTES
    File name:     Get-URI.ps1
    Author:        Florian Carrier
    Creation date: 21/10/2019
    Last modified: 21/10/2019
  #>
  Param(
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Scheme"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Scheme,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Authority"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Authority,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Path"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Query"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Query,
    [Parameter (
      Position    = 5,
      Mandatory   = $false,
      HelpMessage = "Fragment"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Fragment
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Construct URI
    $URI = $Scheme + ':'
    # Add authority if applicable
    if ($PSBoundParameters.ContainsKey("Authority") -And $Authority) {
      $URI = $Scheme + '://' + $Authority
    }
    # Add path if applicable
    if ($PSBoundParameters.ContainsKey("Path") -And $Path) {
      # Check URI format
      if ($URI.SubString($URI.Length - 1) -ne ':') {
        $URI = $URI + '/' + $Path
      } else {
        $URI = $URI + $Path
      }
    }
    # Add query if applicable
    if ($PSBoundParameters.ContainsKey("Query") -And $Query) {
      # TODO add support for multiple queries
      $URI = $URI + '?' + $Query
    }
    # Add fragment if applicable
    if ($PSBoundParameters.ContainsKey("Fragment") -And $Fragment) {
      $URI = $URI+ '#' + $Fragment
    }
    # Return URI
    Write-Log -Type "DEBUG" -Object $URI
    return $URI
  }
}
