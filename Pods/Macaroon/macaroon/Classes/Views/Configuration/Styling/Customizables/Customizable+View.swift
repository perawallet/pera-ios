// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension Customizable where Self: UIView {
    public func customizeAppearance(
        _ style: ViewStyle
    ) {
        style.forEach {
            switch $0 {
            case .backgroundColor(let backgroundColor):
                customizeBaseAppearance(
                    backgroundColor: backgroundColor
                )
            case .tintColor(let tintColor):
                customizeBaseAppearance(
                    tintColor: tintColor
                )
            }
        }
    }

    public func recustomizeAppearance(
        _ style: ViewStyle
    ) {
        resetAppearance()
        customizeAppearance(style)
    }
}
