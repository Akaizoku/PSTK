# ------------------------------------------------------------------------------
# Compare two properties list
# ------------------------------------------------------------------------------
function Compare-Properties {
  <#
    .SYNOPSIS
    Checks that all required property are defined

    .DESCRIPTION
    Checks that all required property are defined by returning a list of missing
     properties

    .PARAMETER Properties
    The properties parameter corresponds to the list of properties defined

    .PARAMETER Required
    The required parameter corresponds to the list of properties that are requi-
    red

    .OUTPUTS
    [System.Collections.ArrayList] Compare-Properties returns an array containing
     the missing properties from the list.

    .EXAMPLE
    Assert-Properties -Properties $Properties -Required $Required

    .NOTES
    Check if returned list is empty to verify that all is well
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of properties"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary] # Ordered hashtable
    $Properties,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "List of properties to check"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $Required
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Variables
    $Missing = New-Object -TypeName System.Collections.ArrayList
    $Parameters = $Required.Split(",")
  }
  Process {
    # Loop through parameters
    foreach ($Parameter in $Parameters) {
      $Property = $Parameter.Trim()
      # Check if property exists
      if ($Property -ne "" -And !$Properties.$Property) {
        Write-Log -Type "DEBUG" -Message "$Property is missing"
        [Void]$Missing.Add($Property)
      }
    }
    # Force array-list format
    return @($Missing)
  }
}
