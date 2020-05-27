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
    
    func applyMultipleShadows(_ shadows: [Shadow]) {
        for (index, shadow) in shadows.enumerated() {
            let shadowLayer = CALayer()
            shadowLayer.name = "shadow_\(index)"
            shadowLayer.shadowColor = shadow.color.cgColor
            shadowLayer.shadowRadius = shadow.radius
            shadowLayer.shadowOpacity = shadow.opacity
            shadowLayer.shadowOffset = shadow.offset
            shadowLayer.backgroundColor = backgroundColor?.cgColor
            shadowLayer.needsDisplayOnBoundsChange = true
            shadowLayer.cornerRadius = layer.cornerRadius
            shadowLayer.masksToBounds = false

            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    func applySmallShadow() {
        applyMultipleShadows([smallTopShadow, smallBottomShadow])
    }
    
    func applyMediumShadow() {
        applyMultipleShadows([mediumTopShadow, mediumBottomShadow])
    }
    
    func applyErrorShadow() {
        applyShadow(errorShadow)
    }
    
    func setShadowFrames() {
        layer.sublayers?.forEach { sublayer in
            if let sublayerName = sublayer.name,
                sublayerName.hasPrefix("shadow_") {
                    sublayer.frame = bounds
            }
        }
    }
}
