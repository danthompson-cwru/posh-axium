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

# Version 1.3.0
* Added the ability to pass public properties to `Install-MSI`.
* Fixed some documentation bugs.

# Version 1.3.1
* Fixed a bug where the path to the source files was not calculated correctly if `MultipleCopies` was set on `Copy-AxiumFiles`.

# Version 1.4.0
* Added ability to check if a copy of axiUm is installed in a given folder. Fixes issue #28.

# Version 1.4.1
* Added missing documentation for `Test-AxiumCopy` to `README.MD`. Fixes issue #29.
