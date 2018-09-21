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
  Last modified:  21/09/2018
  Repository:     https://github.com/Akaizoku/PSTK
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

    .EXAMPLE
    Write-Log -Type "WARN" -Message "This is a warning message."

    .EXAMPLE
    Write-Log -Type "ERROR" -Message "This is an error message."

    .EXAMPLE
    Write-Log -Type "CHECK" -Message "This is a checkpoint message."
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

    .INPUTS
    None. You cannot pipe objects to Test-SQLConnection.

    .OUTPUTS
    Boolean. Test-SQLConnection returns a boolean depending on the result of the
    connection attempt.

    .EXAMPLE
    Test-SQLConnection -Server localhost -Database database

    .NOTES
    TODO Add secured password handling
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
      Write-Log -Type "ERROR" -Message "Please provide a valid username"
      Stop-Script 1
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

    .OUTPUTS
    System.Collections.Specialized.OrderedDictionary. Read-Properties returns an
    ordered hash table containing the content of the property file.

    .EXAMPLE
    Read-Properties -File "default.ini" -Directory "\conf"

    .EXAMPLE
    Read-Properties -File "default.ini" -Directory "\conf" -Section
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
      HelpMessage = "Define if section headers should be used to group properties or be ignored"
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
    The Content parameter should be the content of the property

    .INPUTS
    System.String.

    .OUTPUTS
    System.Collections.Specialized.OrderedDictionary. Read-Property returns an
    ordered hash table containing the name and value of a given property.

    .EXAMPLE
    Read-Property -Content "Key = Value"
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "Property content"
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
# Properties setting function
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

    .OUTPUTS
    System.Collections.Specialized.OrderedDictionary. Set-Properties returns an
    ordered hash table containing the names and values of the properties listed
    in the property files.

    .EXAMPLE
    Set-Properties -File "default.ini" -Directory "\conf"

    .EXAMPLE
    Set-Properties -File "default.ini" -Directory "\conf" -Custom "custom.ini"

    .EXAMPLE
    Set-Properties -File "default.ini" -Directory "\conf" -Custom "custom.ini" -CustomDirectory "\shared"

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
    [Alias ("CD", "CustomDir")]
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
    exit 1
  }
}

# ------------------------------------------------------------------------------
# Function to compare hashtables content
# ------------------------------------------------------------------------------
function Compare-Hashtables {
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
    Boolean. Compare-Hashtables returns a boolean depnding on the result of the
    comparison between the two hashtables.

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
    System.Collections.Specialized.OrderedDictionary. Copy-OrderedHashtable returns an
    exact copy of the ordered hash table specified.

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
    $MemoryStream     = New-Object -TypeName System.IO.MemoryStream
    $BinaryFormatter  = New-Object -TypeName System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
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
    The transcript parameter corresponds to the file to be generated to log the
    session.

    .EXAMPLE
    Start-Script -Transcript ".\log\transcript.log"
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Transcript file path"
    )]
    [Alias ("T", "L", "Log", "LogFile")]
    $Transcript
  )
  begin {
    Set-StrictMode -Version Latest
  }
  process {
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
    The error code parameter corresponds to the error code thrown after exiting the script. Default is 0 (i.e. no errors).

    .EXAMPLE
    Stop-Script -ErrorCode 1
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $false,
      HelpMessage = "Error code"
    )]
    [Alias ("E", "Err", "Error", "C", "Code")]
    $ErrorCode = 0
  )
  begin {
    Set-StrictMode -Off
    try {
      Stop-Transcript
    } catch {
      Write-Log -Type "WARN" -Message "No transcript is being produced"
    }
  }
  process {
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
    Checks that all required property are defined by returning a list of missing properties

    .PARAMETER Properties
    The properties parameter corresponds to the list of properties defined

    .PARAMETER Required
    The required parameter corresponds to the list of properties that are required

    .OUTPUTS
    System.Collections.ArrayList. Compare-Properties returns an array containing the
    missing properties from the list.

    .EXAMPLE
    Assert-Properties -Properties $Properties -Required $Required

    .NOTES
    Check if returned list is empty to verify that all is well
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of properties"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("P")]
    $Properties,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "List of properties to check"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("C")]
    [String[]]
    $Required
  )
  $Missing = New-Object -TypeName System.Collections.ArrayList
  $Parameters = $Required.Split(",")
  foreach ($Parameter in $Parameters) {
    $Property = $Parameter.Trim()
    if ($Property -ne "" -And !$Properties.$Property) {
      $Missing.Add($Property)
    }
  }
  return $Missing
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
    System.Array.Object[]

    .OUTPUTS
    System.Array.Object[]. ConvertTo-NaturalSort returns a sorted array.

    .EXAMPLE
    ConvertTo-NaturalSort -Array @("a10", "b1", "a1")

    .EXAMPLE
    ConvertTo-NaturalSort -Array @("a10", "b1", "a1") -Order "Descending"

    .NOTES
    TODO Make generic to allow sorting simple string arrays
  #>
  [CmdletBinding ()]
  param(
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "List of files to sort"
    )]
    [Alias ("F", "L", "List")]
    $Files,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Specifies the order of the sort"
    )]
    [ValidateSet ("A", "Asc", "Ascending", "D", "Dsc", "Desc", "Descending")]
    [Alias ("O")]
    [String]
    $Order = "Ascending"
  )
  $Ascending  = @("A", "Asc", "Ascending")
  $Descending = @("D", "Dsc", "Desc", "Descending")
  $MaximumLength = 0
  foreach ($File in $Files) {
    [Int]$Length = $File.BaseName | Measure-Object -Character | Select -Expand Characters
    if ($Length -gt $MaximumLength) {
      $MaximumLength = $Length
    }
  }
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
    System.String
    System.Integer

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
  param(
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "Alphanumeric chain of character"
    )]
    [Alias ("A", "Alpha", "Alphanum", "N", "Num", "Numeric")]
    $Alphanumeric,
    [Parameter (
      Position          = 2,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "Offset"
    )]
    [Alias ("O", "Off")]
    [Int]
    $Offset
  )
  # Declare valid formats
  $Number = [RegEx]::New('^\d+$')
  $NumStr = [RegEx]::New('^\d+\D+$')
  $StrNum = [RegEx]::New('^\D+\d+$')
  try {
    $Format = Test-Alphanumeric -Alphanumeric $Alphanumeric
    if ($Format -ne 0) {
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
    - [System.String]   Path to the folder containing the files to rename.
    - [System.Integer]  Offset to add to the file names.
    - [System.String]   Filter to apply

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
  param (
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "Path to the files"
    )]
    [ValidateScript ({Test-Path -Path $_})]
    [Alias ("P")]
    [String]
    $Path,
    [Parameter (
      Position          = 2,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "Offset"
    )]
    [ValidateScript ({if ($_ -eq 0) {Throw "The offset cannot be 0."} else {$true}})]
    [Alias ("O", "Off")]
    [Int]
    $Offset,
    [Parameter (
      Position          = 3,
      Mandatory         = $false,
      ValueFromPipeline = $true,
      HelpMessage       = "Filter to apply"
    )]
    [Alias ("F", "Filters")]
    [String]
    $Filter = "*",
    [Parameter (
      Position          = 4,
      Mandatory         = $false,
      ValueFromPipeline = $true,
      HelpMessage       = "Pattern to exclude"
    )]
    [Alias ("E")]
    [String]
    $Exclude = $null
  )
  $Output   = $false
  $Count    = 0
  $Numeric  = [RegEx]::New('\d+')
  # Get files
  $Files  = Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude
  $Files  = $Files | Where-Object {$_.BaseName -match $Numeric}
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
    The alphanumeric parameter corresponds to the chain of characters to offset.t.

    .INPUTS
    [System.String] Alphanumeric chain of characters

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
  param(
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "Alphanumeric chain of character"
    )]
    [Alias ("A", "Alpha", "Alphanum", "N", "Num", "Numeric")]
    $Alphanumeric
  )
  begin {
    # Declare valid formats
    $Number = [RegEx]::New('^\d+$')
    $NumStr = [RegEx]::New('^\d+\D+$')
    $StrNum = [RegEx]::New('^\D+\d+$')
  }
  process {
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
    Measure-FileProperty -Files $Files -Property "MinimumValue"
  #>
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of Files to parse"
    )]
    [Alias ("F", "File", "L", "List")]
    $Files,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Property to measure"
    )]
    [Alias ("P", "Prop")]
    $Property
  )
  process {
    foreach ($File in $Files) {
      switch ($Property) {
        # Maximum length of file names
        "MaximumLength" {
          $MaximumLength = 0
          [Int]$Length = $File.BaseName | Measure-Object -Character | Select -Expand Characters
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
