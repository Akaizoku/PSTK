# ------------------------------------------------------------------------------
# Generate checksum file
# ------------------------------------------------------------------------------
function Write-Checksum {
  <#
    .SYNOPSIS
    Generate checksum file

    .DESCRIPTION
    Get checksum for a specified file and generate a file

    .PARAMETER Path
    The path parameter corresponds to the path of the file(s) to check.

    .PARAMETER Algorithm
    The algorithm parameter corresponds to the algorithm to use to generate the file hash.
    Five different algorithms are supported:
    - SHA1    : Secure Hash Algorithm 1
    - SHA256  : Secure Hash Algorithm 2 (256)
    - SHA384  : Secure Hash Algorithm 2 (384)
    - SHA512  : Secure Hash Algorithm 2 (512)
    - MD5     : MD5 message-digest algorithm

    .PARAMETER Filter
    The filter parameter corresponds to the pattern to use to filter files if the path provided is a directory.
    If not specified, by default all files will be selected.

    .PARAMETER OutputDirectory
    The output directory parameter corresponds to the directory in which to generate the file(s) containing the checksum value(s).
    If not specified, the default output location is the same as the file(s) analyses.

    .EXAMPLE
    Write-Checksum -Path "C:\Files" -Algorithm "MD5" -Filter "*.zip"

    In this example, the function will generate a checksum file for each of the archive (ZIP) files contained in the directory "C:\Files".

    .EXAMPLE
    Write-Checksum -Path "C:\Files\file.zip" -Algorithm "MD5"

    In this example, the function will generate a checksum file for the file "file.zip" located in the directory "C:\Files".

    .EXAMPLE
    Write-Checksum -Path "C:\Files\file.zip" -Algorithm "MD5" -OutputDirectory "C:\Checksum"

    In this example, the function will generate a checksum file under the name "file.zip.md5" in the directory "C:\Checksum" for the file "file.zip" located in the directory "C:\Files".

    .NOTES
    File name:      Write-Checksum.ps1
    Author:         Florian Carrier
    Creation date:  11/10/2019
    TODO            Add Exclude filter

    .LINK
    https://www.powershellgallery.com/packages/PSTK
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path of the file(s) to check"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Algorithm to use for hash"
    )]
    [ValidateSet (
      "SHA1",
      "SHA256",
      "SHA384",
      "SHA512",
      "MD5"
    )]
    [String]
    $Algorithm,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Filter to apply in case of directory"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Filter = "*",
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Directory in which to save generate checksum files"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $OutputDirectory
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Check path
    if (Test-Path -Path $Path) {
      # Check output directory
      if ($PSBoundParameters.ContainsKey("OutputDirectory")) {
        # Check if the path exists
        if (-Not (Test-Path -Path $OutputDirectory)) {
          # Create directory
          Write-Log -Type "DEBUG" -Object $OutputDirectory
          New-Item -Path $OutputDirectory -ItemType "Directory" | Out-Null
        }
      } else {
        # Check if path provided is a directory
        if (Test-Path -Path $Path -PathType "Container") {
          $OutputDirectory = $Path
        } else {
          # If not get parent directory
          $OutputDirectory = Split-Path -Path $Path
        }
      }
    } else {
      Write-Log -Type "ERROR" -Object "Path not found: $Path" -ErrorCode 1
    }
  }
  Process {
    $Files = Get-ChildItem -Path $Path -Filter $Filter
    foreach ($File in $Files) {
      # Get file hash
      $FileHash = Get-FileHash -Path $File.FullName -Algorithm $Algorithm
      Write-Log -Type "DEBUG" -Object $FileHash.Hash
      # Generate checksum file
      $FileName = $File.Name + "." + (Format-String -String $Algorithm -Format "LowerCase")
      $FilePath = Join-Path -Path $OutputDirectory -ChildPath $FileName
      Write-Log -Type "DEBUG" -Object $FilePath
      $FileHash.Hash | Out-File -FilePath $FilePath -Encoding "UTF8" -Force
    }
  }
}
