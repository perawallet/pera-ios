//
//  TabBarItemConvertible.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

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
