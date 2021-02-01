//
//  TabBarItemConvertible.swift

import UIKit

protocol TabBarItemConvertible {
    var name: String { get }
    var barButtonItem: TabBarButtonItemConvertible { get }
    var content: UIViewController? { get }
}

extension TabBarItemConvertible {
    func equalsTo(_ other: TabBarItemConvertible?) -> Bool {
        if let other = other {
            return name == other.name
        }
        return false
    }
}
