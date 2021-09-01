// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol Image {
    var image: UIImage { get }
    var highlighted: UIImage? { get }
    var selected: UIImage? { get }
    var disabled: UIImage? { get }
}

extension Image {
    public var highlighted: UIImage? {
        return nil
    }
    public var selected: UIImage? {
        return nil
    }
    public var disabled: UIImage? {
        return nil
    }
}

extension Image {
    public var original: UIImage {
        return image.original
    }
    public var template: UIImage {
        return image.template
    }
}

extension UIImage: Image {
    public var image: UIImage {
        return self
    }
}

extension String: Image {
    public var image: UIImage {
        return img(self)
    }
}

extension RawRepresentable where RawValue == String {
    public var image: UIImage {
        return rawValue.image
    }
}

public struct ImageSet: Image {
    public let image: UIImage
    public let highlighted: UIImage?
    public let selected: UIImage?
    public let disabled: UIImage?

    public init(
        _ image: Image,
        highlighted: Image? = nil,
        selected: Image? = nil,
        disabled: Image? = nil
    ) {
        self.image = image.image
        self.highlighted = highlighted?.image
        self.selected = selected?.image
        self.disabled = disabled?.image
    }
}
