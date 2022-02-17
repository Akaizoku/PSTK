function Ping-Host {
    <#
        .SYNOPSIS
        Ping host

        .DESCRIPTION
        Test the connection to a specified host

        .NOTES
        File name:      Ping-Host.ps1
        Author:         Florian Carrier
        Creation date:  2022-02-15
        Last modified:  2022-02-15

        .LINK
        https://docs.microsoft.com/en-us/previous-versions/windows/desktop/wmipicmp/win32-pingstatus
    #>
    [CmdletBinding ()]
    Param (
        [Parameter (
            Position    = 1,
            Mandatory   = $true,
            HelpMessage = "Hostname or IP address"
        )]
        [ValidateNotNullOrEmpty ()]
        [Alias ("Address")]
        [System.String]
        $Hostname,
        [Parameter (
            Position    = 2,
            Mandatory   = $false,
            HelpMessage = "Timeout (in seconds)"
        )]
        [ValidateNotNullOrEmpty ()]
        [System.Int32]
        $TimeOut = 1,
        [Parameter (
            HelpMessage = "Return detailed status"
        )]
        [Switch]
        $Status
    )
    Begin {
        # Get global preference vrariables
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        # Status codes
        $StatusCodes = [Ordered]@{
            [System.UInt32]0      = "Success"
            [System.UInt32]11001  = "Buffer Too Small"
            [System.UInt32]11002  = "Destination Net Unreachable"
            [System.UInt32]11003  = "Destination Host Unreachable"
            [System.UInt32]11004  = "Destination Protocol Unreachable"
            [System.UInt32]11005  = "Destination Port Unreachable"
            [System.UInt32]11006  = "No Resources"
            [System.UInt32]11007  = "Bad Option"
            [System.UInt32]11008  = "Hardware Error"
            [System.UInt32]11009  = "Packet Too Big"
            [System.UInt32]11010  = "Request Timed Out"
            [System.UInt32]11011  = "Bad Request"
            [System.UInt32]11012  = "Bad Route"
            [System.UInt32]11013  = "TimeToLive Expired Transit"
            [System.UInt32]11014  = "TimeToLive Expired Reassembly"
            [System.UInt32]11015  = "Parameter Problem"
            [System.UInt32]11016  = "Source Quench"
            [System.UInt32]11017  = "Option Too Big"
            [System.UInt32]11018  = "Bad Destination"
            [System.UInt32]11032  = "Negotiating IPSEC"
            [System.UInt32]11050  = "General Failure"
        }
        # Convert time-out to milliseconds
        $TimeOut = $TimeOut * 1000
    }
    Process {
        # Ping host
        $Ping = Get-CimInstance -ClassName "Win32_PingStatus" -Filter "Address='$Hostname' AND Timeout=$TimeOut"
        if ($Status) {
            # Return status label
            if ($null -eq $Ping.StatusCode) {
                $Output = "Failure"
            } else {
                $Output = $StatusCodes.$($Ping.StatusCode)
            }
        } else {
            # Return boolean
            $Output = ($Ping.StatusCode -eq 0)
        }
        return $Output
    }
}