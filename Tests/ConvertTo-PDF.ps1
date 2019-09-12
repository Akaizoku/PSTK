<#
  .SYNOPSIS
  ConvertTo-PDF Unit Testing

  .DESCRIPTION
  Unit Test for ConvertTo-PDF function from PSTK module

  .NOTES
  File name:      ConvertTo-PDF.ps1
  Author:         Florian Carrier
  Creation date:  26/09/2018
  Last modified:  26/09/2018
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
$DocumentPath = Join-Path -Path $Path -ChildPath ".\res"
$PDF          = "*.pdf"
$Expected     = @("Test Word 97-2003 Document.pdf", "Test Word Document.pdf")

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
$Check1     = ConvertTo-PDF -Path $DocumentPath
$Generated  = Get-ChildItem -Path $DocumentPath -Filter $PDF | Select -Expand "Name"
$Compare    = Compare-Object -ReferenceObject $Generated -DifferenceObject $Expected -PassThru
if ($Compare -eq $null) {
  $Check2 = $true
} else {
  $Check2 = $false
}
# Clean-up
Remove-Item -Path "$DocumentPath\*" -Filter $PDF

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
if ($Check1 -And $Check2) {
  return $true
} else {
  return $false
}
