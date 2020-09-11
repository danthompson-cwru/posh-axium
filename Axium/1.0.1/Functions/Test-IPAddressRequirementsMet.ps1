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

    tiar is an alias of this.
.PARAMETER IPAddress
    The IPv4 address to check. This can be passed from the pipeline. On the pipeline,
    this can be a collection of IP addresses.
.PARAMETER InSubnetAddress
    The subnet address of the subnet to check for membership in.
.PARAMETER InSubnetMask
    The subnet mask of the subnet to check for membership in.
.PARAMETER NotInSubnetAddress
    The subnet address of the subnet to check for a lack of membership in.
.PARAMETER NotInSubnetMask
    The subnet mask of the subnet to check for a lack of membership in.
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
    [Parameter(
        Position = 0,
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
        Mandatory = $True
    )]
    [ValidateNotNullOrEmpty()]
    [Alias('ip_addr', 'ip')]
    [System.Net.IPAddress]$IPAddress,

    [ValidateCount(2,2)]
    [Alias('in_snet')]
    [System.Net.IPAddress[]]$InSubnet,

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
            $RequirementsMet = $RequirementsMet -or (Test-IPAddressInSubnet -IPAddress $IPAddress -SubnetAddress $InSubnet[0] -SubnetMask $InSubnet[1])
        }

        if ($RequireNotInSubnetSet) {
            $RequirementsMet = $RequirementsMet -or (-not (Test-IPAddressInSubnet -IPAddress $IPAddress -SubnetAddress $NotInSubnet[0] -SubnetMask $NotInSubnet[1]))
        }
    }

    return $RequirementsMet
}
}

New-Alias -Name 'tiarm' -Value 'Test-IPAddressRequirementsMet'
