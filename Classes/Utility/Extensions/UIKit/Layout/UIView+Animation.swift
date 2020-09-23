//
//  UIView+Animation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

extension UIView {
    func rotate360Degrees(duration: Double, repeatCount: Float) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = repeatCount
        layer.add(rotation, forKey: "rotationAnimation")
    }
}
