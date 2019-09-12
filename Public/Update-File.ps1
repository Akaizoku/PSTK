function Update-File {
  <#
    .SYNOPSIS
    Replaces a string value in a file

    .DESCRIPTION
    Replaces a specified string in a text file by a given value.

    .PARAMETER Path
    The path parameter corresponds

    .NOTES
    File name:      Update-File.ps1
    Author:         Florian Carrier
    Creation date:  08/12/2018
    Last modified:  14/06/2018
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the file to update"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Old string to replace"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $OldString,
    [Parameter (
      Position    = 3,
      Mandatory   = $true,
      HelpMessage = "New string to replace old with"
    )]
    [String]
    $NewString,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Encoding"
    )]
    [String]
    $Encoding = "ASCII"
  )
  $FileContent = Get-Content -Path $Path
  $FileContent -replace $OldString, $NewString | Out-File -FilePath $Path -Encoding $Encoding
}
