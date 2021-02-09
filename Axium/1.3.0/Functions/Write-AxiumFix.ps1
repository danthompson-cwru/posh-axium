function Write-AxiumFix {
    <#
        .SYNOPSIS
            Makes applicable compatibility fixes to axiUm

        .DESCRIPTION
            Makes applicable compatibility fixes to axiUm. Currently, the only supported fix is making axiUm
            verions less than 7.06 work with Crystal Reports Runtime 13 SP26.

        .INPUTS
            System.String

        .OUTPUTS
            System.Boolean

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Boolean])]

    param(
        # Where the copy of axiUm you wish to fix is installed. This must contain, at minimum, all of the following
        # files:
        #   axiUm.exe
        #   axiUm.exe.Config
        #
        # Aliases: p
        [Parameter(
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Mandatory = $True
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            ($_ | Test-Path -PathType 'Container') -and
            ($_ | Join-Path -ChildPath 'axiUm.exe' | Test-Path -PathType 'Leaf') -and
            ($_ | Join-Path -ChildPath 'axiUm.exe.Config' | Test-Path -PathType 'Leaf')
        })]
        [Alias('p')]
        [string]$Path,

        # The fix to apply. Must be one of the following:
        #
        # CrystalReportsRuntime13SP26
        #   Makes a copy of axiUm older than 7.06 compatible with Crystal Reports Runtime 13 SP26 if the latter is
        #   installed. This is done by applying the change to axiUm.exe.Config outlined by Exan.
        # All
        #   Applies all of the fixes above.
        #
        # Aliases: f
        [ValidateNotNullOrEmpty()]
        [ValidateSet('CrystalReportsRuntime13SP26', 'All')]
        [Alias('f')]
        [string]$Fix = 'All'
    )

    begin {
        # Get paths.

        $ModulePath = $PSScriptRoot | Split-Path
        Write-Verbose -Message "Module located at ""$ModulePath""."

        $AssetsPath = $ModulePath | Join-Path -ChildPath 'Assets'
        Write-Verbose -Message "Assets located at ""$AssetsPath""."

        $XmlAssetsPath = $AssetsPath | Join-Path -ChildPath 'XML'
        Write-Verbose -Message "XML assets located at ""$XmlAssetsPath""."

        # Create a variable to determine if we were successful.
        $Success = $True

        # Determine which fixes we may possible need to apply.

        $PossibleFixes = @{}

        $PossibleFixes.Add(
            'CrystalReportsRuntime13SP26',
            'All' -eq $Fix -or 'CrystalReportsRuntime13SP26' -eq $Fix
        )

        # Get the list of installed products if we may need them. If we do this here rather than in process, we
        # limit ourselves to having to do it at most once. In process, we might have to do it n times, where n is
        # the number of items in the incoming pipe.

        $NeedProducts = $PossibleFixes.CrystalReportsRuntime13SP26

        if ($NeedProducts) {
            Write-Verbose -Message 'Based on our fixes, we may need the list of installed products. Fetching ...'

            $Products = Get-InstalledProduct
        }

        # Determine if Crystal Reports Runtime 13 SP26 is installed if we need to. We do this here rather than in
        # process as Where-Object is slow, and we only want to call it once.

        $CrystalReportsRuntime13SP26Installed = $False

        if ($PossibleFixes.CrystalReportsRuntime13SP26) {
            $CrystalReportsRuntime13SP26Installed = $Null -ne ($Products | Where-Object {
                $_.DisplayName -eq 'SAP Crystal Reports runtime engine for .NET Framework (32-bit)' -and
                $_.DisplayVersion.StartsWith('13.0.26')
            })
        }
    }

    process {
        $AxiumExePath = $Path | Join-Path -ChildPath 'axiUm.exe'
        Write-Verbose -Message "axiUm.exe located at ""$AxiumExePath""."

        $AxiumExeConfigPath = $Path | Join-Path -ChildPath 'axiUm.exe.Config'
        Write-Verbose -Message "axiUm.exe.Config located at ""$AxiumExeConfigPath""."

        if ($PossibleFixes.CrystalReportsRuntime13SP26) {
            Write-Verbose -Message 'Seeing if we need to apply the fix for compatbility with Crystal Reports Runtime 13 SP26 ...'

            $AxiumVersion = ($AxiumExePath | Get-Item).VersionInfo.ProductVersion
            Write-Verbose -Message "axiUm version is $AxiumVersion."

            if ($AxiumVersion -lt 7.06) {
                Write-Verbose -Message "$AxiumVersion is less than 7.06."

                if ($CrystalReportsRuntime13SP26Installed) {
                    Write-Verbose -Message 'Crystal Reports Runtime 13 SP26 is installed.'

                    if ($PSCmdlet.ShouldProcess($AxiumExeConfigPath, 'apply fix')) {
                        $AxiumExeConfigXml = $AxiumExeConfigPath | Get-Item | Select-Xml -XPath '/'
                        $RuntimeXml = $XmlAssetsPath | Join-Path -ChildPath 'CRR13SP26FixRuntime.xml' | Get-Item | Select-Xml -XPath '/'

                        $ReplacementResults = $AxiumExeConfigXml.Node.Configuration.ReplaceChild(
                            $AxiumExeConfigXml.Node.ImportNode($RuntimeXml.Node.DocumentElement, $True),
                            $AxiumExeConfigXml.Node.Configuration.Runtime
                        )

                        $ResultsMessageSuffix = "the axiUm copy at ""$Path"" compatible with Crystal Reports Runtime 13 SP26."

                        if ($Null -eq $ReplacementResults) {
                            Write-Error -Message "Unable to make $ResultsMessageSuffix"
                            $Success = $False
                        } else {
                            $AxiumExeConfigXml.Node.Save($AxiumExeConfigPath)
                            Write-Verbose -Message "Successfully made $ResultsMessageSuffix"
                        }
                    }
                }
            } else {
                Write-Verbose -Message "$AxiumVersion is greater than or equal to 7.06. Not applying fix."
            }
        }

        $Success
    }
}

New-Alias -Name 'wraf' -Value 'Write-AxiumFix'
