//
//  UIView+Layout.swift

import UIKit

extension UIView {
    func prepareWholeScreenLayoutFor(_ subview: UIView) {
        addSubview(subview)
        subview.pinToSuperview()
    }

    func pinToSuperview() {
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
