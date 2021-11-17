// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol GradientBorderDrawable: UIView {
    var gradientBorder: GradientBorder? { get set }
    var gradientLayer: CAGradientLayer { get }
}

extension GradientBorderDrawable {
    public func drawAppearance(
        gradientBorder: GradientBorder?
    ) {
        guard let gradientBorder = gradientBorder else {
            eraseGradientBorder()
            return
        }

        draw(
            gradientBorder: gradientBorder
        )
    }
}

extension GradientBorderDrawable {
    public func draw(
        gradientBorder: GradientBorder
    ) {
        gradientLayer.draw(
            gradientBorder: gradientBorder
        )

        layer.addIfNeeded(
            gradientLayer: gradientLayer
        )

        updateOnLayoutSubviews(
            gradientBorder: gradientBorder
        )

        self.gradientBorder = gradientBorder
    }

    public func updateOnLayoutSubviews(
        gradientBorder: GradientBorder
    ) {
        if bounds.isEmpty {
            return
        }

        gradientLayer.frame = bounds
        gradientLayer.drawPath(
            gradientBorder: gradientBorder
        )
    }

    public func eraseGradientBorder() {
        gradientLayer.removeFromSuperlayer()
        gradientLayer.eraseGradientBorder()

        gradientBorder = nil
    }
}

extension CAGradientLayer {
    public func draw(
        gradientBorder: GradientBorder
    ) {
        colors = gradientBorder.colors

        let shapeMask = CAShapeLayer()
        shapeMask.lineWidth = gradientBorder.width
        shapeMask.strokeColor = UIColor.black.cgColor
        shapeMask.fillColor = UIColor.clear.cgColor

        mask = shapeMask
    }

    public func drawPath(
        gradientBorder: GradientBorder
    ) {
        func calculatePath() -> CGPath {
            if gradientBorder.isRounded {
                return UIBezierPath(
                    roundedRect: bounds,
                    byRoundingCorners: gradientBorder.corners,
                    cornerRadii: gradientBorder.cornerRadii
                ).cgPath
            }

            return UIBezierPath(rect: bounds).cgPath
        }

        if bounds.isEmpty {
            return
        }

        guard let shapeMask = mask as? CAShapeLayer else {
            return
        }

        shapeMask.frame = bounds
        shapeMask.path = calculatePath()
    }

    public func eraseGradientBorder() {
        draw(
            gradientBorder: GradientBorder(colors: [], width: 0)
        )
    }
}

extension CALayer {
    public func addIfNeeded(
        gradientLayer: CAGradientLayer
    ) {
        if let sublayers = sublayers,
           sublayers.contains(
               gradientLayer
           ) {
            return
        }

        addSublayer(
            gradientLayer
        )
    }
}
