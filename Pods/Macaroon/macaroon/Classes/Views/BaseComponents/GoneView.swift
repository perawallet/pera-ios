// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class GoneView<ContextView: UIView>: UIView {
    public var isGone = false {
        didSet { invalidateIntrinsicContentSize() }
    }
    public var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet { updateLayoutWhenContentEdgeInsetsDidChange() }
    }

    public let contextView: ContextView

    open override var intrinsicContentSize: CGSize {
        return isGone ? .zero : super.intrinsicContentSize
    }

    public init(_ contextView: ContextView) {
        self.contextView = contextView
        super.init(frame: .zero)
        addSubview(contextView)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func updateLayoutWhenContentEdgeInsetsDidChange() {
        contextView.snp.remakeConstraints { maker in
            maker.top.lessThanOrEqualToSuperview().inset(contentEdgeInsets.top)
            maker.leading.lessThanOrEqualToSuperview().inset(contentEdgeInsets.left)
            maker.bottom.greaterThanOrEqualToSuperview().inset(contentEdgeInsets.bottom)
            maker.trailing.greaterThanOrEqualToSuperview().inset(contentEdgeInsets.right)
        }
    }
}
