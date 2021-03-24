function New-AxiumSubfolder {
    <#
        .SYNOPSIS
            Creates a subfolder under a folder containing a copy of axiUm.

        .DESCRIPTION
            Creates a subfolder under a folder containing a copy of axiUm. This is useful to create a folder to
            hold temporary files, such as the ones needed for printing letters.

            Aliases: nas

        .INPUTS
            System.String

        .OUTPUTS
            System.IO.DirectoryInfo

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.DirectoryInfo])]

    param(
        # The path to a folder that may contain a copy of axiUm.
        #
        # Aliases: p
        [Parameter(
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Mandatory = $True
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        # The name of the folder to create if it doesn't already exist.
        #
        # Aliases: n
        [ValidateNotNullOrEmpty()]
        [string]$Name = 'Temp'
    )

    process {
        $Output = $Null

        if ($Path | Test-AxiumCopy -Verbose:$VerbosePreference) {
            Write-Verbose -Message """$Path"" contains a copy of axiUm."
            $Output = New-Item -Path $Path -Name $Name -Verbose:$VerbosePreference -WhatIf:$WhatIfPreference
        } else {
            Write-Verbose -Message """$Path doesn't contain a copy of axiUm. Nothing to do."
        }

        $Output
    }
}

New-Alias -Name 'nas' -Value 'New-AxiumSubfolder'
