// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import Kingfisher
import UIKit

public protocol URLImageLoadable: ImageLoadable {
    var placeholderContainer: URLImagePlaceholderContainer? { get }
}

extension URLImageLoadable {
    public func load(
        from source: ImageSource?,
        onCompleted execute: ((Swift.Error?) -> Void)? = nil
    ) {
        guard let source = source else {
            unloadSource()

            execute?(
                nil
            )

            return
        }

        if let urlSource = source as? PNGImageSource {
            urlSource.load(
                in: imageContainer,
                displayingPlaceholderIn: placeholderContainer,
                onCompleted: execute
            )
        } else {
            source.load(
                in: imageContainer,
                onCompleted: execute
            )
        }
    }

    public func unloadSource() {
        imageContainer.kf.cancelDownloadTask()
        imageContainer.image = nil
    }
}

extension UIImageView: URLImageLoadable {
    public var placeholderContainer: URLImagePlaceholderContainer? {
        return nil
    }
}
