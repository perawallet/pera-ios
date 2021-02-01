//
//  NodeSelectionCell.swift

import UIKit

class NodeSelectionCell: BaseCollectionViewCell<NodeSelectionView> {
    func bind(_ viewModel: NodeSettingsViewModel) {
        contextView.bind(viewModel)
    }
}
