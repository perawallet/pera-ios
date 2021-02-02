//
//  UIStackView+Additions.swift

import UIKit

extension UIStackView {
    func deleteAllArrangedSubviews() {
        arrangedSubviews.forEach { deleteArrangedSubview($0) }
    }

    func deleteArrangedSubview(_ view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
}
