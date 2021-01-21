function Get-InstalledProduct {
    <#
        .SYNOPSIS
            Gets information on the installed products.

        .DESCRIPTION
            Gets a table of information on the installed products. Each column is one of the possible properties
            for an installed product on Windows that is also in $Properties.
            
            Aliases: gip

        .INPUTS
            System.String[]

        .OUTPUTS
            System.Object[]
    #>

    [CmdletBinding()]
    [OutputType([System.Object[]])]

    param(
        # What property to sort by. Defaults to sorting by DisplayName.
        #
        # Aliases: s, sort
        [Alias('s', 'sort')]
        [string]$SortBy = 'DisplayName',

        # Includes products that don't have DisplayName set. This usually isn't very useful.
        [switch]$IncludeEmptyDisplayName,

        # Includes products that don't have an uninstall string set. This usually isn't very useful.
        [switch]$IncludeEmptyUninstallString
    )

    begin {
        # Determine where to search in the registry. 64 bit Windows uses two registry locations, whereas 32 bit
        # Windows uses only one.
        #
        # Searching the registry directly is also faster than Get-WMIObject, and can also get products that were
        # not installed from an MSI.

        $RegistryPaths = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
        if ([System.Environment]::Is64BitOperatingSystem) {
            $RegistryPaths += 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        }

        Write-Verbose -Message 'Searching the following registry locations for installed products:'
        $RegistryPaths | Write-Verbose
    }

    process {
        $Results = $RegistryPaths | Get-ItemProperty

        if ([string]::IsNullOrWhiteSpace($SortBy)) {
            Write-Verbose -Message 'Not sorting by anything.'
        } else {
            Write-Verbose -Message "Sorting by $SortBy."

            $Results = $Results | Sort-Object -Property $SortBy
        }

        if ($IncludeEmptyDisplayName.IsPresent) {
            Write-Verbose -Message 'Including programs with an empty DisplayName.'
        } else {
            Write-Verbose -Message 'Excluding programs with an empty DisplayName.'
            $Results = $Results | Where-Object { -not [string]::IsNullOrWhiteSpace($_.DisplayName) }
        }

        if ($IncludeEmptyUninstallString.IsPresent) {
            Write-Verbose -Message 'Including programs with an empty UninstallString.'
        } else {
            $Results = $Results | Where-Object { -not [string]::IsNullOrWhiteSpace($_.UninstallString) }
            Write-Verbose -Message 'Excluding programs with an empty UninstallString.'
        }

        $Results
    }
}

New-Alias -Name 'gip' -Value 'Get-InstalledProduct'
New-Alias -Name 'Get-InstalledApp' -Value 'Get-InstalledProduct'
New-Alias -Name 'Get-InstalledApplication' -Value 'Get-InstalledProduct'
New-Alias -Name 'Get-InstalledProgram' -Value 'Get-InstalledProduct'
New-Alias -Name 'Get-InstalledSoftware' -Value 'Get-InstalledProduct'
