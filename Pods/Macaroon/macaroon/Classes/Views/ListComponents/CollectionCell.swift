// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class CollectionCell<
    ContextView: ViewComposable & ListReusable
>: UICollectionViewCell,
   ListComposable,
   ListSeparatorAdaptable {
    open class var contextPaddings: LayoutPaddings {
        return (0, 0, 0, 0)
    }

    public private(set) lazy var contextView = getContextView()
    public private(set) var separatorView: UIView?

    open var separatorStyle: ListSeparatorStyle = .none {
        didSet {
            removeSeparator()
            addSeparator()
        }
    }

    public override init(
        frame: CGRect
    ) {
        super.init(
            frame: frame
        )

        prepareLayout()
        setListeners()
    }

    @available(*, unavailable)
    public required init?(
        coder: NSCoder
    ) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    open func prepareLayout() {
        addContext()
    }

    open func addContext() {
        contentView.addSubview(
            contextView
        )
        contextView.snp.makeConstraints {
            $0.setPaddings(
                Self.contextPaddings
            )
        }
    }

    open func setListeners() { }

    open func getContextView() -> ContextView {
        return ContextView()
    }

    open override func prepareForReuse() {
        contextView.prepareForReuse()
    }
}

extension CollectionCell {
    private func addSeparator() {
        switch separatorStyle {
        case .none:
            return
        case .single(let separator):
            if let separatorView = separatorView,
               separatorView.isDescendant(
                   of: contentView
               ) {
                return
            }

            separatorView =
                contentView.addSeparator(
                    separator
                )
        }
    }

    private func removeSeparator() {
        separatorView?.removeFromSuperview()
        separatorView = nil
    }
}
