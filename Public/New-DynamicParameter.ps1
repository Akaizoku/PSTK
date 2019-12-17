# ------------------------------------------------------------------------------
# Dynamic parameters
# ------------------------------------------------------------------------------
function New-DynamicParameter {
  <#
    .SYNOPSIS
    Creates dynamic parameter

    .DESCRIPTION
    Wrapper function to easily create dynamic parameters.

    .PARAMETER Name
    The name parameter corresponds to the name of the dynamic parameter to defi-
    ne.

    .PARAMETER Type
    The type parameter corresponds to the type of the dynamic parameter to defi-
    ne. The default value is [System.String].

    .PARAMETER Position
    The position parameter corresponds to the position to give to the dynamic
    parameter to define.

    .PARAMETER HelpMessage
    The help message parameter corresponds to the description to give to the dy-
    namic parameter to define.

    .PARAMETER ValidateSet
    The validate set parameter corresponds to the set of values against which to
    validate the dynamic parameter values.

    .PARAMETER Alias
    The alias parameter corresponds to the list of aliases to assig to the dyna-
    mic parameter.

    .PARAMETER Mandatory
    The mandatory switch defines if the parameter is required.

    .OUTPUTS
    [System.Management.Automation.RuntimeDefinedParameterDictionary]
    New-DynamicParameter returns a parameter dictionnary containing the dynamic
    parameter.

    .EXAMPLE
    New-DynamicParameter -Name "Source" -Type String -Position 2 -Mandatory -Alias "Origin"

    In this example, New-DynamicParameter will create a parameter called
    "Source", that has a type of [System.String], will be assigned to the second
    position, be mandatory, and have an alias of "Origin".

    .NOTES
    TODO expand validation rules definition to allow broader cases.
  #>
  [CmdletBinding ()]
  Param (
    [Parameter (
      Position    = 1,
      Mandatory   = $true,
      HelpMessage = "Name of the dynamic parameter"
    )]
    [ValidateNotNullOrEmpty ()]
    [String]
    $Name,
    [Parameter (
      Position    = 2,
      Mandatory   = $false,
      HelpMessage = "Type of the dynamic parameter"
    )]
    [ValidateNotNullOrEmpty ()]
    [System.Type]
    $Type = [String],
    [Parameter (
      Position    = 3,
      Mandatory   = $false,
      HelpMessage = "Position of the dynamic parameter"
    )]
    [Int]
    $Position,
    [Parameter (
      Position    = 4,
      Mandatory   = $false,
      HelpMessage = "Description of the dynamic parameter"
    )]
    [String]
    $HelpMessage,
    [Parameter (
      Position    = 5,
      Mandatory   = $false,
      HelpMessage = "Define if the dynamic parameter is required"
    )]
    [Switch]
    $Mandatory,
    [Parameter (
      Position    = 6,
      Mandatory   = $false,
      HelpMessage = "Validation rules of the dynamic parameter"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $ValidateSet,
    [Parameter (
      Position    = 7,
      Mandatory   = $false,
      HelpMessage = "Alias(es) of the dynamic parameter"
    )]
    [ValidateNotNullOrEmpty ()]
    [String[]]
    $Alias = @()
  )
  Process {
    # Define parameter attribute
    $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
    # Set parameter attribute values
    if ($Position) {
      $ParameterAttribute.Position    = $Position
    }
    if ($Mandatory) {
      $ParameterAttribute.Mandatory   = $true
    }
    if ($HelpMessage) {
      $ParameterAttribute.HelpMessage = $HelpMessage
    }
    # Define attribute collection to store attributes
    $ParameterAttributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
    $ParameterAttributeCollection.Add($ParameterAttribute)
    # Define validation rules
    if ($ValidateSet) {
      $ValidationAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList $ValidateSet
      $ParameterAttributeCollection.Add($ValidationAttribute)
    }
    # Define alias
    if ($Alias) {
      $AliasAttribute = New-Object -TypeName System.Management.Automation.AliasAttribute -ArgumentList $Alias
      $ParameterAttributeCollection.Add($AliasAttribute)
    }
    # Define dynamic parameter
    $RuntimeParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($Name, $Type, $ParameterAttributeCollection)
    # Define parameter dictionnary
    $ParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
    $ParameterDictionary.Add($Name, $RuntimeParameter)
    return $ParameterDictionary
  }
}
