function Install-Axium {
    <#
        .SYNOPSIS
            Installs axiUm.

        .DESCRIPTION
            Installs axiUm. This includes installing the Crystal Reports runtime if needed, which isn't done by the
            defaults installers provided by Exan anymore.

            Aliases: isa

        .NOTES
            Author    : Dan Thompson
            Copyright : 2020 Case Western Reserve University
    #>
}

New-Alias -Name 'isa' -Value 'Install-Axium'
