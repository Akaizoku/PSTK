# ------------------------------------------------------------------------------
# Advanced start function
# ------------------------------------------------------------------------------
function Start-Script {
  <#
    .SYNOPSIS
    Start script

    .DESCRIPTION
    Start transcript and set strict mode

    .PARAMETER Transcript
    [String] The transcript parameter corresponds to the path to the file to be
    generated to log the session.

    .EXAMPLE
    Start-Script -Transcript ".\log\transcript.log"

    In this example, Start-Script will set stric mode on, and record all the
    output in a file colled "transcript.log" under the ".\log" directory.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Transcript file path"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("LogFile")]
    [String]
    $Transcript
  )
  Begin {
    Set-StrictMode -Version Latest
  }
  Process {
    Start-Transcript -Path $Transcript -Append -Force
  }
}
