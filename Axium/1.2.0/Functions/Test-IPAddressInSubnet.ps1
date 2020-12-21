function Test-IPAddressInSubnet {
    <#
        .SYNOPSIS
            Tests membership of a IPv4 address in a given subnet.

        .DESCRIPTION
            Tests membership of a IPv4 address in a given subnet.

            Aliases: tias

        .INPUTS
            System.Net.IPAddress

        .OUTPUTS
            System.Boolean

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]

    param(
        # The IPv4 address to check. This can be passed from the pipeline. On the pipeline,
        # this can be a collection of IP addresses.
        #
        # Aliases: ip_addr, ip
        [Parameter(
            Position = 0,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Mandatory = $True
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('ip_addr', 'ip')]
        [System.Net.IPAddress]$IPAddress,

        # The subnet address.
        #
        # Aliases: snet_addr
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [Alias('snet_addr')]
        [System.Net.IPAddress]$SubnetAddress,
        
        # The subnet mask.
        #
        # Aliases: snet_mask
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [Alias('snet_mask')]
        [System.Net.IPAddress]$SubnetMask
    )

    process {
        Write-Verbose -Message "Testing address $($IPAddress.ToString()) for membership in $($SubnetAddress.ToString())/$($SubnetMask.ToString()) ..."

        $InSubnet = $SubnetAddress.Address -eq ($IPAddress.Address -band $SubnetMask.Address)

        $ResultVerboseMessage = "$($IPAddress.ToString()) "
        if ($InSubnet) {
            $ResultVerboseMessage += 'is in'
        } else {
            $ResultVerboseMessage += 'is not in'
        }
        $ResultVerboseMessage += " $($SubnetAddress.ToString())/$($SubnetMask.ToString())."
        Write-Verbose -Message $ResultVerboseMessage

        return $InSubnet
    }
}

New-Alias -Name 'tias' -Value 'Test-IPAddressInSubnet'
