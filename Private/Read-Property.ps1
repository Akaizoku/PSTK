# ------------------------------------------------------------------------------
# Property parsing function
# ------------------------------------------------------------------------------
function Read-Property {
  <#
    .SYNOPSIS
    Parse property content

    .DESCRIPTION
    Parse property content

    .PARAMETER Content
    [System.String] The Content parameter should be the content of the property.

    .INPUTS
    None.

    .OUTPUTS
    [System.Collections.Specialized.OrderedDictionary] Read-Property returns an
    ordered hashtable containing the name and value of a given property.

    .EXAMPLE
    Read-Property -Content "Key = Value"

    In this example, Read-Property will parse the content and assign the value
    "Value" to the property "Key".

    .NOTES
    File name:      Read-Property.ps1
    Author:         Florian Carrier
    Creation date:  15/10/2018
    Last modified:  16/10/2018
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property content"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Content
  )
  $Property = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
  $Index    = $Content.IndexOf("=")
  if ($Index -gt 0) {
    $Offset = 1
    $Key    = $Content.Substring(0, $Index)
    $Value  = $Content.Substring($Index + $Offset, $Content.Length - $Index - $Offset)
    $Property.Add("Key"   , $Key.Trim())
    $Property.Add("Value" , $Value.Trim())
  }
  return $Property
}
