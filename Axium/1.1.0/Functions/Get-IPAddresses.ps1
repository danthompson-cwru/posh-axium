function Get-IPAddresses {
    <#
        .SYNOPSIS
            Gets all of the IPv4 addresses associated with the device this script is run on.

        .DESCRIPTION
            Gets all of the IPv4 addresses associated with the device this script is run on.

            Aliases: gia

        .OUTPUTS
            System.Net.IPAddress[]

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([System.Net.IPAddress[]])]

    param()

    begin {
        Get-NetIPAddress -AddressFamily 'IPv4' | Select-Object -ExpandProperty IPAddress
    }
}

New-Alias -Name 'gia' -Value 'Get-IPAddresses'
