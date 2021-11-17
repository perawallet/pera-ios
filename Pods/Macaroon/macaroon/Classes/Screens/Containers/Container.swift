// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

public protocol Container: UIViewController {}

extension Container {
    @discardableResult
    public func fitInContainer(
        _ screen: UIViewController,
        insetBy paddings: LayoutPaddings = (0, 0, 0, 0)
    ) -> UIViewController {
        return addFragment(
            screen
        ) { screenView in
            view.addSubview(
                screenView
            )
            screenView.snp.makeConstraints {
                $0.setPaddings(
                    paddings
                )
            }
        }
    }

    @discardableResult
    public func addFragment(
        _ screen: UIViewController,
        prepareLayout: (UIView) -> Void
    ) -> UIViewController {
        addChild(
            screen
        )
        prepareLayout(
            screen.view
        )
        screen.didMove(
            toParent: self
        )

        return screen
    }

    public func removeFragment(
        _ screen: UIViewController
    ) {
        screen.removeFromContainer()
    }
}

extension UIViewController {
    public func removeFromContainer() {
        willMove(
            toParent: nil
        )
        removeFromParent()
        view.removeFromSuperview()
    }
}

