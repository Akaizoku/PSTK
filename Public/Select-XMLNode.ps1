function Select-XMLNode {
  [CmdletBinding()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "XML content"
    )]
    [ValidateNotNullOrEmpty()]
    [System.XML.XMLDocument]
    $XML,
    [Parameter (
      Position    = 2,
      Mandatory   = $true,
      HelpMessage = "XPath corresponding to the node"
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $XPath,
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Namespace"
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $Namespace = $XML.DocumentElement.NamespaceURI
  )
  Begin {
    # Get global preference variables
    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
  }
  Process {
    # Variables
    $Delimiter          = "/"
    $Alias              = "x"
    $SpecialCharacters  = [RegEx]::New('^[/.@]*')
    if ($XPath -match $SpecialCharacters) {
      $Prefix = $Matches[0]
      $XPath  = $XPath -replace $SpecialCharacters, ''
    }
    # Get namespace
    $NamespaceManager = New-Object -TypeName "Xml.XmlNamespaceManager" -ArgumentList $XML.NameTable
    $NamespaceManager.AddNamespace($Alias, $Namespace)
    # Split XPath to identify nodes
    $Nodes = $XPath.Split($Delimiter)
    $PrefixedNodes = New-Object -TypeName "System.Collections.ArrayList"
    # Prefix nodes with namespace (alias)
    foreach($Node in $Nodes) {
      if ($Node) {
        [Void]$PrefixedNodes.Add("${Alias}:${Node}")
      }
    }
    # Join prefixed-nodes to create new XPath with namespace
    $XPathWithNamespace = $PrefixedNodes -join $Delimiter
    # Check XPath prefix
    if ($Prefix) {
      $XPathWithNamespace = $Prefix + "" + $XPathWithNamespace
    }
    # Select and return nodes
    $SelectedNodes = $XML.SelectNodes($XPathWithNamespace, $NamespaceManager)
    return $SelectedNodes
  }
}
