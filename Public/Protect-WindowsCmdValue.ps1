function Protect-WindowsCmdValue {
  <#
    .SYNOPSIS
    Protect value for Windows Command Line

    .DESCRIPTION
    Parse and protects value for use in Windows Command line by escaping special characters

    .PARAMETER Value
    The value parameter corresponds to the value to protect.

    .PARAMETER Pipeline
    The pipeline switch determines if the value will be used in the pipeline.

    .NOTES
    File name:      Protect-WindowsCmdValue.ps1
    Author:         Florian CARRIER
    Creation date:  2019-11-29
    Last modified:  2019-11-30

    .LINK
    https://ss64.com/nt/syntax-esc.html
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Value to resolve"
    )]
    [String]
    $Value,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Escape character"
    )]
    [String]
    $EscapeCharacter = '^',
    [Parameter (
      HelpMessage = "Enable pipeline escaping"
    )]
    [Switch]
    $Pipeline,
    [Parameter (
      HelpMessage = "Delayed expansion"
    )]
    [Switch]
    $DelayedExpansion
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # List of restricted characters
    $RestrictedCharacters = @('&', '\', '<', '>', '^', '|')
    # Escaping the pipeline
    if ($Pipeline) {
      # Double escaping
      $EscapeCharacter = $EscapeCharacter + $EscapeCharacter + $EscapeCharacter
    }
    # Protected character list
    $ProtectedCharacters = New-Object -TypeName "System.Collections.ArrayList"
  }
  Process {
    # Loop through characters
    for ($i=0; $i -lt $Value.length; $i++) {
      # Check character
      if ($Value[$i] -in $RestrictedCharacters) {
        # Escape restricted characters
        [Void]$ProtectedCharacters.Add($EscapeCharacter + $Value[$i])
      } elseif ($Value[$i] -eq '%') {
        # Escape percentage sign
        [Void]$ProtectedCharacters.Add('%%')
      } else {
        [Void]$ProtectedCharacters.Add($Value[$i])
      }
    }
    # Check for delayed expansion
    if ($DelayedExpansion) {
      # Escape Exclamation marks
      $ProtectedCharacters = $ProtectedCharacters.Replace('!', $EscapeCharacter + $EscapeCharacter + '!')
    }
    # Build protected value
    $ProtectedValue = $ProtectedCharacters -join ''
    # Return protected value
    return $ProtectedValue
  }
}
