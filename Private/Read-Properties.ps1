function Read-Properties {
	<#
		.SYNOPSIS
		Parse properties file

		.DESCRIPTION
		Parse properties file to generate configuration variables

		.PARAMETER Path
		[String] The patch parameter corresponds to the path to the property file to read.

		.PARAMETER Section
		[Switch] The Section parameter indicates if properties should be grouped depending on existing sections in the file.

        .PARAMETER Metadata
        [Switch] The metadata parameter indicates that the value (data) as well as the description and section (metadata) should be returned. This does not apply is the section switch is enabled.

		.OUTPUTS
		[System.Collections.Specialized.OrderedDictionary] Read-Properties returns an ordered hash table containing the content of the property file.

		.EXAMPLE
		Read-Properties -Path ".\conf\default.ini" -Section

		In this example, Read-Properties will parse the default.ini file contained in the .\conf directory and generate an ordered hashtable containing the key-values pairs.

		.NOTES
		File name:      Read-Properties.ps1
		Author:         Florian Carrier
		Creation date:	2018-11-27
		Last modified:	2024-09-13
	#>
	[CmdletBinding ()]
	Param (
		[Parameter (
			Position    = 1,
			Mandatory   = $true,
			HelpMessage = "Path to the property file"
		)]
		[ValidateNotNullOrEmpty ()]
		[String]
		$Path,
		[Parameter (
			Position    = 3,
			Mandatory   = $false,
			HelpMessage = "Define if section headers should be used to group properties or be ignored"
			)]
		[Switch]
		$Section,
		[Parameter (
			HelpMessage = "Switch to retrieve metadata about properties"
			)]
		[Switch]
		$Metadata
	)
	Begin {
		# Get global preference variables
		Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
	}
	Process {
		# Check that the file exists
		if (Test-Path -Path $Path) {
            # Load property file content
			$Content        = Get-Content -Path $Path
            # Instantiate variables
            $Properties     = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
            $Sections       = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
            $Errors         = 0
			$LineNumber     = 0
			$Header         = $null
			$PreviousLine   = $null
			# Read content line by line
			foreach ($Line in $Content) {
				$LineNumber += 1
				# If properties have to be grouped by section
				if ($Section) {
					# If end of file and section is open
					if ($LineNumber -eq $Content.Count -And $Header) {
						if ($Line[0] -ne "#" -And $Line[0] -ne ";" -And $Line -ne "") {
							$Property = Read-Property -Property $Line
							if ($Property.Count -gt 0) {
								$Sections.Add($Property.Key, $Property.Value)
							} else {
								Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $Path"
							}
						}
						$Clone = Copy-OrderedHashtable -Hashtable $Sections -Deep
						$Properties.Add($Header, $Clone)
					} elseif ($Line[0] -eq "[") {
						# If previous section exists add it to the property list
						if ($Header) {
							$Clone = Copy-OrderedHashtable -Hashtable $Sections -Deep
							$Properties.Add($Header, $Clone)
						}
						# Create new property group
						$Header = $Line.Substring(1, $Line.Length - 2)
						$Sections.Clear()
					} elseif ($Header -And $Line[0] -ne "#" -And $Line[0] -ne ";" -And $Line -ne "") {
						$Property = Read-Property -Property $Line
						if ($Property.Count -gt 0) {
							$Sections.Add($Property.Key, $Property.Value)
						} else {
							Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $Path"
						}
					}
				} else {
					# Parse rows
					if ($null -eq $Line -or $Line -eq "") {
						# Ignore empty lines
					} elseif ($Line[0] -eq "[") {
						# Parse sections
						$Header = $Line.Substring(1, $Line.Length - 2).Trim()
					} elseif ($Line[0] -eq "#" -Or $Line[0] -eq ";" ) {
						# Parse comments
						$PreviousLine = $Line.Substring(1, $Line.Length - 1).Trim()
					} else {
						# Parse properties
						$Property = Read-Property -Property $Line
						if ($Property.Count -gt 0) {
                            if ($Metadata -eq $true) {
                                # Create custom object including metadata
                                $Value = [Ordered]@{
                                    "Value"				 = $Property.Value
                                    "Description"	 = $PreviousLine
                                    "Section"			 = $Header
                                }
                            } else {
                                # Return raw value
                                $Value = $Property.Value
                            }
							try {
								# Assign property
								$Properties.Add($Property.Key, $Value)
							} catch {
								Write-Log -Type "WARN" -Object "Two distinct definitions of the property $($Property.Key) have been found in the configuration file"
								$Errors += 1
							}
							# Reset metadata
							$PreviousLine = $null
						} else {
							Write-Log -Type "WARN" -Message "Unable to process line $LineNumber from $Path"
						}
					}
				}
			}
		} else {
			# Alert that configuration file does not exist at specified location
			Write-Log -Type "ERROR" -Message "Path not found $Path" -ExitCode 1
		}
		if ($Errors -gt 0) {
			Write-Log -Type "ERROR" -Object "Unable to proceed. Resolve the issues in $Path" -ExitCode 1
		}
	}
	End {
		# Return list of properties
		return $Properties
	}
}
