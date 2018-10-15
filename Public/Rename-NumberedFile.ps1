# ------------------------------------------------------------------------------
# Increment/decrement numbered files
# ------------------------------------------------------------------------------
function Rename-NumberedFile {
  <#
    .SYNOPSIS
    Renames numbered files by a given offset

    .DESCRIPTION
    Rename numbered files by offsetting their numbers by a specified integer.

    .PARAMETER Path
    The path parameter corresponds to the path to the directory containing the
    files to be renamed.

    .PARAMETER Offset
    The offset parameter corresponds to the integer to add to the file names.

    .PARAMETER Filter
    The filter parameter corresponds to the pattern to apply as a filter to
    select files to rename in the specified directory.
    Default value is "*" (all).

    .PARAMETER Exclude
    The exclude parameter corresponds to the pattern of files to exclude from
    the scope of the procedure.
    Default value is null (none).

    .INPUTS
    None.

    .OUTPUTS
    [Boolean] Rename-NumberedFile returns a boolean depending on the success of
    the operation.

    .EXAMPLE
    Rename-NumberedFile -Path "\folder" -Offset 1

    .EXAMPLE
    Rename-NumberedFile -Path "\folder" -Offset 1 -Filter "*.txt"

    .EXAMPLE
    Rename-NumberedFile -Path "\folder" -Offset 1 -Filter "*.txt" -Exclude "test.txt"

    .NOTES
    Rename-NumberedFile only works with positive numbers to avoid conflicts with
    dashes in filenames.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Path to the files"
    )]
    [ValidateScript ({if (Test-Path -Path $_) {$true} else {Throw "Path does not exist."}})]
    [String]
    $Path,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Offset"
    )]
    [ValidateScript ({if ($_ -eq 0) {Throw "The offset cannot be 0."} else {$true}})]
    [Int]
    $Offset,
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
  $Output   = $false
  $Count    = 0
  $Numeric  = [RegEx]::New('\d+')
  # Get files
  $Files = Get-ChildItem -Path $Path -Filter $Filter -Exclude $Exclude
  $Files = $Files | Where-Object {$_.BaseName -match $Numeric}
  if ($Files.Count -eq 0) {
    if ($Filter -ne "*") {
      Write-Log -Type "ERROR" -Message "No numbered files were found in $Path matching the filter ""$Filter""."
    } elseif ($Exclude) {
      Write-Log -Type "ERROR" -Message "No numbered files corresponding to the criterias were found in $Path."
    } else {
      Write-Log -Type "ERROR" -Message "No numbered files were found in $Path."
    }
    Stop-Script 1
  } else {
    # Check offset sign
    if ($Offset -lt 0) {
      # If negative, check that it will not generate negative values
      $Minimum = Measure-FileProperty -Files $Files -Property "MinimumValue"
      if ($Minimum -eq 0) {
        Write-Log -Type "ERROR" -Message "The minimum value is already 0."
        Stop-Script 1
      } elseif ($Minimum -lt [System.Math]::Abs($Offset)) {
        Write-Log -Type "ERROR" -Message "The offset is greater than the minimum value ($Minimum)."
        Stop-Script 1
      }
    } elseif ($Offset -gt 0) {
      # If positive, sort in descending order
      $Files = ConvertTo-NaturalSort -Files $Files -Order "Descending"
    }
    # Rename files
    foreach ($File in $Files) {
      $Filename     = $File.BaseName
      $Extension    = $File.Extension
      $NewFilename  = Add-Offset -Alphanumeric $Filename -Offset $Offset
      # Check if file name has changed
      if ($NewFilename -eq $Filename) {
        Write-Log -Type "ERROR" -Message "The ""$File"" file could not be renamed."
      } else {
        try {
          Write-Log -Type "INFO" -Message "Renaming ""$($File.Name)"" in ""$NewFilename$Extension""."
          Rename-Item -Path $File -NewName "$NewFilename$Extension"
          $Count += 1
        } catch [System.Management.Automation.PSInvalidOperationException] {
          Write-Log -Type "ERROR" -Message "The ""$File"" file could not be renamed."
        }
      }
    }
    if ($Count -gt 0) {
      Write-Log -Type "CHECK" -Message "$Count files were successfully renamed."
      $Output = $true
    }
  }
  return $Output
}
