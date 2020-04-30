//
//  UIView+Shadow.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.04.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

extension UIView {
    func applyShadow(_ shadow: Shadow) {
        layer.shadowColor = shadow.color.cgColor
        layer.shadowOffset = shadow.offset
        layer.shadowRadius = shadow.radius
        layer.shadowOpacity = shadow.opacity
        layer.masksToBounds = false
    }
}
