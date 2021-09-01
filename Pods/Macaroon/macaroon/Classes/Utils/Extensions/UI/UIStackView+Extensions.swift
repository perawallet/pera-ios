// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UIStackView {
    public func deleteAllArrangedSubviews() {
        arrangedSubviews.forEach {
            deleteArrangedSubview(
                $0
            )
        }
    }

    public func deleteArrangedSubview(
        _ view: UIView
    ) {
        removeArrangedSubview(
            view
        )
        view.removeFromSuperview()
    }

    public func deleteAllSubviews() {
        deleteAllArrangedSubviews()

        subviews.reversed().forEach {
            $0.removeFromSuperview()
        }
    }
}
