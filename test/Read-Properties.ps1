<#
  .SYNOPSIS
  Read-Properties Unit Testing

  .DESCRIPTION
  Unit Test for Read-Properties function from PSTK module

  .NOTES
  File name:      Read-Properties.ps1
  Author:         Florian Carrier
  Creation date:  31/08/2018
  Last modified:  26/09/2018
#>

# ------------------------------------------------------------------------------
# Initialisation
# ------------------------------------------------------------------------------
$Path         = Split-Path $MyInvocation.MyCommand.Definition
$Repository   = Split-Path $Path -Parent
$PropertyFile = "properties.ini"
# Import toolbox
Import-Module "$Repository\PSTK" -Force
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
$Properties1  = Read-Properties -File $PropertyFile -Directory $Repository\test\res
$Check1       = Compare-Hashtables -Reference $Expected1 -Difference $Properties1

# With Sections
$Properties2  = Read-Properties -File $PropertyFile -Directory $Repository\test\res -Section
$Check2       = Compare-Hashtables -Reference $Expected2 -Difference $Properties2

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($Check1 -And $Check2) {
  return $true
} else {
  return $false
}

# Y U NO WORK
