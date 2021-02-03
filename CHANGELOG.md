# Version 1.0.0
* First release.

# Version 1.0.1
* Fixed copyright string in `Axium.psd1` so that `Publish-Module` likes it.

# Version 1.1.0
* Updated the [security policy](SECURITY.md).
* Corrected information about mass deployment in the [readme](README.md).
* Corrected the prerequisites in the [readme](README.md) so that they explicitly state what functions RoboCopy is needed for.
* Cleaned up formatting to be (hopefully) compliant with the standards published at https://poshcode.gitbooks.io/powershell-practice-and-style/content.
* Added the [release notes](CHANGELOG.md) to the module manifest.
* Added a [project icon](Icon.svg).

# Version 1.2.0
* Added the following functions, which resolve issue #3:
  - `Get-InstalledProduct`
  - `Get-MSIProperties`
  - `Install-MSI`
  - `Install-AxiumWorkstation`
  - `Write-AxiumFix`
* Cleaned up code style.
* Switched to using `Start-Process` instead of `&` to start `robocopy.exe` in `Copy-AxiumFiles` for the following reasons:
  * Allows for more detailed output on the result of running the command.
  * Is more consistent with how things are done in `Install-MSI`.
* Added a workflow to automatically publish the module to the PowerShell Gallery when a new release is made.
