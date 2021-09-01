// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol BottomScrollOverlayFragment: UIViewController {
    var isScrollEnabled: Bool { get set }
    var scrollView: UIScrollView { get }
}

extension BottomScrollOverlayFragment {
    public func updateLayoutWhenScrollViewDidScroll() {
        if isScrollEnabled {
            return
        }

        scrollView.scrollToTop(
            animated: false
        )
    }

    public func updateLayoutWhenScrollViewWillEndDragging(
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if isScrollEnabled {
            return
        }

        targetContentOffset.pointee = scrollView.contentOffsetAtTop
    }
}
