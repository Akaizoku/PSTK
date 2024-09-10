function Update-ProcessObject {
    <#
        .SYNOPSIS
        Update a process object

        .DESCRIPTION
        Update the properties of a specified PSCustomObject holding the information of a process

        .NOTES
        File name:      Update-ProcessObject.ps1
        Author:         Florian Carrier
        Creation date:  2024-09-10
        Last modified:  2024-09-10
    #>
    [CmdletBinding ()]
    Param (
        [Parameter (
            Position    = 1,
            Mandatory   = $true,
            HelpMessage = "Process object to update"
        )]
        [ValidateNotNullOrEmpty ()]
        [Alias ("Process")]
        [PSCustomObject]
        $ProcessObject,
        [Parameter (
            Position    = 2,
            Mandatory   = $false,
            HelpMessage = "Process status"
        )]
        [ValidateSet (
            "Cancelled",
            "Completed",
            "Failed",
            "Running",
            "Started",
            "Stopped"
        )]
        [System.String]
        $Status,
        [Parameter (
            Position    = 2,
            Mandatory   = $false,
            HelpMessage = "Status of the process"
        )]
        [ValidateNotNullOrEmpty ()]
        [System.Boolean]
        $Success,
        [Parameter (
            Position    = 3,
            Mandatory   = $false,
            HelpMessage = "Exit code of the process"
        )]
        [ValidateNotNullOrEmpty ()]
        [System.Int32]
        $ExitCode,
        [Parameter (
            Position    = 4,
            Mandatory   = $false,
            HelpMessage = "Exit code of the process"
        )]
        [ValidateNotNullOrEmpty ()]
        [System.Int32]
        $ErrorCount
    )
    Begin {
        # Get global preference vrariables
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        # Log function call
        Write-Log -Type "DEBUG" -Message $MyInvocation.MyCommand.Name
    }
    Process {
        # Update status
        if ($PSBoundParameters.ContainsKey("Status")) {
            $ProcessObject.Status = $Status
        }
        # Update success flag
        if ($PSBoundParameters.ContainsKey("Success")) {
            $ProcessObject.Success = $Success
        }
        # Update exit code
        if ($PSBoundParameters.ContainsKey("ExitCode")) {
            $ProcessObject.ExitCode = $ExitCode
        }
        # Update error count
        if ($PSBoundParameters.ContainsKey("ErrorCount")) {
            $ProcessObject.ErrorCount += $ErrorCount
        }
    }
    End {
        return $ProcessObject
    }
}