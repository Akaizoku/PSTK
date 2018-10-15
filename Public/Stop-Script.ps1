# ------------------------------------------------------------------------------
# Advanced exit function
# ------------------------------------------------------------------------------
function Stop-Script {
  <#
    .SYNOPSIS
    Stop script

    .DESCRIPTION
    Exit script, set error code, disable stric-mode, and stop transcript if any.

    .PARAMETER ErrorCode
    The error code parameter corresponds to the error code thrown after exiting
    the script. Default is 0 (i.e. no errors).

    .EXAMPLE
    Stop-Script

    In this example, Stop-Script will set strict mode off, stop the transcript
    if any is currently active, and exit the script with error code 0.

    .EXAMPLE
    Stop-Script -ErrorCode 1

    In this example, Stop-Script will set strict mode off, stop the transcript
    if any is currently active, and exit the script with error code 1.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $false,
      HelpMessage = "Error code"
    )]
    [Alias ("Code")]
    [Int]
    $ErrorCode = 0
  )
  Begin {
    Set-StrictMode -Off
    try {
      Stop-Transcript
    } catch {
      Write-Log -Type "WARN" -Message "No transcript is being produced"
    }
  }
  Process {
    exit $ErrorCode
  }
}
