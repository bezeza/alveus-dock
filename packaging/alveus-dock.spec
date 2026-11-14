Name:           alveus-dock
Version:        0.1.2
Release:        1%{?dist}
Summary:        Lightweight animated application dock for KDE Plasma 6

License:        GPL-2.0-or-later
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

Requires:       plasma-workspace >= 6.8.0
Requires:       libplasma >= 6.8.0
Requires:       kf6-kcmutils
Requires:       kf6-kirigami
Requires:       qt6-qtdeclarative

%description
Alveus Dock is a compact KDE Plasma applet using KDE's native TaskManager
model for application launchers and window actions. It adds lightweight
icon reactions, launcher drops and manual task reordering.

%prep
%autosetup -n %{name}-%{version}

%build
:

%install
install -d %{buildroot}%{_datadir}/plasma/plasmoids/org.bezeza.alveusdock
cp -a package/. %{buildroot}%{_datadir}/plasma/plasmoids/org.bezeza.alveusdock/

%files
%license LICENSE
%doc README.md
%{_datadir}/plasma/plasmoids/org.bezeza.alveusdock

%changelog
* Sat Nov 14 2026 Alveus Dock contributors - 0.1.2-1
- Add privacy-conscious runtime diagnostics
- Add changelog, development log and expanded roadmap
- Add journal log collection helper
- Fix drop overlay placement and stale delegate property reference
