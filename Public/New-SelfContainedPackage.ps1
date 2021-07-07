function New-SelfContainedPackage {
    <#
        .SYNOPSIS
        Create self-contained package

        .DESCRIPTION
        Bundle package with embedded dependencies

        .PARAMETER Package
        The package parameter corresponds to the path to the package to bundle.

        .NOTES
        File name:      New-SelfContainedPackage.ps1
        Author:         Florian Carrier
        Creation date:  2021-07-06
        Last modified:  2021-07-06
    #>
    [CmdletBinding (
        SupportsShouldProcess = $true
    )]
    Param (
        [Parameter (
            Position    = 1,
            Mandatory   = $true,
            HelpMessage = "Path to the package to bundle"
        )]
        [ValidateNotNullOrEmpty ()]
        [Alias ("Path")]
        [System.String]
        $Package,
        [Parameter (
            Position    = 2,
            Mandatory   = $false,
            HelpMessage = "Path to the location where to create the package"
        )]
        [ValidateNotNullOrEmpty ()]
        [System.String]
        $Destination,
        [Parameter (
            Position    = 3,
            Mandatory   = $false,
            HelpMessage = "List of modules to add to bundle"
        )]
        [ValidateNotNullOrEmpty ()]
        [System.String[]]
        $Modules,
        [Parameter (
            Position    = 4,
            Mandatory   = $false,
            HelpMessage = "List of files or directories to ignore"
        )]
        [ValidateNotNullOrEmpty ()]
        [System.String[]]
        $Ignore
    )
    Begin {
        # Get global preference vrariables
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        # Variables
        $Properties = New-Object -TypeName "System.Collections.Specialized.OrderedDictionary"
        $Properties.PackageName = Split-Path -Path $Package -Leaf
        $Properties.PackagePath = Resolve-Path -Path $Package
        if ($PSBoundParameters.ContainsKey('Destination')) {
            if (Test-Path -Path $Destination -PathType "Leaf") {
                $Extension = [System.IO.Path]::GetExtension($Destination)
                if ($Extension -ne ".zip") {
                    Write-Log -Type "WARN" -Message "$Extension is not a supported archive file format. .zip is the only supported archive file format."
                    $Destination = $Destination.Replace($Extension, ".zip")
                }
                $Properties.StagingPath        = Join-Path -Path (Split-Path -Path $Destination -Parent) -ChildPath $Properties.PackageName
                $Properties.CompressedPackage  = $Destination
            } else {
                $Properties.StagingPath        = Join-Path -Path $Destination -ChildPath $Properties.PackageName
                $Properties.CompressedPackage  = [System.String]::Concat($Properties.StagingPath, ".zip")
            }
        } else {
            $Properties.StagingPath        = Join-Path -Path (Split-Path -Path $Properties.PackagePath -Parent) -ChildPath $Properties.PackageName
            $Properties.CompressedPackage  = [System.String]::Concat($Properties.PackagePath, ".zip")
        }
        # Debug
        foreach ($Property in $Properties.GetEnumerator()) {
            Write-Log -Type "DEBUG" -Message "$($Property.Name)=$($Property.Value)"
        }
    }
    Process {
        Write-Log -Type "CHECK" -Message "Creating self-contained $($Properties.PackageName) package"
        # Stage package
        if (Test-Path -Path $Properties.PackagePath) {
            if (Test-Path -Path $Properties.StagingPath) {
                Write-Log -Type "WARN" -Message "Overwriting existing package folder"
                Remove-Object -Path $Properties.StagingPath
            }
            Copy-Item -Path "$($Properties.PackagePath)\*" -Destination $Properties.StagingPath -Recurse
            Write-Log -Type "DEBUG" -Message $Properties.StagingPath
        } else {
            Write-Log -Type "ERROR" -Message "Path not found $Properties.PackagePath" -ErrorCode 1
        }
        # List all required modules
        foreach ($Module in $Modules) {
            Write-Log -Type "INFO" -Message "Retrieving module $Module"
            $Load = $false
            :loop foreach ($Repository in ($env:PSModulePath -split ";")) {
                Write-Log -Type "DEBUG" -Message $Repository
                $ModulePath = Join-Path -Path $Repository -ChildPath $Module
                Write-Log -Type "DEBUG" -Message $ModulePath
                if (Test-Path -Path $ModulePath) {
                    $ModuleDirectory = Join-Path -Path $Properties.StagingPath -ChildPath "lib\$Module"
                    Copy-Item -Path $ModulePath -Destination $ModuleDirectory -Recurse -Exclude $Ignore
                    Get-Object -Path $ModuleDirectory
                    $Load = $true
                    break loop
                }
            }
            if ($Load -eq $false) {
                Write-Log -Type "WARN" -Message "module $Module could not be found"
            }
        }
        # # Compress package
        # if (Test-Path -Path $Properties.StagingPath) {
        #     # Remove unwanted files
        #     if ($PSBoundParameters.ContainsKey('Ignore')) {
        #         Write-Log -Type "INFO" -Message "Removing unwanted files"
        #         foreach ($Filter in $Ignore) {
        #             Remove-Object -Path $Properties.StagingPath -Filter $Filter
        #         }
        #     }
        #     Write-Log -Type "INFO" -Message "Compressing package"
        #     Write-Log -Type "DEBUG" -Message $Properties.CompressedPackage
        #     if (Test-Path -Path $Properties.CompressedPackage) {
        #         Write-Log -Type "WARN" -Message "Overwriting existing package"
        #     }
        #     Compress-Archive -Path "$Properties.StagingPath\*" -DestinationPath $Properties.CompressedPackage -CompressionLevel "Fastest" -Force
        # } else {
        #     Write-Log -Type "ERROR" -Message "Path not found $Properties.StagingPath"
        #     Write-Log -Type "ERROR" -Message "Script packaging failed" -ErrorCode 1
        # }
        # # Delete staging package
        # Write-Log -Type "INFO"  -Message "Deleting staged package folder"
        # Write-Log -Type "DEBUG" -Message $Properties.StagingPath
        # # Remove-Object -Path $Properties.StagingPath
        # # End
        # Write-Log -Type "CHECK" -Message "$($Properties.PackageName) self-contained package complete"
    }
}