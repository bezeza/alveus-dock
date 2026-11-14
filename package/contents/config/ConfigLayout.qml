/*
 * SPDX-License-Identifier: GPL-3.0-only
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    property alias cfg_dockLayoutMode: layoutMode.currentIndex
    property alias cfg_layerSpacing: layerSpacing.value

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
            Kirigami.FormData.label: i18n("Space between layers:")
            from: 0
            to: 16
        }

        QQC2.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: i18n("Dual and Adaptive layouts need additional panel thickness. Increase the Plasma panel height if the second layer is clipped.")
        }
    }
}
