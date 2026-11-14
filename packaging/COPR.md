# Fedora COPR publication

The RPM spec and GitHub Actions build are prepared, but Alveus Dock is **not published to COPR yet**. The owner name and repository URL must not be guessed.

## Before publication

1. Confirm the Fedora 44 / KDE Plasma 6.8.x runtime test passes.
2. Confirm clean install, upgrade and removal using the built RPM.
3. Create a COPR project named alveus-dock under the actual maintainer account.
4. Configure COPR credentials as GitHub Actions secrets if automated publishing is desired.
5. Build and test the package from a tagged release.
6. Replace OWNER in the commands below with the real COPR owner only after the repository is public.

## DNF installation after COPR is published

~~~bash
sudo dnf copr enable OWNER/alveus-dock
sudo dnf install alveus-dock
~~~

## Install a local RPM before COPR publication

~~~bash
sudo dnf install ./rpmbuild/RPMS/noarch/alveus-dock-*.rpm
~~~

Remove the package with:

~~~bash
sudo dnf remove alveus-dock
~~~

Do not present the COPR commands as working until the repository exists and the package has passed runtime testing.
