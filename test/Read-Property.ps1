<#
  .SYNOPSIS
  Read-Property Unit Testing

  .DESCRIPTION
  Unit Test for Read-Property function from PSTK module

  .NOTES
  File name:      Read-Property.ps1
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
# Expected results
# ------------------------------------------------------------------------------
$Expected = [ordered]@{
  Key     = "Property Name"
  Value   = "Property Value"
}

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
$Property1  = Read-Property -Content "Property Name = Property Value"
$Property2  = Read-Property -Content "Property Name   Property Value"
$Property3  = Read-Property -Content "Property Name = Property=Value"
$Property4  = Read-Property -Content "Property Name =Property Value"
$Property5  = Read-Property -Content "Property Name=Property Value"
$Property6  = Read-Property -Content "Property Name= Property Value"

$Check1     = Compare-Hashtable -Reference $Expected -Difference $Property1
$Check2     = Compare-Hashtable -Reference $Expected -Difference $Property2
$Check3     = Compare-Hashtable -Reference $Expected -Difference $Property3
$Check4     = Compare-Hashtable -Reference $Expected -Difference $Property4
$Check5     = Compare-Hashtable -Reference $Expected -Difference $Property5
$Check6     = Compare-Hashtable -Reference $Expected -Difference $Property6

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($Check1 -And !$Check2 -And !$Check3 -And $Check4 -And $Check5 -And $Check6) {
  return $true
} else {
  return $false
}
