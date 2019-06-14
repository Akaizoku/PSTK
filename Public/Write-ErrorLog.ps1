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
    [Alias ("Message")]
    [Object]
    $Object,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Error code"
    )]
    [Int]
    $ErrorCode
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Ensure message is a string
    if ($Object.GetType() -ne "String") {
      $Message = ($Object | Out-String).Trim()
    } else {
      $Message = $Object.Trim()
    }
  }
  Process {
    Write-Log -Type "DEBUG" -Message $Path
    $Message | Out-File -FilePath $Path -Append -Force
    if ($PSBoundParameters.ContainsKey("ErrorCode")) {
      Stop-Script -ErrorCode $ErrorCode
    }
  }
}
