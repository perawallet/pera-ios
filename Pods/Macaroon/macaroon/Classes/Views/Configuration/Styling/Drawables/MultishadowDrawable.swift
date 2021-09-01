// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol DoubleShadowDrawable: ShadowDrawable {
    var secondShadow: Shadow? { get set }
    var secondShadowLayer: CAShapeLayer { get }
}

extension DoubleShadowDrawable {
    public func drawAppearance(
        secondShadow: Shadow?
    ) {
        drawAppearance(
            shadow: secondShadow,
            on: secondShadowLayer
        )

        self.secondShadow = secondShadow
    }
}

extension DoubleShadowDrawable {
    public func draw(
        secondShadow: Shadow
    ) {
        draw(
            shadow: secondShadow,
            on: secondShadowLayer
        )

        self.secondShadow = secondShadow
    }

    public func updateOnLayoutSubviews(
        secondShadow: Shadow
    ) {
        updateOnLayoutSubviews(
            shadow: secondShadow,
            on: secondShadowLayer
        )
    }

    public func eraseSecondShadow() {
        eraseShadow(
            from: secondShadowLayer
        )

        self.secondShadow = nil
    }
}

public protocol TripleShadowDrawable: DoubleShadowDrawable {
    var thirdShadow: Shadow? { get set }
    var thirdShadowLayer: CAShapeLayer { get }
}

extension TripleShadowDrawable {
    public func drawAppearance(
        thirdShadow: Shadow?
    ) {
        drawAppearance(
            shadow: thirdShadow,
            on: thirdShadowLayer
        )

        self.thirdShadow = thirdShadow
    }
}

extension TripleShadowDrawable {
    public func draw(
        thirdShadow: Shadow
    ) {
        draw(
            shadow: thirdShadow,
            on: thirdShadowLayer
        )

        self.thirdShadow = thirdShadow
    }

    public func updateOnLayoutSubviews(
        thirdShadow: Shadow
    ) {
        updateOnLayoutSubviews(
            shadow: thirdShadow,
            on: thirdShadowLayer
        )
    }

    public func eraseThirdShadow() {
        eraseShadow(
            from: thirdShadowLayer
        )

        self.thirdShadow = nil
    }
}
