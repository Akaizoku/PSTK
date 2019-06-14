# ------------------------------------------------------------------------------
# Generic Remove-Item with checks
# ------------------------------------------------------------------------------
function Remove-Object {
  <#
    .SYNOPSIS
    Remove objects

    .DESCRIPTION
    Remove list of objects matching specifications

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
  }
  Process {
    $Objects = New-Object -TypeName System.Collections.ArrayList
    # Check PowerShell version to prevent issue
    $PSVersion = $PSVersionTable.PSVersion | Select-Object -ExpandProperty "Major"
    if ($PSVersion -lt 6) {
      $Objects = Get-Object -Path $Path -Type $Type -Filter $Filter
    } else {
      $Objects = Get-Object -Path $Path -Type $Type -Filter $Filter -Exclude $Exclude
    }
    # If objects are found
    if ($Objects. Count -gt 0) {
      foreach ($Object in $Objects) {
        Write-Log -Type "DEBUG" -Object $Object
        Remove-Item -Path $Path -Recurse -Force
      }
    }
  }
}
