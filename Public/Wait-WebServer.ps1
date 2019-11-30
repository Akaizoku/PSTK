function Wait-WebServer {
  <#
    .SYNOPSIS
    Wait until a web-page is accessible

    .DESCRIPTION
    Queries a server and returns the status of the request

    .PARAMETER WebServer
    The web-server parameter corresponds to the properties of the web-server.
    It must contains the four following attributes:
    - Protocol
    - Hostname
    - Port
    - Name

    .NOTES
    File name:     Wait-WebServer.ps1
    Author:        Florian Carrier
    Creation date: 21/10/2019
    Last modified: 21/10/2019
  #>
  Param(
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Properties"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $WebServer,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Time in seconds before time-out"
    )]
    [ValidateNotNullOrEmpty ()]
    [Int]
    $TimeOut = 60,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Interval in between retries"
    )]
    [ValidateNotNullOrEmpty ()]
    [Int]
    $RetryInterval = 1
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Construct web-server URI
    $URI = Get-URI -Scheme $WebServer.Protocol -Authority ($WebServer.Hostname + ':' + $WebServer.Port)
  }
  Process {
    # Wait for web-server to come back up
    $Timer          = [System.Diagnostics.Stopwatch]::StartNew()
    while (($Timer.Elapsed.TotalSeconds -lt $TimeOut) -And (-Not (Test-HTTPStatus -URI $URI))) {
      Start-Sleep -Seconds $RetryInterval
      Write-Log -Type "DEBUG" -Object "Waiting for $($WebServer.Name) to come back up"
    }
    $Timer.Stop()
    return $true
    # Check state
    if (($Timer.Elapsed.TotalSeconds -gt $TimeOut) -And (-Not (Test-HTTPStatus -System $WebServer))) {
      # Timeout
      return $false
    }
  }
}
