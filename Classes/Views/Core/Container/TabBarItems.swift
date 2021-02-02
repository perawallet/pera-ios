//
//  TabBarItems.swift

import UIKit

class AccountsTabBarItem: TabBarItem {
    init(content: UIViewController) {
        super.init(
            name: "accounts",
            style: TabBarButtonItemStyle(icon: img("tabbar-icon-accounts"), selectedIcon: img("tabbar-icon-accounts-selected")),
            content: content
        )
    }
}

class ContactsTabBarItem: TabBarItem {
    init(content: UIViewController) {
        super.init(
            name: "contacts",
            style: TabBarButtonItemStyle(icon: img("tabbar-icon-contacts"), selectedIcon: img("tabbar-icon-contacts-selected")),
            content: content
        )
    }
}

class TransactionTabBarItem: TabBarItem {
    init() {
        super.init(
            name: "transaction",
            style: TabBarButtonItemStyle(icon: img("tabbar-icon-transaction"), selectedIcon: img("tabbar-icon-transaction-selected")),
            content: nil
        )
    }
}

class NotificationsTabBarItem: TabBarItem {
    init(content: UIViewController) {
        super.init(
            name: "notifications",
            style: TabBarButtonItemStyle(icon: img("tabbar-icon-notifications"), selectedIcon: img("tabbar-icon-notifications-selected")),
            content: content
        )
    }
}

class SettingsTabBarItem: TabBarItem {
    init(content: UIViewController) {
        super.init(
            name: "settings",
            style: TabBarButtonItemStyle(icon: img("tabbar-icon-settings"), selectedIcon: img("tabbar-icon-settings-selected")),
            content: content
        )
    }
}

class TabBarItem: TabBarItemConvertible {
    let name: String
    let barButtonItem: TabBarButtonItemConvertible
    let content: UIViewController?

    init(
        name: String,
        style: TabBarButtonItemStyle,
        content: UIViewController?
    ) {
        self.name = name
        self.barButtonItem = TabBarButtonItem(style, selectable: content != nil)
        self.content = content
    }
}

struct TabBarButtonItem: TabBarButtonItemConvertible {
    let icon: UIImage?
    let selectedIcon: UIImage?
    let badgeIcon: UIImage?
    let badgePositionAdjustment: CGPoint?
    let width: CGFloat
    let isSelectable: Bool

    init(
        _ style: TabBarButtonItemStyle,
        selectable: Bool = true
    ) {
        self.icon = style.icon
        self.selectedIcon = style.selectedIcon
        self.badgeIcon = style.badgeIcon
        self.badgePositionAdjustment = CGPoint(x: -4.0, y: 4.0)
        self.width = UIView.noIntrinsicMetric
        self.isSelectable = selectable
    }
}

struct TabBarButtonItemStyle {
    let icon: UIImage?
    let selectedIcon: UIImage?
    var badgeIcon: UIImage?
    
    init(icon: UIImage?, selectedIcon: UIImage?, badgeIcon: UIImage? = nil) {
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.badgeIcon = badgeIcon
    }
}
