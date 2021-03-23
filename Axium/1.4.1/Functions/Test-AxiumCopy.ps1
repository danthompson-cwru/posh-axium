function Test-AxiumCopy {
    <#
        .SYNOPSIS
            Tests if a given folder contains an installation of axiUm.

        .DESCRIPTION
            Tests if a given folder contains an installation of axiUm.
            
            By default, this will just look for a copy of axiUm Workstation (and not PowerAdmin) itself.

            Aliases: tac

        .INPUTS
            System.String

        .OUTPUTS
            System.Boolean

        .EXAMPLE
            'C:\axiUm' | Test-AxiumCopy

            Tests to see if there is a copy of axiUm in "C:\axiUm". This outpts $True even if this folder does not
            contain PowerAdmin.
        .EXAMPLE
            'C:\axiUm' | Test-AxiumCopy -IncludePowerAdmin

            Tests to see if there is a copy of axiUm in "C:\axiUm" that includes PowerAdmin.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]

    param(
        # The path to the folder that you want to check for a copy of axiUm Workstation.
        #
        # Aliases: p
        [Parameter(
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Mandatory = $True
        )]
        [Alias('p')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        # Set this to include files for PowerAdmin.
        #
        # Aliases: ipa, IncludePA
        [Alias('ipa', 'IncludePA')]
        [switch]$IncludePowerAdmin,

        # Set this to exclude files for axiUm Workstation itself.
        #
        # Aliases: ew, ExcludeWS
        [Alias('ew', 'ExcludeWS')]
        [switch]$ExcludeWorkstation
    )

    begin {
        # Store the names of Workstation files.
        $WSFileNames = @('axiUm.ini', 'axiUmDB.ini', 'axiUm.exe.Config', 'axiUm.exe')

        # Store the names of PowerAdmin files.
        $PAFileNames = @('PowerAdm.exe', 'PowerAdm.ini')

        # Calculate the names of all required files.

        $ReqFileNames = @()

        if ($IncludePowerAdmin.IsPresent) {
            Write-Verbose -Message 'Including PowerAdmin in check.'
            $ReqFileNames += $PAFileNames
        } else {
            Write-Verbose -Message 'Not including PowerAdmin in check.'
        }

        if ($ExcludeWorkstation.IsPresent) {
            Write-Verbose -Message 'Not including workstation in check.'
        } else {
            Write-Verbose -Message 'Including workstation in check.'
            $ReqFileNames += $WSFileNames
        }
    }

    process {
        $Output = $Path | Test-Path -PathType 'Container'
        if ($Output) {
            # $Path exists and is a container, so we can check to see if it contains the proper files.

            Write-Verbose -Message """$Path"" is a container."

            $ReqFileNames | ForEach-Object {
                $ReqFilePath = $Path | Join-Path -ChildPath $_
                $ReqFileExists = $ReqFilePath | Test-Path -PathType 'Leaf'

                $Output = $Output -and $ReqFileExists

                if ($ReqFileExists) {
                    Write-Verbose -Message """$ReqFilePath"" exists."
                } else {
                    Write-Verbose -Message """$ReqFilePath"" doesn't exist."
                }
            }
        } else {
            # $Path doesn't exist, or is not a container.

            Write-Verbose -Message """$Path"" is not a container."
        }

        $Output
    }
}

New-Alias -Name 'tac' -Value 'Test-AxiumCopy'
