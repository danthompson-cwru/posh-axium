function Install-AxiumWorkstation {
    <#
        .SYNOPSIS
            Installs axiUm Workstation.

        .DESCRIPTION
            Installs axiUm Workstation. This does not include:
                - Any prerequisites, such as the Crystal Reports Runtime.
                - Applying any compatbility fixes.
                - PowerAdmin (unless you have a custom installer that includes it)

            If the answer file "$Path\Setup.iss" exists, a silent installation will be performed. This can be
            written to "C:\WINDOWS\Setup.iss" by running "$Path\Setup.exe /r" and going through the installation.

            Aliases: Install-AxiumWS, isaws

        .INPUTS
            string

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
        [string]$Path
    )

    begin {
        $StartProcessArgs = @{
            'Wait' = $True
            'NoNewWindow' = $True
            'PassThru' = $True
        }
    }

    process {
        $AnswerFilePath = $Path | Join-Path -ChildPath 'Setup.iss'
        if ($AnswerFilePath | Test-Path -PathType 'Leaf') {
            Write-Verbose -Message "Answer file found at ""$AnswerFilePath"". Will perform silent install."
            $StartProcessArgs.ArgumentList = '/s'
        } else {
            Write-Verbose -Message "Answer file not found at ""$AnswerFilePath"". Will not perform a silent install."
        }

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
