function Write-ErrorLog {
  [CmdletBinding()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the output file"
    )]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Message to log"
    )]
    [String]
    $Message,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Error code"
    )]
    [Int]
    $ErrorCode
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    Write-Log -Type "DEBUG" -Message $Path
    $Message | Out-File -FilePath $Path -Append -Force
    if ($PSBoundParameters["ErrorCode"]) {
      Stop-Script -ErrorCode $ErrorCode
    }
  }
}
