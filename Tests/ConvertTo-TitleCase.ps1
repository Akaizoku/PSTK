<#
  .SYNOPSIS
  ConvertTo-TitleCase Unit Testing

  .DESCRIPTION
  Unit Test for ConvertTo-TitleCase function from PSTK module

  .NOTES
  File name:      ConvertTo-TitleCase.ps1
  Author:         Florian Carrier
  Creation date:  05/10/2018
  Last modified:  16/10/2018
#>

# ------------------------------------------------------------------------------
# Initialisation
# ------------------------------------------------------------------------------
$Path       = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition) -Parent
$Repository = Join-Path -Path $Path -ChildPath "Private"
# Import functions
$Scripts = @(
  $MyInvocation.MyCommand.Name
)
foreach ($Script in $Scripts) {
  $Link = Join-Path -Path $Repository -ChildPath $Script
  . $Link
}

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
  Letter          = "L"
  Word            = "Lorem"
  Sentence        = "Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit."
  Test            = "Lorem"
}


# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
$Check = $true
foreach ($Entry in $Strings.GetEnumerator()) {
  $Key    = $Entry.Key
  $String = $Entry.Value
  $FormattedString = ConvertTo-TitleCase -String $String
  if ($FormattedString -ne $Expected.$Key) {
    $Check = $false
    break
  }
}

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
return $Check
