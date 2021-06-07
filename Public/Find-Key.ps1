function Find-Key {
  <#
    .SYNOPSIS
    Check if a key exists in a hashtable

    .DESCRIPTION
    Check if a specified key exists in a hashtable with or without regards to
    the case.

    .PARAMETER Hashtable
    The hastable parameter corresponds to the hastable in which to look for the
    key.

    .PARAMETER Key
    The key parameter corresponds to the key to search for.

    .PARAMETER CaseSensitive
    The case sensitive switch defines is the search should be case sensitive.

    .OUTPUTS
    [System.Boolean] The function returns a boolean.

    .EXAMPLE
    Find-Key -Hashtable @{"key"="value"} -Key "KEY"

    In this example, the function returns true.

    .EXAMPLE
    Find-Key -Hashtable @{"key"="value"} -Key "KEY" -CaseSensitive

    In this example, the function returns false.

    .NOTES
    File name:      Find-Key.ps1
    Author:         Florian Carrier
    Creation date:  2018-12-08
    Last modified:  2018-12-08
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Hashtable"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $Hashtable,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Key to search for"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Key,
    [Parameter (
      HelpMessage = "Define if match should be case sensitive"
    )]
    [Switch]
    $CaseSensitive
  )
  Process {
    $Check = $false
    if ($Hashtable.$Key) {
      $Check = $true
    } elseif (-Not $CaseSensitive) {
      $UpperCaseKey = Format-String -String $Key -Format "UpperCase"
      if ($Hashtable.$UpperCaseKey) {
        $Check = $true
      } else {
        $FormattedKey = Format-String -String $Key -Format "lowercase"
        foreach ($Item in $Hashtable.Keys) {
          $FormattedItem = Format-String -String $Item -Format "lowercase"
          if ($FormattedItem -eq $FormattedKey) {
            $Check = $true
          }
        }
      }
    }
    return $Check
  }
}
