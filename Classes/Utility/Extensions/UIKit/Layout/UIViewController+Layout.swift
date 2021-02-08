//
//  UIViewController+Layout.swift

import UIKit

extension UIViewController {
    func prepareWholeScreenLayoutFor(_ subview: UIView) {
        view.addSubview(subview)
        subview.pinToSuperview()
    }
}
