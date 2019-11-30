# ------------------------------------------------------------------------------
# Prepare tags for Set-Tags
# ------------------------------------------------------------------------------
function Resolve-Tags {
  <#
    .SYNOPSIS
    Prepare tags for Set-Tags

    .DESCRIPTION
    Transform hashtable of variables into list of tags usable by Set-Tags

    .PARAMETER Tags
    The tags parameter corresponds to the list of variables to be replaced with their corresponding values.

    It has to be in the following format:

    $Tags = [Ordered]@{
      Variable1 = Value1,
      Variable2 = Value2,
    }

    .OUTPUTS
    Resolve-Tags returns a formatted hashtable.

    .EXAMPLE
    Resolve-Tags-Tags $Tags
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Tags"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $Tags,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Prefix to append to the tag name"
    )]
    [String]
    $Prefix,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Suffix to append to the tag name"
    )]
    [String]
    $Suffix
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Instantiate variables
    $FormattedTags = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
  }
  Process {
    # Loop through each tags
    foreach ($Tag in $Tags.GetEnumerator()) {
      # Generate token-value pair
      $FormattedTag = [Ordered]@{
        "Token" = [System.String]::Concat($Prefix, $Tag.Name, $Suffix)
        "Value" = $Tag.Value
      }
      $FormattedTags.Add($Tag.Name, $FormattedTag)
    }
    # Return formatted tag list
    return $FormattedTags
  }
}
