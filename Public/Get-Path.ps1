function Get-Path {
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of paths to resolve"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $PathToResolve,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "Hashtable containing the paths"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.Specialized.OrderedDictionary]
    $Hashtable,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Root for relative path"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Root = $PSScriptRoot
  )
  Process {
    $Paths = Resolve-Array -Array $PathToResolve -Delimiter ","
    foreach ($Path in $Paths) {
      $Pathway = $Hashtable.$Path
      # If path is relative
      if ($Pathway -match "^.*\\") {
        $RelativePath = $Pathway -replace "^.*\\", ""
        $AbsolutePath = Join-Path -Path $Root -ChildPath $RelativePath
        if (Test-Path -Path $AbsolutePath) {
          $Hashtable.$Path = $AbsolutePath
        } else {
          Write-Log -Type "INFO" -Message "Creating directory: $AbsolutePath"
          New-item -ItemType "Directory" -Path "$AbsolutePath" | Out-Null
        }
      } elseif (-Not (Test-Path -Path $Pathway)) {
        Write-Log -Type "ERROR" -Message "Path not found: $Pathway"
      }
    }
    return $Hashtable
  }
}
