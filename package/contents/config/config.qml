/*
 * SPDX-License-Identifier: GPL-3.0-only
 */
import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-theme"
        source: "ConfigAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Behavior")
        icon: "preferences-desktop"
        source: "ConfigBehavior.qml"
    }
}
