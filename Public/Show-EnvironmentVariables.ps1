function Show-EnvironmentVariables {
    <#
        .SYNOPSIS
        Show environment variables

        .DESCRIPTION
        Lists all available environment variables in a specified scope

        .NOTES
        File name:      Show-EnvironmentVariables.ps1
        Author:         Florian Carrier
        Creation date:  2022-01-14
        Last modified:  2022-01-14
    #>
    [CmdletBinding ()]
    Param (
        [Parameter (
            Position    = 1,
            Mandatory   = $false,
            HelpMessage = "Scope"
        )]
        [ValidateSet(
            "Machine",
            "Process",
            "User"
        )]
        [System.String]
        $Scope
    )
    Begin {
        # Get global preference vrariables
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    }
    Process {
        if ($PSBoundParameters.ContainsKey("Scope")) {
            $EnvironmentVariables = [System.Environment]::GetEnvironmentVariables($Scope)
        } else {
            $EnvironmentVariables = [System.Environment]::GetEnvironmentVariables()
        }
        return $EnvironmentVariables
    }
}