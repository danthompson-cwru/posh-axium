function Install-MSI {
    <#
        .SYNOPSIS
            Installs one or more MSIs using msiexec.

        .DESCRIPTION
            Installs one or more MSIs using msiexec. Assumes Windows Installer 3.0 or latter is installed, which
            is true with Windows XP SP2 and latter, and Windows Server 2003 R2 and latter.

            Aliases: ismsi

        .INPUTS
            System.IO.FileInfo

        .OUTPUTS
            System.Boolean

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Boolean])]

    param(
        # The path to the MSI. A collection of paths can be passed via the pipeline.
        #
        # Aliases: p, msi
        [Parameter(
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Mandatory = $True
        )]
        [Alias('p', 'msi')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $_ | Test-Path -PathType 'Leaf' })]
        [System.IO.FileInfo]$MSIFilePath,

        # What to display on the screen. Must be one of the following:
        # - Full (Regular, full UI is shown on screen, just as if the user double-clicked the MSI.)
        # - Passive (Only a progress bar is shown on the screen. This is the default option.)
        # - Quiet (Nothing is shown on the screen. This is useful for when this is run from a startup, shutdown,
        #   login, or logout script.)
        #
        # Aliases: dm
        [Alias('dm')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Full', 'Passive', 'Quiet')]
        [string]$DisplayMode = 'Passive',

        # Controls if the computer is restarted after installing the MSI. Must be one of the following:
        # - Default (Restarts automatically if a restart is needed. This is the default.)
        # - Suppress (No restart is ever done, even if the MSI would normally require it.)
        # - Force (Forces the computer to restart after the MSI is installed, even if it isn't needed.)
        # - Prompt (Prompts the suer if they want to restart. This CANNOT be used if $DisplayMode is set to
        #   'Quiet'.)
        #
        # Aliases: rb
        [Alias('rb')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Default', 'Suppress', 'Force', 'Prompt')]
        [ValidateScript({
            -not ( ($_ -eq 'Prompt') -and ($DisplayMode -eq 'Quiet') )
        })]
        [string]$RestartBehavior = 'Default',

        # The directory to place MSI log files in. Each MSI specified via either $MSIFilePath or the pipe will log
        # to a file named after the MSI in this directory.
        #
        # See https://docs.microsoft.com/en-us/windows/win32/msi/standard-installer-command-line-options for what
        # is logged.
        #
        # Aliases: l, log
        [Alias('l', 'log')]
        [ValidateNotNullOrEmpty()]
        [System.IO.DirectoryInfo]$LogDirectoryPath
    )

    begin {
        # Determine if MSIEXEC exists and is in the path.
        $MSIExec = Get-Command -Name 'msiexec' -CommandType 'Application' -ErrorAction 'SilentlyContinue'
        if ($Null -eq $MSIExec) {
            throw 'MSIExec is not available.'
        }

        # If the logging directory is specified, and it doesn't already exist, we need to create it ahead of time
        # as MSIEXEC will not do this for us.

        $LogDirectoryExists = $False

        if ([string]::IsNullOrWhiteSpace($LogDirectoryPath)) {
            Write-Verbose -Message 'MSI logging not enabled.'
        } else {
            if (Test-Path -Path $LogDirectoryPath) {
                Write-Verbose -Message "`"$($LogDirectoryPath.FullName)`" already exists, so not creating it."

                $LogDirectoryExists = $True
            } else {
                Write-Verbose -Message "`"$($LogDirectoryPath.FullName)`" doesn't exist, so creating it ..."

                if ($Null -eq (New-Item -Path $LogDirectoryPath -ItemType 'Directory')) {
                    Write-Error -Message "Failed to create `"$($LogDirectoryPath.FullName)`". MSI logging will not be done."
                } else {
                    Write-Verbose -Message "Successfully created `"$($LogDirectoryPath.FullName)`"."

                    $LogDirectoryExists = $True
                }
            }
        }

        # Set display mode argument.

        Write-Verbose -Message "Display mode of $DisplayMode detected."

        $DisplayModeArgument = $Null
        switch ($DisplayMode) {
            'Passive' {
                $DisplayModeArgument = '/passive'
            }

            'Quiet' {
                $DisplayModeArgument = '/quiet'
            }
        }

        # Set restart argument.

        Write-Verbose -Message "Restart behavior of $RestartBehavior detected."

        $RestartBehaviorArgument = $Null
        switch ($RestartBehavior) {
            'Suppress' {
                $RestartBehaviorArgument = '/norestart'
            }

            'Force' {
                $RestartBehaviorArgument = '/forcerestart'
            }

            'Prompt' {
                $RestartBehaviorArgument = '/promptrestart'
            }
        }
    }

    process {
        # Create the (currently empty) log file if needed. (MSIEXEC won't write to a log file that doesn't exist.)

        [System.IO.FileInfo]$LogFilePath = $Null
        $LogFileExists = $False

        if ($LogDirectoryExists) {
            $LogFilePath = Join-Path -Path $LogDirectoryPath -ChildPath "$($MSIFilePath.BaseName).log"

            $LogMessageSuffix = "for `"$($MSIFilePath.FullName)`"."
            $LogVerboseMessageSuffix = "Logging $LogMessageSuffix."
            $LogErrorMessageSuffix = "Not logging $LogMessageSuffix."

            if (Test-Path -Path $LogFilePath) {
                if (-not (Test-Path -Path $LogFilePath -PathType 'Leaf')) {
                    Write-Error -Message "`"$($LogFilePath.FullName)`" is not a file. $LogErrorMessageSuffix"
                } else {
                    Write-Verbose -Message "`"$($LogFilePath.FullName)`" exists and is a file. $LogVerboseMessageSuffix"

                    $LogFileExists = $True
                }
            } else {
                Write-Verbose "`"$($LogFilePath.FullName)`" doesn't exist. Attempting to create it ..."

                if ($Null -eq (New-Item -Path $LogFilePath -ItemType 'File')) {
                    Write-Error -Message "Unable to create `"$($LogFilePath.FullName)`". $LogErrorMessageSuffix"
                } else {
                    Write-Verbose -Message "Successfully created `"$($LogFilePath.FullName)`". $LogVerboseMessageSuffix"

                    $LogFileExists = $True
                }
            }
        }

        # Install the MSI.

        $ArgumentList = @("/package `"$($MSIFilePath.FullName)`"")

        if ($Null -ne $DisplayModeArgument) {
            $ArgumentList += $DisplayModeArgument
        }

        if ($Null -ne $RestartBehaviorArgument) {
            $ArgumentList += $RestartBehaviorArgument
        }

        if ($LogFileExists) {
            $ArgumentList += "/log `"$($LogFilePath.FullName)`""
        }

        if ($PSCmdlet.ShouldProcess($MSIExec.Source, 'Start-Process')) {
            $RunMessageSuffix = "$($MSIExec.Source[0]) $ArgumentList"

            Write-Verbose -Message "Attempting to run: $RunMessageSuffix"

            $MSIExecProcess = Start-Process -FilePath $MSIExec.Source[0] -ArgumentList $ArgumentList -Wait -PassThru

            if ($MSIExecProcess.ExitCode -eq 0) {
                Write-Verbose -Message "Successfully ran: $RunMessageSuffix"
                $True
            } else {
                throw "Encountered error code $($MSIExecProcess.ExitCode) when running: $RunMessageSuffix"
                $False
            }
        } else {
            $True
        }
    }
}

New-Alias -Name 'ismsi' -Value 'Install-MSI'
