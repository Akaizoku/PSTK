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
        Last modified:  2021-07-08
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
        [Alias ("Package")]
        [System.String]
        $Path,
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
        $PackageName = Split-Path   -Path $Path -Leaf
        $PackagePath = Resolve-Path -Path $Path
        if ($PSBoundParameters.ContainsKey('Destination')) {
            if (Test-Path -Path $Destination -PathType "Leaf") {
                $Extension = [System.IO.Path]::GetExtension($Destination)
                if ($Extension -ne ".zip") {
                    Write-Log -Type "WARN" -Message "$Extension is not a supported archive file format. .zip is the only supported archive file format."
                    $Destination = $Destination.Replace($Extension, ".zip")
                }
                $CompressedPackage  = $Destination
                $Destination        = Split-Path -Path $Destination -Parent
                $StagingPath        = Join-Path -Path $Destination  -ChildPath $PackageName
            } else {
                $StagingPath        = Join-Path -Path $Destination -ChildPath $PackageName
                $CompressedPackage  = [System.String]::Concat($StagingPath, ".zip")
            }
        } else {
            $Destination        = Split-Path -Path $PackagePath -Parent
            $StagingPath        = Join-Path -Path $Destination -ChildPath $PackageName
            $CompressedPackage  = [System.String]::Concat($PackagePath, ".zip")
        }
    }
    Process {
        Write-Log -Type "CHECK" -Message "Creating self-contained $PackageName package"
        # Stage package
        if (Test-Path -Path $PackagePath) {
            if (Test-Path -Path $StagingPath) {
                Write-Log -Type "WARN" -Message "Removing existing staging directory $StagingPath"
                Remove-Object -Path $StagingPath
            }
            Copy-Object -Path $PackagePath -Destination $Destination -Exclude $Ignore -Force
        } else {
            Write-Log -Type "ERROR" -Message "Path not found $PackagePath" -ErrorCode 1
        }
        # # List all required modules
        foreach ($Module in $Modules) {
            $ModuleDirectory = Join-Path -Path $StagingPath -ChildPath "lib"
            Write-Log -Type "INFO" -Message "Retrieving module $Module"
            $Load = $false
            :loop foreach ($Repository in ($env:PSModulePath -split ";")) {
                Write-Log -Type "DEBUG" -Message $Repository
                $ModulePath = Join-Path -Path $Repository -ChildPath $Module
                Write-Log -Type "DEBUG" -Message $ModulePath
                if (Test-Path -Path $ModulePath) {
                    Copy-Object -Path $ModulePath -Destination $ModuleDirectory -Exclude $Ignore -Force
                    $Load = $true
                    break loop
                }
            }
            if ($Load -eq $false) {
                Write-Log -Type "WARN" -Message "module $Module could not be found"
            }
        }
        # # Compress package
        if (Test-Path -Path $StagingPath) {
            Write-Log -Type "INFO" -Message "Compressing package"
            Write-Log -Type "DEBUG" -Message $CompressedPackage
            if (Test-Path -Path $CompressedPackage) {
                Write-Log -Type "WARN" -Message "Overwriting existing package"
            }
            Compress-Archive -Path "$StagingPath\*" -DestinationPath $CompressedPackage -CompressionLevel "Fastest" -Force
        } else {
            Write-Log -Type "ERROR" -Message "Path not found $StagingPath"
            Write-Log -Type "ERROR" -Message "Script packaging failed" -ErrorCode 1
        }
        # Delete staging package
        Write-Log -Type "INFO"  -Message "Deleting staged package folder"
        Write-Log -Type "DEBUG" -Message $StagingPath
        # Remove-Object -Path $StagingPath
        # # End
        Write-Log -Type "CHECK" -Message "$PackageName self-contained package complete"
    }
}