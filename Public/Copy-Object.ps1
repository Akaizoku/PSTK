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
    Last modified:  2021-07-07
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
      HelpMessage = "Move content only to target location"
    )]
    [Switch]
    $ContentOnly
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Check path
    $Path = Resolve-Path -Path $Path
    if (Test-Object -Path $Path -NotFound) {
      Write-Log -Type "ERROR" -Message "Path not found $Path" -ErrorCode 1
    }
    # Destination
    if ($ContentOnly -eq $false) {
      $Content = "$Path\*"
      $Destination = Join-Path -Path $Destination -ChildPath (Split-Path -Path $Path -Leaf)
    }
    Write-Log -Type "DEBUG" -Message $Content
    Write-Log -Type "DEBUG" -Message $Destination
  }
  Process {
    if ($PSCmdlet.ShouldProcess($Path, "Copy")) {
      # Ensure destination exists to prevent error "Copy-Item : Container cannot be copied onto existing leaf item."
      # https://groups.google.com/g/microsoft.public.windows.powershell/c/rpuLRCTCryI/m/Ap-kKFY2CWcJ
      if (Test-Object -Path $Destination -NotFound) {
        New-Item -Path $Destination -ItemType "Directory"
      }
      # Copy directory content
      Copy-Item -Path $Content -Destination $Destination -Filter $Filter -Exclude $Exclude -Container -Recurse -Force
    }
  }
}