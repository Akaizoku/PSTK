function Resolve-Array {
  <#
    .SYNOPSIS
    Creates an array from string

    .DESCRIPTION
    Creates an array from a string containing items delimited by a specified delimiter

    .PARAMETER Array
    The array parameter corresponds to the string to transform to an array.

    .PARAMETER Delimiter
    The delimiter parameters corresponds to the character delimiting the items
    in the string.
    The default value is a comma (",").

    .EXAMPLE
    Resolve-Array -Array "a, b, c" -Delimiter ","

    In this example, the function will return an array containing the values a,
    b, and c.

    .NOTES
    File name:      Resolve-Array.ps1
    Author:         Florian Carrier
    Creation date:  2018-12-08
    Last modified:  2018-12-08
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Array to resolve"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $Array,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Item delimiter"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Delimiter = ","
  )
  Process {
    if ($Array.Count -eq 1) {
      $Array = $Array.Split($Delimiter).Trim()
    }
    return $Array
  }
}
