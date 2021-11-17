// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class ScrollView: UIScrollView {
    public var autoScrollsToFirstResponder = true

    open override func scrollRectToVisible(
        _ rect: CGRect,
        animated: Bool
    ) {
        /// <workaround> If the variable is false, this scroll view will ignore this method so that
        /// it can't auto-scroll the editing text field/view. Because it seems it doesn't work
        /// properly before iOS 13, and also breaks the handling mechanism of KeyboardController of
        /// our own.
        if autoScrollsToFirstResponder {
            super.scrollRectToVisible(
                rect,
                animated: animated
            )
        }
    }
}
