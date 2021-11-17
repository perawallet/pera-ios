// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol BottomSheetPresentable: ModalCustomPresentable {
    /// <note>
    /// If the presented screen has a scroll view, return it via this property, so that the
    /// interactive dismissal can be handled properly without messing with the scrolling behaviour.
    var presentedScrollView: UIScrollView? { get }
}

extension BottomSheetPresentable {
    public var presentedScrollView: UIScrollView? {
        return nil
    }
}
