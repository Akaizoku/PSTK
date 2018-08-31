<#
  .SYNOPSIS
  CompareHashtables Unit Testing

  .DESCRIPTION
  Unit Test for CompareHashtables function from PSTK module

  .NOTES
  File name:      CompareHashtables.ps1
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
# Test objects
# ------------------------------------------------------------------------------
# Reference
$Reference    = [ordered]@{
  Property1   = 1
  Property2   = 2
  Property3   = 3
  Property4   = 4
  Property5   = 5
}
# Exact match
$Exact        = [ordered]@{
  Property1   = 1
  Property2   = 2
  Property3   = 3
  Property4   = 4
  Property5   = 5
}
# No match
$Inexact      = [ordered]@{
  Property1   = 5
  Property2   = 4
  Property3   = 3
  Property4   = 2
  Property5   = 1
}
# Empty hashtable
$Empty        = [ordered]@{}

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
$CheckExact   = CompareHashtables -Reference $Reference -Difference $Exact
$CheckInexact = CompareHashtables -Reference $Reference -Difference $Inexact
$CheckEmpty   = CompareHashtables -Reference $Reference -Difference $Empty

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($CheckExact -And !$CheckInexact -And !$CheckEmpty) {
  return $true
} else {
  return $false
}
