function Confirm-Prompt {
    <#
        .SYNOPSIS
        Prompt user for confirmation

        .DESCRIPTION
        Prompt user to confirm agreement to a specified statement

        .NOTES
        File name:      Confirm-Prompt.ps1
        Author:         Florian Carrier
        Creation date:  2019-06-14
        Last modified:  2024-09-13
    #>
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
			'\Ayes\Z|\Ay\Z|\A1\Z|\Atrue\Z|\At\Z'	{ return $true	}
			'\Ano\Z|\An\Z|\A0\Z|\Afalse\Z|\Af\Z'	{ return $false }
			default {
				Write-Log -Type "ERROR" -Object "Unable to process answer. Please enter either [Y] Yes or [N] No"
				Confirm-Prompt -Prompt $Prompt
			}
		}
	}
}
