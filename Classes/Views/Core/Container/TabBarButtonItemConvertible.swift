//
//  TabBarButtonItemConvertible.swift

import UIKit

protocol TabBarButtonItemConvertible {
    var icon: UIImage? { get }
    var selectedIcon: UIImage? { get }
    var badgeIcon: UIImage? { get }
    var badgePositionAdjustment: CGPoint? { get }
    var width: CGFloat { get } /// <note> The explicit width for the tabbar button
    var isSelectable: Bool { get }
}

extension TabBarButtonItemConvertible {
    var badgeIcon: UIImage? {
        return nil
    }
    
    var badgePositionAdjustment: CGPoint? {
        return .zero
    }
}
