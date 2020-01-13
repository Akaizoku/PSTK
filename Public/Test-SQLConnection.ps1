# ------------------------------------------------------------------------------
# Database connection testing function
# ------------------------------------------------------------------------------
function Test-SQLConnection {
  <#
    .SYNOPSIS
    Check a SQL Server database connection

    .DESCRIPTION
    Check that a SQL Server database connection is working

    .PARAMETER Server
    [String] The server parameter corresponds to the database server to connect to

    .PARAMETER Database
    [String] The database parameter corresponds to the database to be tested

    .PARAMETER Security
    [DEPRECATED] The security parameter defines if the connection should be made us-
    ing the SQL Server Integrated Security (Windows Active Directory) or the
    default SQL authentication with username and password.

    .PARAMETER Username
    [String] The username parameter corresponds to the username of the account
    to use in case of SQL authentication.

    .PARAMETER Password
    [String] The password parameter corresponds to the password of the account
    to use in case of SQL authentication.

    .PARAMETER Credentials
    [System.Management.Automation.PSCredential] The credentials parameter corresponds to the credentials of account
    to use in case of SQL authentication.

    .INPUTS
    None. You cannot pipe objects to Test-SQLConnection.

    .OUTPUTS
    [Boolean] Test-SQLConnection returns a boolean depending on the result of the
    connection attempt.

    .EXAMPLE
    Test-SQLConnection -Server "localhost" -Database "MSSQLServer"

    In this example, Test-SQLConnection will try to connect to the MSSQLServer
    database on the local server using the current Windows user.

    .EXAMPLE
    Test-SQLConnection -Server "localhost" -Database "MSSQLServer" -Username "user" -Password "password"

    In this example, Test-SQLConnection will try to connect to the MSSQLServer
    database on the local server using the credentials of the user "user" with
    the "password" password.

    .EXAMPLE
    $SecurePassword = ConvertTo-SecureString -String "password" -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList ("user", $SecurePassword)
    Test-SQLConnection -Server "localhost" -Database "MSSQLServer" -Credentials $Credentials

    In this example, Test-SQLConnection will try to connect to the MSSQLServer
    database on the local server using the credentials of the user "user" with
    the "password" password.

    .NOTES
    File name:      Test-SQLConnection.ps1
    Author:         Florian Carrier
    Creation date:  15/10/2018
    Last modified:  02/12/2019
    Dependencies:   Test-SQLConnection requires the SQLServer module

    .LINK
    https://www.powershellgallery.com/packages/PSTK

    .LINK
    https://docs.microsoft.com/en-us/sql/powershell/download-sql-server-ps-module

  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Database server to connect to"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Svr")]
    [String]
    $Server,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Database to connect to"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Database,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "User name"
    )]
    [Alias ("Name")]
    [String]
    $Username,
    [Parameter (
      Position    = 5,
      Mandatory   = $false,
      HelpMessage = "Password"
    )]
    [Alias ("Pw")]
    [String]
    $Password,
    [Parameter (
      Position    = 6,
      Mandatory   = $false,
      HelpMessage = "Database user credentials"
    )]
    [System.Management.Automation.PSCredential]
    $Credentials,
    [Parameter (
      HelpMessage = "[DEPRECATED] Use of specific credentials instead of integrated security"
    )]
    [Switch]
    $Security = $false
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Define connection string
    $ConnectionString = "Server=$Server; Database=$Database; Connect Timeout=3;"
    # Check authentication mode
    if ($PSBoundParameters.ContainsKey("Credentials")) {
      # If "secured" credentials are provided
      $FullConnectionString = $ConnectionString + "Integrated Security=False; User ID=$($Credentials.Username); Password=$($Credentials.GetNetworkCredential().Password);"
      $Obfuscate            = $Credentials.GetNetworkCredential().Password
    } elseif ($PSBoundParameters.ContainsKey("Username") -And $PSBoundParameters.ContainsKey("Password")) {
      # If plain text credentials are provided
      if ($Username) {
        $FullConnectionString = $ConnectionString + "Integrated Security=False; User ID=$Username; Password=$Password;"
        $Obfuscate            = $Password
      } else {
        Write-Log -Type "ERROR" -Message "Please provide a valid username"
        Write-Log -Type "DEBUG" -Message "$Username"
        Stop-Script 1
      }
    } else {
      # Else default to integrated security (Windows authentication)
      Write-Log -Type "DEBUG" -Message "Integrated Security"
      $FullConnectionString = $ConnectionString + "Integrated Security=True;"
    }
    # Create connection object
    Write-Log -Type "DEBUG" -Object $FullConnectionString -Obfuscate $Obfuscate
    $Connection = New-Object -TypeName "System.Data.SqlClient.SqlConnection" -ArgumentList $FullConnectionString
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
