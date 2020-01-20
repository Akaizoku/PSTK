function ConvertTo-JavaProperty {
  <#
    .SYNOPSIS
    Convert to Java property

    .DESCRIPTION
    Format property key-value pair as Java property

    .PARAMETER Property
    The property parameter corresponds to the property key-value pair to format.

    .PARAMETER Prefix
    The optional prefix parameter corresponds to the prefix of the expected Java property. The default value is "D".

    .INPUTS
    System.Collections.Specialized.OrderedDictionary. You can pipe the property key-value pair to ConvertTo-JavaProperty.

    .OUTPUTS
    System.String. ConvertTo-JavaProperty returns the formatted Java property.

    .NOTES
    File name:      ConvertTo-JavaProperty.ps1
    Author:         Florian Carrier
    Creation date:  15/10/2019
    Last modified:  16/01/2020
  #>
  [CmdletBinding ()]
  Param(
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      HelpMessage       = "Property key-value pair",
      ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty()]
    [Alias ("Properties")]
    [System.Collections.Specialized.OrderedDictionary]
    $Property,
    [Parameter (
      Position          = 2,
      Mandatory         = $false,
      HelpMessage       = "Java property prefix"
    )]
    [String]
    $Prefix = "D"
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    if ($Property.Count -gt 0) {
      $JavaString = New-Object -TypeName "System.String" -ArgumentList ""
      # Loop through properties (if multiple have been provided)
      foreach ($SingleProperty in $Property.GetEnumerator()) {
        # Add space between consecutive properties
        if ($JavaString) {
          $JavaString += " "
        }
        # Format property
        $JavaString += "-" + $Prefix + '"' + $SingleProperty.Name + '"' + "=" + '"' + $SingleProperty.Value + '"'
      }
      # Return Java property string
      return $JavaString
    } else {
      # If property is invalid
      return $null
    }
  }
}
