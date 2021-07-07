function Remove-Object {
  <#
    .SYNOPSIS
    Remove object(s)

    .DESCRIPTION
    Remove list of objects matching specifications (wrapper for Remove-Item with checks)

    .PARAMETER Path
    The path parameter corresponds to the location of the objects to remove.

    .PARAMETER Type
    The type parameter corresponds to the type of objects to remove.

    .PARAMETER Filter
    The filter parameter corresponds to the filter to apply to the name of objects to remove.

    .PARAMETER Exclude
    The exclude parameter corresponds to the filter to apply to the name of objects *not* to remove.
    /!\ Exclude is currently not supported in Windows PowerShell
    See https://github.com/PowerShell/PowerShell/issues/6865

    .NOTES
    File name:      Remove-Object.ps1
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
    $Exclude = $null
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Check path
    $Path = Resolve-Path -Path $Path
    if (Test-Object -Path $Path -NotFound) {
      Write-Log -Type "ERROR" -Message "Path not found $Path" -ErrorCode 1
    }
  }
  Process {
    $Objects = New-Object -TypeName "System.Collections.ArrayList"
    # Check PowerShell version to prevent issue
    $PSVersion = $PSVersionTable.PSVersion | Select-Object -ExpandProperty "Major"
    if ($PSVersion -lt 6) {
      $Objects = Get-Object -Path $Path -Type $Type -Filter $Filter
    } else {
      $Objects = Get-Object -Path $Path -Type $Type -Filter $Filter -Exclude $Exclude
    }
    # If objects are found
    if ($Objects.Count -ge 1) {
      foreach ($Object in $Objects) {
        if ($null -ne $Object) {
          Write-Log -Type "DEBUG" -Object $Object
          try {
            Remove-Item -Path $Object.FullName -Recurse -Force
          } catch {
            Write-Log -Type "ERROR" -Message $Error[0].Exception.Message
          }
        }
      }
    }
  }
}
