<#
  .SYNOPSIS
  PowerShell Toolbox

  .DESCRIPTION
  Collection of useful functions and procedures

  .NOTES
  File name:      PowerShell-Toolbox.psm1
  Author:         Florian Carrier
  Creation date:  23/08/2018
  Last modified:  31/08/2018
#>

# ------------------------------------------------------------------------------
# Logging function
# ------------------------------------------------------------------------------
function LogMessage {
  <#
    .SYNOPSIS
    Formats output message as a log

    .DESCRIPTION
    The LogMessage function outputs the time and type of a message in a formatt-
    ed manner with respective colour code.

    .PARAMETER Type
    The Type parameter defines the level of importance of the message and will
    influence the colour of the output.

    .PARAMETER Message
    The Message parameter corresponds to the desired output to be logged.
  #>
  [CmdletBinding ()]
  # Inputs
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Type of message to output"
    )]
    [ValidateSet ("CHECK","ERROR","INFO","WARN")]
    [Alias ("T")]
    [String]
    $Type,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Message to output"
    )]
    [Alias ("M", "Msg", "O", "Out", "Output", "L", "Log")]
    [String]
    $Message
  )
  # Variables
  $Time   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $Colour = @{
    "CHECK" = "Green"
    "ERROR" = "Red"
    "INFO"  = "White"
    "WARN"  = "Yellow"
  }
  # Format log
  $Log = "$Time`t$Type`t$Message"
  # Output
  Write-Host $Log -ForegroundColor $Colour[$Type]
}

# ------------------------------------------------------------------------------
# Database connection testing function
# ------------------------------------------------------------------------------
function CheckSQLConnection {
  <#
    .SYNOPSIS
    Check a SQL Server database connection

    .DESCRIPTION
    Check that a SQL Server database connection is working

    .PARAMETER Server
    The Server parameter corresponds to the database server to connect to

    .PARAMETER Database
    The Database parameter corresponds to the database to be tested

    .EXAMPLE
    CheckSQLConnection -Server localhost -Database OneSumX_fsdb
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Database server to connect to"
    )]
    [Alias ("S", "Svr")]
    [String]
    $Server,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Database to connect to"
    )]
    [Alias ("D", "Data", "Base")]
    [String]
    $Database,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Use of specific credentials instead of integrated security"
    )]
    [Alias ("Sec")]
    [Switch]
    $Security = $false,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "User name"
    )]
    [Alias ("U", "User", "Name")]
    [String]
    $Username,
    [Parameter (
      Position    = 5,
      Mandatory   = $false,
      HelpMessage = "Password"
    )]
    [Alias ("P", "Pw", "Pass")]
    [String]
    $Password
  )
  # Break-down connection info
  if ($Security) {
    if ($Username) {
      $ConnectionString = "Server=$Server; Database=$Database; Integrated Security=False; User ID=$Username; Password=$Password; Connect Timeout=3;"
    } else {
      LogMessage -Type "ERROR" -Message "Please provide a valid username"
      exit
    }
  } else {
    $ConnectionString = "Server=$Server; Database=$Database; Integrated Security=True; Connect Timeout=3;"
  }
  # Create connection object
  $Connection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
  # Try to open the connection
  try {
    $Connection.Open()
    $Connection.Close()
    return $true
  } catch {
    # If it fails, return false
    return $false
  }
}

# ------------------------------------------------------------------------------
# Properties parsing function
# ------------------------------------------------------------------------------
function ParseProperties {
  <#
    .SYNOPSIS
    Parse properties file

    .DESCRIPTION
    Parse properties file to generate configuration variables

    .PARAMETER File
    The File parameter should be the name of the property file.

    .PARAMETER Directory
    The Directory parameter should be the path to the directory containing the property file.

    .EXAMPLE
    ParseProperties -File "default.ini" -Directory ".\conf"
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property file name"
    )]
    [Alias ("F")]
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property file"
      )]
    [Alias ("D", "Dir")]
    $Directory,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Define if section headers should be used to group properties or ignored"
      )]
    [Alias ("S")]
    [Switch]
    $Section = $false
  )
  # Properties path
  $PropertyFile     = Join-Path $Directory $File
  # Check that the file exists
  if (Test-Path $PropertyFile) {
    # Read the property file line by line
    $FileContent    = Get-Content $PropertyFile
    $Properties     = [ordered]@{}
    $Property       = [ordered]@{}
    $LineNumber     = 0
    $Offset         = 2
    foreach ($Content in $FileContent) {
      $LineNumber  += 1
      # Ignore comments, sections, and blank lines
      if ($Content[0] -ne "#" -And $Content[0] -ne ";" -And $Content[0] -ne "[" -And $Content -ne "") {
        $Index        = $Content.IndexOf("=")
        if ($Index -gt 0) {
          $Key          = $Content.Substring(0, $Index -1)
          $Value        = $Content.Substring($Index + $Offset, $Content.Length - $Index - $Offset)
          $Property.Add("Key", $Key.Trim())
          $Property.Add("Value", $Value.Trim())
          # Check that properties has a name and value
          if ($Property.Key -And $Property.Value) {
            # Add configuration to the list of properties
            $Properties.Add($Property.Key, $Property.Value)
          } else {
            LogMessage -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
          }
          $Property.Clear()
        }
      }
    }
    # LogMessage -Type "INFO" -Message "Configuration loaded"
    return $Properties
  } else {
    # Alert that configuration file does not exists at specified location
    LogMessage -Type "ERROR" -Message "The $File file cannot be found under $(Resolve-Path $Directory)"
    exit 1
  }
}

# ------------------------------------------------------------------------------
# Server properties parsing function
# ------------------------------------------------------------------------------
function SetServerProperties {
  <#
    .SYNOPSIS
    Parse server properties file

    .DESCRIPTION
    Parse server properties file to generate hashtable

    .PARAMETER File
    The File parameter should be the name of the property file.

    .PARAMETER Directory
    The Directory parameter should be the path to the directory containing the property file.

    .EXAMPLE
    SetServerProperties -File "server.properties"
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property file name"
    )]
    [Alias ("F")]
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property file"
      )]
    [Alias ("D", "Dir")]
    $Directory
  )
  # Server properties path
  $ServerProperties = Join-Path $Directory $File
  $FileContent      = Get-Content $ServerProperties
  # Initialise variables
  $Environments = [ordered]@{}
  $Environment  = $null
  $Properties   = @{}
  $Property     = @{}
  $LineNumber   = 0
  # Read the property file line by line
  foreach ($Content in $FileContent) {
    $LineNumber  += 1
    # Check that line is neither a comment nor an empty line
    if ($Content[0] -ne "#" -And $Content[0] -ne "!" -And $Content -ne "") {
      $Index = $Content.IndexOf("=")
      # If entering a section (environment)
      if ($Content[0] -eq "[" -And $Index -lt 0) {
        # Save previous environment properties (if any)
        if ($Environment) {$Environments.Add($Environment, $Properties.Clone())}
        $Environment = $Content.Substring(1, $Content.Length -2)
        $Properties.Clear()
      } elseif ($Index -gt 0) {
        $Key    = $Content.Substring(0, $Index -1)
        $Value  = $Content.Substring($Index + $Offset, $Content.Length - $Index - $Offset)
        $Property.Add("Key", $Key.Trim())
        $Property.Add("Value", $Value.Trim())
        if ($Property.Key -And $Property.Value) {
          $Properties.Add($Property.Key, $Property.Value)
        } else {
          LogMessage -Type "WARN" -Message "Unable to process line $LineNumber from $ServerProperties"
        }
      }
      $Property.Clear()
    }
  }
  return $Environments
}

# ------------------------------------------------------------------------------
# Properties parsing function
# ------------------------------------------------------------------------------
function SetProperties {
  <#
    .SYNOPSIS
    Set properties from configuration files

    .DESCRIPTION
    Set properties from configuration files

    .PARAMETER File
    The File parameter should be the name of the property file.

    .PARAMETER Custom
    The Custom parameter should be the name of the custom property file.

    .PARAMETER Directory
    The Directory parameter should be the path to the directory containing the property file.

    .PARAMETER CustomDirectory
    The CustomDirectory parameter should be the path to the directory containing the custom property file.

    .EXAMPLE
    SetProperties -File "default.ini" -Custom "custom.properties" -Directory ".\conf"
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property file name"
    )]
    [Alias ("F")]
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Custom property file name"
    )]
    [Alias ("C")]
    $Custom,
    [Parameter (
      Position    = 3,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property files"
    )]
    [Alias ("D", "Dir")]
    $Directory,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Path to the directory containing the custom property file"
    )]
    $CustomDirectory = $Directory
  )
  # Parse properties
  $Properties = ParseProperties -File $File   -Directory $Directory
  $Customs    = ParseProperties -File $Custom -Directory $CustomDirectory
  # Override default with custom
  foreach ($Property in $Customs.Keys) {
    if ($Properties.$Property) {
      $Properties.$Property = $Customs.$Property
    } else {
      LogMessage -Type "WARN" -Message "The ""$Property"" property defined in $Custom is unknown"
    }
  }
  return $Properties
}
