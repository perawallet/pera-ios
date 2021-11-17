// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol Color {
    var color: UIColor { get }
    var highlighted: UIColor? { get }
    var selected: UIColor? { get }
    var disabled: UIColor? { get }
}

extension Color {
    public var highlighted: UIColor? {
        return nil
    }
    public var selected: UIColor? {
        return nil
    }
    public var disabled: UIColor? {
        return nil
    }
}

extension UIColor: Color {
    public var color: UIColor {
        return self
    }
}

extension String: Color {
    public var color: UIColor {
        return col(self)
    }
}

extension RawRepresentable where RawValue == String {
    public var color: UIColor {
        return rawValue.color
    }
}

public struct ColorSet: Color {
    public let color: UIColor
    public let highlighted: UIColor?
    public let selected: UIColor?
    public let disabled: UIColor?

    public init(
        _ color: Color,
        highlighted: Color? = nil,
        selected: Color? = nil,
        disabled: Color? = nil
    ) {
        self.color = color.color
        self.highlighted = highlighted?.color
        self.selected = selected?.color
        self.disabled = disabled?.color
    }
}
