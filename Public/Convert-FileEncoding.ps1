# ------------------------------------------------------------------------------
# Convert file encoding
# ------------------------------------------------------------------------------
function Convert-FileEncoding {
  <#
    .SYNOPSIS
    Convert file to specified encoding

    .DESCRIPTION
    Create a copy of a given file and convert the encoding as specified.

    .PARAMETER Path
    [String] The path parameter corresponds to the path to the directory or file
     to encode.

     .PARAMETER Encoding
     [String] The encoding parameter corresponds to the encoding to converting
     the file(s) to.

    .PARAMETER Filter
    [String] The filter parameters corresponds to the pattern to match to filter
     objects from the result set.

    .PARAMETER Exclude
    [String] The exclude parameters corresponds to the pattern to match to ex-
    clude objects from the result set.

    .NOTES
    /!\ Exclude is currently not supported in Windows PowerShell
    See Get-Object

    .LINK
    Get-Object
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the files to convert"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Encoding"
    )]
    [ValidateSet ("ASCII", "BigEndianUnicode", "OEM", "Unicode", "UTF7", "UTF8", "UTF8BOM", "UTF8NoBOM", "UTF32")]
    [String]
    $Encoding,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Filter to apply"
    )]
    [String]
    $Filter = "*",
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Pattern to exclude"
    )]
    [String]
    $Exclude = $null
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Check parameters and instantiate variables
    # $Path     = Resolve-Path -Path $Path
    $Files    = Get-Object -Path $Path -Type "File" -Filter $Filter -Exclude $Exclude
    $Encoding = $Encoding.ToUpper()
    $Output   = $false
    $Count    = 0
  }
  Process {
    try {
      foreach ($File in $Files) {
        Write-Log -Type "INFO" -Object "Converting ""$($File.Name)"" to $Encoding"
        $Filename = "$($File.BaseName)_$Encoding$($File.Extension)"
        $FilePath = Join-Path -Path $Path -ChildPath $File
        $NewFile  = Join-Path -Path $Path -ChildPath $Filename
        Get-Content -Path $FilePath | Out-File -Encoding $Encoding $NewFile
        Write-Log -Type "DEBUG" -Object "$NewFile"
        $Count += 1
      }
      if ($Count -gt 0) {
        $Output = $true
      }
      Write-Log -Type "CHECK" -Object "$Count files were converted to $Encoding"
    } catch {
      if ($Error[0].Exception) {
        Write-Log -Type "ERROR" -Object "$($Error[0].Exception)"
      } else {
        Write-Log -Type "ERROR" -Object "An unknown error occurred"
      }
    }
    return $Output
  }
}
