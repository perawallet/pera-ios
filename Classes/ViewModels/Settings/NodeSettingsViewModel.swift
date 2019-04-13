//
//  NodeSettingsViewModel.swift
//  algorand
//
//  Created by Omer Emre Aslan on 12.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol NodeSettingsViewModelDelegate: class {
    func nodeSettingsViewModel(_ viewModel: NodeSettingsViewModel,
                               didToggleValue value: Bool,
                               atIndexPath indexPath: IndexPath)
}

class NodeSettingsViewModel {
    var indexPath: IndexPath?
    
    weak var delegate: NodeSettingsViewModelDelegate?
    
    func configureToggle(_ cell: SettingsToggleCell,
                         enabled: Bool,
                         with node: Node,
                         for indexPath: IndexPath) {
        self.indexPath = indexPath
        
        cell.contextView.nameLabel.text = node.name
        cell.contextView.toggle.setOn(enabled, animated: false)
        cell.contextView.delegate = self
    }
}

// MARK: - SettingsToggleContextViewDelegate
extension NodeSettingsViewModel: SettingsToggleContextViewDelegate {
    func settingsToggle(_ toggle: Toggle, didChangeValue value: Bool) {
        guard let indexPath = self.indexPath else {
            return
        }
        
        delegate?.nodeSettingsViewModel(self, didToggleValue: value, atIndexPath: indexPath)
    }
}
