/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Alveus Dock — a small KDE Plasma task dock.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQml.Models

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
    readonly property int dockLayoutMode: Plasmoid.configuration.dockLayoutMode
    readonly property int layerSpacing: Plasmoid.configuration.layerSpacing
    readonly property int quickAccessIconSize: Plasmoid.configuration.quickAccessIconSize
    readonly property int runningTasksIconSize: Plasmoid.configuration.runningTasksIconSize
    readonly property int quickAccessSpacing: Plasmoid.configuration.quickAccessSpacing
    readonly property int runningTasksSpacing: Plasmoid.configuration.runningTasksSpacing
    readonly property int quickAccessItemExtent: quickAccessIconSize + 8
    readonly property int runningTasksItemExtent: runningTasksIconSize + 8
    readonly property bool splitLayoutEnabled: dockLayoutMode !== 0
    readonly property bool showRunningLayer: dockLayoutMode === 1
        || (dockLayoutMode === 2 && runningTasksVisualModel.count > 0)
    readonly property int quickAccessLength: quickAccessVisualModel.count * quickAccessItemExtent
        + Math.max(0, quickAccessVisualModel.count - 1) * quickAccessSpacing
        + dockPadding * 2
    readonly property int runningTasksLength: runningTasksVisualModel.count * runningTasksItemExtent
        + Math.max(0, runningTasksVisualModel.count - 1) * runningTasksSpacing
        + dockPadding * 2
    readonly property int panelLength: splitLayoutEnabled
        ? Math.max(quickAccessItemExtent + dockPadding * 2,
                   quickAccessLength, showRunningLayer ? runningTasksLength : 0)
        : Math.max(itemExtent + dockPadding * 2,
                   taskModel.count * itemExtent
                   + Math.max(0, taskModel.count - 1) * Plasmoid.configuration.iconSpacing
                   + dockPadding * 2)
    readonly property int panelThickness: splitLayoutEnabled && showRunningLayer
        ? quickAccessItemExtent + runningTasksItemExtent + layerSpacing + dockPadding * 2
        : (splitLayoutEnabled ? quickAccessItemExtent : itemExtent) + dockPadding * 2

    function iconSizeForTask(isLauncher) {
        if (!splitLayoutEnabled) {
            return iconSize;
        }
        return isLauncher ? quickAccessIconSize : runningTasksIconSize;
    }

    function itemExtentForTask(isLauncher) {
        return iconSizeForTask(isLauncher) + (splitLayoutEnabled ? 8 : 12);
    }

    signal iconGeometryRefreshRequested()

    property Item groupVisualParent: null
    property int groupParentIndex: -1
    property string groupTitle: ""

    function closeGroupChooser() {
        groupWindowChooser.visible = false;
        groupVisualParent = null;
        groupParentIndex = -1;
        groupTitle = "";
    }

    function toggleGroupChooser(delegateItem) {
        if (groupWindowChooser.visible && groupVisualParent === delegateItem) {
            closeGroupChooser();
            return;
        }

        groupVisualParent = delegateItem;
        groupParentIndex = delegateItem.sourceIndex;
        groupTitle = String(delegateItem.model.display || "");
        groupWindowChooser.visible = true;
    }

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

    Layout.minimumWidth: vertical
        ? panelThickness
        : Math.max(itemExtent, quickAccessItemExtent, runningTasksItemExtent) + dockPadding * 2
    Layout.minimumHeight: vertical
        ? Math.max(itemExtent, quickAccessItemExtent, runningTasksItemExtent) + dockPadding * 2
        : panelThickness

    Layout.preferredWidth: vertical ? panelThickness : panelLength
    Layout.preferredHeight: vertical ? panelLength : panelThickness

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

    function updateVisualGroup(visualModel, row, groupName, shouldBelong) {
        const item = visualModel.items.get(row);
        const groups = item && item.groups ? item.groups : [];
        const alreadyBelongs = groups.indexOf(groupName) !== -1;

        if (shouldBelong && !alreadyBelongs) {
            visualModel.items.addGroups(row, 1, [groupName]);
        } else if (!shouldBelong && alreadyBelongs) {
            visualModel.items.removeGroups(row, 1, [groupName]);
        }
    }

    // Split the native TaskManager model into two presentation groups. KDE
    // remains the only source of launcher and window data; no second registry
    // or background polling is introduced.
    function syncTaskVisualGroups() {
        if (!splitLayoutEnabled) {
            return;
        }

        const count = taskModel.count;
        if (quickAccessVisualModel.items.count !== count
                || runningTasksVisualModel.items.count !== count) {
            logWarning("visual-model-sync-pending", {
                taskCount: count,
                quickItems: quickAccessVisualModel.items.count,
                runningItems: runningTasksVisualModel.items.count
            });
            return;
        }

        for (let row = 0; row < count; ++row) {
            const sourceIndex = taskModel.makeModelIndex(row);
            const isLauncher = !!taskModel.data(
                sourceIndex,
                TaskManager.AbstractTasksModel.IsLauncher
            );
            const isRunning = !!taskModel.data(
                sourceIndex,
                TaskManager.AbstractTasksModel.IsWindow
            ) || !!taskModel.data(
                sourceIndex,
                TaskManager.AbstractTasksModel.IsGroupParent
            ) || !!taskModel.data(
                sourceIndex,
                TaskManager.AbstractTasksModel.IsStartup
            );

            updateVisualGroup(quickAccessVisualModel, row, "quickAccess", isLauncher);
            updateVisualGroup(runningTasksVisualModel, row, "runningTasks", isRunning);
        }
    }

    function scheduleTaskVisualGroups() {
        Qt.callLater(root.syncTaskVisualGroups);
    }

    function sourceIndexFromDelegate(delegateItem) {
        return delegateItem ? delegateItem.sourceIndex : -1;
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
        separateLaunchers: root.splitLayoutEnabled
        launchInPlace: !root.splitLayoutEnabled
        hideActivatedLaunchers: false
        taskReorderingEnabled: Plasmoid.configuration.enableDragReorder

        onCountChanged: {
            root.logInfo("task-count-changed", { count: count });
            iconGeometryTimer.restart();
            root.scheduleTaskVisualGroups();
        }

        onLauncherListChanged: {
            Plasmoid.configuration.launchers = launcherList;
            root.logInfo("launcher-list-changed", { count: launcherList.length });
            root.scheduleTaskVisualGroups();
        }

        Component.onCompleted: {
            launcherList = Plasmoid.configuration.launchers;
            root.logInfo("task-model-ready", { taskCount: count });
            root.scheduleTaskVisualGroups();
        }
    }

    DelegateModel {
        id: quickAccessVisualModel

        model: taskModel
        filterOnGroup: "quickAccess"
        groups: [
            DelegateModelGroup {
                name: "quickAccess"
                includeByDefault: false
            }
        ]

        delegate: TaskDelegate {
            dockRoot: root
            taskModel: taskModel
            sourceIndex: DelegateModel.itemsIndex
            allowReorder: true
        }
    }

    DelegateModel {
        id: runningTasksVisualModel

        model: taskModel
        filterOnGroup: "runningTasks"
        groups: [
            DelegateModelGroup {
                name: "runningTasks"
                includeByDefault: false
            }
        ]

        delegate: TaskDelegate {
            dockRoot: root
            taskModel: taskModel
            sourceIndex: DelegateModel.itemsIndex
            allowReorder: false
        }
    }

    Connections {
        target: taskModel

        function onRowsInserted() {
            root.scheduleTaskVisualGroups();
        }

        function onRowsRemoved() {
            root.scheduleTaskVisualGroups();
        }

        function onModelReset() {
            root.scheduleTaskVisualGroups();
        }

        function onDataChanged() {
            root.scheduleTaskVisualGroups();
        }
    }

    GroupWindowChooser {
        id: groupWindowChooser

        visualParent: root.groupVisualParent
        taskModel: taskModel
        parentIndex: root.groupParentIndex
        groupTitle: root.groupTitle
        vertical: root.vertical

        onActivateRequested: childIndex => {
            root.runAction(
                "activate-group-window",
                () => taskModel.requestActivate(childIndex)
            );
            root.closeGroupChooser();
        }

        onCloseRequested: childIndex => {
            root.runAction(
                "close-group-window",
                () => taskModel.requestClose(childIndex)
            );
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
            root.scheduleTaskVisualGroups();
        }

        function onDockLayoutModeChanged() {
            root.scheduleTaskVisualGroups();
            iconGeometryTimer.restart();
        }
    }

    Rectangle {
        id: dockSurface

        anchors.fill: parent
        radius: Math.min(width, height) / 2
        color: Plasmoid.configuration.showBackground
            ? Qt.rgba(0.055, 0.070, 0.095, 0.84)
            : "transparent"
        border.width: Plasmoid.configuration.showBackground ? 1 : 0
        border.color: Qt.rgba(1, 1, 1, 0.14)
        antialiasing: true
    }

    // Single mode preserves the original unified task row.
    ListView {
        id: singleDockList

        anchors.fill: parent
        anchors.margins: root.dockPadding
        z: 1
        orientation: root.vertical ? ListView.Vertical : ListView.Horizontal
        spacing: Plasmoid.configuration.iconSpacing
        model: root.splitLayoutEnabled ? null : taskModel
        visible: !root.splitLayoutEnabled
        clip: false
        interactive: false
        boundsBehavior: Flickable.StopAtBounds
        reuseItems: true

        delegate: TaskDelegate {
            dockRoot: root
            taskModel: taskModel
            sourceIndex: index
            allowReorder: true
        }
    }

    // The same native KDE model is presented as pinned launchers and live windows.
    ListView {
        id: quickAccessList

        x: root.dockPadding
        y: root.dockPadding
        width: root.vertical ? root.quickAccessItemExtent : Math.max(0, parent.width - root.dockPadding * 2)
        height: root.vertical ? Math.max(0, parent.height - root.dockPadding * 2) : root.quickAccessItemExtent
        z: 1
        orientation: root.vertical ? ListView.Vertical : ListView.Horizontal
        spacing: root.quickAccessSpacing
        model: root.splitLayoutEnabled ? quickAccessVisualModel : null
        visible: root.splitLayoutEnabled
        clip: false
        interactive: false
        boundsBehavior: Flickable.StopAtBounds
        reuseItems: true
    }

    ListView {
        id: runningTasksList

        x: root.vertical
            ? root.dockPadding + root.quickAccessItemExtent + root.layerSpacing
            : root.dockPadding
        y: root.vertical
            ? root.dockPadding
            : root.dockPadding + root.quickAccessItemExtent + root.layerSpacing
        width: root.vertical ? root.runningTasksItemExtent : Math.max(0, parent.width - root.dockPadding * 2)
        height: root.vertical ? Math.max(0, parent.height - root.dockPadding * 2) : root.runningTasksItemExtent
        z: 1
        orientation: root.vertical ? ListView.Vertical : ListView.Horizontal
        spacing: root.runningTasksSpacing
        model: root.showRunningLayer ? runningTasksVisualModel : null
        visible: root.showRunningLayer
        clip: false
        interactive: false
        boundsBehavior: Flickable.StopAtBounds
        reuseItems: true
    }

    // One overlay handles launcher pinning, launcher reordering and file drops.
    DropArea {
        id: dockDropArea

        anchors.fill: dockSurface
        z: 3

        onDropped: drop => {
            const reorderList = root.splitLayoutEnabled ? quickAccessList : singleDockList;
            const reorderPoint = mapToItem(reorderList, drop.x, drop.y);
            const reorderViewIndex = reorderList.indexAt(reorderPoint.x, reorderPoint.y);
            const reorderDelegate = reorderViewIndex >= 0
                ? reorderList.itemAtIndex(reorderViewIndex) : null;
            const reorderTargetIndex = root.sourceIndexFromDelegate(reorderDelegate);

            // Internal drag is restricted to the quick-access layer in split mode.
            if (drop.source && drop.source.dockIndex !== undefined) {
                const sourceIndex = Number(drop.source.dockIndex);

                if (!Plasmoid.configuration.enableDragReorder || !drop.source.allowReorder) {
                    root.logWarning("reorder-disabled", {});
                    return;
                }

                if (!Number.isInteger(sourceIndex)
                        || sourceIndex < 0
                        || sourceIndex >= taskModel.count
                        || reorderTargetIndex < 0
                        || reorderTargetIndex >= taskModel.count) {
                    root.logWarning("reorder-invalid-index", {
                        sourceIndex: sourceIndex,
                        targetIndex: reorderTargetIndex,
                        taskCount: taskModel.count
                    });
                    return;
                }

                if (root.splitLayoutEnabled) {
                    const sourceIndexModel = taskModel.makeModelIndex(sourceIndex);
                    const targetIndexModel = taskModel.makeModelIndex(reorderTargetIndex);
                    const sourceIsLauncher = taskModel.data(
                        sourceIndexModel,
                        TaskManager.AbstractTasksModel.IsLauncher
                    );
                    const targetIsLauncher = taskModel.data(
                        targetIndexModel,
                        TaskManager.AbstractTasksModel.IsLauncher
                    );
                    if (!sourceIsLauncher || !targetIsLauncher) {
                        root.logWarning("reorder-non-launcher-rejected", {});
                        return;
                    }
                }

                if (sourceIndex === reorderTargetIndex) {
                    drop.acceptProposedAction();
                    return;
                }

                const moved = root.runAction(
                    "reorder-task",
                    () => taskModel.move(sourceIndex, reorderTargetIndex)
                );

                if (moved === true) {
                    root.runAction("sync-launchers", () => taskModel.syncLaunchers());
                    root.logInfo("task-reordered", {
                        sourceIndex: sourceIndex,
                        targetIndex: reorderTargetIndex
                    });
                    drop.acceptProposedAction();
                } else {
                    root.logWarning("reorder-rejected", {
                        sourceIndex: sourceIndex,
                        targetIndex: reorderTargetIndex
                    });
                }
                return;
            }

            // External application launcher: pin it anywhere on the dock.
            if (root.addDroppedLaunchers(drop.urls)) {
                drop.acceptProposedAction();
                return;
            }

            // File drops target a live window: the lower layer in split mode,
            // or the unified row in single mode.
            const taskList = root.splitLayoutEnabled ? runningTasksList : singleDockList;
            const taskPoint = mapToItem(taskList, drop.x, drop.y);
            const taskViewIndex = taskList.indexAt(taskPoint.x, taskPoint.y);
            const taskDelegate = taskViewIndex >= 0
                ? taskList.itemAtIndex(taskViewIndex) : null;
            const targetIndex = root.sourceIndexFromDelegate(taskDelegate);

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
