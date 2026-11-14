# Fedora COPR publication

The project has a noarch RPM spec but is not published to COPR yet.

After the applet passes a real Plasma 6.8.x runtime test:

1. Create a COPR project named `alveus-dock`.
2. Build the source RPM or submit the source archive using `copr-cli`.
3. Test installation, upgrade and removal in a clean Fedora KDE session.
4. Publish the exact COPR owner and install instructions only after a successful build.

Expected commands after publication:

```bash
sudo dnf copr enable OWNER/alveus-dock
sudo dnf install alveus-dock
```

For a local RPM build:

```bash
sudo dnf install ./alveus-dock-0.1.2-1.fc*.noarch.rpm
```

Do not present the COPR commands as working until the repository exists.
