#Requires -Version 3.0

<#
  .SYNOPSIS
  PowerShell Toolbox

  .DESCRIPTION
  Collection of useful functions and procedures.

  .NOTES
  File name:      PSTK.psm1
  Author:         Florian Carrier
  Creation date:  2018-08-23
  Last modified:  2019-10-11
  Repository:     https://github.com/Akaizoku/PSTK
  Dependencies:   Test-SQLConnection requires the SQLServer module

  .LINK
  https://github.com/Akaizoku/PSTK

  .LINK
  https://www.powershellgallery.com/packages/PSTK

  .LINK
  https://docs.microsoft.com/en-us/sql/powershell/download-sql-server-ps-module
#>

# Get public and private function definition files
$Public  = @( Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction "SilentlyContinue" )
$Private = @( Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction "SilentlyContinue" )

# Import files using dot sourcing
foreach ($File in @($Public + $Private)) {
  try   { . $File.FullName }
  catch { Write-Error -Message "Failed to import function $($File.FullName): $_" }
}

# Export public functions
Export-ModuleMember -Function $Public.BaseName
