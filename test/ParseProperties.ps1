# Initialisation
$Path       = Split-Path $MyInvocation.MyCommand.Definition
$Repository = Split-Path $Path -Parent

# Import toolbox
Import-Module "$Repository\PowerShell-Toolbox.psm1"

# Expected result
$Expected = [ordered]@{
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

# Test function
$Properties = ParseProperties -File properties.ini -Directory $Repository\test\res

# # Check outcome
# if ($Properties -eq $Expected) {
#   return $true
# } else {
#   return $false
# }

$Properties

$Expected
