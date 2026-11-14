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
GROUP_CHOOSER_PATH = ROOT / "package/contents/ui/GroupWindowChooser.qml"
TASK_DELEGATE_PATH = ROOT / "package/contents/ui/TaskDelegate.qml"
LAYOUT_CONFIG_PATH = ROOT / "package/contents/config/ConfigLayout.qml"
CONFIG_XML_PATH = ROOT / "package/contents/config/main.xml"
APP_CONFIG_PATHS = [
    ROOT / "package/contents/config/ConfigAppearance.qml",
    ROOT / "package/contents/config/ConfigBehavior.qml",
    LAYOUT_CONFIG_PATH,
]
KCFG_NS = "{http://www.kde.org/standards/kcfg/1.0}"


class PackageContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.qml = QML_PATH.read_text(encoding="utf-8")
        cls.group_chooser = GROUP_CHOOSER_PATH.read_text(encoding="utf-8")
        cls.task_delegate = TASK_DELEGATE_PATH.read_text(encoding="utf-8")
        cls.all_qml = cls.qml + "\n" + cls.task_delegate
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
        controls = {
            "iconSize": "iconSize",
            "iconSpacing": "iconSpacing",
            "hoverScale": "hoverScale",
            "layerSpacing": "layerSpacing",
        }
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
        move_pos = self.qml.find("taskModel.move(sourceIndex, reorderTargetIndex)")
        sync_pos = self.qml.find("taskModel.syncLaunchers()", move_pos)
        self.assertGreaterEqual(move_pos, 0)
        self.assertGreater(sync_pos, move_pos)
        self.assertIn("if (moved === true)", self.qml[move_pos:sync_pos])
        self.assertIn("drop.acceptProposedAction()", self.qml[sync_pos:])

    def test_recycled_delegates_reset_transient_state(self):
        pooled = self.task_delegate.find("ListView.onPooled")
        reused = self.task_delegate.find("ListView.onReused")
        self.assertGreaterEqual(pooled, 0)
        self.assertGreater(reused, pooled)
        pooled_block = self.task_delegate[pooled:reused]
        for token in ["hovered = false", "launchScale = 1.0", "launchBounce.stop()",
                      "launchPulse.stop()", "attentionReaction.stop()", "energyPulse.opacity = 0",
                      "attentionRing.opacity = 0", "contextMenu.close()"]:
            self.assertIn(token, pooled_block)
        self.assertIn("launchScale = 1.0", self.task_delegate[reused:])

    def test_qmllint_fails_on_unqualified_access(self):
        lint_config = (ROOT / ".qmllint.ini").read_text(encoding="utf-8")
        self.assertIn("UnqualifiedAccess=error", lint_config)
        self.assertIn("pragma ComponentBehavior: Bound", self.qml)
        self.assertIn("pragma ComponentBehavior: Bound", self.task_delegate)

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
        self.assertNotIn("loops: Animation.Infinite", self.all_qml)
        self.assertRegex(self.all_qml, r"loops:\s*2\b")

    def test_reorder_rejects_out_of_range_indices(self):
        self.assertIn("Number.isInteger(sourceIndex)", self.qml)
        self.assertIn("sourceIndex >= taskModel.count", self.qml)
        self.assertIn("reorderTargetIndex >= taskModel.count", self.qml)

    def test_grouping_setting_uses_native_tasks_model(self):
        entry = self.kcfg.find(f".//{KCFG_NS}entry[@name='groupApplications']")
        self.assertIsNotNone(entry)
        self.assertEqual(entry.attrib["type"], "Bool")
        self.assertEqual(entry.find(f"{KCFG_NS}default").text, "false")
        self.assertIn("cfg_groupApplications", self.config_qml)
        self.assertIn("id: groupApplications", self.config_qml)
        self.assertIn("TaskManager.TasksModel.GroupApplications", self.qml)
        self.assertIn("TaskManager.TasksModel.GroupDisabled", self.qml)
        self.assertIn("groupMode: Plasmoid.configuration.groupApplications", self.qml)

    def test_group_chooser_uses_hierarchical_task_model(self):
        self.assertIn("DelegateModel", self.group_chooser)
        self.assertIn(
            "rootIndex: chooser.taskModel.makeModelIndex(chooser.parentIndex)",
            self.group_chooser,
        )
        self.assertIn(
            "taskModel.makeModelIndex(parentIndex, childRow)",
            self.group_chooser,
        )
        self.assertIn("signal activateRequested(var childIndex)", self.group_chooser)
        self.assertIn("signal closeRequested(var childIndex)", self.group_chooser)
        self.assertIn("chooser.activateRequested(childIndex)", self.group_chooser)
        self.assertIn("chooser.closeRequested(childIndex)", self.group_chooser)

    def test_group_parent_has_window_count_badge_and_chooser(self):
        self.assertIn("delegateRoot.model.IsGroupParent", self.task_delegate)
        self.assertIn("dockRoot.toggleGroupChooser(delegateRoot)", self.task_delegate)
        self.assertIn("id: groupWindowChooser", self.qml)
        self.assertIn("dockRoot.groupVisualParent === delegateRoot", self.task_delegate)
        self.assertIn("id: windowCountBadge", self.task_delegate)
        self.assertIn("delegateRoot.childCount > 1", self.task_delegate)
        self.assertIn('qsTr("Ungroup windows")', self.task_delegate)

    def test_grouped_windows_keep_kde_minimize_geometry(self):
        self.assertIn(
            "!delegateRoot.model.IsWindow && !delegateRoot.model.IsGroupParent",
            self.task_delegate,
        )

    def test_group_chooser_closes_when_delegate_is_recycled(self):
        pooled = self.task_delegate.find("ListView.onPooled")
        reused = self.task_delegate.find("ListView.onReused")
        self.assertIn("dockRoot.closeGroupChooser()", self.task_delegate[pooled:reused])

    def test_group_chooser_supports_keyboard_navigation(self):
        self.assertIn("Keys.onEscapePressed", self.group_chooser)
        self.assertIn("Keys.onReturnPressed", self.group_chooser)
        self.assertIn("focus: true", self.group_chooser)
        self.assertIn("chooser.activateRequested(childIndex)", self.group_chooser)

    def test_group_actions_are_logged(self):
        self.assertIn('"activate-group-window"', self.task_delegate)
        self.assertIn('"close-group-window"', self.task_delegate)
        self.assertIn('"ungroup-windows"', self.task_delegate)

    def test_kde_minimize_effect_geometry_is_published(self):
        self.assertIn("function globalRect(item)", self.qml)
        self.assertIn("item.mapToGlobal(0, 0)", self.qml)
        self.assertIn("taskModel.requestPublishDelegateGeometry(", self.task_delegate)
        self.assertIn("delegateRoot.model.IsWindow", self.task_delegate)
        self.assertIn("publishIconGeometry();", self.task_delegate)
        minimize_pos = self.task_delegate.find('dockRoot.runAction("toggle-minimized"')
        publish_pos = self.task_delegate.rfind("publishIconGeometry();", 0, minimize_pos)
        self.assertGreaterEqual(publish_pos, 0)
        self.assertIn(
            "delegateRoot.modelIndex(),\n            geometry,\n            delegateRoot",
            self.task_delegate,
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
            "signal iconGeometryRefreshRequested()",
            "function onIconGeometryRefreshRequested()",
            "delegateRoot.scheduleIconGeometryPublish()",
        ]:
            self.assertIn(token, self.qml + "\n" + self.task_delegate)


    def test_layout_settings_have_safe_defaults_and_controls(self):
        mode = self.kcfg.find(f".//{KCFG_NS}entry[@name='dockLayoutMode']")
        spacing = self.kcfg.find(f".//{KCFG_NS}entry[@name='layerSpacing']")
        self.assertIsNotNone(mode)
        self.assertIsNotNone(spacing)
        self.assertEqual(mode.attrib["type"], "Int")
        self.assertEqual(mode.find(f"{KCFG_NS}default").text, "0")
        self.assertEqual(mode.find(f"{KCFG_NS}min").text, "0")
        self.assertEqual(mode.find(f"{KCFG_NS}max").text, "2")
        self.assertEqual(spacing.find(f"{KCFG_NS}default").text, "4")
        self.assertIn("cfg_dockLayoutMode", self.config_qml)
        self.assertIn("cfg_layerSpacing", self.config_qml)
        for label in ["Single row", "Dual layer", "Adaptive"]:
            self.assertIn(label, self.config_qml)

    def test_dual_layout_uses_one_native_model_with_two_filtered_views(self):
        self.assertIn("separateLaunchers: root.splitLayoutEnabled", self.qml)
        self.assertIn("launchInPlace: !root.splitLayoutEnabled", self.qml)
        self.assertIn('filterOnGroup: "quickAccess"', self.qml)
        self.assertIn('filterOnGroup: "runningTasks"', self.qml)
        self.assertIn('name: "quickAccess"', self.qml)
        self.assertIn('name: "runningTasks"', self.qml)
        self.assertIn("visualModel.items.addGroups", self.qml)
        self.assertIn("visualModel.items.removeGroups", self.qml)
        self.assertIn("TaskManager.AbstractTasksModel.IsLauncher", self.qml)
        self.assertIn("TaskManager.AbstractTasksModel.IsWindow", self.qml)
        self.assertIn("TaskManager.AbstractTasksModel.IsGroupParent", self.qml)
        self.assertIn("TaskManager.AbstractTasksModel.IsStartup", self.qml)

    def test_single_dual_and_adaptive_layouts_are_distinct(self):
        self.assertIn("dockLayoutMode === 1", self.qml)
        self.assertIn("dockLayoutMode === 2", self.qml)
        self.assertIn("id: singleDockList", self.qml)
        self.assertIn("id: quickAccessList", self.qml)
        self.assertIn("id: runningTasksList", self.qml)
        self.assertIn("root.vertical ? root.itemExtent", self.qml)
        self.assertIn("root.itemExtent + root.layerSpacing", self.qml)
        self.assertIn("Layout.preferredHeight: vertical ? panelLength : panelThickness", self.qml)

    def test_running_layer_is_not_manually_reordered(self):
        self.assertIn("allowReorder: false", self.qml)
        self.assertIn(
            "enabled: Plasmoid.configuration.enableDragReorder && delegateRoot.allowReorder",
            self.task_delegate,
        )
        self.assertIn("if (!sourceIsLauncher || !targetIsLauncher)", self.qml)

    def test_filtered_views_keep_source_model_indices(self):
        self.assertIn("sourceIndex: DelegateModel.itemsIndex", self.qml)
        self.assertIn("return taskModel.makeModelIndex(sourceIndex)", self.task_delegate)
        self.assertIn("delegateRoot.modelIndex(),", self.task_delegate)
        self.assertIn("taskDelegate ? taskDelegate.sourceIndex : -1", self.qml)
        self.assertIn("reorderDelegate ? reorderDelegate.sourceIndex : -1", self.qml)

    def test_project_has_performance_diagnostic(self):
        self.assertTrue((ROOT / "docs/PERFORMANCE.md").is_file())
        self.assertTrue((ROOT / "scripts/profile-plasmashell.py").is_file())


if __name__ == "__main__":
    unittest.main()
