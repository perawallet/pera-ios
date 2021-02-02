//
//  OptionsCell.swift

import UIKit

class OptionsCell: BaseCollectionViewCell<OptionsContextView> {

    func bind(_ viewModel: OptionsViewModel) {
        contextView.bind(viewModel)
    }
}
