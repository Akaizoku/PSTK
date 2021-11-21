function Stop-AllTranscripts {
    <#
        .SYNOPSIS
        Stop all transcripts

        .DESCRIPTION
        Stop all active PowerShell transcripts

        .NOTES
        File name:      Stop-AllTranscripts.ps1
        Author:         Florian Carrier
        Creation date:  2021-10-28
        Last modified:  2021-10-28
    #>
    [CmdLetBinding ()]
    Param (
        [Parameter (
            HelpMessage = "Suppress summary output"
        )]
        [Switch]
        $Silent
    )
    Begin {
        # Get global preference vrariables
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    }
    Process {
        # Variables
        $ActiveTranscript   = $true
        $Count              = 0
        # Stop transcripts
        while ($ActiveTranscript) {
            try {
                Stop-Transcript
                $Count += 1
            } catch {
                $ActiveTranscript = $false
            }
        }
        # Generate log
        if ($Silent -eq $false) {
            switch ($Count) {
                0       { return "The host is not currently transcribing."  }
                1       { $Log = "One single transcript was stopped."       }
                default { $Log = "$Count transcripts were stopped."         }
            }
            Write-Log -Type "DEBUG" -Message $Log
        }
    }
}