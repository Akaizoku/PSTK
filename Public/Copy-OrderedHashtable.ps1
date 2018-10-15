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
    [System.Collections.Specialized.OrderedDictionary] Copy-OrderedHashtable re-
    turns an exact copy of the ordered hash table specified.

    .EXAMPLE
    Copy-OrderedHashtable -Hashtable $Hashtable
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
  $Clone = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
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
      $Clone.$Item.Key = $Item.Value
    }
  }
  return $Clone
}
