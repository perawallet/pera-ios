//
//  AccountViewCell.swift

import UIKit

class AccountViewCell: BaseCollectionViewCell<AccountContextView> {

    func bind(_ viewModel: AccountListViewModel) {
        contextView.bind(viewModel)
    }
}
