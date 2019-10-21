function Test-HTTPStatus {
  <#
    .SYNOPSIS
    Check the HTTP status

    .DESCRIPTION
    Check that a specified web-platform is available by querying its HTTP
    status.

    .PARAMETER System
    The system parameter corresponds to a collection containing all the information relative to the platform to check.
    It must contain the following properties:
    - ApplicationProtocol: the protocol used by the web-application (HTTP or HTTPS);
    - ApplicationServer: the name/alias of the web-server hosting the web-application;
    - ApplicationPort: the port number used by the web-application.

    .OUTPUTS
    [Boolean] This function returns a boolean specifying if the status of the platform is up or down.

    .EXAMPLE
    Test-HTTPStatus -URI "http://localhost:80"

    In this example, the function will return the status of the localhost server using the protocol HTTP and the port 80.

    .NOTES
    File name:     Test-HTTPStatus.ps1
    Author:        Florian Carrier
    Creation date: 18/10/2019
    Last modified: 18/10/2019
  #>
  [CmdletBinding()]
  Param(
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Uniform Resource Identifier"
    )]
    [String]
    $URI
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Get HTTP status
    $Status = Get-HTTPStatus -URI $URI
    Write-Log -Type "DEBUG" -Message "HTTP status: $Status"

    # Check status means "Success"
    if ($Status -in 200..299) {
      return $true
    } else {
      return $false
    }
  }
}
