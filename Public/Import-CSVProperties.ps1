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
    $Delimiter = ',',
    [Parameter (
      Position          = 4,
      Mandatory         = $false,
      HelpMessage       = "Specifies the value to set for empty columns. The default is a null value (NULL)."
    )]
    [String]
    $NullValue = $null,
    [Parameter (
      HelpMessage       = "Specifies that the key will not be added to the corresponding list of properties"
    )]
    [Switch]
    $IgnoreKey
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    # Instantiate variables
    $Properties = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
  }
  Process {
    # Import values from CSV file
    Write-Log -Type "DEBUG" -Object $Path
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
        # If key has to be ignored
        if ($IgnoreKey) {
          # If the property is not the specified key
          if ($Header -ne $Key) {
            # Handle null or empty values
            if ([String]::IsNullOrEmpty($Row.$Header)) {
              $Value = $NullValue
            } else {
              $Value = $Row.$Header
            }
            # Add property to list
            $RowProperties.Add($Header, $Value)
          }
        } else {
          # Handle null or empty values
          if ([String]::IsNullOrEmpty($Row.$Header)) {
            $Value = $NullValue
          } else {
            $Value = $Row.$Header
          }
          # Add property to list
          $RowProperties.Add($Header, $Value)
        }
      }
      # Add row to the property list
      $Properties.Add($Row.$Key, $RowProperties)
    }
    # Return properties hashtable
    return $Properties
  }
}
