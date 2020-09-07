function Set-AxiumHelpLink {
<#
.SYNOPSIS
    Replaces the "axiUm Help Files" directory in a given axiUm copy with a symbolic link to
    another directory.
.DESCRIPTION
    Replaces the "axiUm Help Files" directory in a given axiUm copy with a symbolic link to
    another directory. This is useful for having all of your axiUm installations use help files
    that are on a network share, rather than stored locally. This allows you to not worry about
    updating the help file when using axiUm's auto-update mechanism.

    sahl is an alias for this.
.PARAMETER ClientPath
    Where the axiUm client is installed. Can be passed via the pipeline, in which case it can be
    a collection of paths.
.PARAMETER HelpPathOrPrefix
    If MultipleCopies is set, the name of the last folder in ClientPath will be appended to HelpPathOrPrefix
    to get where the help files are stored.

    Otherwise, HelpPathOrPrefix will be treated as the complete path of where the help files are.
.PARAMETER RequireInSubnet
    An array of 2 IP addresses, the first being the subnet, and the second the subnet mask.
    Files will only be copied if an IP address IS found connected to this subnet. If not set, this
    will not be used to determine if files should be copied.
.PARAMETER RequireNotInSubnet
    An array of 2 IP addresses, the first being the subnet, and the second the subnet mask.
    Files will only be copied if an IP address IS NOT found connected to this subnet. If not set, this
    will not be used to determine if files should be copied.
.PARAMETER MultipleCopies
    Set this if the computer(s) you are running this on may have more than copy installed, and you have
    separate help files for each copy. This might be the case if you have a test copy of axiUm that is
    on a different version from your production instance, thus requiring a separate install.
.INPUTS
    System.IO.DirectoryInfo
.OUTPUTS
    System.IO.DirectoryInfo
.EXAMPLE
    PS> Set-AxiumHelpLinks -ClientPath 'C:\axiUm' -HelpPathOrPrefix '\\domain\axiUm-HelpFiles'

    Creates a link at "C:\axiUm\axiUm Help Files" that points to "\\domain\axiUm-HelpFiles", if such a link
    doesn't already exist. If "C:\axiUm\axiUm Help Files" is already a stock directory containing the help
    files, it will be deleted and replaced with a link.
.EXAMPLE
    PS> Set-AxiumHelpLinks -ClientPath 'C:\axiUm' -HelpPathOrPrefix '\\domain\axiUm-HelpFiles' -RequireInSubnet @('10.0.0.0', '255.0.0.0') -RequireNotInSubnet @('10.2.0.0', '255.255.0.0)

    Let us say that your organization has IP addresses in 10.0.0.0/255.0.0.0, but your VPN uses a small part of
    that (10.1.0.0/255.255.0.0). This would do the same as Example 1, but only if the workstation this was run on
    was connected to your organization's network, but not through VPN.

    This is useful if you are worried about breaking somebody's connection to the help files when they are on a slow,
    off-site Wi-Fi connection.
.EXAMPLE
    PS> Get-ChildItem -Path 'C:\axiUm' -Directory | Set-AxiumHelpLinks -HelpPathOrPrefix '\\domain\axiUm-HelpFiles-' -MultipleCopies

    This is an example of using the MultipleCopies switch to create links for multiple copies of axiUm. Let us assume
    there are two installations of axiUm on the workstation this is being run on:
        * C:\axiUm\Production
        * C:\axiUm\Test

    This will:
        * Create a link at "C:\axiUm\Production\axiUm Help Files" that points to "\\domain\axiUm-HelpFiles-Production",
          if this link doesn't already exist. If "C:\axiUm\Production\axiUm Help Files" is already a stock directory
          containing the help files, it will be deleted and replaced with a link.
        * Create a link at "C:\axiUm\Test\axiUm Help Files" that points to "\\domain\axiUm-HelpFiles-Test",
          if this link doesn't already exist. If "C:\axiUm\Test\axiUm Help Files" is already a stock directory
          containing the help files, it will be deleted and replaced with a link.
.NOTES
    Author    : Dan Thompson
    Copyright : 2020 Case Western Reserve University
#>

[CmdletBinding(SupportsShouldProcess)]

[OutputType([System.IO.DirectoryInfo])]

param(
    [Parameter(
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
        Mandatory = $True
    )]
    [Alias('clp')]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        if (-not ($_ | Test-Path)) {
            throw "$($_.FullName) doesn't exist."
        }

        return $True
    })]
    [System.IO.DirectoryInfo]$ClientPath,

    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [Alias('hpp')]
    [string]$HelpPathOrPrefix,

    [ValidateCount(2,2)]
    [Alias('ris', 'insubnet', 'in_subnet')]
    [System.Net.IPAddress[]]$RequireInSubnet,

    [ValidateCount(2,2)]
    [Alias('rnis', 'notinsubnet', 'not_in_subnet')]
    [System.Net.IPAddress[]]$RequireNotInSubnet,

    [Alias('mi')]
    [switch]$MultipleCopies
)

begin {
    # Determine if we meet the requirements set forth to make the link.

    $SubnetRequirements = @{}

    if ($PSBoundParameters.ContainsKey('RequireInSubnet') -and ($Null -ne $RequireInSubnet)) {
        $SubnetRequirements.InSubnet = $RequireInSubnet
    }

    if ($PSBoundParameters.ContainsKey('RequireNotInSubnet') -and ($Null -ne $RequireNotInSubnet)) {
        $SubnetRequirements.NotInSubnet = $RequireNotInSubnet
    }

    $CanMakeLink = (Get-IPAddresses | Test-IPAddressRequirementsMet @SubnetRequirements).Contains($True)

    if ($CanMakeLink) {
        Write-Verbose -Message 'Met requirements to make links.'
    } else {
        Write-Warning -Message 'Requirements to make links not met, so not doing anything. Bye now!'
    }

    # Set the System.IO.DirectoryInfo we will return.
    [System.IO.DirectoryInfo]$Link = $Null
}

process {
    # Get the actual help files path. This will be different from $HelpPathOrPrefix if we have multiple copies
    # of axiUm.
    [System.IO.DirectoryInfo]$HelpPath = $HelpPathOrPrefix
    if ($MultipleCopies.IsPresent) {
        $HelpPath = $HelpPathOrPrefix + $(Split-Path -Path $ClientPath -Leaf)
    }

    # Check if we have help files for this copy of axiUm.
    $HaveHelpFiles = $True
    if ($MultipleCopies.IsPresent) {
        $HaveHelpFiles = Test-Path -Path $HelpPath -PathType 'Container'
    }

    if ($HaveHelpFiles) {
        # We do, so we are good to create the link.
        Write-Verbose -Message "$($HelpPath.FullName) exists, so creating link ..."

        # Set the path to the link before we make any changes.
        [System.IO.DirectoryInfo]$LinkPath = Join-Path -Path $ClientPath.FullName -ChildPath 'axiUm Help Files'

        # Make the link if we meet the requirements.
        if ($CanMakeLink) {
            # Check if ClientPath actually contains an installation of axiUm.
            [System.IO.FileInfo]$AxiumExePath = Join-Path -Path $ClientPath.FullName -ChildPath 'axiUm.exe'
            if (Test-Path -Path $AxiumExePath.FullName -PathType 'Leaf') {
                Write-Verbose -Message "$($AxiumExePath.FullName) exists, so we have a copy of axiUm."

                # If the help files is already a plain, local directory, we need to recursivley delete it.
                if ((Test-Path -Path $LinkPath -PathType 'Container') -and ($Null -eq (Get-Item -Path $LinkPath).LinkType)) {
                    Write-Verbose -Message "$($LinkPath.FullName) is a plain directory. Deleting it and its contents ..."

                    if ($PSCmdlet.ShouldProcess($LinkPath, 'Delete Directory and Contents')) {
                        Remove-Item -Path $LinkPath -Recurse -Force
                    }
                }

                # Create the link.
                if ($PSCmdlet.ShouldProcess($LinkPath, 'Create Symbolic Link')) {
                    $LinkMessageSuffix = "a link with the following properties:`n`tPATH  : ""$($LinkPath.FullName)""`n`tTARGET: ""$($HelpPath.FullName)"""

                    $Link = New-Item -Path $LinkPath -Value $HelpPath -ItemType 'SymbolicLink' -Force
                    if ($Null -eq $Link) {
                        Write-Error -Message "Failed to create $LinkMessageSuffix"
                    } else {
                        Write-Verbose -Message "Created $LinkMessageSuffix"
                    }
                }
            } else {
                Write-Warning -Message "$($AxiumExePath.FullName) doesn't exist, so we don't have a copy of axiUm. Not creating link."
            }
        }
    } else {
        Write-Warning -Message "$($HelpPath.FullName) doesn't exist, or is not a directory. Not creating link."
    }

    return $Link
}
}

New-Alias -Name 'sahl' -Value 'Set-AxiumHelpLink'
