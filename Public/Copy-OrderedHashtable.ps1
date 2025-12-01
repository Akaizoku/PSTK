function Copy-OrderedHashtable {
  <#
    .SYNOPSIS
    Clone an ordered hashtable.

    .DESCRIPTION
    Create a deep or shallow clone of an ordered hashtable.

    .PARAMETER Hashtable
    The hashtable parameter corresponds to the hashtable to clone.

    .PARAMETER Deep
    The deep switch defines if the copy should be shallow (by default) or deep.

    .OUTPUTS
    [System.Collections.Specialized.OrderedDictionary] Copy-OrderedHashtable re-
    turns an exact copy of the ordered hash table specified.

    .EXAMPLE
    Copy-OrderedHashtable -Hashtable $Hashtable

    In this example, Copy-OrderedHashtable returns a shallow copy of the specified hashtable.

    .EXAMPLE
    Copy-OrderedHashtable -Hashtable $Hashtable -Deep

    In this example, Copy-OrderedHashtable returns a deep copy of the specified hashtable.

    .NOTES
    File name:      Copy-OrderedHashtable.psm1
    Author:         Florian Carrier
    Creation date:  2018-10-15
    Last modified:  2025-09-16
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Hashtable to clone"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
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
  Begin {
    $Clone = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
  }
  Process {
    # If deep copy
    if ($Deep) {
      if ($PSVersionTable.PSVersion.Major -le 5) {
        # Legacy Windows PowerShell (5.1 or older): Use BinaryFormatter
        $MemoryStream     = New-Object -TypeName "System.IO.MemoryStream"
        $BinaryFormatter  = New-Object -TypeName "System.Runtime.Serialization.Formatters.Binary.BinaryFormatter"
        $BinaryFormatter.Serialize($MemoryStream, $Hashtable)
        $MemoryStream.Position = 0
        $Clone = $BinaryFormatter.Deserialize($MemoryStream)
        $MemoryStream.Close()
      }
      else {
        # PowerShell 7 or later: Use PSSerializer instead of BinaryFormatter
        $XML   = [System.Management.Automation.PSSerializer]::Serialize($Hashtable, [int]::MaxValue)
        $Clone = [System.Management.Automation.PSSerializer]::Deserialize($XML)
      }
    }
    else {
      # Shallow copy
      foreach ($Item in $Hashtable.GetEnumerator()) {
        $Clone.$($Item.Name) = $Item.Value
      }
    }
    # Return cloned hashtable
    return $Clone
  }
}
