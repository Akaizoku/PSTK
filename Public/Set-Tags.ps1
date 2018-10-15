# ------------------------------------------------------------------------------
# Replace tags in string
# ------------------------------------------------------------------------------
function Set-Tags {
  <#
    .SYNOPSIS
    Set tags in string

    .DESCRIPTION
    Replace generic tags in string by their corresponding values

    .PARAMETER String
    The string parameter corresponds to the string containing the tags.

    .PARAMETER Tags
    [System.Collections.Specialized.OrderedDictionary] The tags parameter cor-
    responds to the list of tokens to be replaced with their corresponding va-
    lues.

    It has to be in the following format:

    $Tags     = [Ordered]@{
      Tag1    = [Ordered]@{
        Token = "Token to replace"
        Value = "Value"
      }
      Tag2    = [Ordered]@{
        Token = "Token to replace"
        Value = "Value"
      }
    }

    .OUTPUTS
    [System.String] Set-Tags returns a string.

    .EXAMPLE
    Set-Tags -String $String -Tags $Tags

    In this example, all the tokens defined in $Tags and contained in $String
    will be replaced by the corresponding values defined in $Tags.

    .NOTES
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "String"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $String,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Tags"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary] # Ordered hastable
    $Tags
  )
  # Replace tag tokens by their respective values
  foreach ($Tag in $Tags.Values) {
    $String = $String.Replace($Tag.Token, $Tag.Value)
  }
  return $String
}
