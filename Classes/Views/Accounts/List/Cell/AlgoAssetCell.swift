//
//  AlgoAssetCell.swift

import UIKit

class AlgoAssetCell: BaseCollectionViewCell<AlgoAssetView> {

    func bind(_ viewModel: AlgoAssetViewModel) {
        contextView.bind(viewModel)
    }
}
