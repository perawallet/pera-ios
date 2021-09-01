// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ImageLoadable {
    var imageContainer: UIImageView { get }

    func load(from source: ImageSource?, onCompleted execute: ((Swift.Error?) -> Void)?)
    func unloadSource()
}

extension ImageLoadable {
    public func load(from source: ImageSource?, onCompleted execute: ((Swift.Error?) -> Void)? = nil) {
        if let source = source {
            source.load(in: imageContainer, onCompleted: execute)
        } else {
            unloadSource()
            execute?(nil)
        }
    }

    public func unloadSource() {
        imageContainer.image = nil
    }
}

extension UIImageView: ImageLoadable {
    public var imageContainer: UIImageView {
        return self
    }
}
