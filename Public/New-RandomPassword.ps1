function New-RandomPassword {
    <#
        .SYNOPSIS
        Generate a random password

        .DESCRIPTION
        Create a random string according to specifications

        .PARAMETER Length
        The length parameter corresponds the maximum length of the string to generate.

        .INPUTS
        None. You cannot pipe objects to New-RandomPassword.

        .OUTPUTS
        String. New-RandomPassword returns a string of the length specified.

        .EXAMPLE
        New-RandomPassword -Length 32

        This example returns a random string of 32 characters.

        .EXAMPLE
        New-RandomPassword -MinimumLength 8 -MaximumLength 32

        This example returns a random string between 8 and 32 characters.

        .EXAMPLE
        New-RandomPassword -MinimumLength 8 -MaximumLength 32 -AllowedCharacters "abcdefghijklmnopqrstuvwxyz"

        This example returns a random string between 8 and 32 characters containing only lowercase letters.

        .NOTES
        File name:      New-RandomPassword.ps1
        Author:         Florian Carrier
        Creation date:  2021-06-05
        Last modified:  2021-06-05

        .LINK
        https://www.powershellgallery.com/packages/PSTK
    #>
    [CmdletBinding ()]
    # Inputs
    Param (
        [Parameter (
            Position    = 1,
            Mandatory   = $true,
            HelpMessage = "Maximum length of the string to generate"
        )]
        [ValidateNotNullOrEmpty ()]
        [Alias ("Length")]
        [Int]
        $MaximumLength,
        [Parameter (
            Position    = 2,
            Mandatory   = $false,
            HelpMessage = "Minimum length of the string to generate"
        )]
        [ValidateNotNullOrEmpty ()]
        [Int]
        $MinimumLength,
        [Parameter (
            Position    = 3,
            Mandatory   = $false,
            HelpMessage = "List of allowed characters"
        )]
        [ValidateNotNullOrEmpty ()]
        [String]
        $AllowedCharacters,
        [Parameter (
            Position    = 4,
            Mandatory   = $false,
            HelpMessage = "Validation rule"
        )]
        [ValidateNotNullOrEmpty ()]
        [String]
        $ValidationRule,
        [Parameter (
            HelpMessage = "Switch to exclude numerical characters"
        )]
        [Switch]
        $ExcludeDigits = $false,
        [Parameter (
            HelpMessage = "Switch to exclude special characters"
        )]
        [Switch]
        $ExcludePunctuation = $false
    )
    Begin {
        # Get global preference variables
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        # Define password length
        if ($PSBoundParameters.ContainsKey("MinimumLength")) {
            $PasswordLength = Get-Random -Minimum $MinimumLength -Maximum $MaximumLength
        } else {
            $PasswordLength = $MaximumLength
        }
        Write-Log -Type "DEBUG" -Message "Password length: $PasswordLength"
        # Define list of allowed characters
        if ($PSBoundParameters.ContainsKey("AllowedCharacters")) {
            $CharacterArray = $AllowedCharacters.ToCharArray()
        } else {
            $Lowercase          = "abcdefghijklmnopqrstuvwxyz"
            $Uppercase          = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            # Check for digits
            if ($ExcludeDigits -eq $false) {
                $Digits         = "0123456789"
            }
            # Check for punctuation
            if ($ExcludePunctuation -eq $false) {
                $Punctuation    = "!""#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
            }
            $AllowedCharacters  = [System.String]::Concat($Digits, $Uppercase, $Lowercase, $Punctuation)
            $CharacterArray     = $AllowedCharacters.ToCharArray()
        }
        Write-Log -Type "DEBUG" -Message "Allowed characters: $AllowedCharacters"
        # Define validation rule
        if ($PSBoundParameters.ContainsKey("ValidationRule")) {
            $RegEx = $ValidationRule
        } else {
            # Set default robust validation
            $RegEx = "(?=.*[a-z])(?=.*[A-Z])"
            # Check for digits
            if ($ExcludeDigits -eq $false) {
                $RegEx = [System.String]::Concat($RegEx, "(?=.*\d)")
            }
            # Check for punctuation
            if ($ExcludePunctuation -eq $false) {
                $RegEx = [System.String]::Concat($RegEx, "(?=.*\W)")
            }
        }
        Write-Log -Type "DEBUG" -Message "Validation rule: $RegEx"
        # Check if validation rule can be met by list of allowed characters
        if ($AllowedCharacters -notmatch $RegEx) {
            # Write-Debug -Message $Characters
            # Write-Debug -Message $RegEx
            Write-Log -Type "ERROR" -Message "Validation cannot be achieved with the specified list of allowed characters" -ExitCode 1
        }
    }
    Process {
        # Count number of iterations to reach validation
        $Iteration = 0
        # Generate random array of characters
        do {
            $Iteration++
            $RandomCharacters = $CharacterArray | Get-Random -Count $PasswordLength
            $Password = [System.String]::Concat($RandomCharacters)
            Write-Log -Type "DEBUG" -Message "Iteration #${Iteration}: $Password"
        }
        # Validate format
        until ($Password -match $RegEx)
        # Return random password
        return $Password
    }
}