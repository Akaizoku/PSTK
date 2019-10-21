function Out-Hashtable {
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Hashtable to output"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $Hashtable,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Path"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Path,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Encoding"
    )]
    [ValidateSet ("ASCII", "BigEndianUnicode", "default", "OEM", "String", "Unicode", "Unknown", "UTF7", "UTF8", "UTF8BOM", "UTF8NoBOM", "UTF32")]
    [String]
    $Encoding = "UTF8",
    [Parameter (
      HelpMessage = "Adds the output to the end of an existing file"
    )]
    [Switch]
    $Append,
    [Parameter (
      HelpMessage = "Prompts you for confirmation before running the cmdlet"
    )]
    [Switch]
    $Confirm,
    [Parameter (
      HelpMessage = "Prevents an existing file from being overwritten and displays a message that the file already exists"
    )]
    [Switch]
    $NoClobber,
    [Parameter (
      HelpMessage = "Specifies that the content written to the file does not end with a newline character"
    )]
    [Switch]
    $NoNewLine,
    [Parameter (
      HelpMessage = "Shows what would happen if the cmdlet runs"
    )]
    [Switch]
    $WhatIf
  )
  Begin {
    # Convert UTF8NoBOM to default for Out-File encoding validation
    if ($Encoding -eq "UTF8NoBOM") {
        $Encoding = "default"
    }
  }
  Process {
    # Write hashtable content to file
    $Hashtable.GetEnumerator() | % { "$($_.Name)=$($_.Value)"} | Out-File -FilePath $Path -Encoding $Encoding -Append:$Append -Confirm:$Confirm -NoClobber:$NoClobber -NoNewline:$NoNewLine -WhatIf:$WhatIf
  }
}
