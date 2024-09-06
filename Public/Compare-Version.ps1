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
    Creation date:  2019-10-19
    Last modified:  2024-09-06
    WARNING         In case of modified formatting, Compare-Version only checks the semantic versionned part

    .LINK
    https://semver.org/

    .LINK
    https://learn.microsoft.com/en-us/dotnet/api/system.version

    .LINK
    https://learn.microsoft.com/en-us/dotnet/api/system.version.compareto
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
    [System.String]
    $Version,
    [Parameter (
      Position    = 2,
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
    [System.String]
    $Operator,
    [Parameter (
      Position    = 3,
      Mandatory   = $true,
      HelpMessage = "Reference version number to check against"
    )]
    [ValidateNotNullOrEmpty()]
    [System.String]
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
    [System.String]
    $Format = "semantic"
  )
  Begin {
    # Get global preference vrariables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    switch ($Format) {
      "semantic" {
        Write-Log -Type "DEBUG" -Message "Semantic version comparison"
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
        # Compare versions
        $Compare = $VersionNumber.CompareTo($ReferenceNumber)
        if (($Operator -in ("eq", "ge", "le")) -And ($Compare -eq 0)) {
            return $True
        } elseif (($Operator -in ("ne", "gt")) -And ($Compare -eq 1)) {
            return $True
        } elseif (($Operator -in ("ne", "lt")) -And ($Compare -eq -1)) {
            return $True
        } else {
            return $False
        }
      }
      "modified" {
        Write-Log -Type "DEBUG" -Message "String version comparison"
        if ($Operator -in ("eq", "ne")) {
          # Compare strings as-is
          $VersionNumber    = $Version
          $ReferenceNumber  = $Reference
        } else {
          # Parse version numbers
          $SemanticVersion = Select-String -InputObject $Version -Pattern '(\d+.\d+.\d+)(?=\D*)' | ForEach-Object { $PSItem.Matches.Value }
          try {
            $VersionNumber = [System.Version]::Parse($SemanticVersion)
          } catch [FormatException] {
            Write-Log -Type "ERROR" -Object "The version number ""$Version"" does not match semantic numbering"
            return $false
          }
          $SemanticReference = Select-String -InputObject $Reference -Pattern '(\d+.\d+.\d+)(?=\D*)' | ForEach-Object { $PSItem.Matches.Value }
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
