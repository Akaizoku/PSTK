function Test-OracleConnection {
  <#
    .SYNOPSIS
    Test Oracle database connection

    .DESCRIPTION
    Check that an Oracle database connection is working.

    .PARAMETER Hostname
    The host name parameter corresponds to the name of the database host.

    .PARAMETER PortNumber
    The port number parameter corresponds to the port number of the database server.

    .PARAMETER ServiceName
    The service name parameter corresponds to the name of the database service.

    .PARAMETER Credentials
    The credentials parameter corresponds to the credentials of accoun to use in case of SQL authentication.

    .PARAMETER Username
    The username parameter corresponds to the username of the account to use in case of SQL authentication.

    .PARAMETER Password
    The password parameter corresponds to the password of the account to use in case of SQL authentication.

    .PARAMETER TimeOut
    The optional time-out parameter corresponds to the time in seconds before the connection is deemed unresponsive. The default value is 3 seconds.

    .INPUTS
    None. You cannot pipe objects to Test-OracleConnection.

    .OUTPUTS
    Boolean. Test-OracleConnection returns a boolean depending on the result of the connection attempt.

    .NOTES
    File name:      Test-OracleConnection.ps1
    Author:         Florian Carrier
    Creation date:  2020-02-03
    Last modified:  2020-02-04
    Dependencies:   Test-OracleConnection requires Oracle Data Provider for .NET

    .LINK
    https://www.powershellgallery.com/packages/PSTK

    .LINK
    https://www.oracle.com/database/technologies/appdev/dotnet/odp.html

    .LINK
    https://www.nuget.org/packages/Oracle.ManagedDataAccess.Core

  #>
  [CmdletBinding (
    SupportsShouldProcess = $true
  )]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Name of the database host"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Server")]
    [System.String]
    $Hostname,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Database server port number"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String]
    $PortNumber,
    [Parameter (
      Position    = 3,
      Mandatory   = $true,
      HelpMessage = "Name of the Oracle service"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String]
    $ServiceName,
    [Parameter (
      Position          = 4,
      Mandatory         = $false,
      HelpMessage       = "Database user credentials",
      ParameterSetName  = "Credentials"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Management.Automation.PSCredential]
    $Credentials,
    [Parameter (
      Position          = 4,
      Mandatory         = $false,
      HelpMessage       = "User name",
      ParameterSetName  = "UserPassword"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Name")]
    [System.String]
    $Username,
    [Parameter (
      Position          = 5,
      Mandatory         = $false,
      HelpMessage       = "Password",
      ParameterSetName  = "UserPassword"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Pw")]
    [System.String]
    $Password,
    [Parameter (
      Position          = 5,
      Mandatory         = $false,
      HelpMessage       = "Connection timeout (in seconds)",
      ParameterSetName  = "Credentials"
    )]
    [Parameter (
      Position          = 6,
      Mandatory         = $false,
      HelpMessage       = "Connection timeout (in seconds)",
      ParameterSetName  = "UserPassword"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Int32]
    $TimeOut = 3
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Define connection string
    $ConnectionString = "Data Source='(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$Hostname)(PORT=$PortNumber))(CONNECT_DATA=(SERVICE_NAME=$ServiceName)))';"
    # Check authentication mode
    if ($PSBoundParameters.ContainsKey("Credentials")) {
      # If "secured" credentials are provided
      $ConnectionString = $ConnectionString + "User ID=$($Credentials.Username);Password=$($Credentials.GetNetworkCredential().Password);"
      $SensitiveData    = $Credentials.GetNetworkCredential().Password
    } elseif ($PSBoundParameters.ContainsKey("Username") -And $PSBoundParameters.ContainsKey("Password")) {
      # If plain text credentials are provided
      if ($Username) {
        $ConnectionString = $ConnectionString + "User ID=$Username;Password=$Password;"
        $SensitiveData    = $Password
      } else {
        Write-Log -Type "ERROR" -Message "Invalid username ""$Username""" -ExitCode 1
      }
    } else {
      # Else default to integrated security (Windows authentication)
      Write-Log -Type "DEBUG" -Message "Using Integrated Security"
      $ConnectionString = $ConnectionString + "Integrated Security=True;"
    }
    # Technical parameters (Min Pool Size=10;Connection Lifetime=120;Connection Timeout=60;Incr Pool Size=5;Decr Pool Size=2;)
    $ConnectionString = $ConnectionString + "Connection Timeout=$TimeOut;"
    # Create connection object
    Write-Log -Type "DEBUG" -Object $ConnectionString -Obfuscate $SensitiveData
    $Connection = New-Object -TypeName "Oracle.ManagedDataAccess.Client.OracleConnection" -ArgumentList $ConnectionString
    # Try to open the connection
    try {
      $Connection.Open()
      $Connection.Close()
      return $true
    } catch {
      # If connection fails
      return $false
    }
  }
}
