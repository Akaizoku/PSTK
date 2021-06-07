function Invoke-OracleCmd {
  <#
    .SYNOPSIS
    Invoke Oracle SQL command

    .DESCRIPTION
    Run a SQL command on an Oracle database

    .NOTES
    File name:      Invoke-OracleCmd.ps1
    Author:         Florian Carrier
    Creation date:  2020-02-04
    Last modified:  2020-02-06
    Dependencies:   Invoke-OracleCmd requires Oracle Data Provider for .NET

    .LINK
    https://www.powershellgallery.com/packages/PSTK

    .LINK
    Invoke-SqlCmd

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
      Position    = 4,
      Mandatory   = $true,
      HelpMessage = "SQL query"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String]
    $Query,
    [Parameter (
      Position          = 5,
      Mandatory         = $false,
      HelpMessage       = "Database user credentials",
      ParameterSetName  = "Credentials"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Management.Automation.PSCredential]
    $Credentials,
    [Parameter (
      Position          = 5,
      Mandatory         = $false,
      HelpMessage       = "User name",
      ParameterSetName  = "UserPassword"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Name")]
    [System.String]
    $Username,
    [Parameter (
      Position          = 6,
      Mandatory         = $false,
      HelpMessage       = "Password",
      ParameterSetName  = "UserPassword"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Pw")]
    [System.String]
    $Password,
    [Parameter (
      Mandatory   = $false,
      HelpMessage = "Connection timeout (in seconds)"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Int32]
    $ConnectionTimeOut,
    [Parameter (
      Mandatory   = $false,
      HelpMessage = "Query timeout (in seconds)"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Int32]
    $QueryTimeOut,
    [Parameter (
      HelpMessage = "Abort on error"
    )]
    [Switch]
    $AbortOnError,
    [Parameter (
      HelpMessage = "Encrypt connection"
    )]
    [Switch]
    $EncryptConnection,
    [Parameter (
      HelpMessage = "Include SQL user errors"
    )]
    [Switch]
    $IncludeSqlUserErrors,
    [Parameter (
      HelpMessage = "Out SQL errors"
    )]
    [Switch]
    $OutputSqlErrors
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
    if ($PSBoundParameters.ContainsKey("ConnectionTimeOut") -And $ConnectionTimeOut -ne $null) {
      $ConnectionString = $ConnectionString + "Connection Timeout=$ConnectionTimeOut;"
    }
    # Create connection object
    Write-Log -Type "DEBUG" -Object $ConnectionString -Obfuscate $SensitiveData
    $Connection = New-Object -TypeName "Oracle.ManagedDataAccess.Client.OracleConnection" -ArgumentList $ConnectionString
    # Try to open the connection
    try {
      $Connection.Open()
    } catch {
      Write-Log -Type "ERROR" -Object "Unable to reach database $($Hostname):$PortNumber/$ServiceName"
      return $Error
    }
    # Create SQL command
    $Command = $Connection.CreateCommand()
    # TODO sanitize query
    $Command.CommandText = $Query
    Write-Log -Type "DEBUG" -Object $Command
    # Execute command
    try {
      $Reader = $Command.ExecuteReader()
    } catch {
      Write-Log -Type "ERROR" -Object "Could not execute statement`n$Query"
      return $Error
    }
    # Get result
    $Result = $Reader.Read()
    # Close connection
    $Connection.Close()
    # Check outcome
    if ($Result) {
      # TODO return actual result
      return $Result
    } else {
      return $null
    }
  }
}
