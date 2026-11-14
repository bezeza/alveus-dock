/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Shared task/launcher delegate used by the single- and dual-layer layouts.
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

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

    width: dockRoot.itemExtent
    height: dockRoot.itemExtent
    z: hovered ? 2 : 0

    onDemandingAttentionChanged: {
        if (demandingAttention && Plasmoid.configuration.enableAttentionReaction) {
            dockRoot.logInfo("attention-requested", { dockIndex: dockIndex });
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
        if (dockRoot.groupVisualParent === delegateRoot) {
            dockRoot.closeGroupChooser();
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
        return taskModel.makeModelIndex(sourceIndex);
    }

    function publishIconGeometry() {
        if (!delegateRoot.visible
                || !delegateRoot.model
                || (!delegateRoot.model.IsWindow && !delegateRoot.model.IsGroupParent)
                || delegateRoot.model.IsLauncher
                || delegateRoot.model.IsStartup) {
            return;
        }

        const geometry = dockRoot.globalRect(delegateRoot);
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
            dockRoot.toggleGroupChooser(delegateRoot);
            if (dockRoot.groupVisualParent === delegateRoot) {
                dockRoot.logInfo("window-chooser-opened", { childCount: childCount });
            }
            return;
        }

        if (model.IsWindow && model.IsActive) {
            // Refresh the target immediately before asking KWin to minimize.
            publishIconGeometry();
            dockRoot.runAction("toggle-minimized", () => taskModel.requestToggleMinimized(idx));
        } else {
            dockRoot.runAction("activate-window", () => taskModel.requestActivate(idx));
        }
    }

    onChildCountChanged: {
        if (childCount < 2 && dockRoot.groupVisualParent === delegateRoot) {
            dockRoot.closeGroupChooser();
        }
    }

    onModelChanged: {
        if (dockRoot.groupVisualParent === delegateRoot) {
            dockRoot.closeGroupChooser();
        }
    }

    onSourceIndexChanged: {
        if (dockRoot.groupVisualParent === delegateRoot) {
            dockRoot.groupParentIndex = sourceIndex;
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
        width: dockRoot.iconSize
        height: dockRoot.iconSize
        source: delegateRoot.model.decoration
        active: delegateRoot.hovered
        enabled: true
        scale: delegateRoot.launchScale
               * (delegateRoot.hovered ? dockRoot.hoverScale : 1.0)

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
        width: dockRoot.iconSize * 0.68
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
        width: dockRoot.iconSize * 0.9
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
        width: dockRoot.iconSize * 0.58
        height: width
        running: !!delegateRoot.model.IsStartup
        visible: running
    }

    // Active-window marker.
    Rectangle {
        id: activeIndicator

        width: dockRoot.vertical ? 3 : 18
        height: dockRoot.vertical ? 18 : 3
        x: dockRoot.vertical ? parent.width - width - 1 : (parent.width - width) / 2
        y: dockRoot.vertical ? (parent.height - height) / 2 : parent.height - height - 1
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
                delegateRoot.playLaunchReaction();
                delegateRoot.activateTask();
            } else if (mouse.button === Qt.MiddleButton) {
                dockRoot.runAction("new-instance",
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
                    dockRoot.runAction("unpin-launcher",
                                   () => taskModel.requestRemoveLauncher(launcherUrl));
                } else {
                    dockRoot.runAction("pin-launcher",
                                   () => taskModel.requestAddLauncher(launcherUrl));
                }
            }
        }

        Controls.MenuItem {
            text: qsTr("New instance")
            enabled: delegateRoot.model.CanLaunchNewInstance
            onTriggered: dockRoot.runAction(
                "new-instance",
                () => taskModel.requestNewInstance(delegateRoot.modelIndex())
            )
        }

        Controls.MenuItem {
            text: qsTr("Ungroup windows")
            visible: !!delegateRoot.model.IsGroupParent
            onTriggered: dockRoot.runAction(
                "ungroup-windows",
                () => taskModel.requestToggleGrouping(delegateRoot.modelIndex())
            )
        }

        Controls.MenuSeparator {}

        Controls.MenuItem {
            text: qsTr("Close")
            visible: delegateRoot.model.IsWindow
            onTriggered: dockRoot.runAction(
                "close-window",
                () => taskModel.requestClose(delegateRoot.modelIndex())
            )
        }
    }
}
