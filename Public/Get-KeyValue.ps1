function Get-KeyValue {
  <#
    .SYNOPSIS
    Returns a value from a hashtable

    .DESCRIPTION
    Returns a value corresponding to a specified key in a hashtable with or
    without regards to the case.

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

    In this example, the function returns the value "value".

    .EXAMPLE
    Find-Key -Hashtable @{"key"="value"} -Key "KEY" -CaseSensitive

    In this example, the function returns a null value.

    .NOTES
    File name:      Get-KeyValue.ps1
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
    if (Find-Key -Hashtable $Hashtable -Key $Key -CaseSensitive:$CaseSensitive) {
      if ($CaseSensitive) {
        $Value = $Hashtable.$Key
      } else {
        $FormattedKey = Format-String -String $Key -Format "lowercase"
        foreach ($Item in $Hashtable.GetEnumerator()) {
          $FormattedItem = Format-String -String $Item.Key -Format "lowercase"
          if ($FormattedItem -eq $FormattedKey) {
            $Value = $Item.Value
          }
        }
      }
      return $Value
    } else {
      # If key does not exists, returns null
      Write-Log -Type "WARN" -Message """$Key"" was not found"
      return $null
    }
  }
}
