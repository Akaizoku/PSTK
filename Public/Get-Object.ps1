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
