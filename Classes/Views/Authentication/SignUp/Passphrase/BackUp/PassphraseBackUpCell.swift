//
//  PassphraseBackUpCell.swift

import UIKit

class PassphraseBackUpCell: BaseCollectionViewCell<PassphraseBackUpOrderView> {

    func bind(_ viewModel: PassphraseBackUpOrderViewModel) {
        contextView.bind(viewModel)
    }
}
