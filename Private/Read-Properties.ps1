# ------------------------------------------------------------------------------
# Properties parsing function
# ------------------------------------------------------------------------------
function Read-Properties {
  <#
    .SYNOPSIS
    Parse properties file

    .DESCRIPTION
    Parse properties file to generate configuration variables

    .PARAMETER File
    [String] The File parameter should be the name of the property file.

    .PARAMETER Directory
    [String] The Directory parameter should be the path to the directory containing the
    property file.

    .PARAMETER Section
    [Switch] The Section parameter indicates if properties should be grouped depending on
     existing sections in the file.

    .OUTPUTS
    [System.Collections.Specialized.OrderedDictionary] Read-Properties returns an
    ordered hash table containing the content of the property file.

    .EXAMPLE
    Read-Properties -File "default.ini" -Directory ".\conf" -Section

    In this example, Read-Properties will parse the default.ini file contained
    in the .\conf directory and generate an ordered hashtable containing the
    key-values pairs.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Property file name"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $File,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path to the directory containing the property file"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Directory,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Define if section headers should be used to group properties or be ignored"
      )]
    [Switch]
    $Section
  )
  # Properties variables
  $PropertyFile = Join-Path -Path $Directory -ChildPath $File
  $Properties   = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
  $Sections     = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
  $Header       = $null
  # Check that the file exists
  if (Test-Path -Path $PropertyFile) {
    $FileContent  = Get-Content -Path $PropertyFile
    $LineNumber   = 0
    # Read the property file line by line
    foreach ($Content in $FileContent) {
      $LineNumber += 1
      # If properties have to be grouped by section
      if ($Section) {
        # If end of file and section is open
        if ($LineNumber -eq $FileContent.Count -And $Header) {
          if ($Content[0] -ne "#" -And $Content[0] -ne ";" -And $Content -ne "") {
            $Property = Read-Property -Content $Content
            if ($Property.Count -gt 0) {
              $Sections.Add($Property.Key, $Property.Value)
            } else {
              Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
            }
          }
          $Clone = Copy-OrderedHashtable -Hashtable $Sections -Deep
          $Properties.Add($Header, $Clone)
        } elseif ($Content[0] -eq "[") {
          # If previous section exists add it to the property list
          if ($Header) {
            $Clone = Copy-OrderedHashtable -Hashtable $Sections -Deep
            $Properties.Add($Header, $Clone)
          }
          # Create new property group
          $Header = $Content.Substring(1, $Content.Length - 2)
          $Sections.Clear()
        } elseif ($Header -And $Content[0] -ne "#" -And $Content[0] -ne ";" -And $Content -ne "") {
          $Property = Read-Property -Content $Content
          if ($Property.Count -gt 0) {
            $Sections.Add($Property.Key, $Property.Value)
          } else {
            Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
          }
        }
      } else {
        # Ignore comments, sections, and blank lines
        if ($Content[0] -ne "#" -And $Content[0] -ne ";" -And $Content[0] -ne "[" -And $Content -ne "") {
          $Property = Read-Property -Content $Content
          if ($Property.Count -gt 0) {
            $Properties.Add($Property.Key, $Property.Value)
          } else {
            Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $PropertyFile"
          }
        }
      }
    }
  } else {
    # Alert that configuration file does not exists at specified location
    Write-Log -Type "ERROR" -Message "The $File file cannot be found under $(Resolve-Path $Directory)"
  }
  return $Properties
}
