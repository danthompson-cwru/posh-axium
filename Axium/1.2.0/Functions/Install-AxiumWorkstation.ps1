function Install-AxiumWorkstation {
    <#
        .SYNOPSIS
            Installs axiUm Workstation.

        .DESCRIPTION
            Installs axiUm Workstation. This does not include:
                - Any prerequisites, such as the Crystal Reports Runtime.
                - Applying any compatbility fixes.
                - PowerAdmin (unless you have a custom installer that includes it)

            Aliases: Install-AxiumWS, isaws

        .INPUTS
            System.IO.DirectoryInfo

        .OUTPUTS
            System.Boolean

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Boolean])]

    param(
        # The directory that holds the installation media. This must contain setup.exe.
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
        [ValidateScript({
            ($_ | Test-Path -PathType 'Container') -and
            ($_ | Join-Path -ChildPath 'Setup.exe' | Test-Path -PathType 'Leaf')
        })]
        [System.IO.DirectoryInfo]$Path,

        # Run without any user interaction. To use this, the file "$Path\Setup.iss" must exist. This can be
        # written to "C:\WINDOWS\Setup.iss" by running "$Path\Setup.exe /r".
        #
        # Aliases: Quiet, q, s
        [Alias('Quiet', 'q', 's')]
        [ValidateScript({ $Path | Join-Path -ChildPath 'Setup.iss' | Test-Path -PathType 'Setup.iss' })]
        [switch]$Silent
    )

    begin {
        $StartProcessArgs = @{
            'Wait' = $True
            'NoNewWindow' = $True
            'PassThru' = $True
        }

        if ($Silent.IsPresent) {
            $StartProcessArgs.ArgumentList = '/s'
        }
    }

    process {
        $StartProcessArgs.FilePath = $Path | Join-Path -ChildPath 'Setup.exe'

        if ($PSCmdlet.ShouldProcess($StartProcessArgs.FilePath, 'Start-Process')) {
            Write-Verbose -Message "Attempting to run Start-Process with the following arguments: $($StartProcessArgs | Out-String)"
            $Process = Start-Process @StartProcessArgs

            if (0 -eq $Process.ExitCode) {
                Write-Verbose -Message 'Setup successfull!'
                $True
            } else {
                Write-Error -Message "Failed to install ""$Path""."
                $False
            }
        } else {
            $True
        }
    }
}

New-Alias -Name 'Install-AxiumWS' -Value 'Install-AxiumWorkstation'

New-Alias -Name 'isaws' -Value 'Install-AxiumWorkstation'
