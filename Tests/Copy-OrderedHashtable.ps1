<#
  .SYNOPSIS
  Copy-OrderedHashtable Unit Testing

  .DESCRIPTION
  Unit Test for Copy-OrderedHashtable function from PSTK module

  .NOTES
  File name:      Copy-OrderedHashtable.ps1
  Author:         Florian Carrier
  Creation date:  31/08/2018
  Last modified:  04/10/2018
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
# Simple
$Simple       = [ordered]@{
  Property1   = 1
  Property2   = 2
  Property3   = 3
  Property4   = 4
  Property5   = 5
}
# Complex
$Complex      = [ordered]@{
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
$CloneSimple  = Copy-OrderedHashtable -Hashtable $Simple
$CheckSimple  = Compare-Hashtable -Reference $CloneSimple -Difference $Simple

$CloneComplex = Copy-OrderedHashtable -Hashtable $Complex
$CheckComplex = Compare-Hashtable -Reference $CloneComplex -Difference $Complex

$CloneEmpty   = Copy-OrderedHashtable -Hashtable $Empty
$CheckEmpty   = Compare-Hashtable -Reference $CloneEmpty -Difference $Empty

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($CloneSimple -And $CheckComplex -And $CheckEmpty) {
  return $true
} else {
  return $false
}
