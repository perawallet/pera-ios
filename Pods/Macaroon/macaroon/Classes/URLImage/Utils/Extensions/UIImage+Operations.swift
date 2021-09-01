// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import Kingfisher
import UIKit

extension UIImage {
    public func shaped(
        _ shape: ImageShape,
        _ size: CGSize? = nil,
        _ scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        switch shape {
        case .original:
            return self
        case .circle:
            return allRounded(scale)
        case .rounded(let radius):
            return rounded(radius, size, .all, scale)
        }
    }

    public func allRounded(
        _ scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        return rounded(
            (size.minDimension / 2.0).float(),
            size.minSquare,
            .all,
            scale
        )
    }

    public func rounded(
        _ radius: CGFloat,
        _ size: CGSize? = nil,
        _ corners: RectCorner = .all,
        _ scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        let processor =
            RoundCornerImageProcessor(
                cornerRadius: radius.scaled(scale),
                targetSize: size?.scaled(scale),
                roundingCorners: corners
            )
        return processor.process(item: .image(self), options: [])
    }

    public func resized(
        _ newSize: CGSize?,
        _ mode: ContentMode,
        _ scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        let scaledSize =
            newSize?.scaled(
                scale
            )
        let someSize =
            scaledSize.unwrapConditionally(
                where: { !$0.isEmpty && $0 < self.size }
            )

        guard let size = someSize else {
            return self
        }

        let processor = ResizingImageProcessor(referenceSize: size, mode: mode)

        return processor.process(
            item: .image(self),
            options: []
        )
    }

    public func downsampled(
        _ newSize: CGSize?,
        _ scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        let scaledSize =
            newSize?.scaled(
                scale
            )
        let someSize =
            scaledSize.unwrapConditionally(
                where: { !$0.isEmpty && $0 < self.size }
            )

        guard let size = someSize else {
            return self
        }

        let processor = DownsamplingImageProcessor(size: size)

        return processor.process(
            item: .image(self),
            options: []
        )
    }

    public func cropped(
        _ size: CGSize?,
        at anchor: CGPoint = .init(x: 0.5, y: 0.5),
        _ scale: CGFloat = 1.0
    ) -> UIImage? {
        let scaledSize =
            size?.scaled(
                scale
            )
        let someSize =
            scaledSize.unwrapConditionally(
                where: { !$0.isEmpty }
            )

        guard let size = someSize else {
            return self
        }

        let processor = CroppingImageProcessor(size: size , anchor: anchor)

        return processor.process(
            item: .image(self),
            options: []
        )
    }
}

extension UIImage {
    public func formBase64EncodedString(
        newSize: CGSize? = nil,
        compressionQuality: CGFloat = 0.9,
        onCompleted handler: @escaping (String?) -> Void
    ) {
        asyncBackground {
            [weak self] in

            guard let self = self else {
                return
            }

            let image =
                self.downsampled(
                    newSize,
                    1.0
                ) ?? self
            let base64EncodedString =
                image.jpegData(
                    compressionQuality: compressionQuality
                )?.base64EncodedString()

            asyncMain {
                handler(
                    base64EncodedString
                )
            }
        }
    }
}
