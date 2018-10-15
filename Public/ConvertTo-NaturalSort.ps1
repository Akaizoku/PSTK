# ------------------------------------------------------------------------------
# Sort function
# ------------------------------------------------------------------------------
function ConvertTo-NaturalSort {
  <#
    .SYNOPSIS
    Sort a list in the natural order

    .DESCRIPTION
    Sort a list of files by their name in the natural order. Sort can be ascend-
    ing (default) or descending.

    .PARAMETER Files
    The files parameters corresponds to the list of files to be sorted.

    .PARAMETER Order
    The order parameter corresponds to the order of the sort. Two values are
    possible:
    - Ascending (default)
    - Descending

    .INPUTS
    None.

    .OUTPUTS
    [System.Array] ConvertTo-NaturalSort returns a sorted array.

    .EXAMPLE
    ConvertTo-NaturalSort -Array @("a10", "b1", "a1")

    .EXAMPLE
    ConvertTo-NaturalSort -Array @("a10", "b1", "a1") -Order "Descending"

    .NOTES
    TODO Make generic to allow sorting simple string arrays
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "List of files to sort"
    )]
    [ValidateNotNullOrEmpty ()]
    [Alias ("List")]
    $Files,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Specifies the order of the sort"
    )]
    [ValidateSet (
      "A", "Asc", "Ascending",
      "D", "Dsc", "Desc", "Descending"
    )]
    [String]
    $Order = "Ascending"
  )
  $Ascending      = @("A", "Asc", "Ascending")
  $Descending     = @("D", "Dsc", "Desc", "Descending")
  $MaximumLength  = Measure-FileProperty -Files $Files -Property "MaximumLength"
  $RegEx = { [RegEx]::Replace($_.BaseName, '\d+', { $args[0].Value.PadLeft($MaximumLength) }) }
  if ($Descending.Contains($Order)) {
    $SortedFiles = $Files | Sort-Object $RegEx -Descending
  } elseif ($Ascending.Contains($Order)) {
    $SortedFiles = $Files | Sort-Object $RegEx
  }
  return $SortedFiles
}
