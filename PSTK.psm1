#Requires -Version 3.0

<#
  .SYNOPSIS
  PowerShell Toolbox

  .DESCRIPTION
  Collection of useful functions and procedures.

  .NOTES
  File name:      PSTK.psm1
  Author:         Florian Carrier
  Creation date:  23/08/2018
  Last modified:  04/10/2018
  Repository:     https://github.com/Akaizoku/PSTK
  Depndencies:    Test-SQLConnection requires the SQLServer module

  .LINK
  https://github.com/Akaizoku/PSTK

  .LINK
  https://docs.microsoft.com/en-us/sql/powershell/download-sql-server-ps-module
#>

# ------------------------------------------------------------------------------
# Logging function
# ------------------------------------------------------------------------------
function Write-Log {
  <#
    .SYNOPSIS
    Formats output message as a log

    .DESCRIPTION
    The Write-Log function outputs the time and type of a message in a formatt-
    ed manner with respective colour code.

    .PARAMETER Type
    The Type parameter defines the level of importance of the message and will
    influence the colour of the output.

    .PARAMETER Message
    The Message parameter corresponds to the desired output to be logged.

    .INPUTS
    None. You cannot pipe objects to Write-Log.

    .OUTPUTS
    None. Simply writes a message to the host.

    .EXAMPLE
    Write-Log -Type "INFO" -Message "This is an informational message."

    This example outputs an informational message with the timestamp, the "INFO"
     tag, and the specified message itself. It uses the defaut color scheme.

    .EXAMPLE
    Write-Log -Type "WARN" -Message "This is a warning message."

    This example outputs a warning message with the timestamp, the "WARN" tag,
    and the specified message itself. The message will be displayed in yellow in
     the host.

    .EXAMPLE
    Write-Log -Type "ERROR" -Message "This is an error message."

    This example outputs an error message with the timestamp, the "ERROR" tag,
    and the specified message itself. The message will be displayed in red in
     the host.

    .EXAMPLE
    Write-Log -Type "CHECK" -Message "This is a checkpoint message."

    This example outputs a checkpoint message with the timestamp, the "CHECK"
    tag, and the specified message itself. The message will be displayed in
    green in the host.

    .NOTES
    TODO Add locale variable
  #>
  [CmdletBinding ()]
  # Inputs
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Type of message to output"
    )]
    [ValidateSet (
      "CHECK",
      "ERROR",
      "INFO",
      "WARN"
    )]
    [String]
    $Type,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Message to output"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Output", "Log")]
    [String]
    $Message
  )
  # Variables
  $Time     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $Colour   = [Ordered]@{
    "CHECK" = "Green"
    "ERROR" = "Red"
    "INFO"  = "White"
    "WARN"  = "Yellow"
  }
  # Format log
  $Log = "$Time`t$Type`t$Message"
  # Output
  Write-Host $Log -ForegroundColor $Colour.$Type
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
    TODO Add secured password handling
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
  # Break-down connection info
  if ($Security) {
    Write-Debug "SQL Server authentication"
    if ($Username) {
      $ConnectionString = "Server=$Server; Database=$Database; Integrated Security=False; User ID=$Username; Password=$Password; Connect Timeout=3;"
    } else {
      Write-Log -Type "ERROR" -Message "Please provide a valid username"
      Write-Debug "$Username"
      Stop-Script 1
    }
  } else {
    Write-Debug "Integrated Secutiry"
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
    Write-Debug "Unable to connect to $ConnectionString"
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
    [String] The File parameter should be the name of the property file.

    .PARAMETER Directory
    [String] The Directory parameter should be the path to the directory containing the
    property file.

    .PARAMETER Section
    [Switch] The Section parameter indicates if properties should be grouped depending on
     existing sections in the file.

    .OUTPUTS
    [System.Collections.Specialized.OrderedDictionary] Read-Properties returns an
    ordered hash table containing the content of the property file.

    .EXAMPLE
    Read-Properties -File "default.ini" -Directory ".\conf" -Section

    In this example, Read-Properties will parse the default.ini file contained
    in the .\conf directory and generate an ordered hashtable containing the
    key-values pairs.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property file name"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property file"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Directory,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Define if section headers should be used to group properties or be ignored"
      )]
    [Switch]
    $Section
  )
  # Properties variables
  $PropertyFile = Join-Path -Path $Directory -ChildPath $File
  $Properties   = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
  $Sections     = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
  $Header       = $null
  # Check that the file exists
  if (Test-Path -Path $PropertyFile) {
    $FileContent  = Get-Content -Path $PropertyFile
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
              Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
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
            Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
          }
        }
      } else {
        # Ignore comments, sections, and blank lines
        if ($Content[0] -ne "#" -And $Content[0] -ne ";" -And $Content[0] -ne "[" -And $Content -ne "") {
          $Property = Read-Property -Content $Content
          if ($Property.Count -gt 0) {
            $Properties.Add($Property.Key, $Property.Value)
          } else {
            Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
          }
        }
      }
    }
  } else {
    # Alert that configuration file does not exists at specified location
    Write-Log -Type "ERROR" -Message "The $File file cannot be found under $(Resolve-Path $Directory)"
  }
  return $Properties
}

# ------------------------------------------------------------------------------
# Property parsing function
# ------------------------------------------------------------------------------
function Read-Property {
  <#
    .SYNOPSIS
    Parse property content

    .DESCRIPTION
    Parse property content

    .PARAMETER Content
    [String] The Content parameter should be the content of the property.

    .INPUTS
    None.

    .OUTPUTS
    [System.Collections.Specialized.OrderedDictionary] Read-Property returns an
    ordered hashtable containing the name and value of a given property.

    .EXAMPLE
    Read-Property -Content "Key = Value"

    In this example, Read-Property will parse the content and assign the value
    "Value" to the property "Key".
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property content"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Content
  )
  $Property = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
  $Index    = $Content.IndexOf("=")
  if ($Index -gt 0) {
    $Offset = 1
    $Key    = $Content.Substring(0, $Index)
    $Value  = $Content.Substring($Index + $Offset, $Content.Length - $Index - $Offset)
    $Property.Add("Key"   , $Key.Trim())
    $Property.Add("Value" , $Value.Trim())
  }
  return $Property
}

# ------------------------------------------------------------------------------
# Properties setting function
# ------------------------------------------------------------------------------
function Get-Properties {
  <#
    .SYNOPSIS
    Get properties from configuration files

    .DESCRIPTION
    Get properties from configuration files

    .PARAMETER File
    The File parameter should be the name of the property file.

    .PARAMETER Directory
    The Directory parameter should be the path to the directory containing the
    property file.

    .PARAMETER Custom
    The Custom parameter should be the name of the custom property file.

    .PARAMETER CustomDirectory
    The CustomDirectory parameter should be the path to the directory containing
     the custom property file.

    .OUTPUTS
    System.Collections.Specialized.OrderedDictionary. Get-Properties returns an
    ordered hash table containing the names and values of the properties listed
    in the property files.

    .EXAMPLE
    Get-Properties -File "default.ini" -Directory ".\conf" -Custom "custom.ini" -CustomDirectory "\\shared"

    In this example, Get-Properties will read properties from the default.ini
    file contained in the .\conf directory, then read the properties from
    in the custom.ini file contained in the \\shared directory, and override the
    default ones with the custom ones.

    .NOTES
    Get-Properties does not currently allow the use of sections to group proper-
    ties in custom files
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property file name"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property files"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Directory,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Custom property file name"
    )]
    [String]
    $Custom,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Path to the directory containing the custom property file"
    )]
    [String]
    $CustomDirectory = $Directory,
    [Parameter (
      Position    = 5,
      Mandatory   = $false,
      HelpMessage = "Define if section headers should be used to group properties or be ignored"
      )]
    [Switch]
    $Section
  )
  # Check that specified file exists
  if (Test-Path -Path "$Directory\$File") {
    # Parse properties with or without section split
    if ($Section) {
      $Properties = Read-Properties -File $File -Directory $Directory -Section
    } else {
      $Properties = Read-Properties -File $File -Directory $Directory
    }
    # Check if a custom file is provided
    if ($Custom) {
      # Make sure said file does exists
      if (Test-Path -Path "$CustomDirectory\$Custom") {
        # Override default properties with custom ones
        $Customs = Read-Properties -File $Custom -Directory $CustomDirectory
        foreach ($Property in $Customs.Keys) {
          # Override default with custom
          if ($Properties.$Property) {
            $Properties.$Property = $Customs.$Property
          } else {
            Write-Log -Type "WARN" -Message "The ""$Property"" property defined in $Custom is unknown"
          }
        }
      } else {
        Write-Log -Type "WARN" -Message "$Custom not found in directory $CustomDirectory"
      }
    }
    return $Properties
  } else {
    Write-Log -Type "ERROR" -Message "$File not found in directory $Directory"
    Stop-Script 1
  }
}

# ------------------------------------------------------------------------------
# Function to compare hashtables content
# ------------------------------------------------------------------------------
function Compare-Hashtable {
  <#
    .SYNOPSIS
    Compares hashtables content

    .DESCRIPTION
    Check that two given hashtables are identic.

    .PARAMETER Reference
    The Reference parameter should be the hashtable to check.

    .PARAMETER Difference
    The Difference parameter should be the hashtable against which to check the
    first one.

    .OUTPUTS
    Boolean. Compare-Hashtable returns a boolean depnding on the result of the
    comparison between the two hashtables.

    .EXAMPLE
    Compare-Hashtable -Reference $Hashtable1 -Difference $Hashtable2
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Reference hashtable"
    )]
    [ValidateNotNullOrEmpty ()]
    # [System.Collections.Specialized.OrderedDictionary]
    $Reference,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Difference hashtable"
      )]
    [ValidateNotNullOrEmpty ()]
    # [System.Collections.Specialized.OrderedDictionary]
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
          Write-Debug "$($Difference.$Key) does not exists in reference hashtable"
          break
        }
      } else {
        $Check = $false
        Write-Debug "$Key does not exists in difference hashtable"
        break
      }
    }
  }
  return $Check
}

# ------------------------------------------------------------------------------
# Function to clone an existing hashtable
# ------------------------------------------------------------------------------
function Copy-OrderedHashtable {
  <#
    .SYNOPSIS
    Clone an ordered hashtable

    .DESCRIPTION
    Clone an ordered hashtable

    .PARAMETER Hashtable
    The Hashtable parameter should be the hashtable to clone

    .OUTPUTS
    [System.Collections.Specialized.OrderedDictionary] Copy-OrderedHashtable re-
    turns an exact copy of the ordered hash table specified.

    .EXAMPLE
    Copy-OrderedHashtable -Hashtable $Hashtable
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Hashtable to clone"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $Hashtable,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Define if the copy should be shallow or deep"
    )]
    [Alias ("DeepCopy")]
    [Switch]
    $Deep = $false
  )
  $Clone = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
  # If deep copy
  if ($Deep) {
    $MemoryStream     = New-Object -TypeName System.IO.MemoryStream
    $BinaryFormatter  = New-Object -TypeName System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $BinaryFormatter.Serialize($MemoryStream, $Hashtable)
    $MemoryStream.Position = 0
    $Clone = $BinaryFormatter.Deserialize($MemoryStream)
    $MemoryStream.Close()
  } else {
    # Shallow copy
    foreach ($Item in $Hashtable.GetEnumerator()) {
      $Clone.$Item.Key = $Item.Value
    }
  }
  return $Clone
}

# ------------------------------------------------------------------------------
# Advanced start function
# ------------------------------------------------------------------------------
function Start-Script {
  <#
    .SYNOPSIS
    Start script

    .DESCRIPTION
    Start transcript and set strict mode

    .PARAMETER Transcript
    [String] The transcript parameter corresponds to the path to the file to be
    generated to log the session.

    .EXAMPLE
    Start-Script -Transcript ".\log\transcript.log"

    In this example, Start-Script will set stric mode on, and record all the
    output in a file colled "transcript.log" under the ".\log" directory.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Transcript file path"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("LogFile")]
    [String]
    $Transcript
  )
  Begin {
    Set-StrictMode -Version Latest
  }
  Process {
    Start-Transcript -Path $Transcript -Append -Force
  }
}

# ------------------------------------------------------------------------------
# Advanced exit function
# ------------------------------------------------------------------------------
function Stop-Script {
  <#
    .SYNOPSIS
    Stop script

    .DESCRIPTION
    Exit script, set error code, disable stric-mode, and stop transcript if any.

    .PARAMETER ErrorCode
    The error code parameter corresponds to the error code thrown after exiting
    the script. Default is 0 (i.e. no errors).

    .EXAMPLE
    Stop-Script

    In this example, Stop-Script will set strict mode off, stop the transcript
    if any is currently active, and exit the script with error code 0.

    .EXAMPLE
    Stop-Script -ErrorCode 1

    In this example, Stop-Script will set strict mode off, stop the transcript
    if any is currently active, and exit the script with error code 1.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $false,
      HelpMessage = "Error code"
    )]
    [Alias ("Code")]
    [Int]
    $ErrorCode = 0
  )
  Begin {
    Set-StrictMode -Off
    try {
      Stop-Transcript
    } catch {
      Write-Log -Type "WARN" -Message "No transcript is being produced"
    }
  }
  Process {
    exit $ErrorCode
  }
}

# ------------------------------------------------------------------------------
# Compare two properties list
# ------------------------------------------------------------------------------
function Compare-Properties {
  <#
    .SYNOPSIS
    Checks that all required property are defined

    .DESCRIPTION
    Checks that all required property are defined by returning a list of missing
     properties

    .PARAMETER Properties
    The properties parameter corresponds to the list of properties defined

    .PARAMETER Required
    The required parameter corresponds to the list of properties that are requi-
    red

    .OUTPUTS
    [System.Collections.ArrayList] Compare-Properties returns an array containing
     the missing properties from the list.

    .EXAMPLE
    Assert-Properties -Properties $Properties -Required $Required

    .NOTES
    Check if returned list is empty to verify that all is well
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of properties"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary] # Ordered hashtable
    $Properties,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "List of properties to check"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $Required
  )
  $Missing = New-Object -TypeName System.Collections.ArrayList
  $Parameters = $Required.Split(",")
  foreach ($Parameter in $Parameters) {
    $Property = $Parameter.Trim()
    if ($Property -ne "" -And !$Properties.$Property) {
      [Void]$Missing.Add($Property)
    }
  }
  # Force array-list format
  return @($Missing)
}

# ------------------------------------------------------------------------------
# Sort function
# ------------------------------------------------------------------------------
function ConvertTo-NaturalSort {
  <#
    .SYNOPSIS
    Sort a list in the natural order

    .DESCRIPTION
    Sort a list of files by their name in the natural order. Sort can be ascend-
    ing (default) or descending.

    .PARAMETER Files
    The files parameters corresponds to the list of files to be sorted.

    .PARAMETER Order
    The order parameter corresponds to the order of the sort. Two values are
    possible:
    - Ascending (default)
    - Descending

    .INPUTS
    None.

    .OUTPUTS
    [System.Array] ConvertTo-NaturalSort returns a sorted array.

    .EXAMPLE
    ConvertTo-NaturalSort -Array @("a10", "b1", "a1")

    .EXAMPLE
    ConvertTo-NaturalSort -Array @("a10", "b1", "a1") -Order "Descending"

    .NOTES
    TODO Make generic to allow sorting simple string arrays
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of files to sort"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("List")]
    $Files,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Specifies the order of the sort"
    )]
    [ValidateSet (
      "A", "Asc", "Ascending",
      "D", "Dsc", "Desc", "Descending"
    )]
    [String]
    $Order = "Ascending"
  )
  $Ascending      = @("A", "Asc", "Ascending")
  $Descending     = @("D", "Dsc", "Desc", "Descending")
  $MaximumLength  = Measure-FileProperty -Files $Files -Property "MaximumLength"
  $RegEx = { [RegEx]::Replace($_.BaseName, '\d+', { $args[0].Value.PadLeft($MaximumLength) }) }
  if ($Descending.Contains($Order)) {
    $SortedFiles = $Files | Sort-Object $RegEx -Descending
  } elseif ($Ascending.Contains($Order)) {
    $SortedFiles = $Files | Sort-Object $RegEx
  }
  return $SortedFiles
}

# ------------------------------------------------------------------------------
# Increment/decrement alphanumeric string
# ------------------------------------------------------------------------------
function Add-Offset {
  <#
    .SYNOPSIS
    Adds an offset to an alphanumeric chain of characters

    .DESCRIPTION
    Adds an offset to the integer part of an alphanumeric chain of characters.

    .PARAMETER Alphanumeric
    The alphanumeric parameter corresponds to the chain of characters to offset.

    .PARAMETER Offset
    The offset parameter corresponds to the integer by which the alphanumeric
    chain of characters should be offset.

    .INPUTS
    None.

    .OUTPUTS
    System.String. Add-Offset returns an alphanumeric chain of character.

    .EXAMPLE
    Add-Offset -Alphanumeric "a1" -Offset 2

    .NOTES
    The alphanumeric chain of characters has to match the following regular ex-
    pressions:
    - ^\d+$
    - ^\d+\D+$
    - ^\D+\d+$
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Alphanumeric chain of character"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Alphanumeric,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Offset"
    )]
    [ValidateNotNullOrEmpty ()]
    [Int]
    $Offset
  )
  try {
    # Check character chain format
    $Format = Test-Alphanumeric -Alphanumeric $Alphanumeric
    if ($Format -ne 0) {
      # Increment/decrement value
      if ($Format -eq 1) {
        $NewAlphanumeric = [Long]$Alphanumeric + $Offset
      } else {
        $Integer  = $Alphanumeric -replace ('\D+', "")
        $String   = $Alphanumeric -replace ('\d+', "")
        [Long]$Integer += $Offset
        if ($Format -eq 2) {
          $NewAlphanumeric = "$Integer$String"
        } elseif ($Format -eq 3) {
          $NewAlphanumeric = "$String$Integer"
        }
      }
    } else {
      Write-Log -Type "WARN" -Message "The alphanumeric chain of character (""$Alphanumeric"") does not have a correct format."
      return $Alphanumeric
    }
  } catch [System.Management.Automation.RuntimeException] {
    Write-Log -Type "ERROR" -Message "The numeric value is too large (greater than $([Long]::MaxValue))."
  }
  return $NewAlphanumeric
}

# ------------------------------------------------------------------------------
# Increment/decrement numbered files
# ------------------------------------------------------------------------------
function Rename-NumberedFile {
  <#
    .SYNOPSIS
    Renames numbered files by a given offset

    .DESCRIPTION
    Rename numbered files by offsetting their numbers by a specified integer.

    .PARAMETER Path
    The path parameter corresponds to the path to the directory containing the
    files to be renamed.

    .PARAMETER Offset
    The offset parameter corresponds to the integer to add to the file names.

    .PARAMETER Filter
    The filter parameter corresponds to the pattern to apply as a filter to
    select files to rename in the specified directory.
    Default value is "*" (all).

    .PARAMETER Exclude
    The exclude parameter corresponds to the pattern of files to exclude from
    the scope of the procedure.
    Default value is null (none).

    .INPUTS
    None.

    .OUTPUTS
    [Boolean] Rename-NumberedFile returns a boolean depending on the success of
    the operation.

    .EXAMPLE
    Rename-NumberedFile -Path "\folder" -Offset 1

    .EXAMPLE
    Rename-NumberedFile -Path "\folder" -Offset 1 -Filter "*.txt"

    .EXAMPLE
    Rename-NumberedFile -Path "\folder" -Offset 1 -Filter "*.txt" -Exclude "test.txt"

    .NOTES
    Rename-NumberedFile only works with positive numbers to avoid conflicts with
    dashes in filenames.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the files"
    )]
    [ValidateScript ({if (Test-Path -Path $_) {$true} else {Throw "Path does not exist."}})]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Offset"
    )]
    [ValidateScript ({if ($_ -eq 0) {Throw "The offset cannot be 0."} else {$true}})]
    [Int]
    $Offset,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Filter to apply"
    )]
    [String]
    $Filter = "*",
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Pattern to exclude"
    )]
    [String]
    $Exclude = $null
  )
  $Output   = $false
  $Count    = 0
  $Numeric  = [RegEx]::New('\d+')
  # Get files
  $Files = Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude
  $Files = $Files | Where-Object {$_.BaseName -match $Numeric}
  if ($Files.Count -eq 0) {
    if ($Filter -ne "*") {
      Write-Log -Type "ERROR" -Message "No numbered files were found in $Path matching the filter ""$Filter""."
    } elseif ($Exclude) {
      Write-Log -Type "ERROR" -Message "No numbered files corresponding to the criterias were found in $Path."
    } else {
      Write-Log -Type "ERROR" -Message "No numbered files were found in $Path."
    }
    Stop-Script 1
  } else {
    # Check offset sign
    if ($Offset -lt 0) {
      # If negative, check that it will not generate negative values
      $Minimum = Measure-FileProperty -Files $Files -Property "MinimumValue"
      if ($Minimum -eq 0) {
        Write-Log -Type "ERROR" -Message "The minimum value is already 0."
        Stop-Script 1
      } elseif ($Minimum -lt [System.Math]::Abs($Offset)) {
        Write-Log -Type "ERROR" -Message "The offset is greater than the minimum value ($Minimum)."
        Stop-Script 1
      }
    } elseif ($Offset -gt 0) {
      # If positive, sort in descending order
      $Files = ConvertTo-NaturalSort -Files $Files -Order "Descending"
    }
    # Rename files
    foreach ($File in $Files) {
      $Filename     = $File.BaseName
      $Extension    = $File.Extension
      $NewFilename  = Add-Offset -Alphanumeric $Filename -Offset $Offset
      # Check if file name has changed
      if ($NewFilename -eq $Filename) {
        Write-Log -Type "ERROR" -Message "The ""$File"" file could not be renamed."
      } else {
        try {
          Write-Log -Type "INFO" -Message "Renaming ""$($File.Name)"" in ""$NewFilename$Extension""."
          Rename-Item -Path $File -NewName "$NewFilename$Extension"
          $Count += 1
        } catch [System.Management.Automation.PSInvalidOperationException] {
          Write-Log -Type "ERROR" -Message "The ""$File"" file could not be renamed."
        }
      }
    }
    if ($Count -gt 0) {
      Write-Log -Type "CHECK" -Message "$Count files were successfully renamed."
      $Output = $true
    }
  }
  return $Output
}

# ------------------------------------------------------------------------------
# Test alphanumeric chain
# ------------------------------------------------------------------------------
function Test-Alphanumeric {
  <#
    .SYNOPSIS
    Check the format of an alphanumeric chain of characters

    .DESCRIPTION
    Test the format of an alphanumeric chain of characters to see if it can be
    incremented or decremented easily.

    .PARAMETER Alphanumeric
    The alphanumeric parameter corresponds to the chain of characters to offset.

    .INPUTS
    None.

    .OUTPUTS
    [System.Integer] Test-Alphanumeric returns the type of format that the alpha
    numeric chain of characters if using.

    .EXAMPLE
    Test-Alphanumeric -Alphanumeric "a1"

    .NOTES
    Types of format allowed and corresponding regular expressions (0 is invalid):
    1. ^\d+$
    2. ^\d+\D+$
    3. ^\D+\d+$
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Alphanumeric chain of character"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Alphanumeric
  )
  Begin {
    # Declare valid formats
    $Number = [RegEx]::New('^\d+$')
    $NumStr = [RegEx]::New('^\d+\D+$')
    $StrNum = [RegEx]::New('^\D+\d+$')
  }
  Process {
    # Test and return format
    if ($Alphanumeric -match $Number) {
      return 1
    } elseif ($Alphanumeric -match $NumStr) {
      return 2
    } elseif ($Alphanumeric -match $StrNum) {
      return 3
    } else {
      return 0
    }
  }
}

# ------------------------------------------------------------------------------
# Measure properties in file list
# ------------------------------------------------------------------------------
function Measure-FileProperty {
  <#
    .SYNOPSIS
    Measure specified property of a list of files

    .DESCRIPTION
    Measure a specified property from a list of files.

    .PARAMETER Files
    The files parameter coresponds to the list of files to analyse.

    .PARAMETER Property
    The property parameter corresponds to the property to measure.
    The available properties are:
    - MaximumLength
    - MinimumValue

    .EXAMPLE
    Measure-FileProperty -Files $Files -Property "MaximumLength"

    In this example, Measure-FileProperty returns the maximum length of file
    names in a specified list of files.

    .EXAMPLE
    Measure-FileProperty -Files $Files -Property "MinimumValue"

    In this example, Measure-FileProperty returns the minimum numeric value in a
     specified list of numbered files.
  #>
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of Files to parse"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("List")]
    $Files,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Property to measure"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Property
  )
  Process {
    foreach ($File in $Files) {
      switch ($Property) {
        # Maximum length of file names
        "MaximumLength" {
          $MaximumLength = 0
          [Int]$Length = $File.BaseName | Measure-Object -Character | Select-Object -ExpandProperty "Characters"
          if ($Length -gt $MaximumLength) {
            $MaximumLength = $Length
          }
          return $MaximumLength
          continue
        }
        # Minimum value of numbered file names
        "MinimumValue" {
          $MinimumValue = $null
          try {
            $Filename = $File.BaseName
            $Format = Test-Alphanumeric -Alphanumeric $Filename
            if ($Format -ne 0) {
              if ($Format -eq 1) {
                [Long]$Integer = $Filename
              } else {
                [Long]$Integer = $Filename -replace ('\D+', "")
              }
              if ($MinimumValue -eq $null -Or $Integer -lt $MinimumValue) {
                $MinimumValue = $Integer
              }
            } else {
              Write-Log -Type "ERROR" -Message "The file ""$Filename"" does not have a correct format."
              Stop-Script 1
            }
          } catch [System.Management.Automation.RuntimeException] {
            Write-Log -Type "ERROR" -Message "The numeric value is too large (greater than $([Long]::MaxValue))."
          }
          return $MinimumValue
          continue
        }
        default {
          Write-Log -Type "ERROR" -Message "Measure-FileProperty: $Property property is not unknown."
          Stop-Script 1
        }
      }
    }
  }
}

# ------------------------------------------------------------------------------
# Convert Word to PDF
# ------------------------------------------------------------------------------
function ConvertTo-PDF {
  <#
    .SYNOPSIS
    Convert Word document to PDF

    .DESCRIPTION
    Convert documents in a Word format to a Portable Document Format (PDF) with-
    out having to open Microsoft Word.

    .PARAMETER Path
    The path parameter corresponds to the path of the directory containing the
    Microsoft Word documents to convert to PDF. It can point to a single file.

    .EXAMPLE
    ConvertTo-PDF -Path ".\doc"
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Directory containing the files to convert"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Directory")]
    [String]
    $Path
  )
  Begin {
    $Output = $false
    $Count  = 0
  }
  Process {
    if (Test-Path -Path $Path) {
      # Initialise MS Word application and identify document
      $MSWord = New-Object -ComObject Word.Application
      $Files  = Get-Object -Path $Path -Filter "*.doc?"
      if ($Files.Count -gt 0) {
        foreach ($File in $Files) {
          try {
            # Generate PDF
            $Document = $MSWord.Documents.Open($File.FullName)
            $PDFName  = "$($File.BaseName).pdf"
            $PDF      = "$($File.DirectoryName)\$PDFName"
            Write-Log -Type "INFO" -Message "Converting ""$($File.Name)"" to PDF"
            $Document.SaveAs([Ref] $PDF, [Ref] 17)
            $Document.Close()
            $Count += 1
          } catch [System.Management.Automation.RuntimeException] {
            Write-Log -Type "WARN" -Message "An error occured while generating $PDFName"
          }
          Write-Log -Type "CHECK" -Message """$PDFName"" successfully generated"
        }
        if ($Count -gt 0) {
          $Output = $true
        }
        Write-Log -Type "CHECK" -Message "$Count Word documents were converted to PDF"
      } else {
        Write-Log -Type "ERROR" -Message "No Microsoft Word documents were found in $Path."
      }
    } else {
      Write-Log -Type "ERROR" -Message "$Path does not exists."
      Stop-Script 1
    }
    return $Output
  }
  End {
    $MSWord.Quit()
  }
}

# ------------------------------------------------------------------------------
# Complete relative paths
# ------------------------------------------------------------------------------
function Complete-RelativePath {
  <#
    .SYNOPSIS
    Make relative path absolute

    .DESCRIPTION
    Auto-complete relative path with working directory to make them absolute

    .OUTPUTS
    [System.Collections.ArrayList] Complete-RelativePath returns a list of abso-
    lute paths.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Relative path to make absolute"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Paths")]
    [String[]]
    $RelativePaths,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Root directory to pre-prend to relative path"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Directory")]
    [String]
    $WorkingDirectory
  )
  Begin {
    if (-Not (Test-Path -Path $WorkingDirectory)) {
      Write-Log -Type "ERROR" -Message "$WorkingDirectory does not exists."
      Stop-Script 1
    }
    $Paths = New-Object -TypeName System.Collections.ArrayList
  }
  Process {
    foreach ($RelativePath in $RelativePaths) {
      # If path is correct, change value to absolute
      $AbsolutePath = Join-Path -Path $WorkingDirectory -ChildPath $RelativePath
      if (Test-Path -Path $AbsolutePath) {
        [Void]$Paths.Add($AbsolutePath)
      } else {
        # If it is not found, keep relative path
        Write-Log -Type "WARN" -Message "$AbsolutePath does not exists."
        [Void]$Paths.Add($RelativePath)
      }
    }
    return $Paths
  }
}

# ------------------------------------------------------------------------------
# Identify exception name
# ------------------------------------------------------------------------------
function Show-ExceptionFullName {
  <#
    .SYNOPSIS
    Show full exception name

    .DESCRIPTION
    Show full exception name to facilitate error handling (try...catch)

    .PARAMETER Errors
    The errors parameters corresponds to the errors thrown.

    .INPUTS
    None.

    .OUTPUTS
    [System.String] Show-ExceptionFullName returns the full name of the except-
    ion as a string.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Errors to analyse"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.ArrayList]
    $Errors
  )
  return $Errors.Exception.GetType().FullName
}

# ------------------------------------------------------------------------------
# Convert file encoding
# ------------------------------------------------------------------------------
function Convert-FileEncoding {
  <#
    .SYNOPSIS
    Convert file to specified encoding

    .DESCRIPTION
    Create a copy of a given file and convert the encoding as specified.

    .PARAMETER Path
    [String] The path parameter corresponds to the path to the directory or file
     to encode.

     .PARAMETER Encoding
     [String] The encoding parameter corresponds to the encoding to converting
     the file(s) to.

    .PARAMETER Filter
    [String] The filter parameters corresponds to the pattern to match to filter
     objects from the result set.

    .PARAMETER Exclude
    [String] The exclude parameters corresponds to the pattern to match to ex-
    clude objects from the result set.

    .NOTES
    /!\ Exclude is currently not supported in Windows PowerShell
    See Get-Object

    .LINK
    Get-Object
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the files to convert"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Encoding"
    )]
    [String]
    $Encoding,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Filter to apply"
    )]
    [String]
    $Filter = "*",
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Pattern to exclude"
    )]
    [String]
    $Exclude = $null
  )
  Begin {
    # Check parameters and instantiate variables
    # $Path     = Resolve-Path -Path $Path
    $Files    = Get-Object -Path $Path -Type "File" -Filter $Filter -Exclude $Exclude
    $Encoding = $Encoding.ToUpper()
    $Output   = $false
    $Count    = 0
  }
  Process {
    try {
      foreach ($File in $Files) {
        Write-Log -Type "INFO" -Message "Converting ""$($File.Name)"" to $Encoding"
        $Filename = "$($File.BaseName)_$Encoding$($File.Extension)"
        $FilePath = Join-Path -Path $Path -ChildPath $File
        $NewFile  = Join-Path -Path $Path -ChildPath $Filename
        Get-Content -Path $FilePath | Out-File -Encoding $Encoding $NewFile
        $Count += 1
      }
      if ($Count -gt 0) {
        $Output = $true
      }
      Write-Log -Type "CHECK" -Message "$Count files were converted to $Encoding"
    } catch {
      Write-Log -Type "ERROR" -Message "$($Error[0].Exception)"
    }
    return $Output
  }
}

# ------------------------------------------------------------------------------
# Generic Get-ChildItem with checks
# ------------------------------------------------------------------------------
function Get-Object {
  <#
    .SYNOPSIS
    Convert file to specified encoding

    .DESCRIPTION
    Create a copy of a given file and convert the encoding as specified.

    .PARAMETER Path
    [String] The path parameter corresponds to the path to the directory or object to
    retrieve.

    .PARAMETER Type
    [String] The type parameters corresponds to the type of object(s) to retrieve. Three
    values are possible:
    - ALL :   files and folders alike
    - File:   only files
    - Folder: only folders

    .PARAMETER Filter
    [String] The filter parameters corresponds to the pattern to match to filter objects
    from the result set.

    .PARAMETER Exclude
    [String] The exclude parameters corresponds to the pattern to match to exclude ob-
    jects from the result set.

    .OUTPUTS
    [System.Collections.ArrayList] Get-Object returns an array list containing
    the list of objects.

    .EXAMPLE
    Get-Object -Path "\path\to\folder"

    In this example, Get-Object will return all the objects (files and folders)
    listed in the "\path\to\folder" directory.

    .EXAMPLE
    Get-Object -Path "\path\to\folder" -Type "File"

    In this example, Get-Object will return all the files listed in the
    "\path\to\folder" directory.

    .EXAMPLE
    Get-Object -Path "\path\to\folder" -Type "Folder"

    In this example, Get-Object will return all the folders listed in the
    "\path\to\folder" directory.

    .EXAMPLE
    Get-Object -Path "\path\to\folder" -Type "File" -Filter "*.txt"

    In this example, Get-Object will return all the text files listed in the
    "\path\to\folder" directory.

    .EXAMPLE
    Get-Object -Path "\path\to\folder" -Type "File" -Exclude "*.txt"

    In this example, Get-Object will return all the non-text files listed in the
     "\path\to\folder" directory.

    /!\ The use of the exclude tag require PowerShell Core v6.1 or later.

    .NOTES
    /!\ Exclude is currently not supported in Windows PowerShell
    See https://github.com/PowerShell/PowerShell/issues/6865
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the items"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Type of item"
    )]
    [ValidateSet (
      "All",
      "File",
      "Folder"
    )]
    [String]
    $Type = "All",
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Filter to apply"
    )]
    [String]
    $Filter = "*",
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Pattern to exclude"
    )]
    [String]
    $Exclude = $null
  )
  Begin {
    $Path = Resolve-Path -Path $Path
    if (-Not (Test-Path -Path $Path)) {
      Write-Log -Type "ERROR" -Message "$Path does not exists."
      Stop-Script 1
    }
    $ObjectType = [Ordered]@{
      "All"     = "items"
      "File"    = "files"
      "Folder"  = "folders"
    }
  }
  Process {
    $Objects = New-Object -TypeName System.Collections.ArrayList
    # Check PowerShell version to prevent issue
    $PSVersion = $PSVersionTable.PSVersion | Select-Object -ExpandProperty "Major"
    if ($PSVersion -lt 6) {
      switch ($Type) {
        "File"    { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -File)       }
        "Folder"  { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Directory)  }
        default   { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter)             }
      }
    } else {
      switch ($Type) {
        "File"    { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude -File)       }
        "Folder"  { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude -Directory)  }
        default   { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude)             }
      }
    }
    # If no files are found, print hints
    if ($Objects. Count -eq 0) {
      if ($Filter -ne "*") {
        Write-Log -Type "ERROR" -Message "No $($ObjectType.$Type) were found in $Path matching the filter ""$Filter""."
      } elseif ($Exclude) {
        Write-Log -Type "ERROR" -Message "No $($ObjectType.$Type) corresponding to the criterias were found in $Path."
      } else {
        Write-Log -Type "ERROR" -Message "No $($ObjectType.$Type) were found in $Path."
      }
      Stop-Script 1
    } else {
      return $Objects
    }
  }
}

# ------------------------------------------------------------------------------
# Replace tags in string
# ------------------------------------------------------------------------------
function Set-Tags {
  <#
    .SYNOPSIS
    Set tags in string

    .DESCRIPTION
    Replace generic tags in string by their corresponding values

    .PARAMETER String
    The string parameter corresponds to the string containing the tags.

    .PARAMETER Tags
    [System.Collections.Specialized.OrderedDictionary] The tags parameter cor-
    responds to the list of tokens to be replaced with their corresponding va-
    lues.

    It has to be in the following format:

    $Tags     = [Ordered]@{
      Tag1    = [Ordered]@{
        Token = "Token to replace"
        Value = "Value"
      }
      Tag2    = [Ordered]@{
        Token = "Token to replace"
        Value = "Value"
      }
    }

    .OUTPUTS
    [System.String] Set-Tags returns a string.

    .EXAMPLE
    Set-Tags -String $String -Tags $Tags

    In this example, all the tokens defined in $Tags and contained in $String
    will be replaced by the corresponding values defined in $Tags.

    .NOTES
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "String"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $String,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Tags"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary] # Ordered hastable
    $Tags
  )
  # Replace tag tokens by their respective values
  foreach ($Tag in $Tags.Values) {
    $String = $String.Replace($Tag.Token, $Tag.Value)
  }
  return $String
}

# ------------------------------------------------------------------------------
# Dynamic parameters
# ------------------------------------------------------------------------------
function New-DynamicParameter {
  <#
    .SYNOPSIS
    Creates dynamic parameter

    .DESCRIPTION
    Wrapper function to easily create dynamic parameters.

    .PARAMETER Name
    The name parameter corresponds to the name of the dynamic parameter to defi-
    ne.

    .PARAMETER Type
    The type parameter corresponds to the type of the dynamic parameter to defi-
    ne. The default value is [System.String].

    .PARAMETER Position
    The position parameter corresponds to the position to give to the dynamic
    parameter to define.

    .PARAMETER HelpMessage
    The help message parameter corresponds to the description to give to the dy-
    namic parameter to define.

    .PARAMETER ValidateSet
    The validate set parameter corresponds to the set of values against which to
    validate the dynamic parameter values.

    .PARAMETER Alias
    The alias parameter corresponds to the list of aliases to assig to the dyna-
    mic parameter.

    .OUTPUTS
    [System.Management.Automation.RuntimeDefinedParameterDictionary]
    New-DynamicParameter returns a parameter dictionnary containing the dynamic
    parameter.

    .EXAMPLE
    New-DynamicParameter -Name "Source" -Type String -Position 2 -Mandatory -Alias "Origin"

    In this example, New-DynamicParameter will create a parameter called
    "Source", that has a type of [System.String], will be assigned to the second
    position, be mandatory, and have an alias of "Origin".

    .NOTES
    TODO expand validation rules definition to allow broader cases.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Name of the dynamic parameter"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Name,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Type of the dynamic parameter"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Type]
    $Type = [String],
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Position of the dynamic parameter"
    )]
    [Int]
    $Position,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Description of the dynamic parameter"
    )]
    [String]
    $HelpMessage,
    [Parameter (
      Position    = 5,
      Mandatory   = $false,
      HelpMessage = "Define if the dynamic parameter is required"
    )]
    [Switch]
    $Mandatory,
    [Parameter (
      Position    = 6,
      Mandatory   = $false,
      HelpMessage = "Validation rules of the dynamic parameter"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $ValidateSet,
    [Parameter (
      Position    = 7,
      Mandatory   = $false,
      HelpMessage = "Alias(es) of the dynamic parameter"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $Alias = @()
  )
  Process {
    # Define parameter attribute
    $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
    # Set parameter attribute values
    if ($Position) {
      $ParameterAttribute.Position    = $Position
    }
    if ($Mandatory) {
      $ParameterAttribute.Mandatory   = $true
    }
    if ($HelpMessage) {
      $ParameterAttribute.HelpMessage = $HelpMessage
    }
    # Define attribute collection to store attributes
    $ParameterAttributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
    $ParameterAttributeCollection.Add($ParameterAttribute)
    # Define validation rules
    if ($ValidateSet) {
      $ValidationAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList $ValidateSet
      $ParameterAttributeCollection.Add($ValidationAttribute)
    }
    # Define alias
    if ($Alias) {
      $AliasAttribute = New-Object -TypeName System.Management.Automation.AliasAttribute -ArgumentList $Alias
      $ParameterAttributeCollection.Add($AliasAttribute)
    }
    # Define dynamic parameter
    $RuntimeParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($Name, $Type, $ParameterAttributeCollection)
    # Define parameter dictionnary
    $ParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
    $ParameterDictionary.Add($Name, $RuntimeParameter)
    return $ParameterDictionary
  }
}

# ------------------------------------------------------------------------------
# Capitalise string
# ------------------------------------------------------------------------------
function ConvertTo-TitleCase {
  <#
    .SYNOPSIS
    Convert string to title case

    .DESCRIPTION
    Capitalise the first letter of each words in a string to form a title.

    .PARAMETER String
    The string parameter corresponds to the string to format. It can be a single
    word or a complete sentence.

    .PARAMETER Delimiter
    The delimiter parameter corresponds to the character used to delimit dis-
    tinct words in the string.
    The default delimiter for words is the space character.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "String to format"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $String,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Word delimiter"
    )]
    [String]
    $Delimiter = " "
  )
  Begin {
    $Words          = $String.Split($Delimiter)
    $FormattedWords = New-Object -TypeName System.Collections.ArrayList
  }
  Process {
    foreach ($Word in $Words) {
      [Void]$FormattedWords.Add((Get-Culture).TextInfo.ToTitleCase($Word.ToLower()))
    }
    $FormattedString = $FormattedWords -join " "
    return $FormattedString
  }
}

# ------------------------------------------------------------------------------
# Format string
# ------------------------------------------------------------------------------
function Format-String {
  <#
    .SYNOPSIS
    Format a string

    .DESCRIPTION
    Convert a string to a specified format

    .PARAMETER String
    The string parameter corresponds to the string to format. It can be a single
    word or a complete sentence.

    .PARAMETER Format
    The format parameter corresponds to the case to convert the string to.

    .PARAMETER Delimiter
    The delimiter parameter corresponds to the character used to delimit dis-
    tinct words in the string.
    The default delimiter for words is the space character

    .NOTES
    When the output word delimiter is not a space (i.e. the formatted string is
    not a sentence), all punctuation is stripped from the string.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "String to format"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $String,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Format"
    )]
    [ValidateSet (
      "CamelCase",
      "KebabCase",
      "LowerCase",
      "PaslcalCase",
      "SentenceCase",
      "SnakeCase",
      "TitleCase",
      "TrainCase",
      "UpperCase"
    )]
    [String]
    $Format,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Word delimiter"
    )]
    [String]
    $Delimiter = " "
  )
  Begin {
    # List cases that have to be capitalized
    $Delimiters = [Ordered]@{
      "CamelCase"     = ""
      "KebabCase"     = "-"
      "LowerCase"     = $Delimiter
      "PaslcalCase"   = ""
      "SentenceCase"  = " "
      "SnakeCase"     = "_"
      "TitleCase"     = " "
      "TrainCase"     = "_"
      "UpperCase"     = $Delimiter
    }
    $Capitalise = [Ordered]@{
      First     = @("PaslcalCase","SentenceCase","TitleCase","TrainCase")
      Others    = @("CamelCase","PaslcalCase","SentenceCase","TitleCase","TrainCase")
    }
    # Create array of words
    if ($Delimiters.$Format -ne " ") {
      $String = $String -replace ("[^A-Za-z0-9\s]", "")
    }
    $Words          = $String.Split($Delimiter)
    $Counter        = 0
    $FormattedWords = New-Object -TypeName System.Collections.ArrayList
  }
  Process {
    foreach ($Word in $Words) {
      if ($Format -ne "UpperCase") {
        if ($Counter -gt 0) {
          if ($Format -in $Capitalise.Others) {
            [Void]$FormattedWords.Add((ConvertTo-TitleCase -String $Word))
          } else {
            [Void]$FormattedWords.Add($Word.ToLower())
          }
        } else {
          if ($Format -in $Capitalise.First) {
            [Void]$FormattedWords.Add((ConvertTo-TitleCase -String $Word))
          } else {
            [Void]$FormattedWords.Add($Word.ToLower())
          }
        }
      } else {
        [Void]$FormattedWords.Add($Word.ToUpper())
      }
      $Counter += 1
    }
    # Reconstruct string
    $FormattedString = $FormattedWords -join $Delimiters.$Format
    return $FormattedString
  }
}
