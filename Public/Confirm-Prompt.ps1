function Confirm-Prompt {
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Prompt message"
    )]
    [String]
    $Prompt
  )
  Begin {
    $ConfirmPrompt = $Prompt + " ([Y] Yes | [N] No)"
  }
  Process {
    $Answer = Read-Host -Prompt $ConfirmPrompt
    switch -RegEx ($Answer) {
      # Switch is case insensitive
      '\Ayes\Z|\Ay\Z|\A1\Z|\Atrue\Z|\At\Z'  { return $true  }
      '\Ano\Z|\An\Z|\A0\Z|\Afalse\Z|\Af\Z'  { return $false }
      default {
        Write-Log -Type "ERROR" -Object "Unable to process answer. Please enter either [Y] Yes or [N] No"
        Confirm-Prompt -Prompt $Prompt
      }
    }
  }
}
