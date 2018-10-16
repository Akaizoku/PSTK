<#
  .SYNOPSIS
  Read-Properties Unit Testing

  .DESCRIPTION
  Unit Test for Read-Properties function from PSTK module

  .NOTES
  File name:      Read-Properties.ps1
  Author:         Florian Carrier
  Creation date:  31/08/2018
  Last modified:  16/10/2018
  TODO            Fix
#>

# ------------------------------------------------------------------------------
# Initialisation
# ------------------------------------------------------------------------------
$Path             = Split-Path -Path $MyInvocation.MyCommand.Definition
$Repository       = Split-Path -Path $Path -Parent
$PrivateDirectory = Join-Path -Path $Repository -ChildPath "Private"
# Import module and private functions
Import-Module -Name "$Repository\PSTK" -Force
$Scripts = @(
  $MyInvocation.MyCommand.Name,
  "Read-Property.ps1"
)
foreach ($Script in $Scripts) {
  $Link = Join-Path -Path $PrivateDirectory -ChildPath $Script
  . $Link
}
# ------------------------------------------------------------------------------
# Expected results
# ------------------------------------------------------------------------------
$PropertyFile = "properties.ini"
# Without Sections
$Expected1      = [Ordered]@{
  "Property1"   = "1"
  "Property2"   = "2"
  "Property3"   = "3"
  "Property4"   = "4"
  "Property5"   = "5"
  "Property6"   = "6"
  "Property7"   = "7"
  "Property8"   = "8"
  "Property9"   = "9"
  "Property10"  = "10"
}

# With Sections
$Expected2        = [Ordered]@{
  "Section1"      = [Ordered]@{
    "Property1"   = "1"
    "Property2"   = "2"
    "Property3"   = "3"
    "Property4"   = "4"
    "Property5"   = "5"
  }
  "Section2"      = [Ordered]@{
    "Property6"   = "6"
    "Property7"   = "7"
    "Property8"   = "8"
    "Property9"   = "9"
    "Property10"  = "10"
  }
}

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
# Without Sections
$Properties1  = Read-Properties -File $PropertyFile -Directory "$Path\res"
$Check1       = Compare-Hashtable -Reference $Expected1 -Difference $Properties1

# With Sections
$Properties2  = Read-Properties -File $PropertyFile -Directory "$Path\res" -Section
$Check2       = Compare-Hashtable -Reference $Expected2 -Difference $Properties2

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($Check1 -And $Check2) {
  return $true
} else {
  return $false
}

# Y U NO WORK
