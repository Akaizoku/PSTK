function Write-Log {
  <#
    .SYNOPSIS
    Formats output message as a log

    .DESCRIPTION
    The Write-Log function outputs the time and type of a message in a formatted manner with respective colour code.

    It takes two parameters:
    - Type of output: information, warning, error, debug, or checkpoint.
    - Message: output content.

    .PARAMETER Type
    The type parameter defines the level of importance of the message and will
    influence the colour of the output.

    There are five available message types:
    - CHECK:  checkpoint, used to confirm a status;
    - DEBUG:  debug message, used to debug scripts;
    - ERROR:  error message, used to provide detail on an issue;
    - INFO:   information, used to convey a message;
    - WARN:   warning, used to highlight a non-blocking issue.

    .PARAMETER Object
    The object parameter corresponds to the desired output to be logged.

    .PARAMETER ExitCode
    The optional exit code parameter acts as a switch. If specified, the script execution is terminated and the value corresponds to the error code to throw when terminating the script.

    .PARAMETER FilePath
    The optional file path parameter corresponds to the path to an output file in which to save the message.

    .PARAMETER Obfuscate
    The optional obfuscate parameter corresponds to specific text to obfuscate from the output. Multiple values can be passed.

    .INPUTS
    None. You cannot pipe objects to Write-Log.

    .OUTPUTS
    None. Simply writes a message to the host.

    .EXAMPLE
    Write-Log -Type "INFO" -Message "This is an informational message."

    This example outputs an informational message with the timestamp, the "INFO" tag, and the specified message itself. It uses the defaut color scheme.

    .EXAMPLE
    Write-Log -Type "WARN" -Message "This is a warning message."

    This example outputs a warning message with the timestamp, the "WARN" tag, and the specified message itself. The message will be displayed in yellow in the host.

    .EXAMPLE
    Write-Log -Type "ERROR" -Message "This is an error message."

    This example outputs an error message with the timestamp, the "ERROR" tag, and the specified message itself. The message will be displayed in red in the host.

    .EXAMPLE
    Write-Log -Type "ERROR" -Message "This is an error message." -ExitCode 1

    This example outputs an error message with the timestamp, the "ERROR" tag, and the specified message itself. The script will terminate with the exit code 1.

    .EXAMPLE
    Write-Log -Type "CHECK" -Message "This is a checkpoint message."

    This example outputs a checkpoint message with the timestamp, the "CHECK" tag, and the specified message itself. The message will be displayed in green in the host.

    .EXAMPLE
    Write-Log -Type "DEBUG" -Message "This is a debug message."

    This example outputs a message through the default DEBUG PowerShell chanel, if the -Debug flag is enabled.

    .EXAMPLE
    Write-Log -Type "INFO" -Message "This is a password." -Obfuscate "password"

    This example outputs a message with the timestamp, the "INFO" tag, and the specified message itself with the "password" word obfuscated.

    Output: "This is a *******."

    .NOTES
    File name:      Write-Log.ps1
    Author:         Florian Carrier
    Creation date:  2018-10-15
    Last modified:  2021-09-02
    TODO            Add locale variable

    .LINK
    https://www.powershellgallery.com/packages/PSTK
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Type of message to output"
    )]
    [ValidateSet (
      "CHECK",
      "DEBUG",
      "ERROR",
      "INFO",
      "WARN"
    )]
    [System.String]
    $Type,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Message to output"
    )]
    [AllowNull()]
    [Alias ("Message", "Output", "Log")]
    [System.Object]
    $Object,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Error code"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias (
      "ErrorCode",
      "ReturnCode"
    )]
    [Int]
    $ExitCode,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Path to an optional output file"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("Path")]
    [System.String]
    $FilePath,
    [Parameter (
      Position    = 5,
      Mandatory   = $false,
      HelpMessage = "Text to obfuscate"
    )]
    [String[]]
    $Obfuscate
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Variables
    $Time     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Colour   = [Ordered]@{
      "CHECK" = "Green"
      "ERROR" = "Red"
      "INFO"  = "White"
      "WARN"  = "Yellow"
    }
    # Message object check
    if ($null -eq $Object) {
      # Output explicit null value
      $Message = '$null'
    } elseif ($Object.GetType() -ne "String") {
      # Serialise object
      $Message = ($Object | Out-String).Trim()
    } else {
      # Trim message
      $Message = $Object.Trim()
    }
    # Obfuscate text
    if ($PSBoundParameters.ContainsKey("Obfuscate")) {
      foreach ($SensitiveText in $Obfuscate) {
        $Message = $Message.Replace($SensitiveText, "*******")
      }
    }
  }
  Process {
    # Check output type
    if ($Type -eq "DEBUG") {
      Write-Debug -Message $Message
    } else {
      # Format log message
      $Log = "$Time`t$Type`t$Message"
      # Output
      Write-Host -Object $Log -ForegroundColor $Colour.$Type
    }
    # If output file is specified
    if ($PSBoundParameters.ContainsKey("FilePath")) {
      Write-Log -Type "DEBUG" -Object $FilePath
      $Message | Out-File -FilePath $FilePath -Append -Force
    }
    # Stop script if exit code is specified
    if ($PSBoundParameters.ContainsKey("ExitCode")) {
      Stop-Script -ExitCode $ExitCode
    }
  }
}
