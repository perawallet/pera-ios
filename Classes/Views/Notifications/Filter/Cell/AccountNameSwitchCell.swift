//
//  AccountNameSwitchCell.swift

import UIKit

class AccountNameSwitchCell: BaseCollectionViewCell<AccountNameSwitchView> {

    weak var delegate: AccountNameSwitchCellDelegate?

    override func linkInteractors() {
        super.linkInteractors()
        contextView.delegate = self
    }
}

extension AccountNameSwitchCell {
    func bind(_ viewModel: AccountNameSwitchViewModel) {
        contextView.bind(viewModel)
    }
}

extension AccountNameSwitchCell: AccountNameSwitchViewDelegate {
    func accountNameSwitchView(_ accountNameSwitchView: AccountNameSwitchView, didChangeToggleValue value: Bool) {
        delegate?.accountNameSwitchCell(self, didChangeToggleValue: value)
    }
}

protocol AccountNameSwitchCellDelegate: class {
    func accountNameSwitchCell(_ accountNameSwitchCell: AccountNameSwitchCell, didChangeToggleValue value: Bool)
}
