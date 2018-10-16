function Select-WriteHost {
  <#
    .SYNOPSIS
    Captures Write-Host output to standard output stream

    .DESCRIPTION
    Creates a proxy function for Write-Host and redirects the console output to
    the standard output stream.

    .PARAMETER InputObject
    The input object parameter corresponds to in-line values passed from the pi-
    peline.

    .PARAMETER ScriptBlock
    The script block parameter corresponds to the script to capture.

    .PARAMETER Quiet
    The quiet parameter is a flag whether the Write-Host output should be sup-
    pressed or kept.

    .INPUTS
    [System.Objects] Select-WriteHost accepts objects from the pipeline.

    .OUTPUTS
    [System.String] Select-WriteHost returns a string.

    .EXAMPLE
    $Output = 1..10 | % { Write-Host $_ } | Select-WriteHost

    In this example, Select-WriteHost will store the list of numbers from one
    to 10 into the $Output variable but still output the results to the console.

    .EXAMPLE
    $Output = 1..10 | % { Write-Host $_ } | Select-WriteHost -Quiet

    In this example, Select-WriteHost will store the list of numbers from one
    to 10 into the $Output variable and suppress the console output.

    .EXAMPLE
    $Output = Select-WriteHost -ScriptBlock { 1..10 | % { Write-Host $_ } } -OutputFile "test"

    In this example, Select-WriteHost will store the list of numbers from one
    to 10 into the $Output variable but still output the results to the console.

    .EXAMPLE
    $Output = Select-WriteHost -ScriptBlock { 1..10 | % { Write-Host $_ } } -OutputFile "test" -Quiet

    In this example, Select-WriteHost will store the list of numbers from one
    to 10 into the $Output variable and suppress the console output.

    .NOTES
    File name:      Select-WriteHost.ps1
    Author:         Florian Carrier
    Creation date:  16/10/2018
    Last modified:  16/10/2018
    Credit:         @LincolnAtkinson

    .LINK
    http://www.latkin.org/blog/2012/04/25/how-to-capture-or-redirect-write-host-output-in-powershell/
  #>
  [CmdletBinding (DefaultParameterSetName = "FromPipeline")]
  Param (
    [Parameter (
      ValueFromPipeline = $true,
      ParameterSetName  = "FromPipeline",
      HelpMessage       = "In-line script input to capture"
    )]
    [Object]
    $InputObject,
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      ParameterSetName  = "FromScriptblock",
      HelpMessage       = "Script to capture"
    )]
    [ScriptBlock]
    $ScriptBlock,
    [Parameter (
      Position          = 2,
      Mandatory         = $false,
      ParameterSetName  = "FromScriptblock",
      HelpMessage       = "Path to the output file"
    )]
    [String]
    $OutputFile,
    [Parameter (
      HelpMessage       = "Define if console output has to be suppressed"
    )]
    [Switch]
    $Quiet
  )
  Begin {
    function Unregister-WriteHost {
      # Clear out the proxy version of Write-Host
      Remove-Item Function:Write-Host -ErrorAction 0
    }
    function Edit-WriteHost ([String] $Scope, [Switch] $Quiet) {
      # Create a proxy for Write-Host
      $MetaData = New-Object -TypeName System.Management.Automation.CommandMetaData (Get-Command -Name "Microsoft.PowerShell.Utility\Write-Host")
      $Proxy    = [System.Management.Automation.ProxyCommand]::Create($MetaData)
      # Amend its behaviour
      $Content = if ($Quiet) {
        # In quiet mode, whack the entire function body, simply pass input di-
        # rectly to the pipeline
        $Proxy -replace '(?s)\bbegin\b.+', '$Object'
      } else {
        # In default mode, pass input to the pipeline, but allow real Write-Host
        # to process as well
        $Proxy -replace '($SteppablePipeline.Process)', '$Object; $1'
      }
      # load our version into the specified scope
      Invoke-Expression "Function ${Scope}:Write-Host { $Content }"
    }
    Unregister-WriteHost
    # If we are running at the end of a pipeline, need to immediately inject the
    # proxy into global scope, so that everybody else in the pipeline uses it.
    # This works great, but dangerous if we don't clean up properly.
    if ($PSCmdlet.ParameterSetName -eq "FromPipeline") {
      Edit-WriteHost -Scope "global" -Quiet:$Quiet
    }
  }
  Process {
    if ($PSCmdlet.ParameterSetName -eq "FromScriptBlock") {
      # If a scriptblock was passed to us, then we can declare the proxy as
      # local scope and let the runtime take it out of scope for us.
      # The scriptblock will inherit the proxy automatically as it's in a child
      # scope.
      . Edit-WriteHost -Scope "local" -Quiet:$Quiet
      if ($OutputFile)  { & $Scriptblock | Out-File -FilePath $OutputFile -Encoding "UTF8" -Append }
      else              { & $Scriptblock }
    } else {
      # In pipeline scenario, just pass input along
      if ($OutputFile)  { $InputObject | Out-File -FilePath $OutputFile -Encoding "UTF8" -Append }
      else              { $InputObject }
    }
  }
  End {
    Unregister-WriteHost
  }
}
