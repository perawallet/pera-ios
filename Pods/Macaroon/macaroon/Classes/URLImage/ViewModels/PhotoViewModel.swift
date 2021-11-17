// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol PhotoViewModel: ViewModel {
    var photo: ImageSource? { get set }
    var hasSomePhoto: Bool { get set }

    var size: ImageSize { get }
    var shape: ImageShape { get }
    var placeholder: ImagePlaceholder { get }
}

extension PhotoViewModel {
    public mutating func bindPhoto(
        _ url: URL?
    ) {
        photo = PNGImageSource(
            url: url,
            size: size,
            shape: shape,
            placeholder: (photo as? AssetImageSource).unwrap(
                { ImagePlaceholder(image: $0) },
                or: placeholder
            )
        )
    }

    public mutating func bindHasSomePhoto(
        _ url: URL?
    ) {
        hasSomePhoto = url != nil
    }
}

extension PhotoViewModel {
    public mutating func bindPhoto(
        _ photo: Photo
    ) {
        let size = self.size.reduce() ?? .zero
        let resizedImage =
            photo.image.resized(
                size,
                .aspectFit
            )
        let fitImage =
            resizedImage?.cropped(
                resizedImage?.size.minSquare
            )
        let scale =
            fitImage.unwrap(
                { min($0.size.width / size.width, $0.size.height / size.height) },
                or: 1.0
            )
        let shapedImage =
            fitImage?.shaped(
                shape,
                nil,
                scale
            )

        self.photo = AssetImageSource(asset: shapedImage)
    }

    public mutating func bindHasSomePhoto(
        _ photo: Photo
    ) {
        hasSomePhoto = true
    }
}
