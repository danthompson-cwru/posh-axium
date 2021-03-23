# Introduction
The axiUm module provides functions for doing things related to axiUm.

# Prerequisites

## All Functions
* A Windows OS.
* PowerShell version 5.1 or latter. This comes with Windows 10 and Windows Server 2016. You can download it for previous versions of Windows.

## `Copy-AxiumFiles`
For `Copy-AxiumFiles` to work, RoboCopy must be present in the path. This is done out of the box with Windows Vista and latter and Windows Server 2008 and latter. It can be downloaded for previous verions of Windows.

# Installation

## Single Workstation
There are multiple ways to do this. Here are a couple.

### From the PowerShell Gallery
1. Log in as a user who is a member of the local _Administrators_ group.
2. Run `Install-Module -Name 'Axium'` from a PowerShell prompt and follow the on-screen instructions.

### Manually
You will want to use this method if your workstation requires all scripts to be signed before they can be run. You would follow these instructions, and then sign the module.

1. Download the module from one of the following:
    * https://www.powershellgallery.com/packages/Axium
    * https://github.com/danthompson-cwru/posh-axium
2. Log in as a user who is a member of the local _Administrators_ group.
3. If you have a previous version of this module installed, it is recomended to delete the old versions by deleting the module folder from whereever your PowerShell modules live, unless you have a reason to keep those old versions around. On Windows, this defaults to `C:\Program Files\WindowsPowerShell\Modules`.
4. Copy the entire `Axium` folder from what you downloaded into whereever your PowerShell modules live. On Windows, this defaults to `C:\Program Files\WindowsPowerShell\Modules`.
5. From PowerShell, issue the following command: `Import-Module -Name 'Axium'`

## Multiple Workstations
There are multiple ways to do this, but here is one way that works for an Active Directory environment:
1. Download the module from one of the following:
    * https://www.powershellgallery.com/packages/Axium
    * https://github.com/danthompson-cwru/posh-axium
2. Create a directory for housing PowerShell modules on a network share. All of your workstations must be able to access this share, and your users must have at least read access to it.
3. Copy the `Axium` directory for what you downloaded into this directory.
4. Use Group Policy to set the environmental variable `PSModulePath` to include the modules directory you set up above. (Not the `Axium` directory itself, but the directory above that.) You can do this either under _Computer Configuration_ or _User Configuration_.
    * If done under _User Configuration_:
        * Your PoSH modules will be available immediatley upon user logon, making deployment quicker.
        * You will not need to remember to include stock Windows modules paths, such as `C:\Program Files\WindowsPowerShell\Modules`.
        * These modules __will not__ be available in startup or shutdown scripts, only logon scripts.
        * You can safely refer to the network share from step #2 above by a mapped network drive letter when adding it to `PSModulePath`.
    * If done under _Computer Configuration_:
        * Your PoSH modules will not be available until a given workstation reboots, which can make deployment slower.
        * You will need to remember to include stock Windows module paths, such as `C:\Program Files\WindowsPowerShell\Modules`.
        * These modules __will__ be available in startup and shutdown scripts in addition to logon scripts.
        * If you plan on using this module in a startup or shutdown script, you will need to refer to the network share from step #2 above by its UNC path when adding it to `PSModulePath`. This is because network drives are not mapped at the time startup and shutdown scripts are run.
5. You can now use these modules in stuff like startup script and logon scripts.

# Usage
See the comment based help for the functions provided by the module.

You will probably want to call the following functions directly:
* `Get-InstalledProduct`
* `Copy-AxiumFiles`
* `Set-AxiumHelpLink`
* `Install-MSI`
* `Install-AxiumWorkstation`
* `Write-AxiumFix`
* `Test-AxiumCopy`

The following are used mainly by other functions, and usually don't need to be called directly:
* `Get-IPAddresses`
* `Get-MSIProperties`
* `Test-IPAddressInSubnet`
* `Test-IPAddressRequirementsMet`

# Support
Support (including bug fixes and new features) as my time allows. Please use the [click here](https://github.com/danthompson-cwru/posh-axium/issues) to report issues.
