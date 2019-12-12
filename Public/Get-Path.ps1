function Get-Path {
  <#
    .SYNOPSIS
    Resolve relative path

    .DESCRIPTION
    Resolve relative path

    .NOTES
    File name:      Get-Path.ps1
    Author:         Florian Carrier
    Creation date:  27/11/2018
    Last modified:  12/12/2019
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of paths to resolve"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $PathToResolve,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Hashtable containing the paths"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $Hashtable,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Root for relative path"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Root = $PSScriptRoot
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    $Paths = Resolve-Array -Array $PathToResolve -Delimiter ","
    foreach ($Path in $Paths) {
      $Pathway = $Hashtable.$Path
      # If path is relative
      if ($Pathway -match "^[\.\\|\\]") {
        $RelativePath = $Pathway -replace "^[\.\\|\\]", ""
        $AbsolutePath = Join-Path -Path $Root -ChildPath $RelativePath
        if (-Not (Test-Path -Path $AbsolutePath)) {
          Write-Log -Type "INFO" -Object "Creating directory: $AbsolutePath"
          New-item -ItemType "Directory" -Path "$AbsolutePath" | Out-Null
        }
        Write-Log -Type "DEBUG" -Object $AbsolutePath
        $Hashtable.$Path = $AbsolutePath
      } elseif (-Not (Test-Path -Path $Pathway)) {
        Write-Log -Type "ERROR" -Object "Path not found: $Pathway"
      }
    }
    return $Hashtable
  }
}
