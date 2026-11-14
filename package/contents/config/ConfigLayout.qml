/*
 * SPDX-License-Identifier: GPL-3.0-only
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    property alias cfg_dockLayoutMode: layoutMode.currentIndex
    property alias cfg_layerSpacing: layerSpacing.value
    property alias cfg_quickAccessIconSize: quickAccessIconSize.value
    property alias cfg_runningTasksIconSize: runningTasksIconSize.value
    property alias cfg_quickAccessSpacing: quickAccessSpacing.value
    property alias cfg_runningTasksSpacing: runningTasksSpacing.value

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: layoutMode
            Kirigami.FormData.label: i18n("Dock layout:")
            model: [
                i18n("Single row"),
                i18n("Dual layer"),
                i18n("Adaptive")
            ]
        }

        QQC2.SpinBox {
            id: layerSpacing
            enabled: layoutMode.currentIndex !== 0
            Kirigami.FormData.label: i18n("Space between layers:")
            from: 0
            to: 16
        }

        QQC2.SpinBox {
            id: quickAccessIconSize
            enabled: layoutMode.currentIndex !== 0
            Kirigami.FormData.label: i18n("Quick Access icon size:")
            from: 24
            to: 72
        }

        QQC2.SpinBox {
            id: runningTasksIconSize
            enabled: layoutMode.currentIndex !== 0
            Kirigami.FormData.label: i18n("Running window icon size:")
            from: 24
            to: 72
        }

        QQC2.SpinBox {
            id: quickAccessSpacing
            enabled: layoutMode.currentIndex !== 0
            Kirigami.FormData.label: i18n("Quick Access icon spacing:")
            from: 0
            to: 18
        }

        QQC2.SpinBox {
            id: runningTasksSpacing
            enabled: layoutMode.currentIndex !== 0
            Kirigami.FormData.label: i18n("Running window spacing:")
            from: 0
            to: 18
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: i18n("Dual and Adaptive layouts need additional panel thickness. Increase the Plasma panel thickness if the second layer is clipped.")
        }
    }
}
