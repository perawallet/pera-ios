//
//  SelectAssetHeaderSupplementaryView.swift

import UIKit

class SelectAssetHeaderSupplementaryView: BaseSupplementaryView<SelectAssetHeaderView> {

    func bind(_ viewModel: SelectAssetViewModel) {
        contextView.bind(viewModel)
    }
}
