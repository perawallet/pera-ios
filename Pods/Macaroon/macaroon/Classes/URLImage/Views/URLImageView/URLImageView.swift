// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class URLImageView:
    View,
    URLImageLoadable {
    open override var tintColor: UIColor! {
        get { contentView.tintColor }
        set { contentView.tintColor = newValue }
    }

    public var imageContainer: UIImageView {
        return contentView
    }
    public var placeholderContainer: URLImagePlaceholderContainer? {
        return placeholderView
    }

    private(set) lazy var contentView = UIImageView()
    private(set) lazy var placeholderView = URLImagePlaceholderView()

    public override init(
        frame: CGRect
    ) {
        super.init(
            frame: frame
        )

        prepareLayout(
            NoLayoutSheet()
        )
    }

    open func customizeAppearance(
        _ styleSheet: URLImageViewStyleSheet
    ) {
        customizeAppearance(
            styleSheet.background
        )
        customizeContentAppearance(
            styleSheet
        )
        customizePlaceholderAppearance(
            styleSheet
        )
    }

    open func customizeContentAppearance(
        _ styleSheet: URLImageViewStyleSheet
    ) {
        contentView.customizeAppearance(
            styleSheet.content
        )
    }

    open func customizePlaceholderAppearance(
        _ styleSheet: URLImageViewStyleSheet
    ) {
        if let placeholder = styleSheet.placeholder {
            placeholderView.customizeAppearance(
                placeholder
            )
        }
    }

    open func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {
        addContent(
            layoutSheet
        )
    }

    open func addContent(
        _ layoutSheet: LayoutSheet
    ) {
        addSubview(
            contentView
        )
        contentView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    open func prepareForReuse() {
        unloadSource()
        placeholderView.prepareForReuse()
    }
}
