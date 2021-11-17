// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

/// <note>
/// The base protocol which includes the common styles in an application.
public protocol StyleGuide: StyleSheet {}

public protocol StyleGroup {
    associatedtype Identifier

    subscript<T>(identifier: Identifier) -> T { get }
}

extension StyleGroup {
    public func createStyle<T: Style, U>(
        _ style: T
    ) -> U {
        guard let expectedStyle = style.create() as? U else {
            mc_crash(
                .styleNotFound(style)
            )
        }
        return expectedStyle
    }
}

public protocol Style {
    associatedtype Value

    func create() -> Value
}

public protocol StyleElementGroup {
    associatedtype Identifier

    subscript<T>(identifier: Identifier) -> T { get }
}

extension StyleElementGroup {
    public func createStyleElement<T: StyleElement, U>(
        _ styleElement: T
    ) -> U {
        guard let expectedStyleElement = styleElement.create() as? U else {
            mc_crash(
                .styleElementNotFound(styleElement)
            )
        }
        return expectedStyleElement
    }
}

public protocol StyleElement {
    associatedtype Value

    func create() -> Value
}
