//
//  AccountFooterSupplementaryView.swift

import UIKit

class AccountFooterSupplementaryView: BaseSupplementaryView<AccountFooterView> {
    
    weak var delegate: AccountFooterSupplementaryViewDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }
}

extension AccountFooterSupplementaryView: AccountFooterViewDelegate {
    func accountFooterViewDidTapAddAssetButton(_ accountFooterView: AccountFooterView) {
        delegate?.accountFooterSupplementaryViewDidTapAddAssetButton(self)
    }
}

protocol AccountFooterSupplementaryViewDelegate: class {
    func accountFooterSupplementaryViewDidTapAddAssetButton(_ accountFooterSupplementaryView: AccountFooterSupplementaryView)
}

class EmptyFooterSupplementaryView: BaseSupplementaryView<EmptyFooterView> {

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

class EmptyFooterView: BaseView {

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}
