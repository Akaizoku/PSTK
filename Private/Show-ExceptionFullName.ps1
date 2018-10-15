# ------------------------------------------------------------------------------
# Identify exception name
# ------------------------------------------------------------------------------
function Show-ExceptionFullName {
  <#
    .SYNOPSIS
    Show full exception name

    .DESCRIPTION
    Show full exception name to facilitate error handling (try...catch)

    .PARAMETER Errors
    The errors parameters corresponds to the errors thrown.

    .INPUTS
    None.

    .OUTPUTS
    [System.String] Show-ExceptionFullName returns the full name of the except-
    ion as a string.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Errors to analyse"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Collections.ArrayList]
    $Errors
  )
  return $Errors.Exception.GetType().FullName
}
