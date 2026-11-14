#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Regression tests for the Alveus Dock package and QML integration contract."""

import json
import pathlib
import re
import unittest
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]
QML_PATH = ROOT / "package/contents/ui/main.qml"
CONFIG_XML_PATH = ROOT / "package/contents/config/main.xml"
APP_CONFIG_PATHS = [
    ROOT / "package/contents/config/ConfigAppearance.qml",
    ROOT / "package/contents/config/ConfigBehavior.qml",
]
KCFG_NS = "{http://www.kde.org/standards/kcfg/1.0}"


class PackageContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.qml = QML_PATH.read_text(encoding="utf-8")
        cls.metadata = json.loads((ROOT / "package/metadata.json").read_text(encoding="utf-8"))
        cls.spec = (ROOT / "packaging/alveus-dock.spec").read_text(encoding="utf-8")
        cls.kcfg = ET.parse(CONFIG_XML_PATH).getroot()
        cls.config_qml = "\n".join(path.read_text(encoding="utf-8") for path in APP_CONFIG_PATHS)

    def test_applet_and_rpm_versions_match(self):
        version = self.metadata["KPlugin"]["Version"]
        spec_match = re.search(r"^Version:\s+(\S+)", self.spec, re.MULTILINE)
        qml_match = re.search(r'version:\s*"([^"]+)"', self.qml)
        self.assertIsNotNone(spec_match)
        self.assertIsNotNone(qml_match)
        self.assertEqual(version, spec_match.group(1))
        self.assertEqual(version, qml_match.group(1))

    def test_applet_identity_and_license(self):
        self.assertEqual(self.metadata["KPackageStructure"], "Plasma/Applet")
        self.assertEqual(self.metadata["KPlugin"]["Id"], "org.bezeza.alveusdock")
        self.assertEqual(self.metadata["KPlugin"]["License"], "GPL-3.0-only")
        self.assertEqual(self.metadata["X-Plasma-API-Minimum-Version"], "6.8")
        self.assertIn("License:        GPL-3.0-only", self.spec)

    def test_every_user_setting_has_a_configuration_control(self):
        entries = {
            entry.attrib["name"]
            for entry in self.kcfg.findall(f".//{KCFG_NS}entry")
        }
        aliases = set(re.findall(r"property\s+alias\s+cfg_(\w+)\s*:", self.config_qml))
        # launchers is persisted by the task model, not edited as a scalar setting.
        entries.discard("launchers")
        self.assertEqual(aliases, entries)

    def test_numeric_controls_match_kconfig_limits(self):
        controls = {"iconSize": "iconSize", "iconSpacing": "iconSpacing", "hoverScale": "hoverScale"}
        for setting, control_id in controls.items():
            entry = self.kcfg.find(f".//{KCFG_NS}entry[@name='{setting}']")
            self.assertIsNotNone(entry, f"Missing KConfig entry: {setting}")
            minimum = entry.find(f"{KCFG_NS}min").text
            maximum = entry.find(f"{KCFG_NS}max").text
            marker = f"id: {control_id}"
            marker_pos = self.config_qml.find(marker)
            self.assertGreaterEqual(marker_pos, 0, f"Missing SpinBox: {control_id}")
            block_start = self.config_qml.rfind("QQC2.SpinBox {", 0, marker_pos)
            block_end = self.config_qml.find("\n        }", marker_pos)
            block = self.config_qml[block_start:block_end]
            self.assertRegex(block, rf"from:\s*{minimum}\b")
            self.assertRegex(block, rf"to:\s*{maximum}\b")

    def test_manual_reordering_syncs_persisted_launchers(self):
        move_pos = self.qml.find("taskModel.move(sourceIndex, targetIndex)")
        sync_pos = self.qml.find("taskModel.syncLaunchers()", move_pos)
        self.assertGreaterEqual(move_pos, 0)
        self.assertGreater(sync_pos, move_pos)
        self.assertIn("if (moved === true)", self.qml[move_pos:sync_pos])
        self.assertIn("drop.acceptProposedAction()", self.qml[sync_pos:])

    def test_recycled_delegates_reset_transient_state(self):
        pooled = self.qml.find("ListView.onPooled")
        reused = self.qml.find("ListView.onReused")
        self.assertGreaterEqual(pooled, 0)
        self.assertGreater(reused, pooled)
        pooled_block = self.qml[pooled:reused]
        for token in ["hovered = false", "launchScale = 1.0", "launchBounce.stop()",
                      "launchPulse.stop()", "attentionReaction.stop()", "energyPulse.opacity = 0",
                      "attentionRing.opacity = 0", "contextMenu.close()"]:
            self.assertIn(token, pooled_block)
        self.assertIn("launchScale = 1.0", self.qml[reused:])

    def test_qmllint_fails_on_unqualified_access(self):
        lint_config = (ROOT / ".qmllint.ini").read_text(encoding="utf-8")
        self.assertIn("UnqualifiedAccess=error", lint_config)
        self.assertIn("pragma ComponentBehavior: Bound", self.qml)

    def test_diagnostics_do_not_copy_exception_messages(self):
        logger_start = self.qml.find("function logError")
        logger_end = self.qml.find("\n    }", logger_start)
        logger = self.qml[logger_start:logger_end]
        self.assertIn("error.name", logger)
        self.assertIn("errorType", logger)
        self.assertNotIn("error.message", logger)
        self.assertNotIn("String(error)", logger)
        self.assertIn('logInfo("action-dispatched"', self.qml)

    def test_animations_are_finite(self):
        self.assertNotIn("loops: Animation.Infinite", self.qml)
        self.assertRegex(self.qml, r"loops:\s*2\b")

    def test_reorder_rejects_out_of_range_indices(self):
        self.assertIn("Number.isInteger(sourceIndex)", self.qml)
        self.assertIn("sourceIndex >= taskModel.count", self.qml)
        self.assertIn("targetIndex >= taskModel.count", self.qml)

    def test_kde_minimize_effect_geometry_is_published(self):
        self.assertIn("function globalRect(item)", self.qml)
        self.assertIn("item.mapToGlobal(0, 0)", self.qml)
        self.assertIn("taskModel.requestPublishDelegateGeometry(", self.qml)
        self.assertIn("delegateRoot.model.IsWindow", self.qml)
        self.assertRegex(
            self.qml,
            r"requestPublishDelegateGeometry\\(\\s*delegateRoot\\.modelIndex\\(\\),"
            r"\\s*geometry,\\s*delegateRoot\\s*\\)",
        )

    def test_window_geometry_is_refreshed_after_layout_changes(self):
        for token in [
            "onXChanged: scheduleIconGeometryPublish()",
            "onYChanged: scheduleIconGeometryPublish()",
            "onWidthChanged: scheduleIconGeometryPublish()",
            "onHeightChanged: scheduleIconGeometryPublish()",
            "onLocationChanged()",
            "onScreenGeometryChanged()",
            "root.publishAllDelegateGeometries()",
            "delegateRoot.scheduleIconGeometryPublish()",
        ]:
            self.assertIn(token, self.qml)

    def test_project_has_performance_diagnostic(self):
        self.assertTrue((ROOT / "docs/PERFORMANCE.md").is_file())
        self.assertTrue((ROOT / "scripts/profile-plasmashell.py").is_file())


if __name__ == "__main__":
    unittest.main()
