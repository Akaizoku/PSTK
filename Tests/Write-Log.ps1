<#
  .SYNOPSIS
  Write-Log Unit Testing

  .DESCRIPTION
  Unit Test for Write-Log procedure from PSTK module

  .NOTES
  File name:      Write-Log.ps1
  Author:         Florian Carrier
  Creation date:  16/10/2018
  Last modified:  16/10/2018
  TODO            Does not work, find workaround
#>

# ------------------------------------------------------------------------------
# Initialisation
# ------------------------------------------------------------------------------
$Path       = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition) -Parent
$Repository = Join-Path -Path $Path -ChildPath "Private"
# Import toolbox
Import-Module "$Path\PSTK" -Force
# Import functions
$Scripts = @(
  "Select-WriteHost.ps1"
)
foreach ($Script in $Scripts) {
  $Link = Join-Path -Path $Repository -ChildPath $Script
  . $Link
}

# ------------------------------------------------------------------------------
# Test objects
# ------------------------------------------------------------------------------
$File     = "$($MyInvocation.MyCommand.Name).log"
$Outputs  = [Ordered]@{
  "CHECK" = "This is a checkpoint message."
  "ERROR" = "This is an error message."
  "INFO"  = "This is an informational message."
  "WARN"  = "This is a warning message."
}
# Expected output
$Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Expected   = @"
$Timestamp`tCHECK`tThis is a checkpoint message.
$Timestamp`tERROR`tThis is an error message.
$Timestamp`tINFO`tThis is an informational message.
$Timestamp`tWARN`tThis is a warning message.
"@

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------
# Generate log
foreach ($Output in $Outputs.GetEnumerator()) {
  $null = Select-WriteHost -ScriptBlock { Write-Log -Type $Output.Name -Message $Output.Value } -OutputFile $File -Quiet
}
# Check output
$FileContent = Get-Content -Path $File -Raw
if ($FileContent -eq $Expected) {
  $Check = $true
} else {
  $Check = $false
}
# Clean-up
Remove-Item -Path $File

# ------------------------------------------------------------------------------
# Check outcome
# ------------------------------------------------------------------------------
return $Check
