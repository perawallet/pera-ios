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
    func nodeSettingsViewModelDidTapEdit(_ viewModel: NodeSettingsViewModel,
                                         atIndexPath indexPath: IndexPath)
}

class NodeSettingsViewModel {
    weak var delegate: NodeSettingsViewModelDelegate?
    
    func configureToggle(_ cell: SettingsToggleCell,
                         with node: Node,
                         for indexPath: IndexPath) {
        cell.contextView.indexPath = indexPath
        cell.contextView.nameLabel.text = node.name
        cell.contextView.toggle.setOn(node.isActive, animated: false)
        cell.contextView.delegate = self
    }
    
    func configureDefaultNode(_ cell: ToggleCell, enabled: Bool, for indexPath: IndexPath) {
        cell.contextView.indexPath = indexPath
        cell.contextView.nameLabel.text = Environment.current.algorandNodeName
        cell.contextView.toggle.setOn(enabled, animated: false)
        cell.contextView.delegate = self
    }
}

// MARK: - SettingsToggleContextViewDelegate
extension NodeSettingsViewModel: SettingsToggleContextViewDelegate {
    func settingsToggleDidTapEdit(forIndexPath indexPath: IndexPath) {
        delegate?.nodeSettingsViewModelDidTapEdit(self, atIndexPath: indexPath)
    }
    
    func settingsToggle(_ toggle: Toggle, didChangeValue value: Bool, forIndexPath indexPath: IndexPath) {
        delegate?.nodeSettingsViewModel(self, didToggleValue: value, atIndexPath: indexPath)
    }
}
