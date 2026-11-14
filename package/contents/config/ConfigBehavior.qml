/*
 * SPDX-License-Identifier: GPL-3.0-only
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    property alias cfg_enableLaunchBounce: launchBounce.checked
    property alias cfg_showLaunchPulse: launchPulse.checked
    property alias cfg_enableAttentionReaction: attentionReaction.checked
    property alias cfg_enableDragReorder: dragReorder.checked
    property alias cfg_groupApplications: groupApplications.checked
    property alias cfg_currentDesktopOnly: currentDesktopOnly.checked
    property alias cfg_currentScreenOnly: currentScreenOnly.checked

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: launchBounce
            text: i18n("Elastic icon reaction when launching")
        }
        QQC2.CheckBox {
            id: launchPulse
            text: i18n("Energy pulse when launching")
        }
        QQC2.CheckBox {
            id: attentionReaction
            text: i18n("Pulse when an application needs attention")
        }
        QQC2.CheckBox {
            id: dragReorder
            text: i18n("Allow dragging icons to reorder the Dock")
        }
        QQC2.CheckBox {
            id: groupApplications
            text: i18n("Group windows from the same application")
        }
        QQC2.CheckBox {
            id: currentDesktopOnly
            text: i18n("Show windows from the current virtual desktop only")
        }
        QQC2.CheckBox {
            id: currentScreenOnly
            text: i18n("Show windows from this screen only")
        }
    }
}
