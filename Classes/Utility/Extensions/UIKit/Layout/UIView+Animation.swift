//
//  UIView+Animation.swift

import UIKit

extension UIView {
    func rotate360Degrees(duration: Double, repeatCount: Float, isClockwise: Bool) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: isClockwise ? Double.pi * 2 : -Double.pi * 2 )
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = repeatCount
        layer.add(rotation, forKey: "rotationAnimation")
    }
}
