//
//  UIStackView+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

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
