//
//  NodeSettingsViewModel.swift
//  algorand
//
//  Created by Omer Emre Aslan on 12.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NodeSettingsViewModel {
    func configure(_ cell: NodeSelectionCell, with node: AlgorandNode, activeNetwork: API.BaseNetwork) {
        cell.contextView.setName(node.name)
        
        if node.network == activeNetwork {
            setActive(cell)
        } else {
            setInactive(cell)
        }
    }
    
    func setSelected(at indexPath: IndexPath, in collectionView: UICollectionView) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? NodeSelectionCell else {
            return
        }
        setActive(cell)
        
        let otherCellIndex = indexPath.item == 0 ? 1 : 0
        
        guard let otherCell = collectionView.cellForItem(at: IndexPath(item: otherCellIndex, section: 0)) as? NodeSelectionCell else {
            return
        }
        
        setInactive(otherCell)
    }
    
    private func setActive(_ cell: NodeSelectionCell) {
        cell.contextView.setBackgroundImage(img("bg-settings-node-selected"))
        cell.contextView.setImage(img("settings-node-active"))
    }
    
    private func setInactive(_ cell: NodeSelectionCell) {
        cell.contextView.setBackgroundImage(img("bg-settings-node-unselected"))
        cell.contextView.setImage(img("settings-node-inactive"))
    }
}
