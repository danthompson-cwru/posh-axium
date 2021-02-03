function Get-MSIProperties {
    <#
        .SYNOPSIS
            Gets the properties of an MSI.

        .DESCRIPTION
            Gets the properties of an MSI.

            Aliases: gmp

        .INPUTS
            string

        .OUTPUTS
            hashtable

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([hashtable])]

    param(
        # The path to the MSI.
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
        [ValidateScript({ $_ | Test-Path -PathType 'Leaf' })]
        [string]$Path
    )

    begin {
        $Com = New-Object -Com 'WindowsInstaller.Installer'
    }

    process {
        $Properties = @{}

        try {
            $Database = $Com.GetType().InvokeMember(
                'OpenDatabase',
                'InvokeMethod',
                $Null,
                $Com,
                @($Path, 0)
            )

            $Query = 'SELECT * FROM Property'

            $View = $Database.GetType().InvokeMember(
                'OpenView',
                'InvokeMethod',
                $Null,
                $Database,
                ($Query)
            )

            $View.GetType().InvokeMember(
                'Execute',
                'InvokeMethod',
                $Null,
                $View,
                $Null
            )

            $Record = $View.GetType().InvokeMember(
                'Fetch',
                'InvokeMethod',
                $Null,
                $View,
                $Null
            )

            while ($Null -ne $Record) {
                $PropertyName = $Record.GetType().InvokeMember(
                    'StringData',
                    'GetProperty',
                    $Null,
                    $Record,
                    1
                )

                $PropertyValue = $Record.GetType().InvokeMember(
                    'StringData',
                    'GetProperty',
                    $Null,
                    $Record,
                    2
                )

                $Properties[$PropertyName] = $PropertyValue

                $Record = $View.GetType().InvokeMember(
                    'Fetch',
                    'InvokeMethod',
                    $Null,
                    $View,
                    $Null
                )
            }
        } catch {
            throw "Failed to get the properties of ""$Path"". The error was: $_"
        }

        $Properties
    }
}

New-Alias -Name 'gmp' -Value 'Get-MSIProperties'
