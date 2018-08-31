<#
  .SYNOPSIS
  ParseProperties Unit Testing

  .DESCRIPTION
  Unit Test for ParseProperties function from PSTK module

  .NOTES
  File name:      ParseProperties.ps1
  Author:         Florian Carrier
  Creation date:  31/08/2018
  Last modified:  31/08/2018
#>

# ------------------------------------------------------------------------------
# Initialisation
# ------------------------------------------------------------------------------
$Path       = Split-Path $MyInvocation.MyCommand.Definition
$Repository = Split-Path $Path -Parent
# Import toolbox
Import-Module "$Repository\PSTK.psm1" -Force
# ------------------------------------------------------------------------------
# Expected results
# ------------------------------------------------------------------------------
# Without Sections
$Expected1    = [ordered]@{
  Property1   = 1
  Property2   = 2
  Property3   = 3
  Property4   = 4
  Property5   = 5
  Property6   = 6
  Property7   = 7
  Property8   = 8
  Property9   = 9
  Property10  = 10
}
# With Sections
$Expected2      = [ordered]@{
  Section1      = [ordered]@{
    Property1   = 1
    Property2   = 2
    Property3   = 3
    Property4   = 4
    Property5   = 5
  }
  Section2      = [ordered]@{
    Property6   = 6
    Property7   = 7
    Property8   = 8
    Property9   = 9
    Property10  = 10
  }
}

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
# Without Sections
$Properties1  = ParseProperties -File properties.ini -Directory $Repository\test\res
$Check1       = CompareHashtables -Reference $Expected1 -Difference $Properties1
# With Sections
$Properties2  = ParseProperties -File properties.ini -Directory $Repository\test\res -Section
$Check2       = CompareHashtables -Reference $Expected2 -Difference $Properties2

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($Check1 -And $Check2) {
  return $true
} else {
  return $false
}

# Y U NO WORK
