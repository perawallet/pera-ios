// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import Kingfisher
import UIKit

public struct PNGImageSource: URLImageSource {
    public let url: URL?
    public let color: UIColor?
    public let placeholder: ImagePlaceholder?
    public let size: ImageSize
    public let shape: ImageShape
    public let forceRefresh: Bool

    public init(
        url: URL?,
        color: UIColor? = nil,
        size: ImageSize = .original,
        shape: ImageShape = .original,
        placeholder: ImagePlaceholder? = nil,
        forceRefresh: Bool = false
    ) {
        self.url = url
        self.color = color
        self.placeholder = placeholder
        self.size = size
        self.shape = shape
        self.forceRefresh = forceRefresh
    }

    public func formImageProcessors() -> [ImageProcessor?] {
        return [
            formSizeImageProcessor(),
            formShapeImageProcessor()
        ]
    }
}

extension PNGImageSource {
    private func formSizeImageProcessor() -> ImageProcessor? {
        switch size {
        case .original:
            return nil
        case .resize(let referenceSize, let mode):
            return ResizingImageProcessor(referenceSize: referenceSize.scaled(), mode: mode)
        case .cropping(let targetSize):
            return CroppingImageProcessor(size: targetSize)
        case .downsampling(let targetSize):
            return DownsamplingImageProcessor(size: targetSize)
        }
    }

    private func formShapeImageProcessor() -> ImageProcessor? {
        guard let size = size.reduce() else {
            return nil
        }
        switch shape {
        case .original:
            return nil
        case .circle:
            return RoundCornerImageProcessor(cornerRadius: (size.scaled().minDimension / 2.0).float())
        case .rounded(let cornerRadius):
            return RoundCornerImageProcessor(cornerRadius: cornerRadius.scaled())
        }
    }
}
