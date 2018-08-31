<#
  .SYNOPSIS
  ParseProperty Unit Testing

  .DESCRIPTION
  Unit Test for ParseProperty function from PSTK module

  .NOTES
  File name:      ParseProperty.ps1
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
$Expected = [ordered]@{
  Key     = "Property Name"
  Value   = "Property Value"
}

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
$Property1  = ParseProperty -Content "Property Name = Property Value"
$Property2  = ParseProperty -Content "Property Name   Property Value"
$Property3  = ParseProperty -Content "Property Name = Property=Value"
$Property4  = ParseProperty -Content "Property Name =Property Value"
$Property5  = ParseProperty -Content "Property Name=Property Value"
$Property6  = ParseProperty -Content "Property Name= Property Value"

$Check1     = CompareHashtables -Reference $Expected -Difference $Property1
$Check2     = CompareHashtables -Reference $Expected -Difference $Property2
$Check3     = CompareHashtables -Reference $Expected -Difference $Property3
$Check4     = CompareHashtables -Reference $Expected -Difference $Property4
$Check5     = CompareHashtables -Reference $Expected -Difference $Property5
$Check6     = CompareHashtables -Reference $Expected -Difference $Property6

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($Check1 -And !$Check2 -And !$Check3 -And $Check4 -And $Check5 -And $Check6) {
  return $true
} else {
  return $false
}
