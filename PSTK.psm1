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
    [String]
    $Type,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Message to output"
    )]
    [Alias ("Output", "Log")]
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
    [Alias ("Svr")]
    [String]
    $Server,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Database to connect to"
    )]
    [Alias ("DB")]
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
    [Alias ("Pw")]
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
  $Connection = New-Object -TypeName System.Data.SqlClient.SqlConnection $ConnectionString
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
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property file"
      )]
    $Directory,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Define if section headers should be used to group properties or be ignored"
      )]
    [Switch]
    $Section
  )
  # Properties path
  $PropertyFile = Join-Path -Path $Directory -ChildPath $File
  $Properties   = [ordered]@{}
  $Sections     = [ordered]@{}
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
    The Content parameter should be the content of the property

    .INPUTS
    None.

    .OUTPUTS
    System.Collections.Specialized.OrderedDictionary. Read-Property returns an
    ordered hash table containing the name and value of a given property.

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
    [String]
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property files"
    )]
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
    $Reference,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Difference hashtable"
      )]
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
    [Alias ("LogFile")]
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
    [Alias ("Code")]
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
  param(
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of files to sort"
    )]
    [Alias ("List")]
    $Files,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Specifies the order of the sort"
    )]
    [ValidateSet ("A", "Asc", "Ascending", "D", "Dsc", "Desc", "Descending")]
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
  param(
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Alphanumeric chain of character"
    )]
    $Alphanumeric,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Offset"
    )]
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
  param (
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
    The alphanumeric parameter corresponds to the chain of characters to offset.t.

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
  param(
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Alphanumeric chain of character"
    )]
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
    [Alias ("List")]
    $Files,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Property to measure"
    )]
    [String]
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
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Directory containing the files to convert"
    )]
    [Alias ("Directory")]
    [String]
    $Path
  )
  begin {
    $Output = $false
    $Count  = 0
  }
  process {
    if (Test-Path -Path $Path) {
      # Initialise MS Word application and identify document
      $MSWord = New-Object -ComObject Word.Application
      $Files  = Get-ChildItem -Path $Path -Filter "*.doc?"
      if ($Files.Count -gt 0) {
        foreach ($File in $Files) {
          try {
            # Generate PDF
            $Document = $MSWord.Documents.Open($File.FullName)
            $PDFName  = "$($File.BaseName).pdf"
            $PDF      = "$($File.DirectoryName)\$PDFName"
            Write-Log -Type "INFO" -Message "Generating $PDFName"
            $Document.SaveAs([Ref] $PDF, [Ref] 17)
            $Document.Close()
            $Count += 1
          } catch [System.Management.Automation.RuntimeException] {
            Write-Log -Type "WARN" -Message "An error occured while generating $PDFName"
          }
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
  end {
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
    [System.Collections.ArrayList] Complete-RelativePath returns
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Relative path to make absolute"
    )]
    [Alias ("Path")]
    $RelativePaths,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Root directory to pre-prend to relative path"
    )]
    [Alias ("Directory")]
    $WorkingDirectory
  )
  begin {
    if (-Not (Test-Path -Path $WorkingDirectory)) {
      Write-Log -Type "ERROR" -Message "$WorkingDirectory does not exists."
      Stop-Script 1
    }
    $Paths = New-Object -TypeName System.Collections.ArrayList
  }
  process {
    foreach ($RelativePath in $RelativePaths) {
      # If path is correct, change value to absolute
      $AbsolutePath = Join-Path -Path $WorkingDirectory -ChildPath $RelativePath
      if (Test-Path -Path $Path) {
        $Paths.Add($Path)
      } else {
        # If it is not found, keep relative path
        Write-Log -Type "WARN" -Message "$Path does not exists."
        $Paths.Add($RelativePath)
      }
    }
    return $Path
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

    .INPUTS
    None.

    .OUTPUTS
    [System.String] Show-ExceptionFullName returns the full name of the except-
    ion as a string.
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Errors to analyse"
    )]
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
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the files to convert"
    )]
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
  begin {
    # Check parameters and instantiate variables
    $Path     = Resolve-Path -Path $Path
    $Files    = Get-Object -Path $Path -Type "File" -Filter $Filter -Exclude $Exclude
    $Encoding = $Encoding.ToUpper()
    $Output   = $false
    $Count    = 0
  }
  process {
    try {
      foreach ($File in $Files) {
        # if ($File.GetType().Name -eq "FileInfo") {
          Write-Log -Type "INFO" -Message "Converting ""$($File.Name)"" to $Encoding"
          $Filename = "$($File.BaseName)_$Encoding$($File.Extension)"
          # $FilePath = Join-Path -Path $Path -ChildPath $File
          $NewFile  = Join-Path -Path $Path -ChildPath "..\$Filename"
          Get-Content -Path $File | Out-File -Encoding $Encoding $NewFile
          $Count += 1
        # }
      }
      if ($Count -gt 0) {
        $Output = $true
      }
      Write-Log -Type "CHECK" -Message "$Count files were converted to $Encoding"
    } catch {
      Write-Log -Type "ERROR" -Message "$_"
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
  #>
  [CmdletBinding ()]
  param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the items"
    )]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Type of item"
    )]
    [ValidateSet ("All", "File", "Folder")]
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
  begin {
    if (-Not (Test-Path -Path $Path)) {
      Write-Log -Type "ERROR" -Message "$Path does not exists."
      Stop-Script 1
    }
    $ObjectType = [ordered]@{
      "All"     = "items"
      "File"    = "files"
      "Folder"  = "folders"
    }
  }
  process {
    # Get files
    switch ($Type) {
      "File"    {
        $Files = Get-ChildItem -Path $Path -File -Filter $Filter -Exclude $Exclude
      }
      "Folder"  {
        $Files = Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude -Directory
      }
      default   {
        $Files = Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude
      }
    }
    # If no files are found, print hints
    if ($Files.Count -eq 0) {
      if ($Filter -ne "*") {
        Write-Log -Type "ERROR" -Message "No $($ObjectType[$Type]) were found in $Path matching the filter ""$Filter""."
      } elseif ($Exclude) {
        Write-Log -Type "ERROR" -Message "No $($ObjectType[$Type]) corresponding to the criterias were found in $Path."
      } else {
        Write-Log -Type "ERROR" -Message "No $($ObjectType[$Type]) were found in $Path."
      }
      Stop-Script 1
    } else {
      return $Files
    }
  }
}
