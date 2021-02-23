//
//  PassphraseMnemonicCell.swift

import UIKit

class PassphraseMnemonicCell: BaseCollectionViewCell<PassphraseMnemonicView> {

    override var isSelected: Bool {
        didSet {
            contextView.isSelected = isSelected
        }
    }

    func bind(_ viewModel: PassphraseMnemonicViewModel) {
        contextView.bind(viewModel)
    }
}
