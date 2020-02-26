function Compare-Version {
  <#
    .SYNOPSIS
    Compare version numbers

    .DESCRIPTION
    Compare the specified version numbers

    .PARAMETER Version
    The version parameter corresponds to the version number to test.

    .PARAMETER Operator
    The operator parameter corresponds to the type of comparison to operate.

    .PARAMETER Reference
    The reference parameter corresponds to the reference version number to compare the specified version against.

    .PARAMETER Format
    The format parameter corresponds to the format of the numbering.

    .NOTES
    File name:      Compare-Version.ps1
    Author:         Florian Carrier
    Creation date:  19/10/2019
    Last modified:  10/02/2020
    WARNING         In case of modified formatting, Compare-Version only checks the semantic versionned part
  #>
  [CmdletBinding (
    SupportsShouldProcess = $true
  )]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Version number to test"
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $Version,
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Comparison operator"
    )]
    [ValidateSet (
      "eq", # Equals
      "ne", # Not equals
      "gt", # Greater than
      "ge", # Greater than or equal
      "lt", # Less than
      "le"  # Less than or equal
    )]
    [String]
    $Operator,
    [Parameter (
      Position    = 3,
      Mandatory   = $true,
      HelpMessage = "Reference version number to check against"
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $Reference,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Numbering format"
    )]
    [ValidateSet (
      "modified",
      "semantic"
    )]
    [String]
    $Format = "semantic"
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    switch ($Format) {
      "semantic" {
        # Prepare version numbers for comparison
        try {
          $VersionNumber = [System.Version]::Parse($Version)
        } catch [FormatException] {
          Write-Log -Type "ERROR" -Object "The version number ""$Version"" does not match $Format numbering"
          return $false
        }
        try {
          $ReferenceNumber = [System.Version]::Parse($Reference)
        } catch [FormatException] {
          Write-Log -Type "ERROR" -Object "The version number ""$Reference"" does not match $Format numbering"
          return $false
        }
        # Build comparison command
        $Command = """$VersionNumber"" -$Operator ""$ReferenceNumber"""
        Write-Log -Type "DEBUG" -Object $Command
        # Execute comparison
        $Result = Invoke-Expression -Command $Command
        # Return comparison result
        return $Result
      }
      "modified" {
        if ($Operator -in ("eq", "ne")) {
          # Compare strings as-is
          $VersionNumber    = $Version
          $ReferenceNumber  = $Reference
        } else {
          # Parse version numbers
          $SemanticVersion = Select-String -InputObject $Version -Pattern '(\d+.\d+.\d+)(?=\D*)' | ForEach-Object { $_.Matches.Value }
          try {
            $VersionNumber = [System.Version]::Parse($SemanticVersion)
          } catch [FormatException] {
            Write-Log -Type "ERROR" -Object "The version number ""$Version"" does not match semantic numbering"
            return $false
          }
          $SemanticReference = Select-String -InputObject $Reference -Pattern '(\d+.\d+.\d+)(?=\D*)' | ForEach-Object { $_.Matches.Value }
          try {
            $ReferenceNumber = [System.Version]::Parse($SemanticReference)
          } catch [FormatException] {
            Write-Log -Type "ERROR" -Object "The version number ""$Reference"" does not match semantic numbering"
            return $false
          }
        }
        # Build comparison command
        $Command = """$VersionNumber"" -$Operator ""$ReferenceNumber"""
        Write-Log -Type "DEBUG" -Object $Command
        # Execute comparison
        $Result = Invoke-Expression -Command $Command
        # Return comparison result
        return $Result
      }
      default {
        Write-Log -Type "ERROR" -Object "The $Format versionning format is not yet supported"
        return $false
      }
    }
  }
}
