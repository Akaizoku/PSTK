function Get-PowerShellError {
    <#
        .SYNOPSIS
        Get latest error

        .DESCRIPTION
        Retrieve latest PowerShell error to occur similar to Get-Help in version 7

        .NOTES
        File name:      Get-PowerShellError.ps1
        Author:         Florian Carrier
        Creation date:  2024-09-23
        Last modified:  2024-09-23
    #>
    [CmdletBinding ()]
    Param ()
    Begin {
        # Get global preference vrariables
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        # Log function call
        Write-Log -Type "DEBUG" -Message $MyInvocation.MyCommand.Name
    }
    Process {
        # Fetch latest error
        $PSError = $PSCmdlet.GetVariableValue('Error')
        $LatestErrorRecord = $PSError[0]
        # Build error object
        $LatestError = [PSCustomObject]@{
            Exception             = if ($LatestErrorRecord.Exception) { $LatestErrorRecord.Exception.GetType().FullName } else { "N/A" }
            Message               = if ($LatestErrorRecord.Exception) { $LatestErrorRecord.Exception.Message            } else { $LatestErrorRecord.ToString() }
            Data                  = if ($LatestErrorRecord.Exception) { $LatestErrorRecord.Exception.Data               } else { "N/A" }
            InnerException        = if ($LatestErrorRecord.Exception -and $LatestErrorRecord.Exception.InnerException) { $LatestErrorRecord.Exception.InnerException.Message } else { "N/A" }
            TargetSite            = if ($LatestErrorRecord.Exception) { $LatestErrorRecord.Exception.TargetSite } else { "N/A" }
            StackTrace            = if ($LatestErrorRecord.Exception) { $LatestErrorRecord.Exception.StackTrace } else { "N/A" }
            HelpLink              = if ($LatestErrorRecord.Exception) { $LatestErrorRecord.Exception.HelpLink   } else { "N/A" }
            Source                = if ($LatestErrorRecord.Exception) { $LatestErrorRecord.Exception.Source     } else { "N/A" }
            HResult               = if ($LatestErrorRecord.Exception) { $LatestErrorRecord.Exception.HResult    } else { "N/A" }
            CategoryInfo          = $LatestErrorRecord.CategoryInfo
            FullyQualifiedErrorId = $LatestErrorRecord.FullyQualifiedErrorId
            ScriptStackTrace      = $LatestErrorRecord.ScriptStackTrace
        }
        # Add invocation information
        $InvocationInfo = $LatestErrorRecord.InvocationInfo
        if ($InvocationInfo) {
            $LatestError | Add-Member -MemberType "NoteProperty" -Name "InvocationInfo" -Value ([PSCustomObject]@{
                MyCommand        = $InvocationInfo.MyCommand
                BoundParameters  = $InvocationInfo.BoundParameters
                UnboundArguments = $InvocationInfo.UnboundArguments
                ScriptLineNumber = $InvocationInfo.ScriptLineNumber
                OffsetInLine     = $InvocationInfo.OffsetInLine
                HistoryId        = $InvocationInfo.HistoryId
                ScriptName       = $InvocationInfo.ScriptName
                Line             = $InvocationInfo.Line
                PositionMessage  = $InvocationInfo.PositionMessage
                PSScriptRoot     = $InvocationInfo.PSScriptRoot
                PSCommandPath    = $InvocationInfo.PSCommandPath
                InvocationName   = $InvocationInfo.InvocationName
                PipelineLength   = $InvocationInfo.PipelineLength
                PipelinePosition = $InvocationInfo.PipelinePosition
                ExpectingInput   = $InvocationInfo.ExpectingInput
                CommandOrigin    = $InvocationInfo.CommandOrigin
            })
        }
    }
    End {
        return $LatestError
    }
}