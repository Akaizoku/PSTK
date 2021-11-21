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
    Creation date: 2019-01-15
    Last modified: 2021-11-14
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
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    try {
      # Query server
      Write-Log -Type "DEBUG" -Object $URI
      $Status = Invoke-WebRequest -URI $URI -UseBasicParsing | Select-Object -ExpandProperty "StatusCode"
    } catch {
      # If server is offline or an error occurs
      if ($null -ne $Error[0].Exception.Message) {
        Write-Log -Type "DEBUG" -Object $Error[0].Exception.Message
      }
      $Status = 0
    }
    return $Status
  }
}
