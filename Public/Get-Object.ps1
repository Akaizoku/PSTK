function Get-Object {
  <#
    .SYNOPSIS
    Get objects

    .DESCRIPTION
    Get list of objects matching specifications (wrapper for Get-ChildItem with checks)

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
    File name:      Get-Object.ps1
    Author:         Florian Carrier
    Creation date:  2019-06-14
    Last modified:  2021-07-06
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the items"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String]
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
    [System.String]
    $Type = "All",
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Filter to apply"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String]
    $Filter = "*",
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Pattern to exclude"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String[]]
    $Exclude = $null,
    [Parameter (
      HelpMessage = "Recursive search"
    )]
    [Switch]
    $Recurse,
    [Parameter (
      HelpMessage = "Silent execution"
    )]
    [Switch]
    $Silent,
    [Parameter (
      HelpMessage = "Stop script if no results are found"
    )]
    [Switch]
    $StopScript
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Check path
    $Path = Resolve-Path -Path $Path
    if (Test-Object -Path $Path -NotFound) {
      Write-Log -Type "ERROR" -Message "Path not found $Path" -ErrorCode 1
    }
    $ObjectType = [Ordered]@{
      "All"     = "items"
      "File"    = "files"
      "Folder"  = "folders"
    }
  }
  Process {
    $Objects = New-Object -TypeName "System.Collections.ArrayList"
    # Check PowerShell version to prevent issue https://github.com/PowerShell/PowerShell/issues/6865
    $PSVersion = $PSVersionTable.PSVersion | Select-Object -ExpandProperty "Major"
    if ($PSVersion -lt 6) {
      switch ($Type) {
        "File"    { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Recurse:$Recurse -File)       }
        "Folder"  { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Recurse:$Recurse -Directory)  }
        default   { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Recurse:$Recurse)             }
      }
      # Workaround to exclude items
      if ($null -ne $Exclude) {
        $Objects = $Objects | Where-Object -Property "Name" -NotMatch -Value ((ConvertTo-RegularExpression -String $Exclude) -join "|")
      }
    } else {
      switch ($Type) {
        "File"    { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude -Recurse:$Recurse -File)       }
        "Folder"  { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude -Recurse:$Recurse -Directory)  }
        default   { $Objects = @(Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude -Recurse:$Recurse)             }
      }
    }
    # Check results
    if ($Objects.Count -eq 0) {
      if ($Silent -eq $false) {
        # Print hints
        if ($Filter -ne "*") {
          Write-Log -Type "ERROR" -Message "No $($ObjectType.$Type) were found in $Path matching the filter ""$Filter""."
        } elseif ($Exclude) {
          Write-Log -Type "ERROR" -Message "No $($ObjectType.$Type) corresponding to the criterias were found in $Path."
        } else {
          Write-Log -Type "ERROR" -Message "No $($ObjectType.$Type) were found in $Path."
        }
      }
      if ($PSBoundParameters.ContainsKey("StopScript")) {
        Stop-Script -ExitCode 1
      } else {
        return $null
      }
    } else {
      return $Objects
    }
  }
}
