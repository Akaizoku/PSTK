<#
  .SYNOPSIS
  Add-Offset Unit Testing

  .DESCRIPTION
  Unit Test for Add-Offset function from PSTK module

  .NOTES
  File name:      Add-Offset.ps1
  Author:         Florian Carrier
  Creation date:  15/10/2018
  Last modified:  15/10/2018
#>

# ------------------------------------------------------------------------------
# Initialisation
# ------------------------------------------------------------------------------
$Path       = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition) -Parent
$Repository = Join-Path -Path $Path -ChildPath "Private"
# Import functions
$Scripts = @(
  $MyInvocation.MyCommand.Name,
  "Test-Alphanumeric.ps1"
)
foreach ($Script in $Scripts) {
  $Link = Join-Path -Path $Repository -ChildPath $Script
  . $Link
}
# ------------------------------------------------------------------------------
# Test objects
# ------------------------------------------------------------------------------
# Reference
$Reference = @(
  "a1",
  "b2",
  "g7",
  "z26"
)

# + 2
$Positive = @(
  "a3",
  "b4",
  "g9",
  "z28"
)

# - 3
$Negative = @(
  "a0",
  "b1",
  "g6",
  "z25"
)

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
$PositiveCounter = 0
$NegativeCounter = 0
for ($i=0; $i -lt $Reference.Length; $i++) {
  $NewPositiveValue = Add-Offset -Alphanumeric $Reference[$i] -Offset 2
  if ($NewPositiveValue -eq $Positive[$i]) { $PositiveCounter += 1 }
  $NewNegativeValue = Add-Offset -Alphanumeric $Reference[$i] -Offset -1
  if ($NewNegativeValue -eq $Negative[$i]) { $NegativeCounter += 1 }
}
if ($PositiveCounter -eq $Reference.Length) { $CheckPositive = $true }
else { $CheckPositive = $false }
if ($NegativeCounter -eq $Reference.Length) { $CheckNegative = $true }
else { $CheckNegative = $false }

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($CheckPositive -And $CheckNegative) {
  return $true
} else {
  return $false
}
