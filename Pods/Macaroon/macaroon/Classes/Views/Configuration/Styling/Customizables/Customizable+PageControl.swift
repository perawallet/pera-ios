// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension Customizable where Self: UIPageControl {
    public func customizeAppearance(
        _ style: PageControlStyle
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
            case .indicatorColor(let indicatorColor):
                customizeBaseAppearance(
                    indicatorColor: indicatorColor
                )
            case .indicatorImage(let indicatorImage):
                customizeBaseAppearance(
                    indicatorImage: indicatorImage
                )
            }
        }

        hidesForSinglePage = true
        isUserInteractionEnabled = false
    }

    public func recustomizeAppearance(
        _ style: PageControlStyle
    ) {
        resetAppearance()
        customizeAppearance(
            style
        )
    }

    public func resetAppearance() {
        resetAppearance()

        customizeBaseAppearance(
            indicatorColor: nil
        )
        customizeBaseAppearance(
            indicatorImage: nil
        )

        hidesForSinglePage = false
        isUserInteractionEnabled = true
    }
}

extension Customizable where Self: UIPageControl {
    public func customizeBaseAppearance(
        indicatorColor: Color?
    ) {
        pageIndicatorTintColor = indicatorColor?.color
        currentPageIndicatorTintColor = indicatorColor?.selected ?? indicatorColor?.highlighted
    }

    public func customizeBaseAppearance(
        indicatorImage: Image?
    ) {
        if #available(iOS 14, *) {
            preferredIndicatorImage = indicatorImage?.image
        }
    }
}
