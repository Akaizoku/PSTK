# ------------------------------------------------------------------------------
# Get HTTP/HTTPS status
# ------------------------------------------------------------------------------
function Get-HTTPStatus {
  <#
    .SYNOPSIS
    Returns the status of an HTTP request

    .DESCRIPTION
    Queries a server and returns the status of the request

    .PARAMETER URI
    The URI parameter corresponds to the URI (Uniform Resource Identifier) of
    the server to query

    .NOTES
    File name:     Get-HTTPStatus.ps1
    Author:        Florian Carrier
    Creation date: 15/01/2019
    Last modified: 17/01/2019
  #>
  Param(
    [Parameter(
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "URI to check"
    )]
    [String]
    $URI
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    try {
      # Query server
      Write-Debug -Message $URI
      $Status = Invoke-WebRequest -URI $URI | Select-Object -ExpandProperty "StatusCode"
    } catch {
      # If server is offline
      $Status = 0
    }
    return $Status
  }
}
