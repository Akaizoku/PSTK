# ------------------------------------------------------------------------------
# Format string
# ------------------------------------------------------------------------------
function Format-String {
  <#
    .SYNOPSIS
    Format a string

    .DESCRIPTION
    Convert a string to a specified format

    .PARAMETER String
    The string parameter corresponds to the string to format. It can be a single
    word or a complete sentence.

    .PARAMETER Format
    The format parameter corresponds to the case to convert the string to.

    .PARAMETER Delimiter
    The delimiter parameter corresponds to the character used to delimit dis-
    tinct words in the string.
    The default delimiter for words is the space character

    .NOTES
    When the output word delimiter is not a space (i.e. the formatted string is
    not a sentence), all punctuation is stripped from the string.
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
      Mandatory   = $true,
      HelpMessage = "Format"
    )]
    [ValidateSet (
      "CamelCase",
      "KebabCase",
      "LowerCase",
      "PaslcalCase",
      "SentenceCase",
      "SnakeCase",
      "TitleCase",
      "TrainCase",
      "UpperCase"
    )]
    [String]
    $Format,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Word delimiter"
    )]
    [String]
    $Delimiter = " "
  )
  Begin {
    # List cases that have to be capitalized
    $Delimiters = [Ordered]@{
      "CamelCase"     = ""
      "KebabCase"     = "-"
      "LowerCase"     = $Delimiter
      "PaslcalCase"   = ""
      "SentenceCase"  = " "
      "SnakeCase"     = "_"
      "TitleCase"     = " "
      "TrainCase"     = "_"
      "UpperCase"     = $Delimiter
    }
    $Capitalise = [Ordered]@{
      First     = @("PaslcalCase","SentenceCase","TitleCase","TrainCase")
      Others    = @("CamelCase","PaslcalCase","SentenceCase","TitleCase","TrainCase")
    }
    # Create array of words
    if ($Delimiters.$Format -ne " ") {
      $String = $String -replace ("[^A-Za-z0-9\s]", "")
    }
    $Words          = $String.Split($Delimiter)
    $Counter        = 0
    $FormattedWords = New-Object -TypeName System.Collections.ArrayList
  }
  Process {
    foreach ($Word in $Words) {
      if ($Format -ne "UpperCase") {
        if ($Counter -gt 0) {
          if ($Format -in $Capitalise.Others) {
            [Void]$FormattedWords.Add((ConvertTo-TitleCase -String $Word))
          } else {
            [Void]$FormattedWords.Add($Word.ToLower())
          }
        } else {
          if ($Format -in $Capitalise.First) {
            [Void]$FormattedWords.Add((ConvertTo-TitleCase -String $Word))
          } else {
            [Void]$FormattedWords.Add($Word.ToLower())
          }
        }
      } else {
        [Void]$FormattedWords.Add($Word.ToUpper())
      }
      $Counter += 1
    }
    # Reconstruct string
    $FormattedString = $FormattedWords -join $Delimiters.$Format
    return $FormattedString
  }
}
