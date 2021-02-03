function Test-IPAddressRequirementsMet {
    <#
        .SYNOPSIS
            Tests if a given IP address meets zero or more of the following requirements:
                1) IS a given subnet.
                2) IS NOT in another given subnet.

        .DESCRIPTION
            Tests if a given IP address meets zero or more of the following requirements:
                1) IS a given subnet.
                2) IS NOT in another given subnet.

            Aliases: tiarm

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

        # The subnet address of the subnet to check for membership in.
        #
        # Aliases: in_snet
        [ValidateCount(2,2)]
        [Alias('in_snet')]
        [System.Net.IPAddress[]]$InSubnet,

        # The subnet mask of the subnet to check for membership in.
        #
        # Aliases: notin_snet
        [ValidateCount(2,2)]
        [Alias('notin_snet')]
        [System.Net.IPAddress[]]$NotInSubnet
    )

    begin {
        # Determine which of the subnet paramters were set, if any.
        $InSubnetSet = $PSBoundParameters.ContainsKey('InSubnet') -and ($Null -ne $InSubnet)
        $NotInSubnetSet = $PSBoundParameters.ContainsKey('NotInSubnet') -and ($Null -ne $NotInSubnet)

        # If both subnet parameters are not set, we meet the requirements.
        $RequirementsMet = (-not $InSubnetSet) -and (-not $NotInSubnetSet)
    }

    process {
        if (-not $RequirementsMet) {
            # One or more of the subnet parameters was set. We actually have to do some work. :(

            if ($InSubnetSet) {
                $TiasArgs = @{
                    IPAddress = $IPAddress
                    SubnetAddress = $InSubnet[0]
                    SubnetMask = $InSubnet[1]
                }

                $RequirementsMet = $RequirementsMet -or (Test-IPAddressInSubnet @TiasArgs)
            }

            if ($RequireNotInSubnetSet) {
                $TiasArgs = @{
                    IPAddress = $IPAddress
                    SubnetAddress = $NotInSubnet[0]
                    SubnetMask = $NotInSubnet[1]
                }

                $RequirementsMet = $RequirementsMet -or (-not (Test-IPAddressInSubnet @TiasArgs))
            }
        }

        $RequirementsMet
    }
}

New-Alias -Name 'tiarm' -Value 'Test-IPAddressRequirementsMet'
