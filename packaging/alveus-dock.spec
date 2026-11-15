Name:           alveus-dock
Version:        0.1.3
Release:        1%{?dist}
Summary:        Configurable single and dual-layer application dock for KDE Plasma 6

License:        GPL-3.0-only
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

Requires:       plasma-workspace >= 6.8.0
Requires:       plasma-workspace-libs >= 6.8.0
Requires:       libplasma >= 6.8.0
Requires:       kf6-kcmutils
Requires:       kf6-kirigami
Requires:       qt6-qtdeclarative

%description
Alveus Dock is a KDE Plasma applet using KDE's native TaskManager model for
pinned launchers and running windows. It supports single-row, dual-layer and
adaptive layouts, grouped windows, launcher drops and lightweight icon reactions.

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
* Sat Nov 14 2026 Alveus Dock contributors - 0.1.3-1
- Stabilize task reordering and launcher synchronization
- Reset recycled delegate animation state
- Tighten diagnostics privacy and QML linting
