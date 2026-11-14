#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Structural checks; not a substitute for qmllint or a live Plasma test."""
import json
import pathlib
import re
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]
APPLET_ID = "org.bezeza.alveusdock"
EXPECTED_LICENSE = "GPL-3.0-only"

metadata = json.loads((ROOT / "package/metadata.json").read_text(encoding="utf-8"))
spec = (ROOT / "packaging/alveus-dock.spec").read_text(encoding="utf-8")
version = metadata["KPlugin"]["Version"]
spec_version = re.search(r"^Version:\s+(\S+)", spec, re.MULTILINE)
assert metadata["KPlugin"]["Id"] == APPLET_ID
assert metadata["KPackageStructure"] == "Plasma/Applet"
assert metadata["X-Plasma-API-Minimum-Version"] == "6.8"
assert metadata["KPlugin"]["License"] == EXPECTED_LICENSE
assert spec_version and spec_version.group(1) == version, "RPM and applet versions differ"
assert re.search(r"^License:\s+GPL-3\.0-only$", spec, re.MULTILINE)
license_text = (ROOT / "LICENSE").read_text(encoding="utf-8")
assert "GNU GENERAL PUBLIC LICENSE" in license_text
assert "Version 3, 29 June 2007" in license_text

required = [
    "AGENTS.md",
    ".contextProperties.ini",
    ".qmllint.ini",
    "README.md",
    "tests/test_package_contract.py",
    "docs/PERFORMANCE.md",
    "scripts/profile-plasmashell.py",
    "CHANGELOG.md",
    "package/contents/ui/main.qml",
    "package/contents/ui/TaskDelegate.qml",
    "package/contents/ui/GroupWindowChooser.qml",
    "package/contents/config/config.qml",
    "package/contents/config/ConfigAppearance.qml",
    "package/contents/config/ConfigBehavior.qml",
    "package/contents/config/ConfigLayout.qml",
    "package/contents/config/main.xml",
    "packaging/alveus-dock.spec",
    "packaging/COPR.md",
    "docs/ROADMAP.md",
    "docs/DEVELOPMENT_LOG.md",
    "docs/LOGGING.md",
    "docs/SCREENSHOTS.md",
    "scripts/build-rpm.sh",
    "scripts/collect-logs.sh",
    ".github/workflows/build-rpm.yml",
]
for relative in required:
    assert (ROOT / relative).is_file(), f"Missing {relative}"

ET.parse(ROOT / "package/contents/config/main.xml")

qml = (ROOT / "package/contents/ui/main.qml").read_text(encoding="utf-8")
task_delegate = (ROOT / "package/contents/ui/TaskDelegate.qml").read_text(encoding="utf-8")
qml_all = qml + "\n" + task_delegate
for token in [
    "org.kde.taskmanager",
    "TaskManager.TasksModel",
    "requestActivate",
    "requestToggleMinimized",
    "requestPublishDelegateGeometry",
    "groupApplications",
    "GroupApplications",
    "GroupWindowChooser",
    "groupWindowChooser",
    "windowCountBadge",
    "requestToggleGrouping",
    "mapToGlobal(0, 0)",
    "publishIconGeometry",
    "requestAddLauncher",
    "requestRemoveLauncher",
    "requestOpenUrls",
    "requestNewInstance",
    "requestClose",
    "taskModel.move(sourceIndex, reorderTargetIndex)",
    "taskModel.syncLaunchers",
    "taskReorderingEnabled",
    "ListView.onPooled",
    "ListView.onReused",
    "pragma ComponentBehavior: Bound",
    "launchBounce",
    "launchPulse",
    "attentionReaction",
    "DropArea",
    "reorderList.indexAt",
    "taskList.indexAt",
    "itemAtIndex(",
    "drop.source.dockIndex",
    "Drag.source: delegateRoot",
    "[AlveusDock][INFO]",
    "[AlveusDock][WARN]",
    "[AlveusDock][ERROR]",
    "applet-started",
    "action-failed:",
]:
    assert token in qml_all, f"Missing QML feature: {token}"

for relative in [
    "package/contents/ui/main.qml",
    "package/contents/ui/TaskDelegate.qml",
    "package/contents/ui/GroupWindowChooser.qml",
    "package/contents/config/config.qml",
    "package/contents/config/ConfigAppearance.qml",
    "package/contents/config/ConfigBehavior.qml",
    "package/contents/config/ConfigLayout.qml",
]:
    source = (ROOT / relative).read_text(encoding="utf-8")
    assert "SPDX-License-Identifier: GPL-3.0-only" in source, f"Wrong or missing SPDX header in {relative}"

behavior = (ROOT / "package/contents/config/ConfigBehavior.qml").read_text(encoding="utf-8")
for token in ["cfg_enableAttentionReaction", "cfg_enableDragReorder", "cfg_groupApplications"]:
    assert token in behavior, f"Missing setting: {token}"

for dependency in [
    "plasma-workspace >= 6.8.0",
    "plasma-workspace-libs >= 6.8.0",
    "libplasma >= 6.8.0",
    "kf6-kcmutils",
    "kf6-kirigami",
    "qt6-qtdeclarative",
]:
    assert dependency in spec, f"Missing RPM dependency: {dependency}"

build_script = (ROOT / "scripts/build-rpm.sh").read_text(encoding="utf-8")
assert "0.1.1" not in build_script, "Old hard-coded source version remains"
assert "$NAME-$VERSION.tar.gz" in build_script

workflow = (ROOT / ".github/workflows/build-rpm.yml").read_text(encoding="utf-8")
for token in ["qmllint", "scripts/check-package.py", "scripts/build-rpm.sh", "actions/upload-artifact@v4"]:
    assert token in workflow, f"Missing CI step: {token}"

assert "dropTarget" not in qml, "Stale dropTarget reference remains"
assert qml.count("DropArea {") == 1
qml_version = re.search(r'version:\s*"([^"]+)"', qml)
assert qml_version and qml_version.group(1) == version, "Runtime log and package versions differ"
layout_config = (ROOT / "package/contents/config/ConfigLayout.qml").read_text(encoding="utf-8")
for token in ["cfg_dockLayoutMode", "cfg_layerSpacing", "Single row", "Dual layer", "Adaptive"]:
    assert token in layout_config, f"Missing layout control: {token}"

assert "dockLayoutMode" in (ROOT / "package/contents/config/main.xml").read_text(encoding="utf-8")
assert "layerSpacing" in (ROOT / "package/contents/config/main.xml").read_text(encoding="utf-8")
assert "UnqualifiedAccess=error" in (ROOT / ".qmllint.ini").read_text(encoding="utf-8")
assert "docs/SCREENSHOTS.md" in (ROOT / "README.md").read_text(encoding="utf-8")

print(f"Alveus Dock {version} structural checks: OK")
print("QML lint and live Plasma validation are separate required checks.")
