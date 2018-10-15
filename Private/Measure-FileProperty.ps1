# ------------------------------------------------------------------------------
# Measure properties in file list
# ------------------------------------------------------------------------------
function Measure-FileProperty {
  <#
    .SYNOPSIS
    Measure specified property of a list of files

    .DESCRIPTION
    Measure a specified property from a list of files.

    .PARAMETER Files
    The files parameter coresponds to the list of files to analyse.

    .PARAMETER Property
    The property parameter corresponds to the property to measure.
    The available properties are:
    - MaximumLength
    - MinimumValue

    .EXAMPLE
    Measure-FileProperty -Files $Files -Property "MaximumLength"

    In this example, Measure-FileProperty returns the maximum length of file
    names in a specified list of files.

    .EXAMPLE
    Measure-FileProperty -Files $Files -Property "MinimumValue"

    In this example, Measure-FileProperty returns the minimum numeric value in a
     specified list of numbered files.
  #>
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of Files to parse"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("List")]
    $Files,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Property to measure"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Property
  )
  Process {
    foreach ($File in $Files) {
      switch ($Property) {
        # Maximum length of file names
        "MaximumLength" {
          $MaximumLength = 0
          [Int]$Length = $File.BaseName | Measure-Object -Character | Select-Object -ExpandProperty "Characters"
          if ($Length -gt $MaximumLength) {
            $MaximumLength = $Length
          }
          return $MaximumLength
          continue
        }
        # Minimum value of numbered file names
        "MinimumValue" {
          $MinimumValue = $null
          try {
            $Filename = $File.BaseName
            $Format = Test-Alphanumeric -Alphanumeric $Filename
            if ($Format -ne 0) {
              if ($Format -eq 1) {
                [Long]$Integer = $Filename
              } else {
                [Long]$Integer = $Filename -replace ('\D+', "")
              }
              if ($MinimumValue -eq $null -Or $Integer -lt $MinimumValue) {
                $MinimumValue = $Integer
              }
            } else {
              Write-Log -Type "ERROR" -Message "The file ""$Filename"" does not have a correct format."
              Stop-Script 1
            }
          } catch [System.Management.Automation.RuntimeException] {
            Write-Log -Type "ERROR" -Message "The numeric value is too large (greater than $([Long]::MaxValue))."
          }
          return $MinimumValue
          continue
        }
        default {
          Write-Log -Type "ERROR" -Message "Measure-FileProperty: $Property property is not unknown."
          Stop-Script 1
        }
      }
    }
  }
}
