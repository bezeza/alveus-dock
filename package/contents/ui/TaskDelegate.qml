/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Shared task/launcher delegate used by the single- and dual-layer layouts.
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

Item {
    id: delegateRoot

    required property int index
    required property var model
    required property var dockRoot
    required property var taskModel
    required property int sourceIndex
    property bool allowReorder: true

    readonly property int dockIndex: sourceIndex
    property real launchScale: 1.0
    property bool hovered: false
    property bool demandingAttention: !!model.IsDemandingAttention
    readonly property int childCount: Number(model.ChildCount || 0)

    Accessible.name: String(model.display || "")
        + (model.IsGroupParent ? qsTr(", %1 windows").arg(childCount) : "")
    Accessible.role: Accessible.Button

    width: delegateRoot.dockRoot.itemExtentForTask(model.IsLauncher)
    height: delegateRoot.dockRoot.itemExtentForTask(model.IsLauncher)
    z: hovered ? 2 : 0

    onDemandingAttentionChanged: {
        if (demandingAttention && Plasmoid.configuration.enableAttentionReaction) {
            delegateRoot.dockRoot.logInfo("attention-requested", { dockIndex: dockIndex });
            attentionReaction.restart();
        }
    }

    // ListView can recycle delegates. Reset transient visual state so an
    // icon never inherits another application's hover or animation state.
    ListView.onPooled: {
        delegateRoot.hovered = false;
        delegateRoot.launchScale = 1.0;
        launchBounce.stop();
        launchPulse.stop();
        attentionReaction.stop();
        energyPulse.opacity = 0;
        energyPulse.scale = 0.45;
        attentionRing.opacity = 0;
        attentionRing.scale = 0.8;
        contextMenu.close();
        if (delegateRoot.dockRoot.groupVisualParent === delegateRoot) {
            delegateRoot.dockRoot.closeGroupChooser();
        }
    }

    ListView.onReused: {
        delegateRoot.hovered = false;
        delegateRoot.launchScale = 1.0;
        if (delegateRoot.demandingAttention
                && Plasmoid.configuration.enableAttentionReaction) {
            attentionReaction.restart();
        }
        delegateRoot.scheduleIconGeometryPublish();
    }

    function modelIndex() {
        return delegateRoot.taskModel.makeModelIndex(sourceIndex);
    }

    // KDE TaskManager::appsMatch compares AppId first and then compares the
    // LauncherUrlWithoutIcon roles directly. Do not strip arbitrary query data.
    function launcherUrlKey(value) {
        return String(value || "");
    }

    function launcherMatchesTask(index, launcherAppId, launcherUrl) {
        const candidateAppId = String(delegateRoot.taskModel.data(
            index,
            TaskManager.AbstractTasksModel.AppId
        ) || "");
        if (launcherAppId && launcherAppId === candidateAppId) {
            return true;
        }

        // Match KDE TaskManager::appsMatch: compare LauncherUrlWithoutIcon
        // when AppIds do not match, including when both IDs are present.
        const candidateUrl = launcherUrlKey(delegateRoot.taskModel.data(
            index,
            TaskManager.AbstractTasksModel.LauncherUrlWithoutIcon
        ));
        return launcherUrl !== "" && candidateUrl !== "" && launcherUrl === candidateUrl;
    }

    function lastActivatedTimestamp(index) {
        const value = delegateRoot.taskModel.data(
            index,
            TaskManager.AbstractTasksModel.LastActivated
        );
        if (value && typeof value.getTime === "function") {
            return value.getTime();
        }
        const numericValue = Number(value);
        if (Number.isFinite(numericValue)) {
            return numericValue;
        }
        const parsedValue = Date.parse(String(value || ""));
        return Number.isFinite(parsedValue) ? parsedValue : 0;
    }

    function isMoreRecentlyActivated(candidateIndex, currentBestIndex) {
        if (!currentBestIndex) {
            return true;
        }

        const candidateIsActive = !!delegateRoot.taskModel.data(
            candidateIndex,
            TaskManager.AbstractTasksModel.IsActive
        );
        const currentBestIsActive = !!delegateRoot.taskModel.data(
            currentBestIndex,
            TaskManager.AbstractTasksModel.IsActive
        );
        if (candidateIsActive !== currentBestIsActive) {
            return candidateIsActive;
        }
        return lastActivatedTimestamp(candidateIndex) > lastActivatedTimestamp(currentBestIndex);
    }

    function findRunningTaskForLauncher() {
        const launcherAppId = String(delegateRoot.model.AppId || "");
        const launcherUrl = launcherUrlKey(
            delegateRoot.model.LauncherUrlWithoutIcon || delegateRoot.model.LauncherUrl
        );
        if (!launcherAppId && !launcherUrl) {
            return null;
        }

        let bestWindowIndex = null;
        let matchingStartupFound = false;

        // Search the same native TasksModel used by both dock layers. This
        // keeps matching consistent with the configured desktop/screen filters.
        for (let row = 0; row < delegateRoot.taskModel.count; ++row) {
            const candidateIndex = delegateRoot.taskModel.makeModelIndex(row);
            if (delegateRoot.taskModel.data(
                    candidateIndex,
                    TaskManager.AbstractTasksModel.IsLauncher
                )) {
                continue;
            }

            const isGroupParent = !!delegateRoot.taskModel.data(
                candidateIndex,
                TaskManager.AbstractTasksModel.IsGroupParent
            );
            if (isGroupParent) {
                let groupMatches = launcherMatchesTask(
                    candidateIndex,
                    launcherAppId,
                    launcherUrl
                );
                if (!groupMatches) {
                    const childCount = delegateRoot.taskModel.rowCount(candidateIndex);
                    for (let childRow = 0; childRow < childCount; ++childRow) {
                        const childIndex = delegateRoot.taskModel.makeModelIndex(row, childRow);
                        const isWindow = !!delegateRoot.taskModel.data(
                            childIndex,
                            TaskManager.AbstractTasksModel.IsWindow
                        );
                        if (isWindow && launcherMatchesTask(childIndex, launcherAppId, launcherUrl)) {
                            groupMatches = true;
                            break;
                        }
                    }
                }
                if (groupMatches) {
                    // The user pinned an application, not a particular window.
                    // Let them choose when KDE has grouped multiple windows.
                    return { kind: "group", parentRow: row };
                }
                continue;
            }

            const isWindow = !!delegateRoot.taskModel.data(
                candidateIndex,
                TaskManager.AbstractTasksModel.IsWindow
            );
            if (isWindow && launcherMatchesTask(candidateIndex, launcherAppId, launcherUrl)) {
                if (isMoreRecentlyActivated(candidateIndex, bestWindowIndex)) {
                    bestWindowIndex = candidateIndex;
                }
                continue;
            }

            const isStartup = !!delegateRoot.taskModel.data(
                candidateIndex,
                TaskManager.AbstractTasksModel.IsStartup
            );
            if (isStartup && launcherMatchesTask(candidateIndex, launcherAppId, launcherUrl)) {
                matchingStartupFound = true;
            }
        }

        if (bestWindowIndex) {
            return { kind: "window", index: bestWindowIndex };
        }
        if (matchingStartupFound) {
            return { kind: "starting" };
        }
        return null;
    }

    function publishIconGeometry() {
        if (!delegateRoot.visible
                || !delegateRoot.model
                || (!delegateRoot.model.IsWindow && !delegateRoot.model.IsGroupParent)
                || delegateRoot.model.IsLauncher
                || delegateRoot.model.IsStartup) {
            return;
        }

        const geometry = delegateRoot.dockRoot.globalRect(delegateRoot);
        delegateRoot.taskModel.requestPublishDelegateGeometry(
            delegateRoot.modelIndex(),
            geometry,
            delegateRoot
        );
    }

    function scheduleIconGeometryPublish() {
        Qt.callLater(publishIconGeometry);
    }

    Connections {
        target: delegateRoot.dockRoot

        function onIconGeometryRefreshRequested() {
            delegateRoot.scheduleIconGeometryPublish();
        }
    }

    onXChanged: scheduleIconGeometryPublish()
    onYChanged: scheduleIconGeometryPublish()
    onWidthChanged: scheduleIconGeometryPublish()
    onHeightChanged: scheduleIconGeometryPublish()

    Component.onCompleted: scheduleIconGeometryPublish()

    function activateTask() {
        const idx = modelIndex();

        if (model.IsGroupParent) {
            delegateRoot.dockRoot.toggleGroupChooser(delegateRoot);
            if (delegateRoot.dockRoot.groupVisualParent === delegateRoot) {
                delegateRoot.dockRoot.logInfo("window-chooser-opened", { childCount: childCount });
            }
            return;
        }

        if (model.IsLauncher) {
            const existingTask = findRunningTaskForLauncher();
            if (existingTask && existingTask.kind === "group") {
                // Anchor the chooser to the pinned icon while keeping the
                // group's top-level source row for the hierarchical child model.
                delegateRoot.dockRoot.toggleGroupChooser(delegateRoot, existingTask.parentRow);
                delegateRoot.dockRoot.logInfo("launcher-group-chooser-toggled", {
                    taskIndex: existingTask.parentRow
                });
            } else if (existingTask && existingTask.kind === "window") {
                // Quick Access raises the most recently active window; it never
                // minimizes an application just because its launcher was clicked.
                delegateRoot.dockRoot.runAction(
                    "activate-existing-application",
                    () => delegateRoot.taskModel.requestActivate(existingTask.index)
                );
            } else if (existingTask && existingTask.kind === "starting") {
                // A startup task already exists. Do not dispatch a duplicate launch.
                delegateRoot.dockRoot.logInfo("launcher-click-while-starting", {});
            } else {
                delegateRoot.playLaunchReaction();
                delegateRoot.dockRoot.runAction(
                    "launch-application",
                    () => delegateRoot.taskModel.requestActivate(idx)
                );
            }
            return;
        }

        if (model.IsWindow && model.IsActive) {
            // Refresh the target immediately before asking KWin to minimize.
            publishIconGeometry();
            delegateRoot.dockRoot.runAction("toggle-minimized", () => delegateRoot.taskModel.requestToggleMinimized(idx));
        } else {
            delegateRoot.dockRoot.runAction("activate-window", () => delegateRoot.taskModel.requestActivate(idx));
        }
    }

    onChildCountChanged: {
        if (childCount < 2 && delegateRoot.dockRoot.groupVisualParent === delegateRoot) {
            delegateRoot.dockRoot.closeGroupChooser();
        }
    }

    onModelChanged: {
        scheduleIconGeometryPublish();
        if (delegateRoot.dockRoot.groupVisualParent === delegateRoot) {
            delegateRoot.dockRoot.closeGroupChooser();
        }
    }

    onSourceIndexChanged: {
        // A moved source row can still occupy the same visual geometry. Republish
        // it so KWin's minimize target follows the task's new model index.
        scheduleIconGeometryPublish();

        // A grouped-window chooser may be anchored to a Quick Access launcher.
        // In that case its parentIndex is the separate running-group row, not
        // this launcher's source index. Only a group delegate owns that index.
        if (delegateRoot.dockRoot.groupVisualParent === delegateRoot
                && !!delegateRoot.model.IsGroupParent) {
            delegateRoot.dockRoot.groupParentIndex = sourceIndex;
        }
    }

    function playLaunchReaction() {
        // Do not bounce when merely switching to an already-running window.
        if (!(model.IsLauncher || model.IsStartup)) {
            return;
        }

        if (Plasmoid.configuration.enableLaunchBounce) {
            launchBounce.restart();
        }
        if (Plasmoid.configuration.showLaunchPulse) {
            launchPulse.restart();
        }
    }

    Kirigami.Icon {
        id: appIcon

        anchors.centerIn: parent
        width: delegateRoot.dockRoot.iconSizeForTask(delegateRoot.model.IsLauncher)
        height: delegateRoot.dockRoot.iconSizeForTask(delegateRoot.model.IsLauncher)
        source: delegateRoot.model.decoration
        active: delegateRoot.hovered
        enabled: true
        scale: delegateRoot.launchScale
               * (delegateRoot.hovered ? delegateRoot.dockRoot.hoverScale : 1.0)

        Behavior on scale {
            NumberAnimation {
                duration: 135
                easing.type: Easing.OutCubic
            }
        }
    }

    // Count badge makes grouped windows visible without changing the icon.
    Rectangle {
        id: windowCountBadge

        visible: !!delegateRoot.model.IsGroupParent && delegateRoot.childCount > 1
        width: Math.max(17, badgeText.implicitWidth + 8)
        height: 17
        radius: height / 2
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: Kirigami.Theme.textColor
        z: 4

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: delegateRoot.childCount
            color: Kirigami.Theme.backgroundColor
            font.pixelSize: 10
            font.bold: true
        }
    }

    // A short energy ring, triggered only by a user action.
    Rectangle {
        id: energyPulse

        anchors.centerIn: appIcon
        width: delegateRoot.dockRoot.iconSizeForTask(delegateRoot.model.IsLauncher) * 0.68
        height: width
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: Kirigami.Theme.highlightColor
        opacity: 0
        scale: 0.45
        visible: opacity > 0.01
    }

    // One finite attention reaction. No idle animation loop.
    Rectangle {
        id: attentionRing

        anchors.centerIn: appIcon
        width: delegateRoot.dockRoot.iconSizeForTask(delegateRoot.model.IsLauncher) * 0.9
        height: width
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: Kirigami.Theme.highlightColor
        opacity: 0
        scale: 0.8
        visible: opacity > 0.01
    }

    SequentialAnimation {
        id: launchBounce

        NumberAnimation {
            target: delegateRoot
            property: "launchScale"
            to: 1.16
            duration: 95
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: delegateRoot
            property: "launchScale"
            to: 0.95
            duration: 65
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: delegateRoot
            property: "launchScale"
            to: 1.0
            duration: 145
            easing.type: Easing.OutBack
        }
    }

    ParallelAnimation {
        id: launchPulse

        NumberAnimation {
            target: energyPulse
            property: "scale"
            from: 0.45
            to: 1.7
            duration: 270
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: energyPulse
            property: "opacity"
            from: 0.78
            to: 0
            duration: 270
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: attentionReaction
        loops: 2

        ParallelAnimation {
            NumberAnimation {
                target: attentionRing
                property: "scale"
                from: 0.8
                to: 1.45
                duration: 230
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: attentionRing
                property: "opacity"
                from: 0.72
                to: 0
                duration: 230
                easing.type: Easing.OutCubic
            }
        }
        PauseAnimation {
            duration: 85
        }
    }

    Controls.BusyIndicator {
        anchors.centerIn: appIcon
        width: delegateRoot.dockRoot.iconSizeForTask(delegateRoot.model.IsLauncher) * 0.58
        height: width
        running: !!delegateRoot.model.IsStartup
        visible: running
    }

    // Active-window marker.
    Rectangle {
        id: activeIndicator

        width: delegateRoot.dockRoot.vertical ? 3 : 18
        height: delegateRoot.dockRoot.vertical ? 18 : 3
        x: delegateRoot.dockRoot.vertical ? parent.width - width - 1 : (parent.width - width) / 2
        y: delegateRoot.dockRoot.vertical ? (parent.height - height) / 2 : parent.height - height - 1
        radius: 2
        color: Kirigami.Theme.highlightColor
        opacity: Plasmoid.configuration.showActiveIndicator
                 && delegateRoot.model.IsActive ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    // Drag an icon onto another icon to reorder it.
    DragHandler {
        id: dragHandler
        target: null
        acceptedButtons: Qt.LeftButton
        enabled: Plasmoid.configuration.enableDragReorder && delegateRoot.allowReorder
    }

    Drag.active: dragHandler.active
    Drag.source: delegateRoot
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.MoveAction
    Drag.mimeData: ({
        "application/x-alveus-dock-index": String(delegateRoot.dockIndex)
    })

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

        onEntered: delegateRoot.hovered = true
        onExited: delegateRoot.hovered = false

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                delegateRoot.activateTask();
            } else if (mouse.button === Qt.MiddleButton) {
                delegateRoot.dockRoot.runAction("new-instance",
                               () => delegateRoot.taskModel.requestNewInstance(delegateRoot.modelIndex()));
            } else if (mouse.button === Qt.RightButton) {
                contextMenu.popup();
            }
        }

        Controls.ToolTip.visible: containsMouse
        Controls.ToolTip.text: delegateRoot.model.IsGroupParent
            ? qsTr("%1 windows").arg(delegateRoot.model.display)
            : delegateRoot.model.display
        Controls.ToolTip.delay: 450
    }

    Controls.Menu {
        id: contextMenu

        Controls.MenuItem {
            text: delegateRoot.model.HasLauncher
                ? qsTr("Unpin from Dock")
                : qsTr("Pin to Dock")

            enabled: delegateRoot.model.LauncherUrlWithoutIcon !== undefined
                     && delegateRoot.model.LauncherUrlWithoutIcon !== null

            onTriggered: {
                const launcherUrl = delegateRoot.model.LauncherUrlWithoutIcon;
                if (delegateRoot.model.HasLauncher) {
                    delegateRoot.dockRoot.runAction("unpin-launcher",
                                   () => delegateRoot.taskModel.requestRemoveLauncher(launcherUrl));
                } else {
                    delegateRoot.dockRoot.runAction("pin-launcher",
                                   () => delegateRoot.taskModel.requestAddLauncher(launcherUrl));
                }
            }
        }

        Controls.MenuItem {
            text: qsTr("New instance")
            enabled: delegateRoot.model.CanLaunchNewInstance
            onTriggered: delegateRoot.dockRoot.runAction(
                "new-instance",
                () => delegateRoot.taskModel.requestNewInstance(delegateRoot.modelIndex())
            )
        }

        Controls.MenuItem {
            text: qsTr("Ungroup windows")
            visible: !!delegateRoot.model.IsGroupParent
            onTriggered: delegateRoot.dockRoot.runAction(
                "ungroup-windows",
                () => delegateRoot.taskModel.requestToggleGrouping(delegateRoot.modelIndex())
            )
        }

        Controls.MenuSeparator {}

        Controls.MenuItem {
            text: qsTr("Close")
            visible: delegateRoot.model.IsWindow
            onTriggered: delegateRoot.dockRoot.runAction(
                "close-window",
                () => delegateRoot.taskModel.requestClose(delegateRoot.modelIndex())
            )
        }
    }
}
