@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Axium.psm1'

    # Version number of this module.
    ModuleVersion = '1.5.1'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop')

    # ID used to uniquely identify this module
    GUID = 'f2412aff-58f4-4c66-9ea8-99a8a0dab27b'

    # Author of this module
    Author = 'Dan Thompson'

    # Company or vendor of this module
    CompanyName = 'Case Western Reserve University'

    # Copyright statement for this module
    Copyright = '(C)2020 Case Western Reserve University. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Provides PowerShell functions for working with axiUm.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry,
    # use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Get-IPAddresses',
        'Get-InstalledProduct',
        'Get-MSIProperties',
        'Test-IPAddressInSubnet',
        'Test-IPAddressRequirementsMet',
        'Test-AxiumCopy',
        'Install-MSI',
        'Install-AxiumWorkstation',
        'Set-AxiumHelpLink',
        'Copy-AxiumFiles',
        'Write-AxiumFix',
        'New-AxiumSubfolder'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry,
    # use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry,
    # use an empty array if there are no aliases to export.
    AliasesToExport = @(
        'gia',
        'gip', 'Get-InstalledApp', 'Get-InstalledApplication', 'Get-InstalledProgram', 'Get-InstalledSoftware',
        'gmp',
        'tias',
        'tiarm',
        'tac',
        'ismsi',
        'isaws',
        'sahl',
        'caf',
        'wraf',
        'nas'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData
    # hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('axiUm')

            # A URL to the license for this module.
            LicenseUri = 'https://www.gnu.org/licenses/gpl-3.0.en.html'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/danthompson-cwru/posh-axium'

            # A URL to an icon representing this module.
            IconUri = 'https://github.com/danthompson-cwru/Icon.svg'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/danthompson-cwru/posh-axium/blob/master/CHANGELOG.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
