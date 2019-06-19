function Import-CSVProperties {
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position          = 1,
      Mandatory         = $true,
      ValueFromPipeline = $true,
      HelpMessage       = "Path to the CSV file"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position          = 2,
      Mandatory         = $false,
      HelpMessage       = "Name of the property to use as key"
    )]
    [String]
    $Key,
    [Parameter (
      Position          = 3,
      Mandatory         = $false,
      HelpMessage       = "Specifies the delimiter that separates the property values in the CSV file. The default is a comma (,)."
    )]
    [String]
    $Delimiter = ','
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Instantiate variables
    $Properties = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
  }
  Process {
    # Import values from CSV file
    $CSVProperties = Import-CSV -Path $Path -Delimiter $Delimiter
    # Grab list of headers
    $Headers = ($CSVProperties | Get-Member -MemberType "NoteProperty").Name
    # Check key parameter
    if ($PSBoundParameters.ContainsKey('Key')) {
      if ($Headers -NotContains $Key) {
        Write-Log -Type "ERROR" -Object "$Key property was not found in $Path" -ErrorCode 1
      }
    }
    # Loop through CSV rows
    foreach ($Row in $CSVProperties) {
      $RowProperties = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
      # Loop through each property
      foreach ($Header in $Headers) {
        # If the property is not the specified key
        if ($Header -ne $Key) {
          # Add property to list
          $RowProperties.Add($Header, $Row.$Header)
        }
      }
      # Add row to the property list
      $Properties.Add($Row.$Key, $RowProperties)
    }
    # Return properties hashtable
    return $Properties
  }
}
