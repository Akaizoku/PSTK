function Import-Function {
  <#
    .SYNOPSIS
    Import PowerShell function

    .DESCRIPTION
    Import PowerShell function(s) from a specified location

    .PARAMETER Path
    The path parameter corresponds to the file or directory from which to import the function(s)

    .NOTES
    File name:      Import-Function.ps1
    Author:         Florian Carrier
    Creation date:  15/10/2019
    Last modified:  15/10/2019
    Warning:        /!\ Does not propagate functions to parent script as expected
  #>
  [CmdletBinding (
    SupportsShouldProcess = $true
  )]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Select files
    $Files = Get-ChildItem -Path $Path -Filter "*.ps1"
    # Loop through files
    foreach ($File in $Files) {
      Write-Log -Type "DEBUG" -Object $File.Name
      try   { . $File.FullName }
      catch { Write-Error -Message "Failed to import function $($File.FullName): $_" }
    }
  }
}
