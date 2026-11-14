/*
 * SPDX-License-Identifier: GPL-3.0-only
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    property alias cfg_iconSize: iconSize.value
    property alias cfg_iconSpacing: iconSpacing.value
    property alias cfg_hoverScale: hoverScale.value
    property alias cfg_showBackground: showBackground.checked
    property alias cfg_showActiveIndicator: showActiveIndicator.checked

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: iconSize
            Kirigami.FormData.label: i18n("Icon size:")
            from: 24
            to: 72
        }
        QQC2.SpinBox {
            id: iconSpacing
            Kirigami.FormData.label: i18n("Icon spacing:")
            from: 0
            to: 18
        }
        QQC2.SpinBox {
            id: hoverScale
            Kirigami.FormData.label: i18n("Hover scale (%):")
            from: 100
            to: 130
        }
        QQC2.CheckBox {
            id: showBackground
            text: i18n("Show floating background")
        }
        QQC2.CheckBox {
            id: showActiveIndicator
            text: i18n("Show active-window indicator")
        }
    }
}
