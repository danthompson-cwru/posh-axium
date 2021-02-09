function Copy-AxiumFiles {
    <#
        .SYNOPSIS
            Used to copy axiUm files. Usually run as a startup or logon script.

        .DESCRIPTION
            Used to copy axiUm files. Usually run as a startup or logon script. Can be limited to only copy files
            when connected to a given network, not connected to a given network, or both. This is useful to copy
            files when connected to your organization's network, but not through on offsite VPN connection which
            may potentially be slow.

            Uses RoboCopy under the hood, so it requires RoboCopy to be located in the path, which is the case by
            default in Windows Vista and latter. RoboCopy will log to "$ClientPath\Copy-AxiumFiles.log".

            Aliases: cpaf

        .INPUTS
            System.String

        .EXAMPLE
            PS> 'C:\axiUm' | Copy-AxiumFiles -SourcePathOrPrefix $PSScriptRoot

            Copies the files for a single instance of axiUm from the directory this script is in to "C:\axiUm",
            writing a log file to "C:\axiUm\Copy-AxiumFiles.log". Only new and updated files are copied, and the IP
            addresses of the device are not considered.
        .EXAMPLE
            PS> 'C:\axiUm' | Copy-AxiumFiles -SourcePathOrPrefix $PSScriptRoot -CopyAll

            Same as Example 1, but copies all files.
        .EXAMPLE
            PS> 'C:\axiUm' | Copy-AxiumFiles -SourcePathOrPrefix $PSScriptRoot -RequireInSubnet @('10.0.0.0', '255.0.0.0') -RequireNotInSubnet @('10.2.0.0', '255.255.0.0)

            Let us say that your organization has IP addresses in 10.0.0.0/255.0.0.0, but your VPN uses a small
            part of that (10.1.0.0/255.255.0.0). This would do the same as Example 1, but only if the workstation
            this was run on was connected to your organization's network, but not through VPN.

            This is useful if you want to push out a lot of files, but are worried about doing this when somebody
            is connected via a slow offsite wifi connection to your VPN. This would skip those workstations, which
            you could then handle manually.
        .EXAMPLE
            PS> 'C:\axiUm' | Get-ChildItem -Directory | Copy-AxiumFiles -SourcePathOrPrefix '\\domain\axiUm-ClientFiles-' -MultipleCopies

            This is an example of using the MultipleCopies switch to copy files for multiple copies of axiUm. Let
            us assume there are two installations of axiUm on the workstation this is being run on:
                * "C:\axiUm\Production"
                * "C:\axiUm\Test"
            
            This will:
                * Copy all files that are not in or newer than the ones in "C:\axiUm\Production" from
                "\\domain\axiUm-ClientFiles-Production" to "C:\axiUm\Production".
                * Copy all files that are not in or newer than the ones in "C:\axiUm\Test" from
                "\\domain\axiUm-ClientFiles-Test" to "C:\axiUm\Test".

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>

    [CmdletBinding(SupportsShouldProcess)]

    param(
        # Where axiUm is installed.
        #
        # Aliases: clp
        [Parameter(
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Mandatory = $True
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $_ | Test-Path -PathType 'Container' })]
        [Alias('clp')]
        [string]$ClientPath,

        # If MultipleCopies is set, the name of the last folder in ClientPath will be appended to
        # SourcePathOrPrefix to get where to copy files from. Otherwise, SourcePathOrPrefix will be treated as the
        # complete path of where the files should be copied from.
        #
        # Aliases: spp
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [Alias('spp')]
        [string]$SourcePathOrPrefix,

        # An array of 2 IP addresses, the first being the subnet, and the second the subnet mask. Files will only
        # be copied if an IP address IS found connected to this subnet. If not set, this will not be used to
        # determine if files should be copied.
        #
        # Aliases: ris, insubnet, in_subnet
        [ValidateCount(2,2)]
        [Alias('ris', 'insubnet', 'in_subnet')]
        [System.Net.IPAddress[]]$RequireInSubnet,

        # An array of 2 IP addresses, the first being the subnet, and the second the subnet mask. Files will only
        # be copied if an IP address IS NOT found connected to this subnet. If not set, this will not be used to
        # determine if files should be copied.
        #
        # Aliases: rnis, notinsubnet, not_in_subnet
        [ValidateCount(2,2)]
        [Alias('rnis', 'notinsubnet', 'not_in_subnet')]
        [System.Net.IPAddress[]]$RequireNotInSubnet,

        # By default, the only files copied are those that are only in the source, or have been modified in the
        # source since they were last copied. This switch changes that behavior to copy ALL files every time this
        # script is run.
        #
        # Aliases: cpa
        [Alias('cpa')]
        [switch]$CopyAll,

        # Set this if the computer(s) you are running this on may have more than copy installed. This might be the
        # case if you have a test copy of axiUm that is on a different version from your production instance, thus
        # requiring a separate install.
        #
        # Aliases: mi
        [Alias('mi')]
        [switch]$MultipleCopies,

        # By default, log files will be cleared before being written to. This changes that behavior to just append
        # to the existing log. Use this carefully, as, in certain circumstances, you could get log files that grow
        # to a very large size (such as if this function is called in a logon or startup script, and you do not
        # have another method in place for clearing the log files).
        #
        # Aliases: al
        [Alias('al')]
        [switch]$AppendToLog
    )

    begin {
        # Abort if RoboCopy isn't in the path.
        if ($Null -eq (Get-Command -Name 'robocopy' -ErrorAction SilentlyContinue)) {
            throw 'RoboCopy was not found in your path. Aborting.'
        }

        # Determine if we meet the requirements set forth to copy files.

        $SubnetRequirements = @{}

        if ($PSBoundParameters.ContainsKey('RequireInSubnet') -and ($Null -ne $RequireInSubnet)) {
            $SubnetRequirements.InSubnet = $RequireInSubnet
        }

        if ($PSBoundParameters.ContainsKey('RequireNotInSubnet') -and ($Null -ne $RequireNotInSubnet)) {
            $SubnetRequirements.NotInSubnet = $RequireNotInSubnet
        }

        $CanCopy = (Get-IPAddresses | Test-IPAddressRequirementsMet @SubnetRequirements).Contains($True)

        if ($CanCopy) {
            Write-Verbose -Message 'Met requirements to copy files.'
        } else {
            Write-Warning -Message 'Requirements to copy files not met, so not doing anything. Bye now!'
        }
    }

    process {
        if ($CanCopy) {
            # Get the actual source path. This will be different from $SourcePathOrPrefix if we have multiple copies
            # of axiUm.
            $SourcePath = $SourcePathOrPrefix
            if ($MultipleCopies.IsPresent) {
                $SourcePath = $SourcePathOrPrefix | Join-Path -ChildPath ($ClientPath | Split-Path -Leaf)
            }

            # Check if we have source files for the copy of axiUm.
            $HaveSourceFiles = $True
            if ($MultipleCopies.IsPresent) {
                $HaveSourceFiles = $SourcePath | Test-Path -PathType 'Container'
            }

            if ($HaveSourceFiles) {
                # We do, so we are good to copy the files.
                Write-Verbose -Message """$SourcePath"" exists, so copying contents to ""$ClientPath"" ..."

                # Set up some RoboCopy options. We have to do this here as doing it in begin will cause
                # $RobocopyOptions to not get emptied for each copy of axiUm.
                
                $RobocopyOptions = @('/E')
                if (-not $CopyAll.IsPresent) {
                    $RobocopyOptions += '/XO'
                }

                $LogPath = $ClientPath | Join-Path -ChildPath 'Copy-AxiumFiles.log'

                $RobocopyLogFlag = '/UNILOG'
                if ($AppendToLog.IsPresent) {
                    $RobocopyLogFlag += '+'
                }
                $RobocopyLogFlag += ":$LogPath"

                $RobocopyOptions += $RobocopyLogFlag

                # Call RoboCopy.

                $RobocopyArgs = @($SourcePath, $ClientPath) + $RobocopyOptions

                if ($PSCmdlet.ShouldProcess('robocopy', 'Start-Process')) {
                    $RunMessageSuffix = "robocopy $RobocopyArgs"
    
                    Write-Verbose -Message "Attempting to run: $RunMessageSuffix"
    
                    $RobocopyProcess = Start-Process -FilePath 'robocopy' -ArgumentList $RobocopyArgs -Wait -PassThru

                    $ExitCodeMessage = "Exit code was $($RobocopyProcess.ExitCode). See https://docs.microsoft.com/en-us/troubleshoot/windows-server/backup-and-storage/return-codes-used-robocopy-utility for details."
    
                    if ($RobocopyProcess.ExitCode -gt 7) {
                        Write-Error -Message "Encountered error when running: $RunMessageSuffix"
                        Write-Error -Message $ExitCodeMessage
                        $False
                    } else {
                        Write-Verbose -Message "Successfully ran: $RunMessageSuffix"
                        Write-Verbose -Message $ExitCodeMessage
                        $True
                    }
                } else {
                    $True
                }
            } else {
                # We don't.
                Write-Warning -Message "Directory ""$SourcePath"" doesn't exist. Not copying contents to ""$ClientPath""."
            }
        }
    }
}
