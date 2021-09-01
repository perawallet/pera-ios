// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class CollectionSupplementaryView<
    ContextView: ViewComposable & ListReusable
>: UICollectionReusableView,
   ListComposable {
    open class var contextPaddings: LayoutPaddings {
        return (0, 0, 0, 0)
    }

    public lazy var contextView = getContextView()

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
        addContextView()
    }

    open func addContextView() {
        addSubview(
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
