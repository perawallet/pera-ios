// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension Customizable where Self: UINavigationBar {
    public func customizeAppearance(
        _ style: NavigationBarStyle
    ) {
        /// <note>
        /// Set `opaque` first so that it can't override the previous attributes for iOS 13 and
        /// later.
        let orderedStyle = style.sorted {
            switch ($0, $1) {
            case (.opaque, _): return true
            case (_, .opaque): return true
            default: return false
            }
        }

        orderedStyle.forEach {
            switch $0 {
            case .backgroundColor(let backgroundColor):
                customizeBarAppearance(
                    backgroundColor: backgroundColor
                )
            case .tintColor(let tintColor):
                customizeBarAppearance(
                    tintColor: tintColor
                )
            case .opaque:
                customizeBarAppearance(
                    opaque: true
                )
            case .shadowImage(let shadowImage):
                customizeBarAppearance(
                    shadowImage: shadowImage
                )
            case .shadowColor(let shadowColor):
                customizeBarAppearance(
                    shadowColor: shadowColor
                )
            case .titleAttributes(let titleAttributes):
                customizeBarAppearance(
                    titleAttributes: titleAttributes
                )
            case .largeTitleAttributes(let largeTitleAttributes):
                customizeBarAppearance(
                    largeTitleAttributes: largeTitleAttributes
                )
            }
        }
    }

    public func recustomizeAppearance(
        _ style: NavigationBarStyle
    ) {
        resetAppearance()
        customizeAppearance(
            style
        )
    }

    public func resetAppearance() {
        resetBaseAppearance()

        customizeBarAppearance(
            backgroundColor: nil
        )
        customizeBarAppearance(
            tintColor: nil
        )
        customizeBarAppearance(
            opaque: false
        )
        customizeBarAppearance(
            shadowImage: nil
        )
        customizeBarAppearance(
            shadowColor: nil
        )
        customizeBarAppearance(
            titleAttributes: nil
        )
        customizeBarAppearance(
            largeTitleAttributes: nil
        )
    }
}

extension Customizable where Self: UINavigationBar {
    public func customizeBarAppearance(
        backgroundColor: Color?
    ) {
        if #available(iOS 13, *) {
            customizeBarAppearance(
                backgroundColor?.color,
                \.backgroundColor
            )
        } else {
            self.barTintColor = backgroundColor?.color
        }
    }

    public func customizeBarAppearance(
        tintColor: Color?
    ) {
        self.tintColor = tintColor?.color
    }

    public func customizeBarAppearance(
        opaque: Bool
    ) {
        self.isTranslucent = !opaque

        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()

            standardAppearance = appearance
            compactAppearance = appearance
            scrollEdgeAppearance = appearance
        }
    }

    public func customizeBarAppearance(
        shadowImage: Image?
    ) {
        if #available(iOS 13, *) {
            customizeBarAppearance(
                shadowImage?.image,
                \.shadowImage
            )
        } else {
            self.shadowImage = shadowImage?.image
        }
    }

    public func customizeBarAppearance(
        shadowColor: Color?
    ) {
        if #available(iOS 13, *) {
            customizeBarAppearance(
                shadowColor?.color,
                \.shadowColor
            )
        }
    }

    public func customizeBarAppearance(
        titleAttributes: [NSAttributedString.Key: Any]?
    ) {
        if #available(iOS 13, *) {
            customizeBarAppearance(
                titleAttributes ?? [:],
                \.titleTextAttributes
            )
        } else {
            self.titleTextAttributes = titleAttributes
        }
    }

    public func customizeBarAppearance(
        largeTitleAttributes: [NSAttributedString.Key: Any]?
    ) {
        /// <note> Don't support large title for iOS 13 and later.
        if #available(iOS 13, *) {
            if LayoutFamily.current == .extraSmall {
                self.prefersLargeTitles = false
                return
            }

            self.prefersLargeTitles = largeTitleAttributes != nil

            customizeBarAppearance(
                largeTitleAttributes ?? [:],
                \.largeTitleTextAttributes
            )
        } else {
            self.prefersLargeTitles = false
        }
    }
}

@available(iOS 13, *)
extension Customizable where Self: UINavigationBar {
    public func customizeBarAppearance<T>(
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<UINavigationBarAppearance, T>
    ) {
        customizeBarStandardAppearance(
            value,
            keyPath
        )
        customizeBarCompactAppearance(
            value,
            keyPath
        )
        customizeBarScrollEdgeAppearance(
            value,
            keyPath
        )
    }

    public func customizeBarStandardAppearance<T>(
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<UINavigationBarAppearance, T>
    ) {
        let appearance = standardAppearance.copy()
        appearance[keyPath: keyPath] = value
        standardAppearance = appearance
    }

    public func customizeBarCompactAppearance<T>(
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<UINavigationBarAppearance, T>
    ) {
        let appearance = compactAppearance?.copy()
        appearance?[keyPath: keyPath] = value
        compactAppearance = appearance
    }

    public func customizeBarScrollEdgeAppearance<T>(
        _ value: T,
        _ keyPath: ReferenceWritableKeyPath<UINavigationBarAppearance, T>
    ) {
        let appearance = scrollEdgeAppearance?.copy()
        appearance?[keyPath: keyPath] = value
        scrollEdgeAppearance = appearance
    }
}
