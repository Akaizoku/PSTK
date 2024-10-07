function Read-Property {
  <#
    .SYNOPSIS
    Parse property

    .DESCRIPTION
    Parse property content to output key-value pair

    .PARAMETER Property
    The property parameter corresponds to the property to read.

    .INPUTS
    None.

    .OUTPUTS
    [System.Collections.Specialized.OrderedDictionary] Read-Property returns an
    ordered hashtable containing the name and value of a given property.

    .EXAMPLE
    Read-Property -Property "Key = Value"

    In this example, Read-Property will parse the content and assign the value
    "Value" to the property "Key".

    .NOTES
    File name:      Read-Property.ps1
    Author:         Florian Carrier
    Creation date:  2018-10-15
    Last modified:  2019-06-17
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "Property content"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Property
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Instantiate variables
    $KeyValuePair = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
    $Index    = $Property.IndexOf("=")
  }
  Process {
    # Check that format is valid
    if ($Index -gt 0) {
      $Offset = 1
      $Key    = $Property.Substring(0, $Index)
      $Value  = $Property.Substring($Index + $Offset, $Property.Length - $Index - $Offset)
      # Generate key-value pair
      $KeyValuePair.Add("Key"   , $Key.Trim())
      $KeyValuePair.Add("Value" , $Value.Trim())
    }
    # Output key-value pair
    return $KeyValuePair
  }
}
