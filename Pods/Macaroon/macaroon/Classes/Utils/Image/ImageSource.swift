// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ImageSource {
    func load(in imageView: UIImageView, onCompleted execute: ((Swift.Error?) -> Void)?)
}

public struct NoImageSource: ImageSource {
    public init() { }

    public func load(in imageView: UIImageView, onCompleted execute: ((Swift.Error?) -> Void)? = nil) {
        imageView.image = nil
        execute?(nil)
    }
}

public struct AssetImageSource: ImageSource {
    public let asset: UIImage?
    public let color: UIColor?

    public init(
        asset: UIImage?,
        color: UIColor? = nil
    ) {
        self.asset = asset
        self.color = color
    }

    public func load(in imageView: UIImageView, onCompleted execute: ((Swift.Error?) -> Void)? = nil) {
        if let color = color {
            imageView.image = asset?.template
            imageView.tintColor = color
        } else {
            imageView.image = asset
        }
        execute?(nil)
    }
}

extension UIImage: ImageSource {
    public func load(in imageView: UIImageView, onCompleted execute: ((Swift.Error?) -> Void)?) {
        AssetImageSource(asset: self).load(in: imageView, onCompleted: execute)
    }
}
