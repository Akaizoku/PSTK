function Expand-CompressedFile {
  <#
    .SYNOPSIS
    Expand compressed file

    .DESCRIPTION
    Expand a compressed file with the "best" method available depending on the
    PowerShell version used.

    .PARAMETER Path
    The path parameter corresponds to the path to the compressed file to expand.

    .PARAMETER DestinationPath
    The destination path parameter corresponds to the target path for the expan-
    sion.
    If not specified, the file will be expanded in the same location under a dir-
    ectory with the same name of the file (without the extension).

    .PARAMETER Force
    The force switch defines if the target should be overwritten in case it al-
    ready exists.

    .EXAMPLE
    Expand-CompressedFile -Path "C:\archive.zip" -DestinationPath "C:\archive"

    In this example,

    .NOTES
    File name:      Expand-CompressedFile.ps1
    Author:         Florian Carrier
    Creation date:  08/12/2018
    Last modified:  08/12/2018
  #>
  [CmdletBinding ()]
  Param(
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the compressed file"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Destination where to extract the contents"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $DestinationPath,
    [Switch]
    $Force
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Check if destination path has been specified
    if (-Not $DestinationPath) {
      $FilePath = Get-ChildItem -Path $Path
      $DestinationPath = Join-Path -Path $FilePath.DirectoryName -ChildPath $FilePath.BaseName
    }
    # Check PowerShell version to determine method to be used for decompressing
    if ($PSVersionTable.PSVersion.Major -ge 5) {
      # If PowerShell version greater than 5 then use more efficien Expand-Archive
      Write-Log -Type "DEBUG" -Message "Using native PowerShell v5.0 Expand-Archive function"
      Expand-Archive -Path $Path -DestinationPath $DestinationPath -Force:$Force
    } else {
      # Else copy files "manually"
      Write-Log -Type "DEBUG" -Message "PowerShell version lower than 5.0"
      Write-Log -Type "DEBUG" -Message "Copying objects out of the compressed file"
      $Shell = New-Object -ComObject Shell.Application
      $File = $Shell.NameSpace($Path)
      foreach($Item in $File.Items()) {
        if ($Force) {
          $Shell.Namespace($DestinationPath).CopyHere($Item, 0x14)
        } else {
          $Shell.Namespace($DestinationPath).CopyHere($Item)
        }
      }
    }
  }
}