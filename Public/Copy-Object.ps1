function Copy-Object {
  <#
    .SYNOPSIS
    Copy object(s)

    .DESCRIPTION
    Copy list of objects matching specifications (wrapper for Copy-Item with checks)

    .PARAMETER Path
    The path parameter corresponds to the location of the objects to copy.

    .PARAMETER Destination
    The destination parameter corresponds to the target copy location.

    .PARAMETER Filter
    The filter parameter corresponds to the filter to apply to the name of objects to copy.

    .PARAMETER Exclude
    The exclude parameter corresponds to the filter to apply to the name of objects *not* to copy.

    .NOTES
    File name:      Copy-Object.ps1
    Author:         Florian Carrier
    Creation date:  2021-07-06
    Last modified:  2021-07-08
  #>
  [CmdletBinding (
    SupportsShouldProcess = $true
  )]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the items"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Target location"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String]
    $Destination,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Filter to apply"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String]
    $Filter = "*",
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Pattern to exclude"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.String[]]
    $Exclude = $null,
    [Parameter (
      HelpMessage = "Switch to force copy"
    )]
    [Switch]
    $Force
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Check path
    if (Select-String -InputObject $Path -Pattern ".+\\\*") {
      Write-Log -Type "DEBUG" -Message $Path
      Write-Log -Type "ERROR" -Message "Please provide a path to a single directory or file" -ErrorCode 1
    }
  }
  Process {
    if ($PSCmdlet.ShouldProcess($Path, "Copy")) {
      # Check target type
      $Target = Get-Object -Path $Path
      if ($Target -is [System.IO.DirectoryInfo]) {
        # If target is a directory
        $Destination = Join-Path -Path $Destination -ChildPath (Split-Path -Path $Path -Leaf)
        if (Test-Object -Path $Destination -NotFound) {
          # Ensure destination exists to prevent error "Copy-Item : Container cannot be copied onto existing leaf item."
          Write-Log -Type "DEBUG" -Message "Create destination directory $Destination"
          New-Item -Path $Destination -ItemType "Directory" | Out-Null
        } else {
          if ($Force -eq $false) {
            Write-Log -Type "ERROR" -Message "Destination path already exists $Destination"
            Write-Log -Type "WARN"  -Message "Use the -Force switch to overwrite"
            Stop-Script -ExitCode 1
          }
        }
        # Copy directory content
        Write-Log -Type "DEBUG" -Message "Copy directory and content $Path to $Destination"
        Copy-Item -Path "$Path\*" -Destination $Destination -Filter $Filter -Exclude $Exclude -Recurse -Force:$Force
      } elseif ($Target -is [System.IO.FileInfo]) {
        # If target is a single file
        Write-Log -Type "DEBUG" -Message "Copy file $Path to $Destination"
        Copy-Item -Path $Path -Destination $Destination -Container -Force:$Force
      }
    }
  }
}