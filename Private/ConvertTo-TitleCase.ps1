# ------------------------------------------------------------------------------
# Capitalise string
# ------------------------------------------------------------------------------
function ConvertTo-TitleCase {
  <#
    .SYNOPSIS
    Convert string to title case

    .DESCRIPTION
    Capitalise the first letter of each words in a string to form a title.

    .PARAMETER String
    The string parameter corresponds to the string to format. It can be a single
    word or a complete sentence.

    .PARAMETER Delimiter
    The delimiter parameter corresponds to the character used to delimit dis-
    tinct words in the string.
    The default delimiter for words is the space character.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "String to format"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $String,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Word delimiter"
    )]
    [String]
    $Delimiter = " "
  )
  Begin {
    $Words          = $String.Split($Delimiter)
    $FormattedWords = New-Object -TypeName System.Collections.ArrayList
  }
  Process {
    foreach ($Word in $Words) {
      [Void]$FormattedWords.Add((Get-Culture).TextInfo.ToTitleCase($Word.ToLower()))
    }
    $FormattedString = $FormattedWords -join " "
    return $FormattedString
  }
}
