//
//  UserInterfaceChangable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import UIKit

protocol UserInterfaceChangable {
    func changeUserInterfaceStyle(to appearance: UserInterfaceStyle)
}

extension UserInterfaceChangable where Self: UIViewController {
    /// <note> overrideUserInterfaceStyle property is used to override interface style for user preference
    func changeUserInterfaceStyle(to appearance: UserInterfaceStyle) {
        guard #available(iOS 13.0, *) else {
            return
        }

        switch appearance {
        case .system:
            let systemAppearance: UIUserInterfaceStyle = UIApplication.shared.deviceInterfaceStyle == .light ? .light : .dark
            UIApplication.shared.appDelegate?.window?.overrideUserInterfaceStyle = systemAppearance
        case .dark:
            UIApplication.shared.appDelegate?.window?.overrideUserInterfaceStyle = .dark
        case .light:
            UIApplication.shared.appDelegate?.window?.overrideUserInterfaceStyle = .light
        }
    }
}
