# ------------------------------------------------------------------------------
# Logging function
# ------------------------------------------------------------------------------
function Write-Log {
  <#
    .SYNOPSIS
    Formats output message as a log

    .DESCRIPTION
    The Write-Log function outputs the time and type of a message in a formatt-
    ed manner with respective colour code.

    It takes two parameters:
    - Type of output: informational, warning, error, or checkpoint.
    - Message: output content.

    .PARAMETER Type
    The Type parameter defines the level of importance of the message and will
    influence the colour of the output.

    There are four different available types:
    - CHECK: checkpoint, used to confirm a status.
    - ERROR: error message, used to provide detail on an issue.
    - INFO: information, used to convey a message.
    - WARN: warnign, used to detail a non-blocking issue.

    .PARAMETER Message
    The Message parameter corresponds to the desired output to be logged.

    .INPUTS
    None. You cannot pipe objects to Write-Log.

    .OUTPUTS
    None. Simply writes a message to the host.

    .EXAMPLE
    Write-Log -Type "INFO" -Message "This is an informational message."

    This example outputs an informational message with the timestamp, the "INFO"
     tag, and the specified message itself. It uses the defaut color scheme.

    .EXAMPLE
    Write-Log -Type "WARN" -Message "This is a warning message."

    This example outputs a warning message with the timestamp, the "WARN" tag,
    and the specified message itself. The message will be displayed in yellow in
     the host.

    .EXAMPLE
    Write-Log -Type "ERROR" -Message "This is an error message."

    This example outputs an error message with the timestamp, the "ERROR" tag,
    and the specified message itself. The message will be displayed in red in
     the host.

    .EXAMPLE
    Write-Log -Type "CHECK" -Message "This is a checkpoint message."

    This example outputs a checkpoint message with the timestamp, the "CHECK"
    tag, and the specified message itself. The message will be displayed in
    green in the host.

    .NOTES
    File name:      Write-Log.ps1
    Author:         Florian Carrier
    Creation date:  15/10/2018
    Last modified:  19/10/2018
    TODO            Add locale variable

    .LINK
    https://github.com/Akaizoku/PSTK
  #>
  [CmdletBinding ()]
  # Inputs
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Type of message to output"
    )]
    [ValidateSet (
      "CHECK",
      "ERROR",
      "INFO",
      "WARN"
    )]
    [String]
    $Type,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Message to output"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Output", "Log")]
    [String]
    $Message
  )
  # Variables
  $Time     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $Colour   = [Ordered]@{
    "CHECK" = "Green"
    "ERROR" = "Red"
    "INFO"  = "White"
    "WARN"  = "Yellow"
  }
  # Format log
  $Log = "$Time`t$Type`t$Message"
  # Output
  Write-Host -Object $Log -ForegroundColor $Colour.$Type
}
