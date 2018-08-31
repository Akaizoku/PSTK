<#
  .SYNOPSIS
  CloneOrderedHashtable Unit Testing

  .DESCRIPTION
  Unit Test for CloneOrderedHashtable function from PSTK module

  .NOTES
  File name:      CloneOrderedHashtable.ps1
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
# Simple
$Simple    = [ordered]@{
  Property1   = 1
  Property2   = 2
  Property3   = 3
  Property4   = 4
  Property5   = 5
}
# Complex
$Complex        = [ordered]@{
  Section1    = [ordered]@{
    Property1 = 1
    Property2 = 2
  }
  Property3   = 3
  Section2    = [ordered]@{
    Property4 = 4
    Property5 = 5
  }
}
# Empty hashtable
$Empty        = [ordered]@{}

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
$CloneSimple  = CloneOrderedHashtable -Hashtable $Simple
$CheckSimple  = CompareHashtables -Reference $CloneSimple -Difference $Simple

$CloneComplex = CloneOrderedHashtable -Hashtable $Complex
$CheckComplex = CompareHashtables -Reference $CloneComplex -Difference $Complex

$CloneEmpty   = CloneOrderedHashtable -Hashtable $Empty
$CheckEmpty   = CompareHashtables -Reference $CloneEmpty -Difference $Empty

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($CloneSimple -And $CheckComplex -And $CheckEmpty) {
  return $true
} else {
  return $false
}
