/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Alveus Dock — a small KDE Plasma task dock.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property int iconSize: Plasmoid.configuration.iconSize
    readonly property int itemExtent: iconSize + 12
    readonly property int dockPadding: 6
    readonly property real hoverScale: Plasmoid.configuration.hoverScale / 100.0

    signal iconGeometryRefreshRequested()

    // Diagnostics are written to the Plasma/Qt journal. Do not log window titles,
    // application names, file paths or dropped URLs.
    function logInfo(eventName, details) {
        console.info("[AlveusDock][INFO]", eventName, JSON.stringify(details || {}));
    }

    function logWarning(eventName, details) {
        console.warn("[AlveusDock][WARN]", eventName, JSON.stringify(details || {}));
    }

    function logError(eventName, error) {
        // Exception messages can contain paths or other user data.
        const errorType = error && error.name ? String(error.name) : "Error";
        console.error("[AlveusDock][ERROR]", eventName, JSON.stringify({
            type: errorType
        }));
    }

    function runAction(actionName, callback) {
        try {
            const result = callback();
            if (result === false) {
                logWarning("action-rejected", { name: actionName });
            } else {
                // This records dispatch, not confirmation of window-manager completion.
                logInfo("action-dispatched", { name: actionName });
            }
            return result;
        } catch (error) {
            logError("action-failed:" + actionName, error);
            return false;
        }
    }

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.constraintHints: Plasmoid.CanFillArea

    Layout.minimumWidth: vertical ? itemExtent + dockPadding * 2 : itemExtent
    Layout.minimumHeight: vertical ? itemExtent : itemExtent + dockPadding * 2

    Layout.preferredWidth: vertical
        ? itemExtent + dockPadding * 2
        : Math.max(itemExtent + dockPadding * 2,
                   taskModel.count * itemExtent
                   + Math.max(0, taskModel.count - 1) * Plasmoid.configuration.iconSpacing
                   + dockPadding * 2)

    Layout.preferredHeight: vertical
        ? Math.max(itemExtent + dockPadding * 2,
                   taskModel.count * itemExtent
                   + Math.max(0, taskModel.count - 1) * Plasmoid.configuration.iconSpacing
                   + dockPadding * 2)
        : itemExtent + dockPadding * 2

    function isApplicationLauncher(url) {
        const value = url.toString().toLowerCase();
        return value.startsWith("applications:")
               || value.endsWith(".desktop")
               || value.includes(".desktop?");
    }

    // Convert a delegate's bounds to screen coordinates. KDE's task model
    // forwards this geometry to KWin for minimize-to-icon effects.
    function globalRect(item) {
        const topLeft = item.mapToGlobal(0, 0);
        const bottomRight = item.mapToGlobal(item.width, item.height);
        return Qt.rect(
            topLeft.x,
            topLeft.y,
            bottomRight.x - topLeft.x,
            bottomRight.y - topLeft.y
        );
    }

    function publishAllDelegateGeometries() {
        iconGeometryRefreshRequested();
    }

    function addDroppedLaunchers(urls) {
        if (!urls || urls.length === 0) {
            logWarning("launcher-drop-empty", {});
            return false;
        }

        let allApplications = true;
        for (let i = 0; i < urls.length; ++i) {
            if (!isApplicationLauncher(urls[i])) {
                allApplications = false;
                break;
            }
        }

        if (!allApplications) {
            logInfo("drop-not-launchers", { itemCount: urls.length });
            return false;
        }

        let addedCount = 0;
        for (let i = 0; i < urls.length; ++i) {
            const added = runAction("pin-launcher",
                                    () => taskModel.requestAddLauncher(urls[i]));
            if (added === true) {
                ++addedCount;
            }
        }

        logInfo("launcher-drop-processed", {
            itemCount: urls.length,
            addedCount: addedCount
        });
        return addedCount > 0;
    }

    // Panel placement can settle a little after Plasma reports a location or
    // screen change. Publish after the layout has finished moving.
    Timer {
        id: iconGeometryTimer
        interval: 200
        repeat: false
        onTriggered: root.publishAllDelegateGeometries()
    }

    onXChanged: iconGeometryTimer.restart()
    onYChanged: iconGeometryTimer.restart()
    onWidthChanged: iconGeometryTimer.restart()
    onHeightChanged: iconGeometryTimer.restart()

    TaskManager.TasksModel {
        id: taskModel

        screenGeometry: Plasmoid.containment.screenGeometry
        filterByCurrentVirtualDesktop: Plasmoid.configuration.currentDesktopOnly
        filterByScreen: Plasmoid.configuration.currentScreenOnly

        // KDE owns task discovery, launcher matching and window activation.
        groupMode: Plasmoid.configuration.groupApplications
            ? TaskManager.TasksModel.GroupApplications
            : TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortManual
        separateLaunchers: false
        launchInPlace: true
        hideActivatedLaunchers: false
        taskReorderingEnabled: Plasmoid.configuration.enableDragReorder

        onCountChanged: {
            root.logInfo("task-count-changed", { count: count });
            iconGeometryTimer.restart();
        }

        onLauncherListChanged: {
            Plasmoid.configuration.launchers = launcherList;
            root.logInfo("launcher-list-changed", { count: launcherList.length });
        }

        Component.onCompleted: {
            launcherList = Plasmoid.configuration.launchers;
            root.logInfo("task-model-ready", { taskCount: count });
        }
    }

    Component.onCompleted: {
        root.logInfo("applet-started", {
            version: "0.1.3",
            iconSize: root.iconSize,
            vertical: root.vertical
        });
    }

    Component.onDestruction: {
        root.logInfo("applet-stopped", {});
    }

    Connections {
        target: Plasmoid

        function onLocationChanged() {
            iconGeometryTimer.restart();
        }
    }

    Connections {
        target: Plasmoid.containment

        function onScreenGeometryChanged() {
            iconGeometryTimer.restart();
        }
    }

    Connections {
        target: Plasmoid.configuration

        function onLaunchersChanged() {
            taskModel.launcherList = Plasmoid.configuration.launchers;
        }
    }

    Rectangle {
        id: dockSurface

        anchors.fill: parent
        radius: height / 2
        color: Plasmoid.configuration.showBackground
            ? Qt.rgba(0.055, 0.070, 0.095, 0.84)
            : "transparent"
        border.width: Plasmoid.configuration.showBackground ? 1 : 0
        border.color: Qt.rgba(1, 1, 1, 0.14)
        antialiasing: true
    }

    ListView {
        id: dockList

        anchors.fill: parent
        anchors.margins: root.dockPadding
        z: 1
        orientation: root.vertical ? ListView.Vertical : ListView.Horizontal
        spacing: Plasmoid.configuration.iconSpacing
        model: taskModel
        clip: false
        interactive: false
        boundsBehavior: Flickable.StopAtBounds
        reuseItems: true

        delegate: Item {
            id: delegateRoot

            required property int index
            required property var model

            readonly property int dockIndex: index
            property real launchScale: 1.0
            property bool hovered: false
            property bool demandingAttention: !!model.IsDemandingAttention
            readonly property int childCount: Number(model.ChildCount || 0)

            Accessible.name: String(model.display || "")
                + (model.IsGroupParent ? qsTr(", %1 windows").arg(childCount) : "")
            Accessible.role: Accessible.Button

            width: root.itemExtent
            height: root.itemExtent
            z: hovered ? 2 : 0

            onDemandingAttentionChanged: {
                if (demandingAttention && Plasmoid.configuration.enableAttentionReaction) {
                    root.logInfo("attention-requested", { dockIndex: dockIndex });
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
                groupWindowChooser.visible = false;
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
                return taskModel.makeModelIndex(index);
            }

            function publishIconGeometry() {
                if (!delegateRoot.visible
                        || !delegateRoot.model
                        || (!delegateRoot.model.IsWindow && !delegateRoot.model.IsGroupParent)
                        || delegateRoot.model.IsLauncher
                        || delegateRoot.model.IsStartup) {
                    return;
                }

                const geometry = root.globalRect(delegateRoot);
                taskModel.requestPublishDelegateGeometry(
                    delegateRoot.modelIndex(),
                    geometry,
                    delegateRoot
                );
            }

            function scheduleIconGeometryPublish() {
                Qt.callLater(publishIconGeometry);
            }

            Connections {
                target: root

                function onIconGeometryRefreshRequested() {
                    delegateRoot.scheduleIconGeometryPublish();
                }
            }

            onXChanged: scheduleIconGeometryPublish()
            onYChanged: scheduleIconGeometryPublish()
            onWidthChanged: scheduleIconGeometryPublish()
            onHeightChanged: scheduleIconGeometryPublish()
            onModelChanged: scheduleIconGeometryPublish()

            Component.onCompleted: scheduleIconGeometryPublish()

            function activateTask() {
                const idx = modelIndex();

                if (model.IsGroupParent) {
                    groupWindowChooser.visible = !groupWindowChooser.visible;
                    if (groupWindowChooser.visible) {
                        root.logInfo("window-chooser-opened", { childCount: childCount });
                    }
                    return;
                }

                if (model.IsWindow && model.IsActive) {
                    // Refresh the target immediately before asking KWin to minimize.
                    publishIconGeometry();
                    root.runAction("toggle-minimized", () => taskModel.requestToggleMinimized(idx));
                } else {
                    root.runAction("activate-window", () => taskModel.requestActivate(idx));
                }
            }

            GroupWindowChooser {
                id: groupWindowChooser

                visualParent: delegateRoot
                taskModel: taskModel
                parentIndex: delegateRoot.index
                groupTitle: String(delegateRoot.model.display || "")
                vertical: root.vertical

                onActivateRequested: childIndex => {
                    root.runAction(
                        "activate-group-window",
                        () => taskModel.requestActivate(childIndex)
                    );
                }

                onCloseRequested: childIndex => {
                    root.runAction(
                        "close-group-window",
                        () => taskModel.requestClose(childIndex)
                    );
                }
            }

            onChildCountChanged: {
                if (childCount < 2) {
                    groupWindowChooser.visible = false;
                }
            }

            onModelChanged: groupWindowChooser.visible = false

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
                width: root.iconSize
                height: root.iconSize
                source: delegateRoot.model.decoration
                active: delegateRoot.hovered
                enabled: true
                scale: delegateRoot.launchScale
                       * (delegateRoot.hovered ? root.hoverScale : 1.0)

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
                width: root.iconSize * 0.68
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
                width: root.iconSize * 0.9
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
                width: root.iconSize * 0.58
                height: width
                running: !!delegateRoot.model.IsStartup
                visible: running
            }

            // Active-window marker.
            Rectangle {
                id: activeIndicator

                width: root.vertical ? 3 : 18
                height: root.vertical ? 18 : 3
                x: root.vertical ? parent.width - width - 1 : (parent.width - width) / 2
                y: root.vertical ? (parent.height - height) / 2 : parent.height - height - 1
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
                enabled: Plasmoid.configuration.enableDragReorder
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
                        delegateRoot.playLaunchReaction();
                        delegateRoot.activateTask();
                    } else if (mouse.button === Qt.MiddleButton) {
                        root.runAction("new-instance",
                                       () => taskModel.requestNewInstance(delegateRoot.modelIndex()));
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
                            root.runAction("unpin-launcher",
                                           () => taskModel.requestRemoveLauncher(launcherUrl));
                        } else {
                            root.runAction("pin-launcher",
                                           () => taskModel.requestAddLauncher(launcherUrl));
                        }
                    }
                }

                Controls.MenuItem {
                    text: qsTr("New instance")
                    enabled: delegateRoot.model.CanLaunchNewInstance
                    onTriggered: root.runAction(
                        "new-instance",
                        () => taskModel.requestNewInstance(delegateRoot.modelIndex())
                    )
                }

                Controls.MenuItem {
                    text: qsTr("Ungroup windows")
                    visible: !!delegateRoot.model.IsGroupParent
                    onTriggered: root.runAction(
                        "ungroup-windows",
                        () => taskModel.requestToggleGrouping(delegateRoot.modelIndex())
                    )
                }

                Controls.MenuSeparator {}

                Controls.MenuItem {
                    text: qsTr("Close")
                    visible: delegateRoot.model.IsWindow
                    onTriggered: root.runAction(
                        "close-window",
                        () => taskModel.requestClose(delegateRoot.modelIndex())
                    )
                }
            }
        }
    }

    // One overlay handles internal reordering and external drops consistently.
    // It does not participate in ordinary mouse clicks.
    DropArea {
        id: dockDropArea

        anchors.fill: dockSurface
        z: 3

        onDropped: drop => {
            const pointInList = mapToItem(dockList, drop.x, drop.y);
            const targetIndex = dockList.indexAt(pointInList.x, pointInList.y);

            // Internal drag: validate indices, move the task and synchronize
            // the launchers so their persisted order matches the visible order.
            if (drop.source && drop.source.dockIndex !== undefined) {
                const sourceIndex = Number(drop.source.dockIndex);

                if (!Plasmoid.configuration.enableDragReorder) {
                    root.logWarning("reorder-disabled", {});
                    return;
                }

                if (!Number.isInteger(sourceIndex)
                        || sourceIndex < 0
                        || sourceIndex >= taskModel.count
                        || targetIndex < 0
                        || targetIndex >= taskModel.count) {
                    root.logWarning("reorder-invalid-index", {
                        sourceIndex: sourceIndex,
                        targetIndex: targetIndex,
                        taskCount: taskModel.count
                    });
                    return;
                }

                if (sourceIndex === targetIndex) {
                    drop.acceptProposedAction();
                    return;
                }

                const moved = root.runAction(
                    "reorder-task",
                    () => taskModel.move(sourceIndex, targetIndex)
                );

                if (moved === true) {
                    root.runAction("sync-launchers", () => taskModel.syncLaunchers());
                    root.logInfo("task-reordered", {
                        sourceIndex: sourceIndex,
                        targetIndex: targetIndex
                    });
                    drop.acceptProposedAction();
                } else {
                    root.logWarning("reorder-rejected", {
                        sourceIndex: sourceIndex,
                        targetIndex: targetIndex
                    });
                }
                return;
            }

            // External application launcher: pin it, even when dropped between icons.
            if (root.addDroppedLaunchers(drop.urls)) {
                drop.acceptProposedAction();
                return;
            }

            // Ordinary files dropped on a running application are opened by it.
            if (drop.urls && drop.urls.length > 0 && targetIndex >= 0) {
                const targetModelIndex = taskModel.makeModelIndex(targetIndex);
                const isWindow = taskModel.data(
                    targetModelIndex,
                    TaskManager.AbstractTasksModel.IsWindow
                );
                if (isWindow) {
                    root.runAction(
                        "open-dropped-files",
                        () => taskModel.requestOpenUrls(targetModelIndex, drop.urls)
                    );
                    root.logInfo("files-dropped-on-window", {
                        itemCount: drop.urls.length,
                        targetIndex: targetIndex
                    });
                    drop.acceptProposedAction();
                }
            }
        }
    }
}
