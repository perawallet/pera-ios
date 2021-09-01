// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ViewModelBindable: UIView {
    associatedtype ViewModel
    associatedtype ViewLayoutSheet

    func bindData(_ viewModel: ViewModel?)
    static func calculatePreferredSize(_ viewModel: ViewModel?, for layoutSheet: ViewLayoutSheet, fittingIn size: CGSize) -> CGSize
}

extension ViewModelBindable where Self: ViewComposable, Self.LayoutSheet == Self.ViewLayoutSheet {
    public static func calculatePreferredSize(
        _ viewModel: ViewModel?,
        for layoutSheet: ViewLayoutSheet,
        fittingIn size: CGSize
    ) -> CGSize {
        return .zero
    }
}
