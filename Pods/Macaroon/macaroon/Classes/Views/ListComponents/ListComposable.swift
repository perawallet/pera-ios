// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ListComposable: UIView {
    associatedtype ContextView: ViewComposable

    static var contextPaddings: LayoutPaddings { get }

    var contextView: ContextView { get }

    func getContextView() -> ContextView
    func customizeAppearance(_ styleSheet: ContextView.StyleSheet)
    func prepareLayout(_ layoutSheet: ContextView.LayoutSheet)
}

extension ListComposable {
    public func customizeAppearance(
        _ styleSheet: ContextView.StyleSheet
    ) {
        contextView.customizeAppearance(
            styleSheet
        )
    }

    public func prepareLayout(
        _ layoutSheet: ContextView.LayoutSheet
    ) {
        contextView.prepareLayout(
            layoutSheet
        )
    }
}

extension ListComposable where Self: ViewModelBindable, Self.ContextView: ViewModelBindable {
    public func bindData(
        _ viewModel: ContextView.ViewModel?
    ) {
        contextView.bindData(
            viewModel
        )
    }

    public static func calculatePreferredSize(
        _ viewModel: ContextView.ViewModel?,
        for layoutSheet: ContextView.ViewLayoutSheet,
        fittingIn size: CGSize
    ) -> CGSize {
        let preferredSize =
            ContextView.calculatePreferredSize(
                viewModel,
                for: layoutSheet,
                fittingIn: size
            )
        return CGSize(
            width: (preferredSize.width + contextPaddings.leading + contextPaddings.trailing).ceil(),
            height: (preferredSize.height + contextPaddings.top + contextPaddings.bottom).ceil()
        )
    }
}
