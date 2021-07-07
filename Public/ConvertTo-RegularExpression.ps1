function ConvertTo-RegularExpression {
    <#
        .SYNOPSIS
        Convert a string to a regular expression

        .DESCRIPTION
        Parse a string and convert it to a regular expression by replacing wildcards and escaping restricted characters

        .PARAMETER String
        The string parameter corresponds to the string to convert.

        .NOTES
        File name:      ConvertTo-RegularExpression.ps1
        Author:         Florian Carrier
        Creation date:  2021-07-07
        Last modified:  2021-07-07

        .LINK
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_regular_expressions
    #>
    [CmdletBinding ()]
    Param (
        [Parameter (
            Position    = 1,
            Mandatory   = $true,
            HelpMessage = "String(s) to convert"
        )]
        [ValidateNotNullOrEmpty ()]
        [Alias (
            "Strings",
            "Value"
        )]
        [System.String[]]
        $String
    )
    Begin {
        # Get global preference vrariables
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        # List wildcards and their equivalent
        $Wildcards = [Ordered]@{
            "*" = ".*"
            "?" = "."
        }
    }
    Process {
        $RegEx = New-Object -TypeName "System.Collections.ArrayList"
        foreach ($Value in $String) {
            $EscapedValue = [RegEx]::Escape($Value)
            foreach ($Wildcard in $Wildcards.GetEnumerator()) {
                $EscapedWildcard = [System.String]::Concat("\", $Wildcard.Name)
                $EscapedValue = $EscapedValue.Replace($EscapedWildcard, $Wildcard.Value)
            }
            [Void]$RegEx.Add($EscapedValue)
        }
        return $RegEx
    }
}