function Wait-WebResource {
  <#
    .SYNOPSIS
    Wait until a web resource is accessible

    .DESCRIPTION
    Queries a web resource and returns the status of the request

    .PARAMETER URI
    The URI parameter corresponds to the Unified Resource Identifier (URI) of the web resource.

    .PARAMETER TimeOut
    The optional time-out parameter corresponds to the wait period after which the resource is declared unreachable.

    .PARAMETER RetryInterval
    The optional retry interval parameter is the interval in millisecond in between each queries to check the availability of the web resource.

    .NOTES
    File name:     Wait-WebResource.ps1
    Author:        Florian Carrier
    Creation date: 21/10/2019
    Last modified: 20/12/2019
  #>
  Param(
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "URI of the web resource"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $URI,
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
  }
  Process {
    # Wait for web-server to come back up
    $Timer = [System.Diagnostics.Stopwatch]::StartNew()
    while (($Timer.Elapsed.TotalSeconds -lt $TimeOut) -And (-Not (Test-HTTPStatus -URI $URI))) {
      Start-Sleep -Seconds $RetryInterval
      Write-Log -Type "DEBUG" -Object "Waiting for $URI to be available"
    }
    $Timer.Stop()
    # Check state
    if (($Timer.Elapsed.TotalSeconds -gt $TimeOut) -And (-Not (Test-HTTPStatus -System $WebServer))) {
      # Timeout
      return $false
    } else {
       return $true
     }
  }
}
