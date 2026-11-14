/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Compact chooser for windows inside one application group.
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQml.Models

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmaCore.PopupPlasmaWindow {
    id: chooser

    required property var taskModel
    required property int parentIndex
    required property string groupTitle
    required property bool vertical

    readonly property int maxVisibleRows: 6

    signal activateRequested(var childIndex)
    signal closeRequested(var childIndex)

    readonly property int childCount: visualParent && parentIndex >= 0
        ? taskModel.rowCount(taskModel.makeModelIndex(parentIndex)) : 0

    width: chooserContent.implicitWidth
    height: chooserContent.implicitHeight
    animated: true
    margin: 4

    popupDirection: {
        if (vertical) {
            return Plasmoid.location === PlasmaCore.Types.LeftEdge
                ? Qt.RightEdge : Qt.LeftEdge;
        }
        return Plasmoid.location === PlasmaCore.Types.TopEdge
            ? Qt.BottomEdge : Qt.TopEdge;
    }

    function modelIndexForChild(childRow) {
        if (!visualParent || parentIndex < 0
                || !Number.isInteger(childRow) || childRow < 0 || childRow >= childCount) {
            return null;
        }
        return taskModel.makeModelIndex(parentIndex, childRow);
    }

    mainItem: Rectangle {
        id: chooserContent

        implicitWidth: 292
        implicitHeight: chooserColumn.implicitHeight + 16
        radius: 12
        focus: true
        Keys.onEscapePressed: event => {
            chooser.visible = false;
            event.accepted = true;
        }
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Kirigami.Theme.disabledTextColor

        DelegateModel {
            id: windowModel

            model: chooser.taskModel
            rootIndex: chooser.taskModel.makeModelIndex(chooser.parentIndex)

            delegate: Controls.ItemDelegate {
                id: childDelegate

                required property int index
                required property var model

                width: windowList.width
                height: 46
                Accessible.name: String(model.display)
                    + (model.IsMinimized ? qsTr(", minimized") : "")
                Accessible.role: Accessible.Button

                contentItem: RowLayout {
                    spacing: 8

                    Kirigami.Icon {
                        source: childDelegate.model.decoration
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Controls.Label {
                            Layout.fillWidth: true
                            text: childDelegate.model.display
                            elide: Text.ElideRight
                        }

                        Controls.Label {
                            Layout.fillWidth: true
                            text: childDelegate.model.IsActive
                                ? qsTr("Active")
                                : childDelegate.model.IsMinimized
                                    ? qsTr("Minimized") : qsTr("Open")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: 10
                        }
                    }

                    Controls.ToolButton {
                        icon.name: "window-close"
                        display: Controls.AbstractButton.IconOnly
                        Accessible.name: qsTr("Close window")
                        onClicked: {
                            const childIndex = chooser.modelIndexForChild(childDelegate.index);
                            if (childIndex) {
                                chooser.closeRequested(childIndex);
                            }
                        }
                    }
                }

                onClicked: {
                    const childIndex = chooser.modelIndexForChild(childDelegate.index);
                    if (childIndex) {
                        chooser.activateRequested(childIndex);
                    }
                    chooser.visible = false;
                }
            }
        }

        ColumnLayout {
            id: chooserColumn

            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            Controls.Label {
                Layout.fillWidth: true
                text: qsTr("%1 windows").arg(chooser.groupTitle)
                font.bold: true
                elide: Text.ElideRight
            }

            ListView {
                id: windowList

                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(
                    Math.max(contentHeight, 46),
                    chooser.maxVisibleRows * 46
                )
                clip: true
                focus: true
                currentIndex: 0
                reuseItems: false
                boundsBehavior: Flickable.StopAtBounds
                model: chooser.visible ? windowModel : null

                Keys.onEscapePressed: event => {
                    chooser.visible = false;
                    event.accepted = true;
                }

                Keys.onReturnPressed: event => {
                    const childIndex = chooser.modelIndexForChild(currentIndex);
                    if (childIndex) {
                        chooser.activateRequested(childIndex);
                    }
                    chooser.visible = false;
                    event.accepted = true;
                }
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!chooser.active) {
                chooser.visible = false;
            }
        }
    }

    onActiveChanged: {
        if (!active && visible) {
            closeTimer.restart();
        }
    }

    onVisibleChanged: {
        if (visible) {
            closeTimer.stop();
            requestActivate();
        } else {
            closeTimer.stop();
        }
    }
}
