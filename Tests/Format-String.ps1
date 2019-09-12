<#
  .SYNOPSIS
  Format-String Unit Testing

  .DESCRIPTION
  Unit Test for Format-String function from PSTK module

  .NOTES
  File name:      Format-String.ps1
  Author:         Florian Carrier
  Creation date:  05/10/2018
  Last modified:  05/10/2018
#>

# ------------------------------------------------------------------------------
# Initialisation
# ------------------------------------------------------------------------------
$Path       = Split-Path $MyInvocation.MyCommand.Definition
$Repository = Split-Path $Path -Parent
# Import toolbox
Import-Module "$Repository\PSTK" -Force

# ------------------------------------------------------------------------------
# Test objects
# ------------------------------------------------------------------------------
$Strings          = [Ordered]@{
  Letter          = "L"
  Word            = "Lorem"
  Sentence        = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  Test            = "lOrEm"
}
$Expected         = [Ordered]@{
  Letter          = [Ordered]@{
    CamelCase     = "l"
    KebabCase     = "l"
    LowerCase     = "l"
    PaslcalCase   = "L"
    SentenceCase  = "L"
    SnakeCase     = "l"
    TitleCase     = "L"
    TrainCase     = "L"
    UpperCase     = "L"
  }
  Word            = [Ordered]@{
    CamelCase     = "lorem"
    KebabCase     = "lorem"
    LowerCase     = "lorem"
    PaslcalCase   = "Lorem"
    SentenceCase  = "Lorem"
    SnakeCase     = "lorem"
    TitleCase     = "Lorem"
    TrainCase     = "Lorem"
    UpperCase     = "LOREM"
  }
  Sentence        = [Ordered]@{
    CamelCase     = "loremIpsumDolorSitAmetConsecteturAdipiscingElit"
    KebabCase     = "lorem-ipsum-dolor-sit-amet-consectetur-adipiscing-elit"
    LowerCase     = "lorem ipsum dolor sit amet, consectetur adipiscing elit."
    PaslcalCase   = "LoremIpsumDolorSitAmetConsecteturAdipiscingElit"
    SentenceCase  = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    SnakeCase     = "lorem_ipsum_dolor_sit_amet_consectetur_adipiscing_elit"
    TitleCase     = "Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit."
    TrainCase     = "Lorem_Ipsum_Dolor_Sit_Amet_Consectetur_Adipiscing_Elit"
    UpperCase     = "LOREM IPSUM DOLOR SIT AMET, CONSECTETUR ADIPISCING ELIT."
  }
  Test            = [Ordered]@{
    CamelCase     = "lorem"
    KebabCase     = "lorem"
    LowerCase     = "lorem"
    PaslcalCase   = "Lorem"
    SentenceCase  = "Lorem"
    SnakeCase     = "lorem"
    TitleCase     = "Lorem"
    TrainCase     = "Lorem"
    UpperCase     = "LOREM"
  }
}


# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
$Check = $true
foreach ($Entry in $Strings.GetEnumerator()) {
  $Key    = $Entry.Key
  $String = $Entry.Value
  foreach ($Format in $Expected.$Key.Keys) {
    $FormattedString = Format-String -String $String -Format $Format
    if ($FormattedString -ne $Expected.$Key.$Format) {
      $Check = $false
      break
    }
  }
}

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
return $Check
