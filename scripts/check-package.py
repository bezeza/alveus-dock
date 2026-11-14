#!/usr/bin/env python3
"""Structural checks; not a substitute for qmllint or a live Plasma test."""
import json
import pathlib
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]
APPLET_ID = "org.bezeza.alveusdock"

metadata = json.loads((ROOT / "package/metadata.json").read_text(encoding="utf-8"))
assert metadata["KPlugin"]["Id"] == APPLET_ID
assert metadata["KPackageStructure"] == "Plasma/Applet"

required = [
    "package/contents/ui/main.qml",
    "package/contents/config/config.qml",
    "package/contents/config/ConfigAppearance.qml",
    "package/contents/config/ConfigBehavior.qml",
    "package/contents/config/main.xml",
    "packaging/alveus-dock.spec",
    "CHANGELOG.md",
    "docs/ROADMAP.md",
    "docs/DEVELOPMENT_LOG.md",
    "docs/LOGGING.md",
    "scripts/collect-logs.sh",
]
for relative in required:
    assert (ROOT / relative).is_file(), f"Missing {relative}"

ET.parse(ROOT / "package/contents/config/main.xml")
qml = (ROOT / "package/contents/ui/main.qml").read_text(encoding="utf-8")
for token in [
    "org.kde.taskmanager",
    "TaskManager.TasksModel",
    "requestActivate",
    "requestAddLauncher",
    "requestRemoveLauncher",
    "requestOpenUrls",
    "taskModel.move",
    "taskReorderingEnabled",
    "launchBounce",
    "launchPulse",
    "attentionReaction",
    "DropArea",
    "dockList.indexAt",
    "drop.source.dockIndex",
    "Drag.source: delegateRoot",
    "[AlveusDock][INFO]",
    "[AlveusDock][WARN]",
    "[AlveusDock][ERROR]",
    "applet-started",
    "action-failed:",
]:
    assert token in qml, f"Missing QML feature: {token}"

behavior = (ROOT / "package/contents/config/ConfigBehavior.qml").read_text(encoding="utf-8")
for token in ["cfg_enableAttentionReaction", "cfg_enableDragReorder"]:
    assert token in behavior, f"Missing setting: {token}"

spec = (ROOT / "packaging/alveus-dock.spec").read_text(encoding="utf-8")
for dependency in ["plasma-workspace", "libplasma", "kf6-kcmutils", "kf6-kirigami", "qt6-qtdeclarative"]:
    assert dependency in spec, f"Missing RPM dependency: {dependency}"

assert "dropTarget" not in qml, "Stale dropTarget reference remains"
assert qml.count("DropArea {") == 1
assert "Version:        0.1.2" in spec

print("Alveus Dock 0.1.2 structural checks: OK")
print("QML compilation and live Plasma validation are still required.")
