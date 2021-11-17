// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class URLImagePlaceholderView:
    View,
    URLImagePlaceholderContainer {
    public var placeholder: ImagePlaceholder? {
        didSet {
            bindData()
        }
    }

    public private(set) lazy var imageView = UIImageView()
    public private(set) lazy var textView = Label()

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
        _ styleSheet: URLImagePlaceholderViewStyleSheet
    ) {
        customizeAppearance(
            styleSheet.background
        )
        customizeImageAppearance(
            styleSheet
        )
        customizeTextAppearance(
            styleSheet
        )
    }

    open func customizeImageAppearance(
        _ styleSheet: URLImagePlaceholderViewStyleSheet
    ) {
        imageView.customizeAppearance(
            styleSheet.image
        )
    }

    open func customizeTextAppearance(
        _ styleSheet: URLImagePlaceholderViewStyleSheet
    ) {
        textView.customizeAppearance(
            styleSheet.text
        )
    }

    open func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {
        addImage(
            layoutSheet
        )
        addText(
            layoutSheet
        )
    }

    open func addImage(
        _ layoutSheet: LayoutSheet
    ) {
        addSubview(
            imageView
        )
        imageView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    open func addText(
        _ layoutSheet: LayoutSheet
    ) {
        addSubview(
            textView
        )
        textView.fitToHorizontalIntrinsicSize()
        textView.fitToVerticalIntrinsicSize()
        textView.snp.makeConstraints {
            $0.setPaddings(
                (8, 8, 8, 8)
            )
        }
    }

    open func bindData() {
        imageView.load(
            from: placeholder?.image
        )
        textView.editText = placeholder?.text
        textView.invalidateIntrinsicContentSize()
    }

    open func prepareForReuse() {
        imageView.image = nil
        textView.editText = nil
    }
}
