# ------------------------------------------------------------------------------
# Complete relative paths
# ------------------------------------------------------------------------------
function Complete-RelativePath {
  <#
    .SYNOPSIS
    Make relative path absolute

    .DESCRIPTION
    Auto-complete relative path with working directory to make them absolute

    .OUTPUTS
    [System.Collections.ArrayList] Complete-RelativePath returns a list of abso-
    lute paths.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Relative path to make absolute"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Paths")]
    [String[]]
    $RelativePaths,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Root directory to pre-prend to relative path"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Directory", "Root")]
    [String]
    $WorkingDirectory
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Test working directory path
    if (-Not (Test-Path -Path $WorkingDirectory)) {
      Write-Log -Type "ERROR" -Message "$WorkingDirectory does not exists."
      Stop-Script 1
    }
    $Paths = New-Object -TypeName System.Collections.ArrayList
  }
  Process {
    foreach ($RelativePath in $RelativePaths) {
      # If path is correct, change value to absolute
      $AbsolutePath = Join-Path -Path $WorkingDirectory -ChildPath $RelativePath
      if (Test-Path -Path $AbsolutePath) {
        [Void]$Paths.Add($AbsolutePath)
      } else {
        # If it is not found, keep relative path
        Write-Log -Type "WARN" -Message "$AbsolutePath does not exists."
        [Void]$Paths.Add($RelativePath)
      }
    }
    return $Paths
  }
}
