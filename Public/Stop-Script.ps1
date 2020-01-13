function Stop-Script {
  <#
    .SYNOPSIS
    Stop script

    .DESCRIPTION
    Exit script, set exit code, disable stric-mode, and stop transcript if any.

    .PARAMETER ExitCode
    The exit code parameter corresponds to the error code thrown after exiting
    the script. Default is 0 (i.e. no errors).

    .EXAMPLE
    Stop-Script

    In this example, Stop-Script will set strict mode off, stop the transcript
    if any is currently active, and exit the script with error code 0.

    .EXAMPLE
    Stop-Script -ExitCode 1

    In this example, Stop-Script will set strict mode off, stop the transcript
    if any is currently active, and exit the script with error code 1.

    .NOTES
    File name:      Stop-Script.ps1
    Author:         Florian Carrier
    Creation date:  15/10/2018
    Last modified:  17/12/2019
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $false,
      HelpMessage = "Script exit code"
    )]
    [Alias (
      "Code",
      "ErrorCode",
      "ReturnCode"
    )]
    [Int]
    $ExitCode = 0
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
    exit $ExitCode
  }
}
