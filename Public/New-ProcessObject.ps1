function New-ProcessObject {
    <#
        .SYNOPSIS
        Create new process custom object

        .DESCRIPTION
        Create a new PSCustomObject to store all information about a process

        .NOTES
        File name:      New-ProcessObject.ps1
        Author:         Florian Carrier
        Creation date:  2024-09-10
        Last modified:  2024-09-12
    #>
    [CmdletBinding ()]
    Param (
        [Parameter (
            Position    = 1,
            Mandatory   = $true,
            HelpMessage = "Name of the process"
        )]
        [ValidateNotNullOrEmpty ()]
        [Alias ("ProcessName")]
        [System.String]
        $Name
    )
    Begin {
        # Get global preference vrariables
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        # Log function call
        Write-Log -Type "DEBUG" -Message $MyInvocation.MyCommand.Name
    }
    Process {
        $Process = [PSCustomObject]@{
            Status      = "Started"
            Success     = $false
            ExitCode    = 0
            ErrorCount  = 0
            ProcessID   = $PID
            ProcessName = $Name
        }
    }
    End {
        Write-Log -Type "DEBUG" -Message $Process
        return $Process
    }
}