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
    Last modified:  19/10/2019
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
          $VersionNumber    = [System.Version]::Parse($Version)
        } catch [FormatException] {
          Write-Log -Type "ERROR" -Object "The version number ""$Version"" does not match $Format numbering"
          return $false
        }
        try {
          $ReferenceNumber    = [System.Version]::Parse($Reference)
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
          # Build comparison command
          $Command = """$Version"" -$Operator ""$Reference"""
          Write-Log -Type "DEBUG" -Object $Command
          # Execute comparison
          $Result = Invoke-Expression -Command $Command
          # Return comparison result
          return $Result
        } else {
          # Parse version numbers
          $VersionNumbers   = $Version.Split(".")
          $ReferenceNumbers = $Reference.Split(".")
          # Check comparison operator
          if ($Operator -in ("gt", "ge")) {
            # TODO implement
            # for ($i = 0; $i -lt $Count; $i++) {
            #   if ($i -lt ($Count - 1)) {
            #     $Command = """$($VersionNumbers[$i])"" -ge ""$($ReferenceNumbers[$i])"""
            #   } else {
            #     $Command = """$($VersionNumbers[$i])"" -Operator ""$($ReferenceNumbers[$i])"""
            #   }
            #   Write-Log -Type "DEBUG" -Object $Command
            #   $Result = Invoke-Expression -Command $Command
            #   if ($Result -eq $false) {
            #     return $false
            #   }
            # }
          } elseif ($Operator -in ("lt", "le")) {
            # TODO implement
          }
        }
      }
      default {
        Write-Log -Type "ERROR" -Object "The $Format versionning format is not yet supported"
        return $false
      }
    }
  }
}