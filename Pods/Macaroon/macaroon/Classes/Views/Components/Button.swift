// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class Button:
    UIButton,
    BorderDrawable,
    CornerDrawable,
    ShadowDrawable {
    open override var intrinsicContentSize: CGSize {
        if currentImage == nil &&
           currentTitle.isNilOrEmpty &&
           currentAttributedTitle.isNilOrEmpty {
            return .zero
        }

        return calculateIntrinsicContentSize() ?? super.intrinsicContentSize
    }

    public var shadow: Shadow?

    public private(set) lazy var shadowLayer = CAShapeLayer()

    private var cachedIntrinsicContentSize: CGSize?

    public let layout: Layout

    public init(_ layout: Layout = .none) {
        self.layout = layout

        super.init(frame: .zero)

        /// <note>
        /// The content width will be set as the title width, so if the title is short to fill the
        /// width, then it will be centered, which is what the caller expects.
        if layout.isVertical {
            titleLabel?.textAlignment = .center
        }
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func preferredUserInterfaceStyleDidChange() {
        drawAppearance(
            shadow: shadow
        )
    }

    open func preferredContentSizeCategoryDidChange() {}

    open override func invalidateIntrinsicContentSize() {
        cachedIntrinsicContentSize = nil
        super.invalidateIntrinsicContentSize()
    }

    open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = super.imageRect(forContentRect: contentRect)

        if currentImage == nil {
            return rect
        }

        switch layout {
        case .none:
            return rect
        case .imageAtTop(let spacing):
            let titleHeight = super.titleRect(forContentRect: contentRect).height
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = ((contentRect.height - (rect.height + spacing + titleHeight)) / 2.0).rounded() + contentEdgeInsets.top
            return rect
        case .imageAtTopmost(let padding, _):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = contentRect.minY + padding + contentEdgeInsets.top
            return rect
        case .imageAtLeft(let spacing):
            rect.origin.x = rect.origin.x - (spacing / 2.0).rounded()
            return rect
        case .imageAtLeftmost(let padding, _):
            rect.origin.x = contentRect.width - (padding + contentEdgeInsets.left)
            return rect
        case .imageAtRight(let spacing):
            let titleWidth = super.titleRect(forContentRect: contentRect).width
            rect.origin.x = rect.minX + titleWidth + (spacing / 2.0).rounded() + contentEdgeInsets.left
            return rect
        case .imageAtRightmost(let padding, _):
            rect.origin.x = contentRect.width - (rect.width + padding + contentEdgeInsets.right)
            return rect
        case .titleAtBottommost(_, let imageAdjustmentY):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = ((contentRect.height - rect.height) / 2.0).rounded() + imageAdjustmentY + contentEdgeInsets.top
            return rect
        }
    }

    open override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = super.titleRect(forContentRect: contentRect)

        if currentTitle == nil &&
           currentAttributedTitle == nil {
            return rect
        }

        switch layout {
        case .none:
            return rect
        case .imageAtTop(let spacing):
            let imageHeight = super.imageRect(forContentRect: contentRect).height
            rect.origin.x = contentEdgeInsets.left
            rect.origin.y = contentRect.height - ((contentRect.height - (imageHeight + spacing + rect.height)) / 2.0).rounded() - (rect.height + contentEdgeInsets.bottom)
            rect.size.width = contentRect.width - contentEdgeInsets.x
            return rect
        case .imageAtTopmost(_, let titleAdjustmentY):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = ((contentRect.height - rect.height) / 2.0).rounded() + titleAdjustmentY + contentEdgeInsets.top
            rect.size.width = contentRect.width - contentEdgeInsets.x
            return rect
        case .imageAtLeft(let spacing):
            rect.origin.x = rect.origin.x + (spacing / 2.0).rounded()
            return rect
        case .imageAtLeftmost(_, let titleAdjustmentX):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + titleAdjustmentX + contentEdgeInsets.left
            return rect
        case .imageAtRight(let spacing):
            let imageWidth = super.imageRect(forContentRect: contentRect).width
            rect.origin.x = ((contentRect.width - (rect.width + spacing + imageWidth)) / 2.0).rounded() + contentEdgeInsets.left
            return rect
        case .imageAtRightmost(_, let titleAdjustmentX):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + titleAdjustmentX + contentEdgeInsets.left
            return rect
        case .titleAtBottommost(let padding, _):
            rect.origin.x = ((contentRect.width - rect.width) / 2.0).rounded() + contentEdgeInsets.left
            rect.origin.y = contentRect.maxY - (rect.height + padding + contentEdgeInsets.bottom)
            rect.size.width = contentRect.width - contentEdgeInsets.x
            return rect
        }
    }

    open override func point(
        inside point: CGPoint,
        with event: UIEvent?
    ) -> Bool {
        let leastTouchMagnitude = CGSize.leastTouchMagnitude

        if bounds.size > leastTouchMagnitude {
            return bounds.contains(
                point
            )
        }

        let touchBounds =
            bounds.insetBy(
                dx: min(0, (bounds.width - leastTouchMagnitude.width) / 2),
                dy: min(0, (bounds.height - leastTouchMagnitude.height) / 2)
            )
        return touchBounds.contains(
            point
        )
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let shadow = shadow else {
            return
        }

        updateOnLayoutSubviews(
            shadow: shadow
        )
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                preferredUserInterfaceStyleDidChange()
            }
        }
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            preferredContentSizeCategoryDidChange()
        }
    }
}

extension Button {
    private func calculateIntrinsicContentSize() -> CGSize? {
        if bounds.isEmpty {
            return nil
        }

        if layout.isHorizontal {
            return nil
        }

        if let cachedIntrinsicContentSize = cachedIntrinsicContentSize {
            return cachedIntrinsicContentSize
        }

        let imageSize = currentImage?.size ?? .zero
        let titleSize: CGSize

        if let currentTitle = currentTitle {
            titleSize =
                currentTitle.boundingSize(
                    attributes: .font(titleLabel?.font),
                    multiline: false,
                    fittingSize: .greatestFiniteMagnitude
                )
        } else if let currentAttributedTitle = currentAttributedTitle {
            titleSize =
                currentAttributedTitle.boundingSize(
                    multiline: false,
                    fittingSize: .greatestFiniteMagnitude
                )
        } else {
            titleSize = .zero
        }

        let width = max(imageSize.width, titleSize.width) + contentEdgeInsets.x
        let height: CGFloat

        switch layout {
        case .imageAtTop(let spacing):
            height = imageSize.height + titleSize.height + spacing + contentEdgeInsets.y
        case .imageAtTopmost(let padding, let titleAdjustmentY):
            height =
                imageSize.height +
                titleSize.height +
                padding +
                contentEdgeInsets.y +
                titleAdjustmentY
        case .titleAtBottommost(let padding, let imageAdjustmentY):
            height =
                imageSize.height +
                titleSize.height +
                padding +
                contentEdgeInsets.y -
                imageAdjustmentY
        default:
            height = 0
        }

        cachedIntrinsicContentSize = CGSize((width, height))

        return cachedIntrinsicContentSize
    }
}

extension Button {
    public enum Layout {
        case none
        case imageAtTop(spacing: CGFloat) /// <note> Spacing equals to the distance between image and title.
        case imageAtTopmost(padding: CGFloat, titleAdjustmentY: CGFloat) /// <note> Padding equals to the inset from top for the image while the title is centered.
        case imageAtLeft(spacing: CGFloat) /// <note> Spacing equals to the distance between image and title.
        case imageAtLeftmost(padding: CGFloat, titleAdjustmentX: CGFloat) /// <note> Padding equals to the inset from left for the image while the title is centered offset by titleAdjustmentX.
        case imageAtRight(spacing: CGFloat) /// <note> Spacing equals to the distance between image and title.
        case imageAtRightmost(padding: CGFloat, titleAdjustmentX: CGFloat) /// <note> Padding equals to the inset from right for the image while the title is centered offset by titleAdjustmentX.
        case titleAtBottommost(padding: CGFloat, imageAdjustmentY: CGFloat)

        public var isHorizontal: Bool {
            switch self {
            case .none,
                 .imageAtLeft,
                 .imageAtLeftmost,
                 .imageAtRight,
                 .imageAtRightmost:
                return true
            default: return false
            }
        }

        public var isVertical: Bool {
            return !isHorizontal
        }
    }
}
