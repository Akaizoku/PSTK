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
    [Switch] The security parameter defines if the connection should be made us-
    ing the SQL Server Integrated Security (Windows Active Directory) or the
    default SQL authentication with username and password.

    .PARAMETER Username
    [String] The username parameter corresponds to the username of the account
    to use in case of SQL authentication.

    .PARAMETER Password
    [String] The password parameter corresponds to the password of the account
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
    Test-SQLConnection -Server "localhost" -Database "MSSQLServer" -Security -Username "user" -Password "password"

    In this example, Test-SQLConnection will try to connect to the MSSQLServer
    database on the local server using the credentials of the user "user" with
    the "password" password.

    .NOTES
    File name:      Test-SQLConnection.ps1
    Author:         Florian Carrier
    Creation date:  15/10/2018
    Last modified:  16/10/2018
    Dependencies:   Test-SQLConnection requires the SQLServer module
    TODO            Add secured password handling

    .LINK
    https://github.com/Akaizoku/PSTK

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
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Use of specific credentials instead of integrated security"
    )]
    [Switch]
    $Security = $false,
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
    [Alias ("PW")]
    [String]
    $Password
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Break-down connection info
    if ($Security) {
      Write-Log -Type "DEBUG" -Message "SQL Server authentication"
      if ($Username) {
        $ConnectionString = "Server=$Server; Database=$Database; Integrated Security=False; User ID=$Username; Password=$Password; Connect Timeout=3;"
      } else {
        Write-Log -Type "ERROR" -Message "Please provide a valid username"
        Write-Log -Type "DEBUG" -Message "$Username"
        Stop-Script 1
      }
    } else {
      # Else default to integrated security
      Write-Log -Type "DEBUG" -Message "Integrated Security"
      $ConnectionString = "Server=$Server; Database=$Database; Integrated Security=True; Connect Timeout=3;"
    }
    # Create connection object
    $Connection = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
    # Try to open the connection
    try {
      $Connection.Open()
      $Connection.Close()
      return $true
    } catch {
      Write-Log -Type "DEBUG" -Message "Unable to connect to $ConnectionString"
      return $false
    }
  }
}