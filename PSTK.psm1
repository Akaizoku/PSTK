#Requires -Version 3.0

<#
  .SYNOPSIS
  PowerShell Toolbox

  .DESCRIPTION
  Collection of useful functions and procedures

  .NOTES
  File name:      PSTK.psm1
  Author:         Florian Carrier
  Creation date:  23/08/2018
  Last modified:  04/09/2018
#>

# ------------------------------------------------------------------------------
# Logging function
# ------------------------------------------------------------------------------
function Out-Log {
  <#
    .SYNOPSIS
    Formats output message as a log

    .DESCRIPTION
    The Out-Log function outputs the time and type of a message in a formatt-
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
function Test-SQLConnection {
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
    Test-SQLConnection -Server localhost -Database OneSumX_fsdb
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
      Out-Log -Type "ERROR" -Message "Please provide a valid username"
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
function Read-Properties {
  <#
    .SYNOPSIS
    Parse properties file

    .DESCRIPTION
    Parse properties file to generate configuration variables

    .PARAMETER File
    The File parameter should be the name of the property file.

    .PARAMETER Directory
    The Directory parameter should be the path to the directory containing the property file.

    .PARAMETER Section
    The Section parameter indicates if properties should be grouped depending on existing sections in the file

    .EXAMPLE
    Read-Properties -File "default.ini" -Directory ".\conf"

    .EXAMPLE
    Read-Properties -File "default.ini" -Directory ".\conf" -Section
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
      HelpMessage = "Define if section headers should be used to group properties or be   ignored"
      )]
    [Alias ("S")]
    [Switch]
    $Section
  )
  # Properties path
  $PropertyFile = Join-Path $Directory $File
  $Properties   = [ordered]@{}
  $Sections     = [ordered]@{}
  $Header       = $null
  # Check that the file exists
  if (Test-Path $PropertyFile) {
    $FileContent  = Get-Content $PropertyFile
    $LineNumber   = 0
    # Read the property file line by line
    foreach ($Content in $FileContent) {
      $LineNumber += 1
      # If properties have to be grouped by section
      if ($Section) {
        # If end of file and section is open
        if ($LineNumber -eq $FileContent.Count -And $Header) {
          if ($Content[0] -ne "#" -And $Content[0] -ne ";" -And $Content -ne "") {
            $Property = Read-Property -Content $Content
            if ($Property.Count -gt 0) {
              $Sections.Add($Property.Key, $Property.Value)
            } else {
              Out-Log -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
            }
          }
          $Clone = Copy-OrderedHashtable -Hashtable $Sections -Deep
          $Properties.Add($Header, $Clone)
        } elseif ($Content[0] -eq "[") {
          # If previous section exists add it to the property list
          if ($Header) {
            $Clone = Copy-OrderedHashtable -Hashtable $Sections -Deep
            $Properties.Add($Header, $Clone)
          }
          # Create new property group
          $Header = $Content.Substring(1, $Content.Length - 2)
          $Sections.Clear()
        } elseif ($Header -And $Content[0] -ne "#" -And $Content[0] -ne ";" -And $Content -ne "") {
          $Property = Read-Property -Content $Content
          if ($Property.Count -gt 0) {
            $Sections.Add($Property.Key, $Property.Value)
          } else {
            Out-Log -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
          }
        }
      } else {
        # Ignore comments, sections, and blank lines
        if ($Content[0] -ne "#" -And $Content[0] -ne ";" -And $Content[0] -ne "[" -And $Content -ne "") {
          $Property = Read-Property -Content $Content
          if ($Property.Count -gt 0) {
            $Properties.Add($Property.Key, $Property.Value)
          } else {
            Out-Log -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
          }
        }
      }
    }
  } else {
    # Alert that configuration file does not exists at specified location
    Out-Log -Type "ERROR" -Message "The $File file cannot be found under $(Resolve-Path $Directory)"
  }
  return $Properties
}

# ------------------------------------------------------------------------------
# Properties parsing function
# ------------------------------------------------------------------------------
function Read-Property {
  <#
    .SYNOPSIS
    Parse property content

    .DESCRIPTION
    Parse property content

    .PARAMETER Content
    The Content parameter should be the content of the property

    .EXAMPLE
    Read-Property -Content "Key = Value"
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property content"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("C")]
    [String]
    $Content
  )
  $Property = [ordered]@{}
  $Index    = $Content.IndexOf("=")
  if ($Index -gt 0) {
    $Offset = 1
    $Key    = $Content.Substring(0, $Index)
    $Value  = $Content.Substring($Index + $Offset, $Content.Length - $Index - $Offset)
    $Property.Add("Key", $Key.Trim())
    $Property.Add("Value", $Value.Trim())
  }
  return $Property
}

# ------------------------------------------------------------------------------
# Properties parsing function
# ------------------------------------------------------------------------------
function Set-Properties {
  <#
    .SYNOPSIS
    Set properties from configuration files

    .DESCRIPTION
    Set properties from configuration files

    .PARAMETER File
    The File parameter should be the name of the property file.

    .PARAMETER Directory
    The Directory parameter should be the path to the directory containing the property file.

    .PARAMETER Custom
    The Custom parameter should be the name of the custom property file.

    .PARAMETER CustomDirectory
    The CustomDirectory parameter should be the path to the directory containing the custom property file.

    .EXAMPLE
    Set-Properties -File "default.ini" -Directory ".\conf"

    .EXAMPLE
    Set-Properties -File "default.ini" -Directory ".\conf" -Custom "custom.properties"

    .EXAMPLE
    Set-Properties -File "default.ini" -Directory ".\conf" -Custom "custom.properties" -CustomDirectory ".\shared"

    .NOTES
    Set-Properties does not currently allow the use of sections to group properties in custom files
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property file name"
    )]
    [Alias ("F")]
    [String]
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property files"
    )]
    [Alias ("D", "Dir")]
    [String]
    $Directory,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Custom property file name"
    )]
    [Alias ("C")]
    [String]
    $Custom,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Path to the directory containing the custom property file"
    )]
    [Alias ("CD")]
    [String]
    $CustomDirectory = $Directory,
    [Parameter (
      Position    = 5,
      Mandatory   = $false,
      HelpMessage = "Define if section headers should be used to group properties or be ignored"
      )]
    [Alias ("S")]
    [Switch]
    $Section
  )
  # Parse properties
  if ($Section) {
    $Properties = Read-Properties -File $File -Directory $Directory -Section
  } else {
    $Properties = Read-Properties -File $File -Directory $Directory
  }
  if ($Custom) {
    $Customs = Read-Properties -File $Custom -Directory $CustomDirectory
    foreach ($Property in $Customs.Keys) {
      # Override default with custom
      if ($Properties.$Property) {
        $Properties.$Property = $Customs.$Property
      } else {
        Out-Log -Type "WARN" -Message "The ""$Property"" property defined in $Custom is unknown"
      }
    }
  }
  return $Properties
}

# ------------------------------------------------------------------------------
# Function to compare hashtables content
# ------------------------------------------------------------------------------
function Compare-Hashtables {
  <#
    .SYNOPSIS
    Compares hashtables content

    .DESCRIPTION
    Check that two given hashtables are identic

    .PARAMETER Reference
    The Reference parameter should be the hashtable to check

    .PARAMETER Difference
    The Difference parameter should be the hashtable to check the first one against

    .EXAMPLE
    Compare-Hashtables -Reference $Hashtable1 -Difference $Hashtable2
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Reference hashtable"
    )]
    [Alias ("R", "Ref")]
    $Reference,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Difference hashtable"
      )]
    [Alias ("D", "Dif")]
    $Difference
  )
  $Check = $true
  # Check that hashtables are of the same size
  if ($Reference.Count -ne $Difference.Count) {
    $Check = $false
  } else {
    # Loop through tables
    foreach ($Key in $Reference.Keys) {
      # Check that they contain the same keys
      if ($Difference.$Key) {
        # Check that they contain the same values
        if ($Difference.$Key -ne $Reference.$Key) {
          $Check = $false
          break
        }
      } else {
        $Check = $false
        break
      }
    }
  }
  return $Check
}

# ------------------------------------------------------------------------------
# Function to compare hashtables content
# ------------------------------------------------------------------------------
function Copy-OrderedHashtable {
  <#
    .SYNOPSIS
    Clone an ordered hashtable

    .DESCRIPTION
    Clone an ordered hashtable

    .PARAMETER Hashtable
    The Hashtable parameter should be the hashtable to clone

    .EXAMPLE
    Copy-OrderedHashtable -Hashtable $Hashtable
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Hashtable to clone"
    )]
    [Alias ("H", "Hash", "T", "Table")]
    $Hashtable,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Define if the copy should be shallow or deep"
    )]
    [Alias ("D", "DeepCopy")]
    [Switch]
    $Deep = $false
  )
  $Clone = [ordered]@{}
  # If deep copy
  if ($Deep) {
    $MemoryStream     = New-Object System.IO.MemoryStream
    $BinaryFormatter  = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $BinaryFormatter.Serialize($MemoryStream, $Hashtable)
    $MemoryStream.Position = 0
    $Clone = $BinaryFormatter.Deserialize($MemoryStream)
    $MemoryStream.Close()
  } else {
    # Shallow copy
    foreach ($Item in $Hashtable.GetEnumerator()) {
      $Clone[$Item.Key] = $Item.Value
    }
  }
  return $Clone
}
