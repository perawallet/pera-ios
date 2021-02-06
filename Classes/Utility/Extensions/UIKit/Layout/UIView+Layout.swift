//
//  UIView+Layout.swift

import UIKit

extension UIView {
    func pinToSuperview() {
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
